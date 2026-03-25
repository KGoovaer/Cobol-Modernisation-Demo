package be.betfin.MYFIN.adapter.stub;

import be.betfin.MYFIN.adapter.model.IBANValidationResult;
import be.betfin.MYFIN.adapter.port.IBANValidationPort;
import be.betfin.MYFIN.exception.IBANServiceUnavailableException;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Stub IBANValidationPort for dev/test.
 *
 * Behaviour:
 * - IBAN = "UNAVAILABLE"         → throws IBANServiceUnavailableException (FR-019 scenario)
 * - IBAN starts with "BE"        → valid, BIC="GEBABEBB", bank="BELFIUS"
 * - IBAN starts with "NL"        → valid, BIC="INGBNL2A", bank="KBC"
 * - Any other prefix             → invalid IBAN
 */
@Component
@Profile("!prod")
public class StubIBANValidationAdapter implements IBANValidationPort {

    @Override
    public IBANValidationResult validate(String iban, char paymentMethod) {
        if ("UNAVAILABLE".equals(iban)) {
            throw new IBANServiceUnavailableException();
        }
        if (iban != null && iban.startsWith("BE")) {
            return new IBANValidationResult(true, "GEBABEBB", "BELFIUS");
        }
        if (iban != null && iban.startsWith("NL")) {
            return new IBANValidationResult(true, "INGBNL2A", "KBC");
        }
        return IBANValidationResult.invalid();
    }
}
