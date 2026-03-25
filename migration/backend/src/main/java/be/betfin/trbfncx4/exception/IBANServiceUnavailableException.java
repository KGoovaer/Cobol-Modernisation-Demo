package be.betfin.MYFIN.exception;

public class IBANServiceUnavailableException extends RuntimeException {
    public IBANServiceUnavailableException() {
        super("IBAN validation service unavailable, please retry");
    }
}
