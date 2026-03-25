package be.betfin.MYFIN.validation;

public class ValidationResult {

    private final boolean accepted;
    private final String diagnosticNl;
    private final String diagnosticFr;

    private ValidationResult(boolean accepted, String nl, String fr) {
        this.accepted = accepted;
        this.diagnosticNl = nl;
        this.diagnosticFr = fr;
    }

    public boolean isAccepted() { return accepted; }
    public String getDiagnosticNl() { return diagnosticNl; }
    public String getDiagnosticFr() { return diagnosticFr; }

    public static ValidationResult accepted() {
        return new ValidationResult(true, null, null);
    }

    public static ValidationResult rejected(String nl, String fr) {
        return new ValidationResult(false, nl, fr);
    }
}
