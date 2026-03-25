# Tasks: MYFIN Web Application – Manual Payment Processing Portal

**Input**: Design documents from `/specs/001-spring-angular-app/`  
**Generated**: 2026-03-23  
**Spec**: spec.md (FR-001–FR-021, US1–US4) | **Plan**: plan.md (5 phases) | **Data model**: data-model.md | **Contracts**: auth-api.md, payments-api.md, admin-api.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel with other [P] tasks in the same phase (different files, no unresolved dependencies)
- **[US#]**: User story this task belongs to (US1=P1 Submit & Validate, US2=P2 Review Lists, US3=P3 Export, US4=P4 Audit)
- All paths are relative to `specs/001-spring-angular-app/`

---

## Phase 1: Setup — Scaffolding

**Purpose**: Initialize both sub-projects and establish shared infrastructure. No user story label — these are prerequisites for everything.

- [ ] T001 Initialize Spring Boot 3 Maven project with Java 21 and all required dependencies (spring-boot-starter-web, spring-security, spring-data-jpa, spring-boot-starter-validation, flyway-core, h2, postgresql driver) in `backend/pom.xml`
- [ ] T002 Create `backend/src/main/resources/application.yml` (base: server port 8080, Flyway enabled), `application-dev.yml` (H2 in-memory `jdbc:h2:mem:MYFIN;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE`), and `application-stub.yml` (activates `stub` Spring profile for adapter beans)
- [ ] T003 [P] Scaffold Angular 19 project using Angular CLI (`ng new MYFIN-frontend --routing --style=scss`) and add Angular Material with a default theme in `frontend/`
- [ ] T004 [P] Implement `WebMvcConfig` (Spring `@Configuration`, CORS `allowedOrigins("http://localhost:4200")` for Angular dev server) in `backend/src/main/java/be/betfin/MYFIN/config/WebMvcConfig.java`
- [ ] T005 [P] Implement `HttpXsrfInterceptor` (reads `XSRF-TOKEN` cookie, attaches value as `X-XSRF-TOKEN` request header on all state-changing requests) in `frontend/src/app/core/http-xsrf.interceptor.ts`
- [ ] T006 [P] Implement `ApiService` base class wrapping `HttpClient` with typed `get`/`post`/`patch` helpers and `withCredentials: true` in `frontend/src/app/core/api.service.ts`
- [ ] T007 [P] Create lazy-loaded Angular route stubs for `/payment`, `/lists`, and `/admin` modules (empty route modules plus placeholder components) in `frontend/src/app/`

**Checkpoint**: Both projects compile; Angular dev server loads at `localhost:4200`; Spring Boot starts at `localhost:8080`

---

## Phase 2: Foundation — Authentication & Security

**Purpose**: Running authentication with JWT-free session cookies, BCrypt password storage, CSRF protection, and role-based routing guards. **⚠️ CRITICAL**: All user story phases depend on this being complete.

- [ ] T008 Create Flyway migration `V1__create_users.sql` — `users` table (UUID PK, username UNIQUE VARCHAR(100), password_hash VARCHAR(72), role CHECK IN ('SUBMITTER','READ_ONLY','ADMIN'), active BOOLEAN, created_at TIMESTAMP) and `user_mutuality_codes` table (composite PK user_id + mutuality_code SMALLINT CHECK 101–169) using PostgreSQL-compatible SQL in `backend/src/main/resources/db/migration/V1__create_users.sql`
- [ ] T009 [P] Implement `Role` enum (`SUBMITTER`, `READ_ONLY`, `ADMIN`) in `backend/src/main/java/be/betfin/MYFIN/auth/Role.java`
- [ ] T010 Implement `User` JPA entity (`@Entity @Table(name="users")`, implements `UserDetails`, UUID `@Id @GeneratedValue`, `@Enumerated(STRING) Role`, `@ElementCollection Set<Integer> mutualityCodes`, `active`, `createdAt @CreationTimestamp`; never expose `passwordHash` in toString/serialisation) in `backend/src/main/java/be/betfin/MYFIN/auth/User.java`
- [ ] T011 Implement `UserRepository` (`JpaRepository<User, UUID>` with `Optional<User> findByUsername(String)`) in `backend/src/main/java/be/betfin/MYFIN/auth/UserRepository.java`
- [ ] T012 Implement `UserDetailsServiceImpl` loading `User` from `UserRepository` by username; throw `UsernameNotFoundException` for unknown users; delegate `active` flag to `isEnabled()` in `backend/src/main/java/be/betfin/MYFIN/auth/UserDetailsServiceImpl.java`
- [ ] T013 Implement `SecurityConfig` (`@Configuration @EnableWebSecurity @EnableMethodSecurity`): form login success handler returning `UserDto` JSON (not redirect), `CookieCsrfTokenRepository.withHttpOnlyFalse()`, `BCryptPasswordEncoder(10)`, `requestMatchers` per the Role–Endpoint Matrix in `data-model.md` (e.g. `/api/admin/**` → ADMIN only, `/api/payments` POST → SUBMITTER only) in `backend/src/main/java/be/betfin/MYFIN/config/SecurityConfig.java`
- [ ] T014 [P] Create `UserDto` record (id, username, role, active, mutualityCodes, createdAt — **no** `passwordHash` field) in `backend/src/main/java/be/betfin/MYFIN/auth/UserDto.java`
- [ ] T015 Implement `AuthController` (`POST /api/auth/login` handled by Spring Security; `POST /api/auth/logout` → session invalidate + clear cookies; `GET /api/auth/me` → return authenticated `UserDto` or 401) in `backend/src/main/java/be/betfin/MYFIN/auth/AuthController.java`
- [ ] T016 Implement `GlobalExceptionHandler` skeleton (`@RestControllerAdvice`): `AccessDeniedException` → 403; `MethodArgumentNotValidException` → 400 with `ValidationErrorDto` field map; `NoSuchElementException` → 404 — to be extended in later phases in `backend/src/main/java/be/betfin/MYFIN/exception/GlobalExceptionHandler.java`
- [ ] T017 Implement Angular `AuthService` (RxJS `BehaviorSubject<UserDto|null>` for `currentUser$`; `login(username, password)` → POST `application/x-www-form-urlencoded`; `logout()`; `me()` on app init; `hasRole(role)` helper) in `frontend/src/app/auth/auth.service.ts`
- [ ] T018 [P] Implement `AuthGuard` (redirect to `/login` if `currentUser$` is null) and `RoleGuard` (return 403 view if role not in `allowedRoles` route data) in `frontend/src/app/auth/auth.guard.ts` and `frontend/src/app/auth/role.guard.ts`
- [ ] T019 Implement `LoginComponent` (reactive form with `username` + `password` fields, submits via `AuthService.login()`, displays 401 error message "Invalid credentials" or "Account is disabled", navigates to `/payment` on success) in `frontend/src/app/auth/login/`
- [ ] T020 Implement `ShellComponent` (top nav bar with role-conditional links: "Submit Payment" [SUBMITTER], "Payment List" [SUBMITTER, READ_ONLY], "Rejection List" [SUBMITTER, READ_ONLY], "Admin" [ADMIN], "Logout" [all]; `<router-outlet>` in body) in `frontend/src/app/core/shell/`
- [ ] T021 Add HTTP 401 interceptor to `ApiService` that calls `AuthService.logout()` and redirects to `/login` when any API response returns 401 in `frontend/src/app/core/api.service.ts`

**Checkpoint**: Login at `/login` works; session cookie set; `GET /api/auth/me` returns `UserDto`; protected shell routes redirect to `/login`; wrong-role routes return 403 view

---

## Phase 3: User Story 1 — Submit and Validate a Manual Payment (Priority: P1) 🎯 MVP

**Goal**: A Submitter can submit a payment form and immediately receive an acceptance confirmation or a bilingual rejection diagnostic. The full 8-step validation pipeline runs against stub adapters covering all spec.md US1 acceptance scenarios.

**Independent Test**: POST `/api/payments` with: (1) valid Belgian IBAN + known member → 200 ACCEPTED; (2) unknown member RNR → 200 REJECTED "LIDNR ONBEKEND / AFFILIE INCONNU"; (3) duplicate constantId+amount → REJECTED "DUBBELE BETALING / DOUBLE PAIEMENT"; (4) invalid IBAN → REJECTED "IBAN FOUTIEF / IBAN ERRONE"; (5) unknown desc code → REJECTED "CODE OMSCHR ONBEK / CODE LIBEL INCON"; (6) unresolvable language → REJECTED "TAALCODE ONBEK / CODE LING INCON". All 6 scenarios testable without Phase 4–7.

### Backend — Database & Domain Entities

- [ ] T022 Create Flyway migration `V2__create_payment_tables.sql` — all five domain tables (`payment_requests`, `payment_records`, `rejection_records`, `bank_account_discrepancies`, `payment_descriptions`) with all constraints per `data-model.md` (CHECK constraints, FK references, currency/method/status enum checks) using PostgreSQL-compatible SQL in `backend/src/main/resources/db/migration/V2__create_payment_tables.sql`
- [ ] T023 Create Flyway migration `V3__seed_payment_descriptions.sql` — `INSERT` statements for codes 1–89 into `payment_descriptions` (descriptionNl, descriptionFr, descriptionDe columns) in `backend/src/main/resources/db/migration/V3__seed_payment_descriptions.sql`
- [ ] T024 [P] [US1] Implement `PaymentRequest` JPA entity (all fields per `data-model.md`: `memberRnr`, `destinationMutuality`, `constantId`, `sequenceNo`, `amountCents`, `currency`, `paymentDescCode`, `iban`, `paymentMethod`, `accountingType`, `@ManyToOne User submittedBy`, `PaymentStatus status` enum ACCEPTED/REJECTED) in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentRequest.java`
- [ ] T025 [P] [US1] Implement `PaymentRecord` JPA entity (`memberName`, `memberRnr`, `amountCents`, `iban`, `bic`, `bankRouting` CHECK BELFIUS/KBC, `regionalTag` CHECK 1/2/4/7/9, `accountingType`, `destinationMutuality`, `paymentDescNl`, `paymentDescFr`, `createdAt`, `@OneToOne PaymentRequest`) in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentRecord.java`
- [ ] T026 [P] [US1] Implement `RejectionRecord` JPA entity (`diagnosticNl VARCHAR(32)`, `diagnosticFr VARCHAR(32)`, `createdAt`, `@OneToOne PaymentRequest`) in `backend/src/main/java/be/betfin/MYFIN/payment/RejectionRecord.java`
- [ ] T027 [P] [US1] Implement `BankAccountDiscrepancy` JPA entity (`providedIban VARCHAR(34)`, `knownIban VARCHAR(34)`, `createdAt`, `@OneToOne PaymentRequest`) in `backend/src/main/java/be/betfin/MYFIN/payment/BankAccountDiscrepancy.java`
- [ ] T028 [P] [US1] Implement `PaymentDescription` JPA entity (`code SMALLINT @Id`, `descriptionNl`, `descriptionFr`, `descriptionDe`) and `PaymentDescriptionRepository` (`JpaRepository<PaymentDescription, Integer>`) in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentDescription.java`

### Backend — Port Interfaces

- [ ] T029 [P] [US1] Define `MemberPort` interface (`findByRnr(long) throws MemberNotFoundException`, `getPaymentDescription(int code, long memberRnr) throws PaymentDescriptionNotFoundException`, `getAddress(long memberRnr)`) in `backend/src/main/java/be/betfin/MYFIN/adapter/MemberPort.java`
- [ ] T030 [P] [US1] Define `IBANValidationPort` interface (`validate(String iban) throws IBANServiceUnavailableException` — returns `IbanResult` with `bic` on success, `valid=false` on invalid) in `backend/src/main/java/be/betfin/MYFIN/adapter/IBANValidationPort.java`
- [ ] T031 [P] [US1] Define `MemberAccountPort` interface (`getKnownIban(long memberRnr) throws MemberNotFoundException` — returns IBAN string or empty if no account on file) in `backend/src/main/java/be/betfin/MYFIN/adapter/MemberAccountPort.java`
- [ ] T032 [P] [US1] Define `PaymentHistoryPort` interface (`isDuplicate(long memberRnr, String constantId, long amountCents) throws PaymentHistoryUnavailableException`) in `backend/src/main/java/be/betfin/MYFIN/adapter/PaymentHistoryPort.java`

### Backend — Stub Adapters (`@Profile("stub")`)

- [ ] T033 [US1] Implement `StubMemberPort` (`@Component @Profile("stub")`): RNR `12345678901` → canned `MemberDto` with `adminLanguage=2` (NL), active insurance section, product code 100; RNR `10000000106` → bilingual mutuality 106 with `adminLanguage=0` and no section language (triggers language failure); unknown RNR → `MemberNotFoundException` in `backend/src/main/java/be/betfin/MYFIN/adapter/stub/StubMemberPort.java`
- [ ] T034 [P] [US1] Implement `StubIBANValidationPort` (`@Component @Profile("stub")`): IBANs matching `^BE\d{14}$` → valid, BIC `"GKCCBEBB"`; IBAN `"BE99000000000000"` → throws `IBANServiceUnavailableException`; all others → invalid (no BIC) in `backend/src/main/java/be/betfin/MYFIN/adapter/stub/StubIBANValidationPort.java`
- [ ] T035 [P] [US1] Implement `StubMemberAccountPort` (`@Component @Profile("stub")`): IBAN `"BE00000000000000"` → returns `"BE68539007547034"` (triggers discrepancy); all other IBANs → returns the submitted IBAN (no discrepancy) in `backend/src/main/java/be/betfin/MYFIN/adapter/stub/StubMemberAccountPort.java`
- [ ] T036 [P] [US1] Implement `StubPaymentHistoryPort` (`@Component @Profile("stub")`): `constantId="DUP0000001"` + `amountCents=99999` + any memberRnr → `isDuplicate=true`; all other combinations → `isDuplicate=false` in `backend/src/main/java/be/betfin/MYFIN/adapter/stub/StubPaymentHistoryPort.java`

### Backend — Validation Pipeline

- [ ] T037 [US1] Define validation pipeline contracts: `ValidationStep` interface (`void execute(ValidationContext ctx) throws ValidationException`), `ValidationContext` (mutable: `memberDto`, `languageCode`, `paymentDescNl`, `paymentDescFr`, `ibanValid`, `bic`, `memberAddress`, `bankRoutingDiscrepancy`, `regionalTag`, `bankRouting`), `ValidationResult`, and `ValidationException` (carries `diagnosticNl` + `diagnosticFr`) in `backend/src/main/java/be/betfin/MYFIN/validation/`
- [ ] T038 [US1] Implement `MemberValidationStep` (step 1): call `MemberPort.findByRnr(memberRnr)`; assert at least one active or closed insurance section; assert no insurance section has excluded product code (609, 659, 679, 689); sets `ctx.memberDto`; failure → `ValidationException("LIDNR ONBEKEND", "AFFILIE INCONNU")` in `backend/src/main/java/be/betfin/MYFIN/validation/MemberValidationStep.java`
- [ ] T039 [P] [US1] Implement `LanguageResolutionStep` (step 2): read `memberDto.adminLanguage`; if 0 fall back to first insurance section language; bilingual mutuality codes 106/107/150/166 require explicit preference (non-zero); valid codes 1=FR, 2=NL, 3=DE; sets `ctx.languageCode`; failure → `ValidationException("TAALCODE ONBEK", "CODE LING INCON")` in `backend/src/main/java/be/betfin/MYFIN/validation/LanguageResolutionStep.java`
- [ ] T040 [P] [US1] Implement `PaymentDescriptionStep` (step 3): codes 1–89 → `PaymentDescriptionRepository.findById(code)`; codes 90–99 → `MemberPort.getPaymentDescription(code, memberRnr)`; sets `ctx.paymentDescNl` and `ctx.paymentDescFr`; code not found → `ValidationException("CODE OMSCHR ONBEK", "CODE LIBEL INCON")` in `backend/src/main/java/be/betfin/MYFIN/validation/PaymentDescriptionStep.java`
- [ ] T041 [P] [US1] Implement `DuplicateDetectionStep` (step 4): call `PaymentHistoryPort.isDuplicate(memberRnr, constantId, amountCents)`; if `true` → `ValidationException("DUBBELE BETALING", "DOUBLE PAIEMENT")` in `backend/src/main/java/be/betfin/MYFIN/validation/DuplicateDetectionStep.java`
- [ ] T042 [P] [US1] Implement `IBANValidationStep` (step 5): call `IBANValidationPort.validate(iban)`; `IBANServiceUnavailableException` → fail-closed `ValidationException("IBAN validation service unavailable, please retry", "IBAN validation service unavailable, please retry")` per FR-019; invalid result → `ValidationException("IBAN FOUTIEF", "IBAN ERRONE")`; success → sets `ctx.bic` in `backend/src/main/java/be/betfin/MYFIN/validation/IBANValidationStep.java`
- [ ] T043 [P] [US1] Implement `CircularChequeStep` (step 6): if `paymentMethod == ' '` → skip (SEPA transfer, no-op); for methods C/D/E/F call `MemberPort.getAddress(memberRnr)` and verify `countryCode == "BE"`; non-Belgian address → `ValidationException` with step-specific message in `backend/src/main/java/be/betfin/MYFIN/validation/CircularChequeStep.java`
- [ ] T044 [US1] Implement `AccountDiscrepancyStep` (step 7 — **non-blocking**): call `MemberAccountPort.getKnownIban(memberRnr)`; if returned IBAN differs from `request.iban` → save `BankAccountDiscrepancy` via its repository; **never throw** — processing continues regardless; sets `ctx.bankRoutingDiscrepancy=true` if discrepancy recorded in `backend/src/main/java/be/betfin/MYFIN/validation/AccountDiscrepancyStep.java`
- [ ] T045 [P] [US1] Implement `RegionalTagStep` (step 8 — pure mapping, no external call): `accountingType → regionalTag`: 1→9, 3→1, 4→2, 5→4, 6→7; `accountingType` in {3,4,5,6} → `bankRouting=BELFIUS`; else `bankRouting=KBC`; sets `ctx.regionalTag` and `ctx.bankRouting` in `backend/src/main/java/be/betfin/MYFIN/validation/RegionalTagStep.java`
- [ ] T046 [US1] Implement `PaymentValidationService` (step orchestrator `@Service`): inject all 8 steps as ordered `List<ValidationStep>` via `@Autowired`; execute steps 1–8 sequentially (step 7 is non-blocking — catch its internal exception and continue); on `ValidationException` → persist `PaymentRequest(status=REJECTED)` + `RejectionRecord` and return REJECTED result; on success → persist `PaymentRequest(status=ACCEPTED)` + `PaymentRecord` and return ACCEPTED result in `backend/src/main/java/be/betfin/MYFIN/validation/PaymentValidationService.java`
- [ ] T047 [US1] Implement `POST /api/payments` in `PaymentController`: accept `@Valid @RequestBody PaymentRequestDto`; enforce mutuality scoping via `@PreAuthorize("@mutalityScopeGuard.canSubmit(authentication, #dto.destinationMutuality)")` (FR-020 — reject with 403 if `destinationMutuality` not in authenticated user's assigned codes); delegate to `PaymentValidationService`; return `PaymentResultDto(status, diagnosticNl, diagnosticFr, recordId=paymentRequest.id)` in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentController.java`
- [ ] T048 [US1] Extend `GlobalExceptionHandler`: map `IBANServiceUnavailableException` → return HTTP 200 with REJECTED `PaymentResultDto` (fail-closed, per FR-019); map `MutualityScopeViolationException` → 403; ensure no `PaymentRecord` or bank instruction is created on any exception path in `backend/src/main/java/be/betfin/MYFIN/exception/GlobalExceptionHandler.java`

### Frontend — Payment Submission

- [ ] T049 [P] [US1] Implement `PaymentFormComponent` (Angular `ReactiveFormsModule`): 10 control fields with validators matching `contracts/payments-api.md` — `memberRnr` (required, positive integer), `destinationMutuality` (101–169), `constantId` (required, max 10 chars), `sequenceNo` (optional, max 4 chars), `amountCents` (required, positive), `currency` (pattern `[EB]`), `paymentDescCode` (1–99), `iban` (required, max 34 chars), `paymentMethod` (pattern `[ CDEF]`), `accountingType` (enum 1/3/4/5/6); show inline field-level error messages; `destinationMutuality` selector pre-filtered to authenticated user's `mutualityCodes` in `frontend/src/app/payment/payment-form/`
- [ ] T050 [P] [US1] Implement `ValidationResultComponent` (Input: `PaymentResultDto`): ACCEPTED → green success alert with checkmark and `recordId`; REJECTED → amber/red alert with bilingual message displayed as "NL: {diagnosticNl} / FR: {diagnosticFr}" side-by-side; resets form on "Submit another" link in `frontend/src/app/payment/validation-result/`
- [ ] T051 [US1] Wire `PaymentFormComponent` to `PaymentApiService.submit(dto)` (POST `/api/payments`): on submit, show loading spinner; on `PaymentResultDto` response, render `ValidationResultComponent` inline below the form; on HTTP 403 show "You are not authorised to submit payments for mutuality {code}" in `frontend/src/app/payment/`

**Checkpoint**: All 6 US1 acceptance scenarios from `spec.md` verifiable via form + backend; stub adapters deterministically produce each rejection; IBAN service outage path returns fail-closed message; mutuality 403 is enforced

---

## Phase 4: User Story 2 — Review Payment and Rejection Lists (Priority: P2)

**Goal**: Submitter and Read-Only users can view paginated, filterable payment, rejection, and discrepancy lists scoped to their assigned mutuality codes.

**Independent Test**: Load a set of processed payments → verify payment detail list shows accepted payments; load rejections → verify bilingual diagnostic column; filter by `accountingType=3` → only Flemish payments shown; cross-mutuality access attempt → 403.

### Backend — List Endpoints

- [ ] T052 [US2] Implement `GET /api/payments` in `PaymentController`: `Page<PaymentRecordDto>` with query params `accountingType`, `dateFrom` (ISO date), `dateTo`, `mutualityCode` (intersected with authenticated user's assigned codes), `page`, `size` (max 100), `sort` (default `createdAt,desc`); apply `PaymentRecordSpecification` for filters in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentController.java`
- [ ] T053 [P] [US2] Implement `GET /api/payments/{id}` in `PaymentController`: return `PaymentRecordDto` for the given UUID; 403 if `destinationMutuality` not in user's assigned codes; 404 if not found in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentController.java`
- [ ] T054 [P] [US2] Implement `RejectionController` (`GET /api/rejections` paginated with same mutuality-scoped filters + bilingual `diagnosticNl`/`diagnosticFr` in response; `GET /api/rejections/{id}` single record; ADMIN → 403) in `backend/src/main/java/be/betfin/MYFIN/payment/RejectionController.java`
- [ ] T055 [P] [US2] Implement `DiscrepancyController` (`GET /api/discrepancies` paginated, mutuality-scoped via `paymentRequest.destinationMutuality`, returning `providedIban` and `knownIban`; ADMIN → 403) in `backend/src/main/java/be/betfin/MYFIN/payment/DiscrepancyController.java`
- [ ] T056 [P] [US2] Implement Spring Data JPA `Specification` classes for `PaymentRecord` (filter by `accountingType`, `createdAt` date range, `destinationMutuality` IN user-codes set) and `RejectionRecord` (same filter set applied via `paymentRequest` join) in `backend/src/main/java/be/betfin/MYFIN/payment/`

### Frontend — List Views

- [ ] T057 [US2] Implement `PaymentListComponent`: `MatTable` + `MatPaginator` + `MatSort`; filter controls (accounting-type dropdown using Angular Material `MatSelect`, date-range pickers, mutuality-code multi-select limited to user's assigned codes); calls `GET /api/payments` on init and on filter change; displays `bankRouting`, `regionalTag`, bilingual `paymentDescNl`/`paymentDescFr` columns in `frontend/src/app/lists/payment-list/`
- [ ] T058 [P] [US2] Implement `RejectionListComponent`: `MatTable` + `MatPaginator`; bilingual diagnostic column rendered as "NL: … | FR: …"; calls `GET /api/rejections`; filterable by accountingType and mutualityCode in `frontend/src/app/lists/rejection-list/`
- [ ] T059 [P] [US2] Implement `DiscrepancyListComponent`: `MatTable` + `MatPaginator`; columns showing `providedIban`, `knownIban`, member RNR, `submittedAt`; calls `GET /api/discrepancies` in `frontend/src/app/lists/discrepancy-list/`

**Checkpoint**: Accepted payments appear in payment list; rejected payments appear in rejection list with bilingual messages; region filter returns only matching records; 403 on cross-mutuality attempt

---

## Phase 5: User Story 3 — Export Payment Data (Priority: P3)

**Goal**: Submitter and Read-Only users can download accepted payment records as a CSV file with the same filter parameters as the list view.

**Independent Test**: Apply `accountingType=1` (standard) filter on payment list → click "Export CSV" → browser downloads a `.csv` file whose rows match the on-screen records.

- [ ] T060 [US3] Implement `GET /api/payments/export/csv` in `PaymentController` using `StreamingResponseBody`: applies same filter params as `GET /api/payments` (minus `page`/`size`/`sort`), restricts to `accountingType=1` standard payments, mutuality-scoped; response `Content-Type: text/csv`, `Content-Disposition: attachment; filename="payments-export-{yyyyMMdd}.csv"`; CSV columns per `contracts/payments-api.md` in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentController.java`
- [ ] T061 [US3] Add "Export CSV" button to `PaymentListComponent` that triggers a browser download by calling `/api/payments/export/csv` with current filter state as query params (use `window.open` or a hidden `<a>` with `href`); visible to SUBMITTER and READ_ONLY only in `frontend/src/app/lists/payment-list/`

**Checkpoint**: CSV download contains records matching the active filter; no export for ADMIN role (403); CSV column order matches `contracts/payments-api.md`

---

## Phase 6: User Story 4 — Audit Payment Processing History (Priority: P4)

**Goal**: Auditors can search for any payment (accepted or rejected) by constant identifier or sequence number and retrieve the full processing result record.

**Independent Test**: POST a payment with `constantId="AUDIT00001"`, then `GET /api/payments/search?constantId=AUDIT00001` → returns the payment request with `status`, `submittedAt`, and linked `recordId`.

- [ ] T062 [US4] Implement `GET /api/payments/search` endpoint in `PaymentController`: at least one query param (`constantId` or `sequenceNo`) required (400 if both absent); exact match against `payment_requests`; returns `List<PaymentSearchResultDto>` including `requestId`, `memberRnr`, `constantId`, `sequenceNo`, `amountCents`, `status`, `submittedAt`, `recordId`; mutuality-scoped (intersect user's assigned codes); ADMIN → 403 in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentController.java`
- [ ] T063 [P] [US4] Add `PaymentRequestRepository` Spring Data query method `findByConstantIdOrSequenceNoWithinMutalityCodes(String constantId, String sequenceNo, Set<Integer> codes)` using `@Query` with `IN` clause in `backend/src/main/java/be/betfin/MYFIN/payment/PaymentRequestRepository.java`
- [ ] T064 [P] [US4] Add search panel to `PaymentListComponent` (two text inputs: "Constant ID" and "Sequence No"; "Search" button calling `GET /api/payments/search`; results rendered in a separate `MatTable` below the main list with status chip — green ACCEPTED / red REJECTED) in `frontend/src/app/lists/payment-list/`

**Checkpoint**: Search by `constantId` returns matching payment with status; search with no params returns 400; cross-mutuality search results are filtered out (403 or empty)

---

## Phase 7: Admin — User Management (Cross-Cutting)

**Purpose**: Admin role can create, deactivate, and reset passwords for user accounts via the in-application UI (FR-017, FR-018). No user story label — this is a cross-cutting operational capability.

- [ ] T065 Implement `UserAdminService` (`@Service`): `createUser` (encode password with `BCryptPasswordEncoder`, validate `mutualityCodes` is empty for ADMIN role; throw `UserAlreadyExistsException` on duplicate username); `deactivateUser` (check at least one other active ADMIN remains — throw `LastAdminException` if not; set `active=false`); `resetPassword` (re-hash `newPassword`, update `passwordHash`) in `backend/src/main/java/be/betfin/MYFIN/admin/UserAdminService.java`
- [ ] T066 [P] Implement `UserAdminController` (`@RestController @RequestMapping("/api/admin") @PreAuthorize("hasRole('ADMIN')")`): `GET /api/admin/users` → list all; `POST /api/admin/users` → `@Valid CreateUserDto`; `PATCH /api/admin/users/{id}/deactivate` → 200 with updated `UserDto` or 400 if last ADMIN; `POST /api/admin/users/{id}/reset-password` → `@Valid ResetPasswordDto`; all returning `UserDto` (no password_hash) in `backend/src/main/java/be/betfin/MYFIN/admin/UserAdminController.java`
- [ ] T067 [P] Extend `GlobalExceptionHandler`: `UserAlreadyExistsException` → 409 `{"error": "Username already exists"}`; `LastAdminException` → 400 `{"error": "Cannot deactivate the last active ADMIN"}` in `backend/src/main/java/be/betfin/MYFIN/exception/GlobalExceptionHandler.java`
- [ ] T068 Implement `UserManagementComponent` (Admin-only; `MatTable` listing users with columns: username, role, active toggle, mutualityCodes, createdAt; "Create User" button opens `MatDialog` with form (username, password, role, mutualityCodes multi-select); "Deactivate" button per row; "Reset Password" button per row opening password dialog; all calls via `/api/admin/*`) in `frontend/src/app/admin/user-management/`

**Checkpoint**: Admin can create a Submitter account with `mutualityCodes=[101]`; deactivate it; reset its password; attempt to deactivate last Admin → 400 with correct error message; Submitter and Read-Only see 403 on all `/api/admin/*` calls

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Logging, integration tests covering all acceptance scenarios, and Angular unit tests.

- [ ] T069 Configure application error logging (FR-021): add `logging.file.name=logs/MYFIN.log`, `logging.level.be.betfin=INFO`, `logging.level.root=WARN` in `backend/src/main/resources/application.yml`; add `GlobalExceptionHandler` logging of all unhandled exceptions at ERROR level before returning HTTP 500 in `backend/src/main/java/be/betfin/MYFIN/exception/GlobalExceptionHandler.java`
- [ ] T070 Write `@SpringBootTest` + `MockMvc` integration tests for authentication flow: 401 on unauthenticated request to `/api/payments`; 401 on bad credentials at login; 401 on deactivated user login; 403 for READ_ONLY user attempting `POST /api/payments`; 200 + `UserDto` on valid login in `backend/src/test/java/be/betfin/MYFIN/auth/AuthIntegrationTest.java`
- [ ] T071 [P] Write `MockMvc` integration tests for all 6 US1 acceptance scenarios (spec.md User Story 1): (1) valid payment → 200 ACCEPTED; (2) unknown RNR → 200 REJECTED "LIDNR ONBEKEND / AFFILIE INCONNU"; (3) duplicate → "DUBBELE BETALING / DOUBLE PAIEMENT"; (4) invalid IBAN → "IBAN FOUTIEF / IBAN ERRONE"; (5) unknown desc code → "CODE OMSCHR ONBEK / CODE LIBEL INCON"; (6) unresolvable language → "TAALCODE ONBEK / CODE LING INCON" in `backend/src/test/java/be/betfin/MYFIN/payment/PaymentSubmissionTest.java`
- [ ] T072 [P] Write JUnit 5 unit tests for each of the 8 validation steps individually: positive path (step passes, context populated correctly) + negative path (failure throws `ValidationException` with correct bilingual message); use stub adapter instances directly in `backend/src/test/java/be/betfin/MYFIN/validation/`
- [ ] T073 [P] Write `MockMvc` tests for list endpoints: pagination returns correct page/size; `accountingType=3` filter returns only Flemish records; mutuality scoping — request with `mutualityCode` outside user's assigned codes → 403; `GET /api/payments/search` with no params → 400 in `backend/src/test/java/be/betfin/MYFIN/payment/PaymentListTest.java`
- [ ] T074 [P] Write Angular unit tests for `PaymentFormComponent` (Jest + Angular TestBed): required field validation triggers error state; invalid IBAN format fails pattern validator; valid form submission emits correct DTO; 403 response displays scope error message in `frontend/src/app/payment/payment-form/`
- [ ] T075 [P] Write Angular unit tests for `AuthGuard` and `RoleGuard`: unauthenticated user → redirected to `/login`; SUBMITTER user accessing admin route → 403 view rendered; ADMIN user accessing `/payment` form → 403 view rendered in `frontend/src/app/auth/`

**Checkpoint**: All 6 US1 acceptance scenarios pass automatically; role-based access matrix from `data-model.md` fully enforced; mutuality scoping verified for 403/filter behaviour

---

## Dependency Graph

```
Phase 1 (Setup)
    └── Phase 2 (Foundation — Auth)
            ├── Phase 3 (US1 — Submit & Validate)  ← MVP: deliver this first
            │       └── Phase 4 (US2 — Review Lists)
            │               ├── Phase 5 (US3 — Export CSV)
            │               └── Phase 6 (US4 — Audit Search)
            └── Phase 7 (Admin — User Management)  ← parallel with Phase 3+
Phase 8 (Tests) — runs after all implementation phases
```

**Phase 3 internal dependencies**:
```
T022,T023 (Flyway) → T024–T028 (entities) → T029–T032 (ports)
                                                    └── T033–T036 (stubs)
                                                            └── T037 (pipeline contracts)
                                                                    └── T038–T045 (validation steps)
                                                                            └── T046 (PaymentValidationService)
                                                                                    └── T047 (POST /api/payments)
                                                                                            └── T049–T051 (Angular form)
```

---

## Parallel Execution Examples

### Phase 3 — US1 (backend first, then frontend)

After T037 (pipeline contracts defined):

```
Parallel batch A (can start immediately after T036 stubs complete):
  T038 MemberValidationStep
  T039 LanguageResolutionStep
  T040 PaymentDescriptionStep
  T041 DuplicateDetectionStep
  T042 IBANValidationStep
  T043 CircularChequeStep
  T045 RegionalTagStep
Then sequentially:
  T044 AccountDiscrepancyStep (writes to DB — ensure T027 entity done)
  T046 PaymentValidationService (assembles all steps)
  T047 POST /api/payments controller
  T048 GlobalExceptionHandler extension
Then in parallel (frontend):
  T049 PaymentFormComponent
  T050 ValidationResultComponent
Then sequentially:
  T051 Wire PaymentFormComponent to API
```

### Phase 4 — US2

```
Parallel batch (all backend — different files):
  T052 GET /api/payments list
  T053 GET /api/payments/{id}
  T054 RejectionController
  T055 DiscrepancyController
  T056 JPA Specifications
Then parallel (frontend):
  T057 PaymentListComponent
  T058 RejectionListComponent
  T059 DiscrepancyListComponent
```

---

## Implementation Strategy

**MVP scope — deliver US1 first** (T001–T051, ~51 tasks):  
A running application where a Submitter can log in, submit a payment form, and receive an immediate acceptance or bilingual rejection is fully demonstrable. This covers the core replacement for the COBOL batch entry point.

**Increment 2 — US2** (T052–T059): adds list review capability; finance staff and auditors can reconcile payments.

**Increment 3 — US3/US4** (T060–T064): CSV export and audit search; low-risk add-ons on top of the list infrastructure.

**Increment 4 — Admin** (T065–T068): Admin UI; can be bootstrapped with a seeded admin user for earlier increments.

**Final — Tests** (T069–T075): Run after each increment to automate acceptance scenario verification.

---

## Summary

| Phase | User Story | Tasks | Key Milestones |
|-------|-----------|-------|----------------|
| 1 — Setup | — | T001–T007 (7) | Both projects compile and start |
| 2 — Foundation | — | T008–T021 (14) | Login, CSRF, role guards working |
| 3 — **US1 (P1 MVP)** | Submit & Validate | T022–T051 (30) | All 6 acceptance scenarios pass |
| 4 — US2 (P2) | Review Lists | T052–T059 (8) | Filterable lists with region scoping |
| 5 — US3 (P3) | Export | T060–T061 (2) | CSV download with active filters |
| 6 — US4 (P4) | Audit Search | T062–T064 (3) | Search by constantId/sequenceNo |
| 7 — Admin | User Mgmt | T065–T068 (4) | Create/deactivate/reset users |
| 8 — Polish | Tests | T069–T075 (7) | All acceptance scenarios automated |
| **Total** | | **75 tasks** | |

**Parallel opportunities identified**: 32 tasks marked `[P]`  
**Format validation**: All 75 tasks follow `- [ ] T### [P?] [US#?] Description with file path`  
**Mutuality scoping (FR-020)**: enforced in T047 (`@PreAuthorize`), T052–T056 (Specification filters), T062 (search endpoint), T073 (MockMvc test)
