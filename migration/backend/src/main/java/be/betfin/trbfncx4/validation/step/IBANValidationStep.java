package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.adapter.model.IBANValidationResult;
import be.betfin.MYFIN.adapter.port.IBANValidationPort;
import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Step 5 – Validate the IBAN via IBANValidationPort (FR-003).
 *
 * IBANServiceUnavailableException propagates up → 503 response (fail-closed, FR-019).
 * Invalid IBAN → "IBAN FOUTIEF" / "IBAN ERRONE"
 * Sets ibanResult on context for use by later steps.
 */
@Component
@Order(5)
public class IBANValidationStep implements ValidationStep {

    private final IBANValidationPort ibanValidationPort;

    public IBANValidationStep(IBANValidationPort ibanValidationPort) {
        this.ibanValidationPort = ibanValidationPort;
    }

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        char method = ctx.getRequest().paymentMethod().charAt(0);
        // IBANServiceUnavailableException is intentionally not caught here — propagates to GlobalExceptionHandler → 503
        IBANValidationResult result = ibanValidationPort.validate(ctx.getRequest().iban(), method);
        if (!result.valid()) {
            return Optional.of(ValidationResult.rejected("IBAN FOUTIEF", "IBAN ERRONE"));
        }
        ctx.setIbanResult(result);
        return Optional.empty();
    }
}
