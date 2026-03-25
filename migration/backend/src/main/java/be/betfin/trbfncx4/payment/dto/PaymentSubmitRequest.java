package be.betfin.MYFIN.payment.dto;

import jakarta.validation.constraints.*;
import java.util.Set;

public record PaymentSubmitRequest(

    @NotNull(message = "memberRnr is required")
    Long memberRnr,

    @NotNull @Min(101) @Max(169)
    Integer destinationMutuality,

    @NotBlank @Size(max = 10)
    String constantId,

    @Size(max = 4)
    String sequenceNo,

    @NotNull @Min(1)
    Long amountCents,

    @NotNull @Pattern(regexp = "[EB]", message = "currency must be E or B")
    String currency,

    @NotNull @Min(1) @Max(99)
    Integer paymentDescCode,

    @NotBlank @Size(max = 34)
    String iban,

    /** ' ' = SEPA, 'C'/'D'/'E'/'F' = circular cheque variants */
    @Pattern(regexp = "[ CDEF]", message = "paymentMethod must be ' ', C, D, E, or F")
    String paymentMethod,

    @NotNull
    Integer accountingType
) {
    public PaymentSubmitRequest {
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = " ";
        }
    }

    @AssertTrue(message = "accountingType must be 1, 3, 4, 5, or 6")
    public boolean isAccountingTypeValid() {
        return accountingType != null && Set.of(1, 3, 4, 5, 6).contains(accountingType);
    }
}
