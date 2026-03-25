package be.betfin.MYFIN.payment;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "rejection_records")
public class RejectionRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_request_id", nullable = false, unique = true)
    private PaymentRequest paymentRequest;

    @Column(name = "diagnostic_nl", nullable = false, length = 32)
    private String diagnosticNl;

    @Column(name = "diagnostic_fr", nullable = false, length = 32)
    private String diagnosticFr;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public UUID getId() { return id; }
    public PaymentRequest getPaymentRequest() { return paymentRequest; }
    public void setPaymentRequest(PaymentRequest paymentRequest) { this.paymentRequest = paymentRequest; }
    public String getDiagnosticNl() { return diagnosticNl; }
    public void setDiagnosticNl(String diagnosticNl) { this.diagnosticNl = diagnosticNl; }
    public String getDiagnosticFr() { return diagnosticFr; }
    public void setDiagnosticFr(String diagnosticFr) { this.diagnosticFr = diagnosticFr; }
    public Instant getCreatedAt() { return createdAt; }
}
