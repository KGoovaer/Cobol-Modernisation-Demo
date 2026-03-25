package be.betfin.MYFIN.exception;

public class LastAdminException extends RuntimeException {
    public LastAdminException() {
        super("Cannot deactivate the last active ADMIN");
    }
}
