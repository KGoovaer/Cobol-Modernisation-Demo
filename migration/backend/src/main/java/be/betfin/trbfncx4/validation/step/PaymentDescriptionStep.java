package be.betfin.MYFIN.validation.step;

import be.betfin.MYFIN.adapter.port.MemberPort;
import be.betfin.MYFIN.payment.PaymentDescription;
import be.betfin.MYFIN.payment.PaymentDescriptionRepository;
import be.betfin.MYFIN.validation.ValidationContext;
import be.betfin.MYFIN.validation.ValidationResult;
import be.betfin.MYFIN.validation.ValidationStep;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@Order(3)
public class PaymentDescriptionStep implements ValidationStep {

    private final PaymentDescriptionRepository descriptionRepository;
    private final MemberPort memberPort;

    public PaymentDescriptionStep(PaymentDescriptionRepository descriptionRepository,
                                   MemberPort memberPort) {
        this.descriptionRepository = descriptionRepository;
        this.memberPort = memberPort;
    }

    @Override
    public Optional<ValidationResult> execute(ValidationContext ctx) {
        int code = ctx.getRequest().paymentDescCode();

        if (code >= 1 && code <= 89) {
            Optional<PaymentDescription> desc = descriptionRepository.findById(code);
            if (desc.isEmpty()) {
                return Optional.of(ValidationResult.rejected("CODE OMSCHR ONBEK", "CODE LIBEL INCON"));
            }
            ctx.setPaymentDescNl(desc.get().getDescriptionNl());
            ctx.setPaymentDescFr(desc.get().getDescriptionFr());
            return Optional.empty();
        }

        if (code >= 90 && code <= 99) {
            Optional<String[]> texts = memberPort.getPaymentDescriptionTexts(code, ctx.getRequest().memberRnr());
            if (texts.isEmpty()) {
                return Optional.of(ValidationResult.rejected("CODE OMSCHR ONBEK", "CODE LIBEL INCON"));
            }
            ctx.setPaymentDescNl(texts.get()[0]);
            ctx.setPaymentDescFr(texts.get()[1]);
            return Optional.empty();
        }

        return Optional.of(ValidationResult.rejected("CODE OMSCHR ONBEK", "CODE LIBEL INCON"));
    }
}
