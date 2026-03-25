package be.betfin.MYFIN.adapter.model;

import java.util.List;

public record MemberInfo(
    long rnr,
    String name,
    String address,
    boolean belgianAddress,
    int languageCode,           // 1=FR, 2=NL, 3=DE, 0=unknown
    int mutualityCode,
    List<InsuranceSectionInfo> sections
) {}
