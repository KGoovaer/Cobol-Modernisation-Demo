package be.betfin.MYFIN.payment;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "bank_account_discrepancies")
public class BankAccountDiscrepancy {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_request_id", nullable = false)
    private PaymentRequest paymentRequest;

    @Column(name = "provided_iban", nullable = false, length = 34)
    private String providedIban;

    @Column(name = "known_iban", nullable = false, length = 34)
    private String knownIban;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public UUID getId() { return id; }
    public PaymentRequest getPaymentRequest() { return paymentRequest; }
    public void setPaymentRequest(PaymentRequest paymentRequest) { this.paymentRequest = paymentRequest; }
    public String getProvidedIban() { return providedIban; }
    public void setProvidedIban(String providedIban) { this.providedIban = providedIban; }
    public String getKnownIban() { return knownIban; }
    public void setKnownIban(String knownIban) { this.knownIban = knownIban; }
    public Instant getCreatedAt() { return createdAt; }
}
