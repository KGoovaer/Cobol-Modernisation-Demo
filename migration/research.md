# Research: MYFIN Web Application

**Phase**: 0 — Architectural Decisions  
**Date**: 2026-03-23  
**Status**: Complete — all decisions resolved, no NEEDS CLARIFICATION items

---

## Decision 1: Runtime & Framework

**Decision**: Java 21 + Spring Boot 3.x  
**Rationale**: Spring Boot 3 requires Java 17+; Java 21 is the current LTS and provides virtual threads (Project Loom) if needed for concurrent adapter calls. Spring Boot's auto-configuration gives us JPA, Security, Validation, and Flyway with minimal boilerplate. The MYFIN domain logic is well-suited to Spring's layered architecture.  
**Alternatives considered**:
- Quarkus: leaner startup, but Spring is the team's presumed baseline given the BETFIN context
- Java 17: LTS, but 21 is newer LTS with Sequenced Collections and improved pattern matching

---

## Decision 2: Authentication Strategy

**Decision**: Spring Security HTTP session with form login; `CookieCsrfTokenRepository.withHttpOnlyFalse()` so Angular can read the `XSRF-TOKEN` cookie and attach it as `X-XSRF-TOKEN` header  
**Rationale**: No external IdP or SSO requirement exists. Session cookies are appropriate for a single-organisation web portal. Storing CSRF token in a readable cookie is the standard Spring + Angular integration pattern.  
**Alternatives considered**:
- JWT: stateless but adds token management complexity; not required here
- OAuth2/OIDC: overkill for an internal standalone tool with its own user store
- Basic auth: not suitable for a browser SPA

---

## Decision 3: Password Storage

**Decision**: BCrypt with strength 10 (`BCryptPasswordEncoder(10)`)  
**Rationale**: BCrypt is the default Spring Security password encoder; strength 10 gives ~100ms hash time on modern hardware, appropriate for a login endpoint that doesn't face brute-force at scale.  
**Alternatives considered**: Argon2 (more modern but less universally supported in Spring tooling; strength 10 BCrypt is sufficient)

---

## Decision 4: Database Strategy

**Decision**: H2 in-memory for `dev` profile; PostgreSQL for `prod` profile; all Flyway migrations written as PostgreSQL-compatible SQL from day 1  
**Rationale**: H2 PostgreSQL compatibility mode (with `MODE=PostgreSQL` JDBC URL option) allows running Flyway migrations against H2 during development with high confidence they will work against real PostgreSQL in production. No schema drift risk.  
**Alternatives considered**: Testcontainers PostgreSQL for dev — more faithful but requires Docker. H2 is simpler for onboarding.

---

## Decision 5: ORM

**Decision**: Spring Data JPA with Hibernate  
**Rationale**: Standard in the Spring ecosystem; repositories reduce boilerplate for CRUD; `@Query` and `Specification` cover the complex filtered queries needed for payment/rejection list endpoints.  
**Alternatives considered**: jOOQ (type-safe SQL, excellent for complex queries, but more setup); plain JDBC (too low-level)

---

## Decision 6: Adapter (Legacy Integration) Pattern

**Decision**: Hexagonal ports-and-adapters. Each external system is modelled as a Java interface (port). A `@Profile("stub")` implementation is provided for each. Real adapters are out of scope for this phase.

| Port Interface | Stub behaviour |
|----------------|---------------|
| `MemberPort` | Returns a canned `MemberDto` for a known test RNR; throws `MemberNotFoundException` for unknown |
| `IBANValidationPort` | Returns valid result for IBANs matching `^BE\d{14}$`; throws `IBANServiceUnavailableException` for a special test IBAN; returns invalid for others |
| `MemberAccountPort` | Returns the same IBAN as submitted (no discrepancy) except for a special test value that triggers discrepancy |
| `PaymentHistoryPort` | Returns empty (no duplicates) except for a canned duplicate key combination |

**Rationale**: Allows full end-to-end testing of the web app and validation pipeline without legacy system access. Stub behaviour is deterministic and covers all acceptance scenarios in spec.md User Story 1.

---

## Decision 7: Validation Pipeline

**Decision**: Eight ordered steps implemented as `ValidationStep` interface instances injected into `PaymentValidationService`. Steps 1–6 fail-fast (throw `ValidationException` with bilingual message). Step 7 (AccountDiscrepancy) is non-blocking (writes `BankAccountDiscrepancy` record, continues). Step 8 (RegionalTag) assigns metadata for record creation.

**Order is fixed and non-negotiable** (Constitution Principle I):
1. MemberValidationStep
2. LanguageResolutionStep
3. PaymentDescriptionStep
4. DuplicateDetectionStep
5. IBANValidationStep (fail-closed on service outage)
6. CircularChequeStep
7. AccountDiscrepancyStep (non-blocking)
8. RegionalTagStep

**Rationale**: Replicates COBOL validation sequence. Ordering ensures expensive external calls (IBAN service) are not made for records that would fail on cheaper local checks first.

---

## Decision 8: Frontend Framework

**Decision**: Angular 19.x with Angular Material (standalone components where possible)  
**Rationale**: Angular's opinionated structure suits a form-heavy enterprise application. Angular Material provides data tables, paginator, form fields, and dialogs that match the UI requirements without custom CSS. RxJS handles async API calls cleanly.  
**Alternatives considered**: React with Material UI (more popular but less opinionated; Angular's built-in guards, interceptors, and reactive forms better suit this use case)

---

## Decision 9: Build Tools

**Decision**: Maven (backend) + Angular CLI (frontend). No unified build at this stage.  
**Rationale**: Each toolchain is idiomatic for its ecosystem. A unified Maven build (maven-frontend-plugin) can be added later if CI/CD requires a single artifact.

---

## Decision 10: Mutuality Scoping

**Decision**: Stored in `user_mutuality_codes` join table. Enforced at the service layer using Spring Security's `@PreAuthorize("@mutualityGuard.canAccess(authentication, #dto.destinationMutuality)")` for submissions. List queries are filtered by a `Specification` that intersects the requesting user's codes with the query results.  
**Rationale**: Declarative security annotations keep controllers thin. A Spring component (`mutualityGuard`) evaluates the user's code set at runtime.

---

## Decision 11: CSV Export

**Decision**: `StreamingResponseBody` returned from `GET /api/payments/export/csv`; written with Apache Commons CSV (or OpenCSV). Respects same filter parameters as the list endpoint.  
**Rationale**: StreamingResponseBody avoids loading an unbounded result set into memory. Filter reuse ensures WYSIWYG export (what you see on screen is what you get in the file).
