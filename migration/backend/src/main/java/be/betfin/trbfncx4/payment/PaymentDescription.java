package be.betfin.MYFIN.payment;

import jakarta.persistence.*;

@Entity
@Table(name = "payment_descriptions")
public class PaymentDescription {

    @Id
    @Column(nullable = false)
    private int code;

    @Column(name = "description_nl", nullable = false, length = 50)
    private String descriptionNl;

    @Column(name = "description_fr", nullable = false, length = 50)
    private String descriptionFr;

    @Column(name = "description_de", length = 50)
    private String descriptionDe;

    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }
    public String getDescriptionNl() { return descriptionNl; }
    public void setDescriptionNl(String descriptionNl) { this.descriptionNl = descriptionNl; }
    public String getDescriptionFr() { return descriptionFr; }
    public void setDescriptionFr(String descriptionFr) { this.descriptionFr = descriptionFr; }
    public String getDescriptionDe() { return descriptionDe; }
    public void setDescriptionDe(String descriptionDe) { this.descriptionDe = descriptionDe; }
}
