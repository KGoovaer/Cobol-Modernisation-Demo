package be.betfin.MYFIN.adapter.port;

import be.betfin.MYFIN.adapter.model.MemberInfo;

import java.util.Optional;

/**
 * Port interface for member data access (backed by MUTF08 in production).
 */
public interface MemberPort {

    Optional<MemberInfo> findByRnr(long rnr);

    /**
     * Retrieve the payment description text for codes 90-99 (fetched from MUTF08 PAR tables).
     * Returns empty Optional if the code is not found.
     */
    Optional<String[]> getPaymentDescriptionTexts(int code, long memberRnr);
}
