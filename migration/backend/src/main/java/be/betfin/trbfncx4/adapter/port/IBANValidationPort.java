package be.betfin.MYFIN.adapter.port;

import be.betfin.MYFIN.adapter.model.IBANValidationResult;
import be.betfin.MYFIN.exception.IBANServiceUnavailableException;

/**
 * Port interface for IBAN validation (wraps SEBNKUK9 in production).
 */
public interface IBANValidationPort {

    /**
     * Validate an IBAN and extract BIC + bank routing.
     *
     * @param iban          the IBAN string to validate
     * @param paymentMethod the payment method character (' ', 'C', 'D', 'E', 'F')
     * @return validation result with BIC and bank code
     * @throws IBANServiceUnavailableException if the underlying SEBNKUK9 service is unreachable
     */
    IBANValidationResult validate(String iban, char paymentMethod);
}
