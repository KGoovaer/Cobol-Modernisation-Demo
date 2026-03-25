package be.betfin.MYFIN.adapter.port;

/**
 * Port interface for duplicate payment detection (backed by BBF payment history in production).
 */
public interface PaymentHistoryPort {

    /**
     * Returns true if a payment with the same constant identifier AND the same amount in cents
     * already exists for this member (duplicate detection per FR-002).
     */
    boolean isDuplicate(long memberRnr, String constantId, long amountCents);

    /**
     * Record a newly accepted payment so future duplicate checks are aware of it.
     */
    void recordPayment(long memberRnr, String constantId, long amountCents);
}
