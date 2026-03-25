package be.betfin.MYFIN.payment.dto;

import be.betfin.MYFIN.payment.PaymentRecord;

import java.time.Instant;
import java.util.UUID;

public record PaymentRecordDto(
    UUID id,
    UUID paymentRequestId,
    long memberRnr,
    String memberName,
    long amountCents,
    String iban,
    String bic,
    String bankRouting,
    int regionalTag,
    int accountingType,
    int destinationMutuality,
    String paymentDescNl,
    String paymentDescFr,
    Instant createdAt
) {
    public static PaymentRecordDto from(PaymentRecord r) {
        return new PaymentRecordDto(
            r.getId(),
            r.getPaymentRequest().getId(),
            r.getMemberRnr(),
            r.getMemberName(),
            r.getAmountCents(),
            r.getIban(),
            r.getBic(),
            r.getBankRouting(),
            r.getRegionalTag(),
            r.getAccountingType(),
            r.getDestinationMutuality(),
            r.getPaymentDescNl(),
            r.getPaymentDescFr(),
            r.getCreatedAt()
        );
    }
}
