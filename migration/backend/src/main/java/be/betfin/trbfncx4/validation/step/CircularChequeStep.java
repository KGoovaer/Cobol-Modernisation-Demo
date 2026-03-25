package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.Set;

/**
 * Step 6 – Validate circular cheque restrictions (FR-014).
 * Payment methods C/D/E/F require a Belgian address.
 * Rejected with: "BETWYZ FOUTIEF" / "METHODE ERRONEE"
 */
@Component
@Order(6)
public class CircularChequeStep implements ValidationStep {

    private static final Set<Character> CIRCULAR_METHODS = Set.of('C', 'D', 'E', 'F');

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        char method = ctx.getRequest().paymentMethod().charAt(0);
        if (CIRCULAR_METHODS.contains(method)) {
            boolean belgianAddress = ctx.getMember() != null && ctx.getMember().belgianAddress();
            if (!belgianAddress) {
                return Optional.of(ValidationResult.rejected("BETWYZ FOUTIEF", "METHODE ERRONEE"));
            }
        }
        return Optional.empty();
    }
}
