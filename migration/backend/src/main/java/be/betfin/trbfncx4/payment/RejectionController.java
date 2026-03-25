package be.betfin.MYFIN.payment;

import be.betfin.MYFIN.auth.Role;
import be.betfin.MYFIN.auth.User;
import be.betfin.MYFIN.payment.dto.RejectionRecordDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/rejections")
public class RejectionController {

    private final PaymentService paymentService;

    public RejectionController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @GetMapping
    public ResponseEntity<Page<RejectionRecordDto>> list(
            @RequestParam(required = false) Integer accountingType,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant dateTo,
            @RequestParam(required = false) Integer mutualityCode,
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 25) Pageable pageable) {

        Set<Integer> allowed = user.getRole() == Role.ADMIN ? null : user.getMutualityCodes();
        return ResponseEntity.ok(
            paymentService.listRejections(accountingType, dateFrom, dateTo, mutualityCode, allowed, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<RejectionRecordDto> getById(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        Set<Integer> allowed = user.getRole() == Role.ADMIN ? null : user.getMutualityCodes();
        return ResponseEntity.ok(paymentService.getRejection(id, allowed));
    }
}
