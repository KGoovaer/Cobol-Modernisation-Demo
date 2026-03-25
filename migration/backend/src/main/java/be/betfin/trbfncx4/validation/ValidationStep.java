package be.betfin.MYFIN.validation;

import java.util.Optional;

/**
 * Single step in the sequential, fail-fast validation pipeline.
 */
public interface ValidationStep {

    /**
     * Execute this step.
     *
     * @param ctx mutable context accumulated by previous steps
     * @return empty Optional to continue, or a ValidationResult to reject and halt
     */
    Optional<ValidationResult> execute(ValidationContext ctx);
}
