package be.betfin.MYFIN.adapter.stub;

import be.betfin.MYFIN.adapter.port.MemberAccountPort;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Stub MemberAccountPort for dev/test.
 *
 * Behaviour:
 * - RNR 99999999900L → known IBAN differs (returns "BE00000099900099900") to trigger discrepancy
 * - All others       → known IBAN = "BE68539007547034"
 */
@Component
@Profile("!prod")
public class StubMemberAccountAdapter implements MemberAccountPort {

    private static final String DEFAULT_KNOWN_IBAN = "BE68539007547034";
    private static final long DISCREPANCY_RNR = 99999999900L;

    @Override
    public Optional<String> getKnownIban(long memberRnr, int paymentDescCode) {
        if (memberRnr == DISCREPANCY_RNR) {
            return Optional.of("BE00000099900099900");
        }
        return Optional.of(DEFAULT_KNOWN_IBAN);
    }
}
