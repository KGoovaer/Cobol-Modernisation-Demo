package be.betfin.MYFIN.admin.dto;

import be.betfin.MYFIN.auth.User;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

public record UserAdminDto(
    UUID id,
    String username,
    String role,
    boolean active,
    Set<Integer> mutualityCodes,
    Instant createdAt
) {
    public static UserAdminDto from(User u) {
        return new UserAdminDto(u.getId(), u.getUsername(), u.getRole().name(),
            u.isActive(), u.getMutualityCodes(), u.getCreatedAt());
    }
}
