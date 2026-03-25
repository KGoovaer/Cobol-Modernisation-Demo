package be.betfin.MYFIN.payment;

import be.betfin.MYFIN.auth.User;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payment_requests")
public class PaymentRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "member_rnr", nullable = false)
    private Long memberRnr;

    @Column(name = "destination_mutuality", nullable = false)
    private Integer destinationMutuality;

    @Column(name = "constant_id", nullable = false, length = 10)
    private String constantId;

    @Column(name = "sequence_no", length = 4)
    private String sequenceNo;

    @Column(name = "amount_cents", nullable = false)
    private Long amountCents;

    @Column(name = "currency", nullable = false, length = 1)
    private Character currency;

    @Column(name = "payment_desc_code", nullable = false)
    private Integer paymentDescCode;

    @Column(name = "iban", nullable = false, length = 34)
    private String iban;

    @Column(name = "payment_method", nullable = false, columnDefinition = "VARCHAR(1)")
    private Character paymentMethod = ' ';

    @Column(name = "accounting_type", nullable = false)
    private Integer accountingType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submitted_by", nullable = false)
    private User submittedBy;

    @CreationTimestamp
    @Column(name = "submitted_at", nullable = false, updatable = false)
    private Instant submittedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private PaymentStatus status;

    public UUID getId() { return id; }
    public Long getMemberRnr() { return memberRnr; }
    public void setMemberRnr(Long memberRnr) { this.memberRnr = memberRnr; }
    public Integer getDestinationMutuality() { return destinationMutuality; }
    public void setDestinationMutuality(Integer destinationMutuality) { this.destinationMutuality = destinationMutuality; }
    public String getConstantId() { return constantId; }
    public void setConstantId(String constantId) { this.constantId = constantId; }
    public String getSequenceNo() { return sequenceNo; }
    public void setSequenceNo(String sequenceNo) { this.sequenceNo = sequenceNo; }
    public Long getAmountCents() { return amountCents; }
    public void setAmountCents(Long amountCents) { this.amountCents = amountCents; }
    public Character getCurrency() { return currency; }
    public void setCurrency(Character currency) { this.currency = currency; }
    public Integer getPaymentDescCode() { return paymentDescCode; }
    public void setPaymentDescCode(Integer paymentDescCode) { this.paymentDescCode = paymentDescCode; }
    public String getIban() { return iban; }
    public void setIban(String iban) { this.iban = iban; }
    public Character getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(Character paymentMethod) { this.paymentMethod = paymentMethod; }
    public Integer getAccountingType() { return accountingType; }
    public void setAccountingType(Integer accountingType) { this.accountingType = accountingType; }
    public User getSubmittedBy() { return submittedBy; }
    public void setSubmittedBy(User submittedBy) { this.submittedBy = submittedBy; }
    public Instant getSubmittedAt() { return submittedAt; }
    public PaymentStatus getStatus() { return status; }
    public void setStatus(PaymentStatus status) { this.status = status; }
}
