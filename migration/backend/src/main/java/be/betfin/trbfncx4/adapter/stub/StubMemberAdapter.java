package be.betfin.MYFIN.adapter.stub;

import be.betfin.MYFIN.adapter.model.InsuranceSectionInfo;
import be.betfin.MYFIN.adapter.model.MemberInfo;
import be.betfin.MYFIN.adapter.port.MemberPort;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

/**
 * Stub MemberPort for dev/test.
 *
 * Behaviour:
 * - RNR 12345678901L  → valid member, Dutch, mutuality 110
 * - RNR 99999999999L  → not found (LIDNR ONBEKEND scenario)
 * - Any other RNR     → valid member with French language
 */
@Component
@Profile("!prod")
public class StubMemberAdapter implements MemberPort {

    private static final long VALID_RNR = 12345678901L;
    private static final long NOT_FOUND_RNR = 99999999999L;

    @Override
    public Optional<MemberInfo> findByRnr(long rnr) {
        if (rnr == NOT_FOUND_RNR) {
            return Optional.empty();
        }
        int langCode = (rnr == VALID_RNR) ? 2 : 1; // 2=NL for primary test member, 1=FR otherwise
        return Optional.of(new MemberInfo(
            rnr,
            "Test Member " + rnr,
            "Teststraat 1, 1000 Brussel",
            true,
            langCode,
            110,
            List.of(
                new InsuranceSectionInfo(100, true, langCode),
                new InsuranceSectionInfo(200, false, langCode)
            )
        ));
    }

    @Override
    public Optional<String[]> getPaymentDescriptionTexts(int code, long memberRnr) {
        // Stub: codes 90-99 return generic descriptions
        return Optional.of(new String[]{
            "Betaling code " + code,
            "Paiement code " + code
        });
    }
}
