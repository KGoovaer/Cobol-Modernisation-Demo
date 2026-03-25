package be.betfin.MYFIN.payment;

import be.betfin.MYFIN.adapter.port.PaymentHistoryPort;
import be.betfin.MYFIN.auth.User;
import be.betfin.MYFIN.payment.dto.*;
import be.betfin.MYFIN.validation.PaymentValidationService;
import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PaymentService {

    private final PaymentValidationService validationService;
    private final PaymentHistoryPort paymentHistoryPort;
    private final PaymentRequestRepository requestRepository;
    private final PaymentRecordRepository recordRepository;
    private final RejectionRecordRepository rejectionRepository;
    private final BankAccountDiscrepancyRepository discrepancyRepository;

    public PaymentService(PaymentValidationService validationService,
                          PaymentHistoryPort paymentHistoryPort,
                          PaymentRequestRepository requestRepository,
                          PaymentRecordRepository recordRepository,
                          RejectionRecordRepository rejectionRepository,
                          BankAccountDiscrepancyRepository discrepancyRepository) {
        this.validationService = validationService;
        this.paymentHistoryPort = paymentHistoryPort;
        this.requestRepository = requestRepository;
        this.recordRepository = recordRepository;
        this.rejectionRepository = rejectionRepository;
        this.discrepancyRepository = discrepancyRepository;
    }

    @Transactional
    public PaymentResultDto submit(be.betfin.MYFIN.payment.dto.PaymentSubmitRequest dto, User submittedBy) {
        ValidationContext ctx;
        ValidationResult result;

        try {
            ctx = validationService.validateAndReturnContext(dto);
            result = ValidationResult.accepted();
        } catch (PaymentValidationService.ValidationFailedException ex) {
            result = ex.getResult();
            ctx = null;
        }

        // Persist PaymentRequest
        PaymentRequest req = new PaymentRequest();
        req.setMemberRnr(dto.memberRnr());
        req.setDestinationMutuality(dto.destinationMutuality());
        req.setConstantId(dto.constantId());
        req.setSequenceNo(dto.sequenceNo());
        req.setAmountCents(dto.amountCents());
        req.setCurrency(dto.currency().charAt(0));
        req.setPaymentDescCode(dto.paymentDescCode());
        req.setIban(dto.iban());
        req.setPaymentMethod(dto.paymentMethod().charAt(0));
        req.setAccountingType(dto.accountingType());
        req.setSubmittedBy(submittedBy);
        req.setStatus(result.isAccepted() ? PaymentStatus.ACCEPTED : PaymentStatus.REJECTED);
        requestRepository.save(req);

        if (!result.isAccepted()) {
            RejectionRecord rejection = new RejectionRecord();
            rejection.setPaymentRequest(req);
            rejection.setDiagnosticNl(result.getDiagnosticNl());
            rejection.setDiagnosticFr(result.getDiagnosticFr());
            rejectionRepository.save(rejection);
            return PaymentResultDto.rejected(req.getId(), result.getDiagnosticNl(), result.getDiagnosticFr());
        }

        // Accepted path
        PaymentRecord record = new PaymentRecord();
        record.setPaymentRequest(req);
        record.setMemberRnr(dto.memberRnr());
        record.setMemberName(ctx.getMember().name());
        record.setAmountCents(dto.amountCents());
        record.setIban(dto.iban());
        record.setBic(ctx.getIbanResult() != null ? ctx.getIbanResult().bic() : null);
        record.setBankRouting(ctx.getBankRouting());
        record.setRegionalTag(ctx.getRegionalTag());
        record.setAccountingType(dto.accountingType());
        record.setDestinationMutuality(dto.destinationMutuality());
        record.setPaymentDescNl(ctx.getPaymentDescNl());
        record.setPaymentDescFr(ctx.getPaymentDescFr());
        recordRepository.save(record);

        if (ctx.isIbanDiscrepancy() && ctx.getKnownIban() != null) {
            BankAccountDiscrepancy disc = new BankAccountDiscrepancy();
            disc.setPaymentRequest(req);
            disc.setProvidedIban(dto.iban());
            disc.setKnownIban(ctx.getKnownIban());
            discrepancyRepository.save(disc);
        }

        paymentHistoryPort.recordPayment(dto.memberRnr(), dto.constantId(), dto.amountCents());

        return PaymentResultDto.accepted(req.getId());
    }

    @Transactional(readOnly = true)
    public Page<PaymentRecordDto> listPayments(Integer accountingType, Instant dateFrom, Instant dateTo,
                                               Integer mutualityCode, Set<Integer> allowedMutualities, Pageable pageable) {
        Set<Integer> effectiveMutualities = scopedMutualities(mutualityCode, allowedMutualities);
        return recordRepository.findFiltered(accountingType, dateFrom, dateTo, effectiveMutualities, pageable)
            .map(PaymentRecordDto::from);
    }

    @Transactional(readOnly = true)
    public PaymentRecordDto getPayment(UUID id, Set<Integer> allowedMutualities) {
        PaymentRecord r = recordRepository.findById(id)
            .orElseThrow(() -> new NoSuchElementException("Payment record not found: " + id));
        checkMutualityScope(r.getDestinationMutuality(), allowedMutualities);
        return PaymentRecordDto.from(r);
    }

    @Transactional(readOnly = true)
    public List<PaymentRecordDto> exportCsv(Set<Integer> allowedMutualities) {
        return recordRepository.findStandardForExport(allowedMutualities)
            .stream().map(PaymentRecordDto::from).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Optional<PaymentRecordDto> searchByConstantId(String constantId, Set<Integer> allowedMutualities) {
        return recordRepository.findByPaymentRequestConstantId(constantId)
            .filter(r -> allowedMutualities == null || allowedMutualities.isEmpty()
                || allowedMutualities.contains(r.getDestinationMutuality()))
            .map(PaymentRecordDto::from);
    }

    @Transactional(readOnly = true)
    public Optional<PaymentRecordDto> searchBySequenceNo(String sequenceNo, Set<Integer> allowedMutualities) {
        return recordRepository.findByPaymentRequestSequenceNo(sequenceNo)
            .filter(r -> allowedMutualities == null || allowedMutualities.isEmpty()
                || allowedMutualities.contains(r.getDestinationMutuality()))
            .map(PaymentRecordDto::from);
    }

    @Transactional(readOnly = true)
    public Page<RejectionRecordDto> listRejections(Integer accountingType, Instant dateFrom, Instant dateTo,
                                                    Integer mutualityCode, Set<Integer> allowedMutualities, Pageable pageable) {
        Set<Integer> effective = scopedMutualities(mutualityCode, allowedMutualities);
        return rejectionRepository.findFiltered(accountingType, dateFrom, dateTo, effective, pageable)
            .map(RejectionRecordDto::from);
    }

    @Transactional(readOnly = true)
    public RejectionRecordDto getRejection(UUID id, Set<Integer> allowedMutualities) {
        RejectionRecord r = rejectionRepository.findById(id)
            .orElseThrow(() -> new NoSuchElementException("Rejection record not found: " + id));
        checkMutualityScope(r.getPaymentRequest().getDestinationMutuality(), allowedMutualities);
        return RejectionRecordDto.from(r);
    }

    @Transactional(readOnly = true)
    public Page<DiscrepancyDto> listDiscrepancies(Set<Integer> allowedMutualities, Pageable pageable) {
        return discrepancyRepository.findForUser(allowedMutualities, pageable)
            .map(DiscrepancyDto::from);
    }

    // ─── helpers ─────────────────────────────────────────────────────────────

    private Set<Integer> scopedMutualities(Integer requestedCode, Set<Integer> allowed) {
        if (allowed == null || allowed.isEmpty()) return null; // Admin: unrestricted
        if (requestedCode != null) {
            if (!allowed.contains(requestedCode)) {
                throw new be.betfin.MYFIN.exception.MutualityScopeViolationException(
                    "Mutuality code " + requestedCode + " is outside your assigned scope");
            }
            return Set.of(requestedCode);
        }
        return allowed;
    }

    private void checkMutualityScope(int destinationMutuality, Set<Integer> allowed) {
        if (allowed != null && !allowed.isEmpty() && !allowed.contains(destinationMutuality)) {
            throw new be.betfin.MYFIN.exception.MutualityScopeViolationException(
                "Record belongs to mutuality " + destinationMutuality + " which is outside your assigned scope");
        }
    }
}
