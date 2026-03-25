package be.betfin.MYFIN.auth;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

/**
 * T014 – User DTO — never exposes passwordHash.
 */
public record UserDto(
    UUID id,
    String username,
    Role role,
    boolean active,
    Set<Integer> mutualityCodes,
    Instant createdAt
) {
    public static UserDto from(User user) {
        return new UserDto(
            user.getId(),
            user.getUsername(),
            user.getRole(),
            user.isActive(),
            Set.copyOf(user.getMutualityCodes()),
            user.getCreatedAt()
        );
    }
}
