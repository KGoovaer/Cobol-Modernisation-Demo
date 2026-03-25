package be.betfin.MYFIN.adapter.model;

public record InsuranceSectionInfo(
    int productCode,
    boolean active,   // true = open, false = closed
    int languageCode  // resolved language from this section, 0=unknown
) {
    private static final java.util.Set<Integer> EXCLUDED_CODES = java.util.Set.of(609, 659, 679, 689);

    public boolean isEligible() {
        return !EXCLUDED_CODES.contains(productCode);
    }
}
