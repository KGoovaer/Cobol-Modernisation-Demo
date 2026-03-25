package be.betfin.MYFIN.adapter.model;

public record IBANValidationResult(
    boolean valid,
    String bic,
    String bankCode   // "BELFIUS" or "KBC" (empty if unknown/invalid)
) {
    public static IBANValidationResult invalid() {
        return new IBANValidationResult(false, null, null);
    }
}
