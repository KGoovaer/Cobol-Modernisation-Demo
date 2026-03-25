package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.adapter.model.InsuranceSectionInfo;
import be.betfin.MYFIN.adapter.model.MemberInfo;
import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.Set;

/**
 * Step 2 – Determine member language (FR-005).
 *
 * Resolution priority:
 * 1. Administrative language (member.languageCode), if 1/2/3
 * 2. First eligible insurance section's languageCode
 * 3. For bilingual mutualities (106,107,150,166): require explicit preference → reject if 0
 *
 * Valid language codes: 1=French, 2=Dutch, 3=German.
 * Rejected with: "TAALCODE ONBEK" / "CODE LING INCON"
 */
@Component
@Order(2)
public class LanguageResolutionStep implements ValidationStep {

    private static final Set<Integer> BILINGUAL_MUTUALITIES = Set.of(106, 107, 150, 166);
    private static final Set<Integer> VALID_CODES = Set.of(1, 2, 3);

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        MemberInfo member = ctx.getMember();
        int lang = member.languageCode();

        if (VALID_CODES.contains(lang)) {
            ctx.setResolvedLanguageCode(lang);
            return Optional.empty();
        }

        // Bilingual mutuality — must have stated preference; no fallback
        if (BILINGUAL_MUTUALITIES.contains(member.mutualityCode())) {
            return Optional.of(ValidationResult.rejected("TAALCODE ONBEK", "CODE LING INCON"));
        }

        // Try insurance section fallback
        int sectionLang = member.sections().stream()
            .filter(InsuranceSectionInfo::isEligible)
            .mapToInt(InsuranceSectionInfo::languageCode)
            .filter(VALID_CODES::contains)
            .findFirst()
            .orElse(0);

        if (!VALID_CODES.contains(sectionLang)) {
            return Optional.of(ValidationResult.rejected("TAALCODE ONBEK", "CODE LING INCON"));
        }

        ctx.setResolvedLanguageCode(sectionLang);
        return Optional.empty();
    }
}
