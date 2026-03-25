# Implementation Plan: MYFIN Web Application – Manual Payment Processing Portal

**Branch**: `001-spring-angular-app` | **Date**: 2026-03-23 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/001-spring-angular-app/spec.md`

---

## Summary

Build a Spring Boot 3 + Angular 19 web application that replaces the COBOL batch program MYFIN (GIRBET manual payment processing) with an interactive, real-time web portal. Mutuality administrators submit individual payment requests via a form; the backend runs a strictly-ordered, fail-fast validation pipeline against stub implementations of the legacy external systems (MUTF08 member DB, BBF payment module, SEBNKUK9 IBAN validation, SCHRKCX9 member account lookup, CGACVXD9 date service) and returns an immediate acceptance or bilingual rejection message. Accepted payments are stored in PostgreSQL (H2 in dev) and visible through filterable payment, rejection, and discrepancy list views. Three roles control access: Submitter, Read-Only, and Admin.

---

## Technical Context

**Language/Version**: Java 21 (backend) · TypeScript / Node.js LTS (frontend)  
**Primary Dependencies**:
- Backend: Spring Boot 3.x (spring-boot-starter-web, spring-security, spring-data-jpa, spring-boot-starter-validation, flyway-core)
- Frontend: Angular 19.x, Angular Material, Angular CLI, RxJS
**Storage**: H2 in-memory (dev profile) + PostgreSQL (prod profile); schema managed by Flyway  
**Testing**: JUnit 5 + MockMvc (backend) · Jest + Angular TestBed (frontend)  
**Target Platform**: JVM / containerisable Linux server; browser SPA  
**Project Type**: Monorepo web application (backend/ + frontend/ co-located in spec directory)  
**Performance Goals**: Payment validation response < 5 s (SC-001); list retrieval < 3 s for historical search (SC-004)  
**Constraints**: Stub adapters for all external systems; real adapter wiring is out of scope; PostgreSQL-compatible Flyway migrations from day 0  
**Scale/Scope**: Single-tenant (one organisation); dozens of mutuality administrators; historical payment records per mutuality code

---

## Constitution Check

*GATE: Validated before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Validation-First Processing** | ✅ COMPLIANT | Eight-step pipeline is strictly ordered and fail-fast; steps 1–7 must pass (step 7 is non-blocking) before any PaymentRecord is persisted. Order matches FR-001 → FR-003 validation hierarchy. |
| **II. SEPA Compliance** | ✅ COMPLIANT | IBANValidationStep (step 5) runs before any record is written; failure → immediate rejection (no BIC extracted, no PaymentRecord). Fail-closed on service outage (FR-019). Regional payments (types 3–6) forced to Belfius (FR-007). |
| **III. Complete Audit Trail** | ✅ COMPLIANT | Every PaymentRequest yields exactly one PaymentRecord (ACCEPTED) or one RejectionRecord (REJECTED). BankAccountDiscrepancy is created for any IBAN mismatch regardless of payment outcome. No request is silently dropped (SC-002). |
| **IV. Regional Accounting Separation** | ✅ COMPLIANT | RegionalTagStep (step 8) assigns regional_tag and bank_routing from accounting_type after all validation passes. Types 3–6 force Belfius. Entities and list filters are scoped per region. |
| **V. Duplicate Prevention** | ✅ COMPLIANT | DuplicateDetectionStep (step 4) queries PaymentHistoryPort before any PaymentRecord or bank instruction is created. Duplicates yield RejectionRecord with "DUBBELE BETALING / DOUBLE PAIEMENT" (FR-002). |
| **Data Integrity Standards** | ✅ COMPLIANT (adapted) | COBOL copybook field widths inform JPA entity column definitions (`@Column(length=...)`) and validation annotations (`@Size`). Character encoding for bilingual fields (NL/FR) is preserved in varchar columns and DTO serialisation. |
| **Batch Execution Standards** | ✅ COMPLIANT (adapted) | The web app is request/response, not batch. Each POST /api/payments is an atomic unit; a single-request failure does not block other requests (maps to "no early abort on single-record failures"). HTTP status codes replace RETURN-CODE. Flat-file output and sequential count logging are not applicable in this phase. |

---

## Project Structure

### Documentation (this feature)

```text
specs/001-spring-angular-app/
├── plan.md              ← this file
├── spec.md              ← feature specification
├── research.md          ← Phase 0: architectural decisions
├── data-model.md        ← Phase 1: JPA entities and DB schema
├── quickstart.md        ← Phase 1: local dev startup guide
├── contracts/           ← Phase 1: REST API contracts
│   ├── auth-api.md
│   ├── payments-api.md
│   └── admin-api.md
└── tasks.md             ← Phase 2 output (/speckit.tasks — NOT created by /speckit.plan)
```

### Source Code (monorepo inside spec directory)

```text
specs/001-spring-angular-app/
├── backend/
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/be/betfin/MYFIN/
│       │   │   ├── auth/
│       │   │   │   ├── User.java
│       │   │   │   ├── Role.java
│       │   │   │   ├── UserMutualityCode.java
│       │   │   │   ├── UserRepository.java
│       │   │   │   ├── UserDetailsServiceImpl.java
│       │   │   │   └── AuthController.java
│       │   │   ├── payment/
│       │   │   │   ├── PaymentRequest.java
│       │   │   │   ├── PaymentRecord.java
│       │   │   │   ├── RejectionRecord.java
│       │   │   │   ├── BankAccountDiscrepancy.java
│       │   │   │   ├── PaymentDescription.java
│       │   │   │   ├── PaymentController.java
│       │   │   │   ├── RejectionController.java
│       │   │   │   └── DiscrepancyController.java
│       │   │   ├── validation/
│       │   │   │   ├── ValidationStep.java          (interface)
│       │   │   │   ├── ValidationContext.java
│       │   │   │   ├── ValidationResult.java
│       │   │   │   ├── PaymentValidationService.java (orchestrator)
│       │   │   │   ├── MemberValidationStep.java
│       │   │   │   ├── LanguageResolutionStep.java
│       │   │   │   ├── PaymentDescriptionStep.java
│       │   │   │   ├── DuplicateDetectionStep.java
│       │   │   │   ├── IBANValidationStep.java
│       │   │   │   ├── CircularChequeStep.java
│       │   │   │   ├── AccountDiscrepancyStep.java
│       │   │   │   └── RegionalTagStep.java
│       │   │   ├── adapter/
│       │   │   │   ├── MemberPort.java              (interface)
│       │   │   │   ├── IBANValidationPort.java      (interface)
│       │   │   │   ├── MemberAccountPort.java       (interface)
│       │   │   │   ├── PaymentHistoryPort.java      (interface)
│       │   │   │   └── stub/
│       │   │   │       ├── StubMemberPort.java
│       │   │   │       ├── StubIBANValidationPort.java
│       │   │   │       ├── StubMemberAccountPort.java
│       │   │   │       └── StubPaymentHistoryPort.java
│       │   │   ├── admin/
│       │   │   │   └── UserAdminController.java
│       │   │   ├── config/
│       │   │   │   ├── SecurityConfig.java
│       │   │   │   └── WebMvcConfig.java
│       │   │   └── exception/
│       │   │       └── GlobalExceptionHandler.java
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── application-dev.yml
│       │       ├── application-stub.yml
│       │       └── db/migration/
│       │           ├── V1__create_users.sql
│       │           ├── V2__create_payment_tables.sql
│       │           └── V3__seed_payment_descriptions.sql
│       └── test/
│           └── java/be/betfin/MYFIN/
│               ├── auth/
│               ├── payment/
│               ├── validation/
│               └── admin/
└── frontend/
    ├── angular.json
    ├── package.json
    └── src/app/
        ├── auth/
        │   ├── login/             (LoginComponent)
        │   ├── auth.service.ts
        │   ├── auth.guard.ts
        │   └── role.guard.ts
        ├── payment/
        │   ├── payment-form/      (PaymentFormComponent)
        │   └── validation-result/ (ValidationResultComponent)
        ├── lists/
        │   ├── payment-list/      (PaymentListComponent)
        │   ├── rejection-list/    (RejectionListComponent)
        │   └── discrepancy-list/  (DiscrepancyListComponent)
        ├── admin/
        │   └── user-management/   (UserManagementComponent)
        └── core/
            ├── http-xsrf.interceptor.ts
            ├── api.service.ts
            └── shell/             (ShellComponent — nav + router-outlet)
