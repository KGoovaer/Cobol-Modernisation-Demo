package be.betfin.MYFIN.payment;

import be.betfin.MYFIN.auth.Role;
import be.betfin.MYFIN.auth.User;
import be.betfin.MYFIN.exception.MutualityScopeViolationException;
import be.betfin.MYFIN.payment.dto.*;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    /** POST /api/payments — SUBMITTER only; mutuality scoping enforced */
    @PostMapping
    public ResponseEntity<PaymentResultDto> submit(
            @Valid @RequestBody PaymentSubmitRequest dto,
            @AuthenticationPrincipal User user) {

        // FR-020: destination must be within user's assigned mutuality codes
        if (!user.getMutualityCodes().isEmpty()
                && !user.getMutualityCodes().contains(dto.destinationMutuality())) {
            throw new MutualityScopeViolationException(
                "Mutuality " + dto.destinationMutuality() + " is outside your assigned scope");
        }

        PaymentResultDto result = paymentService.submit(dto, user);
        return ResponseEntity.ok(result);
    }

    /** GET /api/payments */
    @GetMapping
    public ResponseEntity<Page<PaymentRecordDto>> list(
            @RequestParam(required = false) Integer accountingType,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant dateTo,
            @RequestParam(required = false) Integer mutualityCode,
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 25) Pageable pageable) {

        Set<Integer> allowed = allowedMutualities(user);
        Page<PaymentRecordDto> page = paymentService.listPayments(
            accountingType, dateFrom, dateTo, mutualityCode, allowed, pageable);
        return ResponseEntity.ok(page);
    }

    /** GET /api/payments/{id} */
    @GetMapping("/{id}")
    public ResponseEntity<PaymentRecordDto> getById(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(paymentService.getPayment(id, allowedMutualities(user)));
    }

    /** GET /api/payments/search?constantId=&sequenceNo= */
    @GetMapping("/search")
    public ResponseEntity<?> search(
            @RequestParam(required = false) String constantId,
            @RequestParam(required = false) String sequenceNo,
            @AuthenticationPrincipal User user) {

        Set<Integer> allowed = allowedMutualities(user);
        if (constantId != null) {
            return ResponseEntity.ok(paymentService.searchByConstantId(constantId, allowed));
        }
        if (sequenceNo != null) {
            return ResponseEntity.ok(paymentService.searchBySequenceNo(sequenceNo, allowed));
        }
        return ResponseEntity.badRequest().body("Provide constantId or sequenceNo");
    }

    /** GET /api/payments/export/csv */
    @GetMapping("/export/csv")
    public void exportCsv(@AuthenticationPrincipal User user, HttpServletResponse response) throws IOException {
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"payments.csv\"");

        List<PaymentRecordDto> records = paymentService.exportCsv(allowedMutualities(user));
        try (PrintWriter w = response.getWriter()) {
            w.println("id,memberRnr,memberName,amountCents,iban,bic,bankRouting,regionalTag,accountingType,destinationMutuality,paymentDescNl,paymentDescFr,createdAt");
            for (PaymentRecordDto r : records) {
                w.printf("%s,%d,%s,%d,%s,%s,%s,%d,%d,%d,%s,%s,%s%n",
                    r.id(), r.memberRnr(), csvEscape(r.memberName()), r.amountCents(),
                    r.iban(), r.bic(), r.bankRouting(), r.regionalTag(),
                    r.accountingType(), r.destinationMutuality(),
                    csvEscape(r.paymentDescNl()), csvEscape(r.paymentDescFr()),
                    r.createdAt());
            }
        }
    }

    private Set<Integer> allowedMutualities(User user) {
        // ADMIN has unrestricted access; others are scoped
        return user.getRole() == Role.ADMIN ? null : user.getMutualityCodes();
    }

    private String csvEscape(String s) {
        if (s == null) return "";
        return "\"" + s.replace("\"", "\"\"") + "\"";
    }
}
