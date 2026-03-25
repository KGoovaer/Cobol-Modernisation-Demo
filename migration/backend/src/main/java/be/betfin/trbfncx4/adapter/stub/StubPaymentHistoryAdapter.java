package be.betfin.MYFIN.adapter.stub;

import be.betfin.MYFIN.adapter.port.PaymentHistoryPort;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;

/**
 * Stub PaymentHistoryPort — in-memory duplicate tracking for dev/test.
 * A composite key of memberRnr + constantId + amountCents uniquely identifies a payment.
 */
@Component
@Profile("!prod")
public class StubPaymentHistoryAdapter implements PaymentHistoryPort {

    private final Set<String> recorded = new HashSet<>();

    @Override
    public boolean isDuplicate(long memberRnr, String constantId, long amountCents) {
        return recorded.contains(key(memberRnr, constantId, amountCents));
    }

    @Override
    public void recordPayment(long memberRnr, String constantId, long amountCents) {
        recorded.add(key(memberRnr, constantId, amountCents));
    }

    private String key(long rnr, String constantId, long cents) {
        return rnr + "|" + constantId + "|" + cents;
    }
}