```

**Structure Decision**: Monorepo Option 2 (web application with backend/ + frontend/ subdirectories). Both projects live under `specs/001-spring-angular-app/` to keep implementation co-located with the feature specification. The backend follows a feature-package layout (by domain slice, not by layer) to keep each vertical (auth, payment, admin) self-contained.

---

## Implementation Phases

### Phase 1 — Scaffolding & Authentication

**Goal**: Running app with login, role-based routing, and protected skeleton routes.

| Step | Deliverable |
|------|-------------|
| 1 | Maven project (`pom.xml`) with spring-boot-starter-web, security, data-jpa, validation, h2, postgresql, flyway |
| 2 | `application.yml` (base) + `application-dev.yml` (H2, port 8080) + `application-stub.yml` (enables `@Profile("stub")` adapters) |
| 3 | Flyway `V1__create_users.sql` — `users` and `user_mutuality_codes` tables |
| 4 | `User`, `UserMutualityCode` JPA entities + `UserRepository` |
| 5 | `UserDetailsServiceImpl` loading user + roles from DB |
| 6 | `SecurityConfig` — form login, `CookieCsrfTokenRepository(withHttpOnlyFalse())`, BCrypt(10), role-based `requestMatchers` |
| 7 | `AuthController` — POST /api/auth/login, POST /api/auth/logout, GET /api/auth/me |
| 8 | Angular project scaffold (Angular CLI `ng new`, Angular Material) |
| 9 | `HttpXsrfInterceptor` reading XSRF-TOKEN cookie, `ApiService` base wrapping `HttpClient` |
| 10 | `AuthService`, `AuthGuard`, `RoleGuard` |
| 11 | `LoginComponent`, `ShellComponent` (nav bar with role-conditional menu items) |
| 12 | Lazy-loaded route stubs for payment, lists, admin modules |

### Phase 2 — Domain Model & Validation Engine

**Goal**: Full validation pipeline wired with stub adapters; payment submission returns correct result.

| Step | Deliverable |
|------|-------------|
| 13 | Flyway `V2__create_payment_tables.sql` — all five domain tables |
| 14 | Flyway `V3__seed_payment_descriptions.sql` — codes 1–89 |
| 15 | JPA entities: `PaymentRequest`, `PaymentRecord`, `RejectionRecord`, `BankAccountDiscrepancy`, `PaymentDescription` |
| 16 | Port interfaces: `MemberPort`, `IBANValidationPort`, `MemberAccountPort`, `PaymentHistoryPort` |
| 17 | Stub implementations (`@Profile("stub")`) for all four ports |
| 18 | `ValidationStep` interface + `ValidationContext` (carries member data, resolved language, IBAN result between steps) |
| 19 | Eight ordered validation steps (see data-model.md for step contracts) |
| 20 | `PaymentValidationService` — executes steps in order; step 7 (AccountDiscrepancyStep) is non-blocking (writes record, does not fail-fast) |
| 21 | Mutuality scoping: `@PreAuthorize` expression checking authenticated user's assigned codes against request destination |

### Phase 3 — REST API

**Goal**: All API endpoints from contracts/ implemented and returning correct responses.

| Step | Deliverable |
|------|-------------|
| 22 | `PaymentController` — POST /api/payments (submit + validate + persist), GET list + export CSV, GET by ID, GET search |
| 23 | `RejectionController` — GET list (paginated, filterable), GET by ID |
| 24 | `DiscrepancyController` — GET list (paginated) |
| 25 | `UserAdminController` — full CRUD for users (Admin only) |
| 26 | `GlobalExceptionHandler` — maps `IBANServiceUnavailableException`, `AccessDeniedException`, `ConstraintViolationException`, validation pipeline failures to correct HTTP status + body |
| 27 | CSV export (`/api/payments/export/csv`) using Spring's `StreamingResponseBody` |

### Phase 4 — Angular Frontend

**Goal**: All user stories deliverable through the browser.

| Step | Deliverable |
|------|-------------|
| 28 | `PaymentFormComponent` — all input fields with `ReactiveFormsModule` validators; on submit, calls `PaymentApiService.submit()` |
| 29 | `ValidationResultComponent` — inline success badge or bilingual rejection message (NL / FR side-by-side) |
| 30 | `PaymentListComponent` — `MatTable` + `MatPaginator` + `MatSort`; filters: accountingType, dateFrom, dateTo, mutualityCode |
| 31 | `RejectionListComponent` — same pattern; bilingual diagnostic column (NL | FR) |
| 32 | `DiscrepancyListComponent` — shows provided vs known IBAN |
| 33 | `UserManagementComponent` — user table, create dialog, deactivate action, reset-password action (Admin only) |
| 34 | CSV export button on `PaymentListComponent` calling `/api/payments/export/csv` with current filter params |
| 35 | 401 interceptor in `ApiService` — redirects to login on HTTP 401 |

### Phase 5 — Tests & Verification

**Goal**: All acceptance scenarios from spec.md pass automatically.

| Step | Deliverable |
|------|-------------|
| 36 | `@SpringBootTest` + MockMvc integration tests for authentication (401 without login, 403 wrong role) |
| 37 | MockMvc test per User Story 1 acceptance scenario (6 scenarios → 6 test cases) |
| 38 | Unit tests for each of the 8 validation steps using stub adapters (positive + negative path) |
| 39 | MockMvc tests for list endpoints: pagination, filtering by region/date, mutuality scoping enforcement |
| 40 | Angular unit tests: `PaymentFormComponent` validation, `AuthGuard` / `RoleGuard` activation |

---

## Complexity Tracking

No constitution violations. No non-standard complexity.
