package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.adapter.port.MemberAccountPort;
import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Step 7 – Non-blocking IBAN discrepancy check (FR-010).
 * If the provided IBAN differs from the member's known account, set ibanDiscrepancy=true.
 * This step never rejects — the discrepancy record is created later by PaymentService.
 */
@Component
@Order(7)
public class AccountDiscrepancyStep implements ValidationStep {

    private final MemberAccountPort memberAccountPort;

    public AccountDiscrepancyStep(MemberAccountPort memberAccountPort) {
        this.memberAccountPort = memberAccountPort;
    }

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        Optional<String> knownIban = memberAccountPort.getKnownIban(
            ctx.getRequest().memberRnr(),
            ctx.getRequest().paymentDescCode()
        );
        ctx.setKnownIban(knownIban.orElse(null));
        if (knownIban.isPresent() && !knownIban.get().equalsIgnoreCase(ctx.getRequest().iban())) {
            ctx.setIbanDiscrepancy(true);
        }
        return Optional.empty(); // Non-blocking
    }
}
