package be.betfin.MYFIN.config;

import be.betfin.MYFIN.auth.Role;
import be.betfin.MYFIN.auth.User;
import be.betfin.MYFIN.auth.UserDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;

import java.util.Map;

/**
 * T013 – Spring Security configuration:
 * - Form login returns JSON (not redirect)
 * - CookieCsrfTokenRepository.withHttpOnlyFalse() for Angular XSRF
 * - BCrypt(10)
 * - Role-based requestMatchers per data-model.md Role-Endpoint Matrix
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    private final ObjectMapper objectMapper;

    public SecurityConfig(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(10);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        // CSRF: use cookie-based token readable by Angular
        CsrfTokenRequestAttributeHandler csrfHandler = new CsrfTokenRequestAttributeHandler();
        csrfHandler.setCsrfRequestAttributeName(null); // defers token to cookie

        http
            .csrf(csrf -> csrf
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                .csrfTokenRequestHandler(csrfHandler)
                .ignoringRequestMatchers("/h2-console/**", "/api/auth/login")
            )
            .headers(headers -> headers.frameOptions(fo -> fo.sameOrigin())) // H2 console
            .authorizeHttpRequests(auth -> auth
                // Public
                .requestMatchers("/api/auth/login", "/api/auth/logout").permitAll()
                .requestMatchers("/h2-console/**").permitAll()
                .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()

                // Admin endpoints
                .requestMatchers("/api/admin/**").hasRole(Role.ADMIN.name())

                // SUBMITTER-only write
                .requestMatchers(HttpMethod.POST, "/api/payments").hasRole(Role.SUBMITTER.name())

                // ADMIN cannot access payment/rejection/discrepancy endpoints
                .requestMatchers("/api/payments/**", "/api/rejections/**", "/api/discrepancies/**")
                    .hasAnyRole(Role.SUBMITTER.name(), Role.READ_ONLY.name())

                // Authenticated for everything else
                .requestMatchers("/api/**").authenticated()
                .anyRequest().permitAll()
            )
            .formLogin(form -> form
                .loginProcessingUrl("/api/auth/login")
                .successHandler(jsonSuccessHandler())
                .failureHandler(jsonFailureHandler())
            )
            .logout(logout -> logout
                .logoutUrl("/api/auth/logout")
                .logoutSuccessHandler((req, res, auth) -> {
                    res.setStatus(HttpServletResponse.SC_OK);
                    res.setContentType("application/json");
                    res.getWriter().write("{}");
                })
                .deleteCookies("JSESSIONID", "XSRF-TOKEN")
                .invalidateHttpSession(true)
            )
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((req, res, authEx) -> {
                    res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    res.setContentType("application/json;charset=UTF-8");
                    res.getWriter().write(objectMapper.writeValueAsString(
                        Map.of("error", "Not authenticated")));
                })
                .accessDeniedHandler((req, res, accessEx) -> {
                    res.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    res.setContentType("application/json;charset=UTF-8");
                    res.getWriter().write(objectMapper.writeValueAsString(
                        Map.of("error", "Access denied")));
                })
            );

        return http.build();
    }

    private AuthenticationSuccessHandler jsonSuccessHandler() {
        return (req, res, auth) -> {
            User user = (User) auth.getPrincipal();
            res.setStatus(HttpServletResponse.SC_OK);
            res.setContentType("application/json;charset=UTF-8");
            objectMapper.writeValue(res.getWriter(), UserDto.from(user));
        };
    }

    private AuthenticationFailureHandler jsonFailureHandler() {
        return (req, res, ex) -> {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.setContentType("application/json;charset=UTF-8");
            String message = ex instanceof DisabledException
                ? "Account is disabled"
                : "Bad credentials";
            objectMapper.writeValue(res.getWriter(), Map.of("error", message));
        };
    }
}
