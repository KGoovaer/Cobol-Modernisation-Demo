package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.adapter.model.MemberInfo;
import be.betfin.MYFIN.adapter.port.MemberPort;
import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Step 1 – Verify member exists and has at least one eligible insurance section (FR-001).
 * Rejected with: "LIDNR ONBEKEND" / "AFFILIE INCONNU"
 */
@Component
@Order(1)
public class MemberValidationStep implements ValidationStep {

    private final MemberPort memberPort;

    public MemberValidationStep(MemberPort memberPort) {
        this.memberPort = memberPort;
    }

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        Optional<MemberInfo> memberOpt = memberPort.findByRnr(ctx.getRequest().memberRnr());
        if (memberOpt.isEmpty()) {
            return Optional.of(ValidationResult.rejected("LIDNR ONBEKEND", "AFFILIE INCONNU"));
        }
        MemberInfo member = memberOpt.get();
        boolean hasEligibleSection = member.sections().stream().anyMatch(s -> s.isEligible());
        if (!hasEligibleSection) {
            return Optional.of(ValidationResult.rejected("LIDNR ONBEKEND", "AFFILIE INCONNU"));
        }
        ctx.setMember(member);
        return Optional.empty();
    }
}
