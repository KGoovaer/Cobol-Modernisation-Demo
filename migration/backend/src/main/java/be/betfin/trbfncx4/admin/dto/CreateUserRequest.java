package be.betfin.MYFIN.admin.dto;

import be.betfin.MYFIN.auth.Role;
import jakarta.validation.constraints.*;

import java.util.Set;

public record CreateUserRequest(
    @NotBlank @Size(min = 3, max = 100) String username,
    @NotBlank @Size(min = 8, max = 100) String password,
    @NotNull Role role,
    Set<@Min(101) @Max(169) Integer> mutualityCodes
) {}
