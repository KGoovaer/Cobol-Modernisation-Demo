package be.betfin.MYFIN.validation;

import be.betfin.MYFIN.payment.dto.PaymentSubmitRequest;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PaymentValidationService {

    private final List<ValidationStep> steps;

    public PaymentValidationService(List<ValidationStep> steps) {
        this.steps = steps;
    }

    /**
     * Run all validation steps sequentially.
     * Returns the first rejection encountered, or ValidationResult.accepted() if all pass.
     * IBANServiceUnavailableException propagates uncaught (fail-closed, FR-019).
     */
    public ValidationResult validate(PaymentSubmitRequest request) {
        ValidationContext ctx = new ValidationContext(request);
        for (ValidationStep step : steps) {
            Optional<ValidationResult> rejection = step.execute(ctx);
            if (rejection.isPresent()) {
                return rejection.get();
            }
        }
        return ValidationResult.accepted();
    }

    /**
     * Expose the populated context after a successful validation pass.
     * Used by PaymentService to persist the record without repeating lookups.
     */
    public ValidationContext validateAndReturnContext(PaymentSubmitRequest request) {
        ValidationContext ctx = new ValidationContext(request);
        for (ValidationStep step : steps) {
            Optional<ValidationResult> rejection = step.execute(ctx);
            if (rejection.isPresent()) {
                ctx.setMember(ctx.getMember()); // keep member if populated
                throw new ValidationFailedException(rejection.get());
            }
        }
        return ctx;
    }

    public static class ValidationFailedException extends RuntimeException {
        private final ValidationResult result;
        public ValidationFailedException(ValidationResult result) {
            super("Validation failed");
            this.result = result;
        }
        public ValidationResult getResult() { return result; }
    }
}
