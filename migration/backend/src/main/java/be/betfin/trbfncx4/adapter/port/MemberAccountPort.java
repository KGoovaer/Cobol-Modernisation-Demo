package be.betfin.MYFIN.adapter.port;

import java.util.Optional;

/**
 * Port interface for member known-account lookup (wraps SCHRKCX9 in production).
 */
public interface MemberAccountPort {

    /**
     * Return the IBAN registered at the member's bank for the given payment description code.
     * Returns empty Optional if no account is on file.
     */
    Optional<String> getKnownIban(long memberRnr, int paymentDescCode);
}
