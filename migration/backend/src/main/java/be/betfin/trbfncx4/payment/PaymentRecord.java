package be.betfin.MYFIN.payment;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payment_records")
public class PaymentRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_request_id", nullable = false, unique = true)
    private PaymentRequest paymentRequest;

    @Column(name = "member_name", nullable = false, length = 50)
    private String memberName;

    @Column(name = "member_rnr", nullable = false)
    private long memberRnr;

    @Column(name = "amount_cents", nullable = false)
    private long amountCents;

    @Column(name = "iban", nullable = false, length = 34)
    private String iban;

    @Column(name = "bic", length = 11)
    private String bic;

    @Column(name = "bank_routing", nullable = false, length = 10)
    private String bankRouting;

    @Column(name = "regional_tag", nullable = false)
    private int regionalTag;

    @Column(name = "accounting_type", nullable = false)
    private int accountingType;

    @Column(name = "destination_mutuality", nullable = false)
    private int destinationMutuality;

    @Column(name = "payment_desc_nl", length = 50)
    private String paymentDescNl;

    @Column(name = "payment_desc_fr", length = 50)
    private String paymentDescFr;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public UUID getId() { return id; }
    public PaymentRequest getPaymentRequest() { return paymentRequest; }
    public void setPaymentRequest(PaymentRequest paymentRequest) { this.paymentRequest = paymentRequest; }
    public String getMemberName() { return memberName; }
    public void setMemberName(String memberName) { this.memberName = memberName; }
    public long getMemberRnr() { return memberRnr; }
    public void setMemberRnr(long memberRnr) { this.memberRnr = memberRnr; }
    public long getAmountCents() { return amountCents; }
    public void setAmountCents(long amountCents) { this.amountCents = amountCents; }
    public String getIban() { return iban; }
    public void setIban(String iban) { this.iban = iban; }
    public String getBic() { return bic; }
    public void setBic(String bic) { this.bic = bic; }
    public String getBankRouting() { return bankRouting; }
    public void setBankRouting(String bankRouting) { this.bankRouting = bankRouting; }
    public int getRegionalTag() { return regionalTag; }
    public void setRegionalTag(int regionalTag) { this.regionalTag = regionalTag; }
    public int getAccountingType() { return accountingType; }
    public void setAccountingType(int accountingType) { this.accountingType = accountingType; }
    public int getDestinationMutuality() { return destinationMutuality; }
    public void setDestinationMutuality(int destinationMutuality) { this.destinationMutuality = destinationMutuality; }
    public String getPaymentDescNl() { return paymentDescNl; }
    public void setPaymentDescNl(String paymentDescNl) { this.paymentDescNl = paymentDescNl; }
    public String getPaymentDescFr() { return paymentDescFr; }
    public void setPaymentDescFr(String paymentDescFr) { this.paymentDescFr = paymentDescFr; }
    public Instant getCreatedAt() { return createdAt; }
}
