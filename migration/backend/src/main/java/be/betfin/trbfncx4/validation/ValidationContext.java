package be.betfin.MYFIN.validation;

import be.betfin.MYFIN.adapter.model.IBANValidationResult;
import be.betfin.MYFIN.adapter.model.MemberInfo;
import be.betfin.MYFIN.payment.dto.PaymentSubmitRequest;

public class ValidationContext {

    private final PaymentSubmitRequest request;
    private MemberInfo member;
    private int resolvedLanguageCode;
    private String paymentDescNl;
    private String paymentDescFr;
    private IBANValidationResult ibanResult;
    private int regionalTag;
    private String bankRouting;
    private String knownIban;
    private boolean ibanDiscrepancy;

    public ValidationContext(PaymentSubmitRequest request) {
        this.request = request;
    }

    public PaymentSubmitRequest getRequest() { return request; }
    public MemberInfo getMember() { return member; }
    public void setMember(MemberInfo member) { this.member = member; }
    public int getResolvedLanguageCode() { return resolvedLanguageCode; }
    public void setResolvedLanguageCode(int resolvedLanguageCode) { this.resolvedLanguageCode = resolvedLanguageCode; }
    public String getPaymentDescNl() { return paymentDescNl; }
    public void setPaymentDescNl(String paymentDescNl) { this.paymentDescNl = paymentDescNl; }
    public String getPaymentDescFr() { return paymentDescFr; }
    public void setPaymentDescFr(String paymentDescFr) { this.paymentDescFr = paymentDescFr; }
    public IBANValidationResult getIbanResult() { return ibanResult; }
    public void setIbanResult(IBANValidationResult ibanResult) { this.ibanResult = ibanResult; }
    public int getRegionalTag() { return regionalTag; }
    public void setRegionalTag(int regionalTag) { this.regionalTag = regionalTag; }
    public String getBankRouting() { return bankRouting; }
    public void setBankRouting(String bankRouting) { this.bankRouting = bankRouting; }
    public String getKnownIban() { return knownIban; }
    public void setKnownIban(String knownIban) { this.knownIban = knownIban; }
    public boolean isIbanDiscrepancy() { return ibanDiscrepancy; }
    public void setIbanDiscrepancy(boolean ibanDiscrepancy) { this.ibanDiscrepancy = ibanDiscrepancy; }
}
