package be.betfin.MYFIN.admin;

import be.betfin.MYFIN.admin.dto.CreateUserRequest;
import be.betfin.MYFIN.admin.dto.ResetPasswordRequest;
import be.betfin.MYFIN.admin.dto.UserAdminDto;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/users")
public class UserAdminController {

    private final UserAdminService userAdminService;

    public UserAdminController(UserAdminService userAdminService) {
        this.userAdminService = userAdminService;
    }

    @GetMapping
    public ResponseEntity<List<UserAdminDto>> list() {
        return ResponseEntity.ok(userAdminService.listAll());
    }

    @PostMapping
    public ResponseEntity<UserAdminDto> create(@Valid @RequestBody CreateUserRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userAdminService.create(req));
    }

    @PatchMapping("/{id}/deactivate")
    public ResponseEntity<UserAdminDto> deactivate(@PathVariable UUID id) {
        return ResponseEntity.ok(userAdminService.deactivate(id));
    }

    @PostMapping("/{id}/reset-password")
    public ResponseEntity<Void> resetPassword(@PathVariable UUID id,
                                              @Valid @RequestBody ResetPasswordRequest req) {
        userAdminService.resetPassword(id, req.newPassword());
        return ResponseEntity.noContent().build();
    }
}
