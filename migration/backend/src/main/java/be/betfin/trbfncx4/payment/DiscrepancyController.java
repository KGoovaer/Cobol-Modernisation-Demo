package be.betfin.MYFIN.payment;

import be.betfin.MYFIN.auth.Role;
import be.betfin.MYFIN.auth.User;
import be.betfin.MYFIN.payment.dto.DiscrepancyDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Set;

@RestController
@RequestMapping("/api/discrepancies")
public class DiscrepancyController {

    private final PaymentService paymentService;

    public DiscrepancyController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @GetMapping
    public ResponseEntity<Page<DiscrepancyDto>> list(
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 25) Pageable pageable) {
        Set<Integer> allowed = user.getRole() == Role.ADMIN ? null : user.getMutualityCodes();
        return ResponseEntity.ok(paymentService.listDiscrepancies(allowed, pageable));
    }
}
