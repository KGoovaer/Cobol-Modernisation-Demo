package be.betfin.MYFIN.payment.dto;

import be.betfin.MYFIN.payment.RejectionRecord;

import java.time.Instant;
import java.util.UUID;

public record RejectionRecordDto(
    UUID id,
    UUID paymentRequestId,
    long memberRnr,
    int destinationMutuality,
    String constantId,
    long amountCents,
    String diagnosticNl,
    String diagnosticFr,
    Instant createdAt
) {
    public static RejectionRecordDto from(RejectionRecord r) {
        return new RejectionRecordDto(
            r.getId(),
            r.getPaymentRequest().getId(),
            r.getPaymentRequest().getMemberRnr(),
            r.getPaymentRequest().getDestinationMutuality(),
            r.getPaymentRequest().getConstantId(),
            r.getPaymentRequest().getAmountCents(),
            r.getDiagnosticNl(),
            r.getDiagnosticFr(),
            r.getCreatedAt()
        );
    }
}
