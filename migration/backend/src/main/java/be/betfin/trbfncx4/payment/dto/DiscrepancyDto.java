package be.betfin.MYFIN.payment.dto;

import be.betfin.MYFIN.payment.BankAccountDiscrepancy;

import java.time.Instant;
import java.util.UUID;

public record DiscrepancyDto(
    UUID id,
    UUID paymentRequestId,
    long memberRnr,
    int destinationMutuality,
    String constantId,
    String providedIban,
    String knownIban,
    Instant createdAt
) {
    public static DiscrepancyDto from(BankAccountDiscrepancy d) {
        return new DiscrepancyDto(
            d.getId(),
            d.getPaymentRequest().getId(),
            d.getPaymentRequest().getMemberRnr(),
            d.getPaymentRequest().getDestinationMutuality(),
            d.getPaymentRequest().getConstantId(),
            d.getProvidedIban(),
            d.getKnownIban(),
            d.getCreatedAt()
        );
    }
}
