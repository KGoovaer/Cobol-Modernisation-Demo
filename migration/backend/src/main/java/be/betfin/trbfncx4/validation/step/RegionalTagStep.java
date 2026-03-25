package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;

/**
 * Step 8 – Assign regional tag and bank routing (FR-006, FR-007).
 *
 * Mapping (TRBFN-TYPE-COMPTA → TAGREG-OP):
 *   1 → 9  (General — Belfius or KBC from IBAN result)
 *   3 → 1  (Flemish — Belfius only)
 *   4 → 2  (Walloon — Belfius only)
 *   5 → 4  (Brussels — Belfius only)
 *   6 → 7  (German-speaking — Belfius only)
 */
@Component
@Order(8)
public class RegionalTagStep implements ValidationStep {

    private static final Map<Integer, Integer> TYPE_TO_TAG = Map.of(
        1, 9,
        3, 1,
        4, 2,
        5, 4,
        6, 7
    );

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        int accountingType = ctx.getRequest().accountingType();
        int tag = TYPE_TO_TAG.getOrDefault(accountingType, 9);
        ctx.setRegionalTag(tag);

        // Regional types 3-6: Belfius only (FR-007)
        if (accountingType != 1) {
            ctx.setBankRouting("BELFIUS");
        } else {
            // General: use bank determined by IBAN validation
            String ibanBank = ctx.getIbanResult() != null ? ctx.getIbanResult().bankCode() : "BELFIUS";
            ctx.setBankRouting("KBC".equalsIgnoreCase(ibanBank) ? "KBC" : "BELFIUS");
        }
        return Optional.empty();
    }
}
