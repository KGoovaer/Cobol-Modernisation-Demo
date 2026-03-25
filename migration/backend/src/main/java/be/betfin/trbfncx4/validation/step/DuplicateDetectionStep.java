package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.adapter.port.PaymentHistoryPort;
import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Step 4 – Detect duplicate payments (FR-002).
 * A duplicate is defined as: same memberRnr + same constantId + same amountCents.
 * Rejected with: "DUBBELE BETALING" / "DOUBLE PAIEMENT"
 */
@Component
@Order(4)
public class DuplicateDetectionStep implements ValidationStep {

    private final PaymentHistoryPort paymentHistoryPort;

    public DuplicateDetectionStep(PaymentHistoryPort paymentHistoryPort) {
        this.paymentHistoryPort = paymentHistoryPort;
    }

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        boolean duplicate = paymentHistoryPort.isDuplicate(
            ctx.getRequest().memberRnr(),
            ctx.getRequest().constantId(),
            ctx.getRequest().amountCents()
        );
        if (duplicate) {
            return Optional.of(ValidationResult.rejected("DUBBELE BETALING", "DOUBLE PAIEMENT"));
        }
        return Optional.empty();
    }
}
