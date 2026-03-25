package be.betfin.MYFIN.admin;

import be.betfin.MYFIN.admin.dto.CreateUserRequest;
import be.betfin.MYFIN.admin.dto.UserAdminDto;
import be.betfin.MYFIN.auth.Role;
import be.betfin.MYFIN.auth.User;
import be.betfin.MYFIN.auth.UserRepository;
import be.betfin.MYFIN.exception.LastAdminException;
import be.betfin.MYFIN.exception.UserAlreadyExistsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UserAdminService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserAdminService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public List<UserAdminDto> listAll() {
        return userRepository.findAll().stream().map(UserAdminDto::from).collect(Collectors.toList());
    }

    @Transactional
    public UserAdminDto create(CreateUserRequest req) {
        if (userRepository.existsByUsername(req.username())) {
            throw new UserAlreadyExistsException(req.username());
        }
        User user = new User();
        user.setUsername(req.username());
        user.setPasswordHash(passwordEncoder.encode(req.password()));
        user.setRole(req.role());
        user.setActive(true);
        if (req.mutualityCodes() != null) {
            user.setMutualityCodes(new HashSet<>(req.mutualityCodes()));
        }
        return UserAdminDto.from(userRepository.save(user));
    }

    @Transactional
    public UserAdminDto deactivate(UUID id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new NoSuchElementException("User not found: " + id));
        if (user.getRole() == Role.ADMIN) {
            long activeAdmins = userRepository.countByRoleAndActiveTrue(Role.ADMIN);
            if (activeAdmins <= 1) {
                throw new LastAdminException();
            }
        }
        user.setActive(false);
        return UserAdminDto.from(userRepository.save(user));
    }

    @Transactional
    public void resetPassword(UUID id, String newPassword) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new NoSuchElementException("User not found: " + id));
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
}
