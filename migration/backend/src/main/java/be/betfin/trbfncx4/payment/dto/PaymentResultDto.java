package be.betfin.MYFIN.payment.dto;

import java.util.UUID;

public record PaymentResultDto(
    UUID requestId,
    String status,        // "ACCEPTED" or "REJECTED"
    String diagnosticNl,  // null when ACCEPTED
    String diagnosticFr   // null when ACCEPTED
) {
    public static PaymentResultDto accepted(UUID requestId) {
        return new PaymentResultDto(requestId, "ACCEPTED", null, null);
    }

    public static PaymentResultDto rejected(UUID requestId, String nl, String fr) {
        return new PaymentResultDto(requestId, "REJECTED", nl, fr);
    }
}
