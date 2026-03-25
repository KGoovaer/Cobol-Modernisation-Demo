<!--
Sync Impact Report — Constitution v1.0.0
========================================
Version change: template (unversioned) → 1.0.0
Version bump type: MINOR (initial population; all content is new)

Added sections:
  - I. Validation-First Processing
  - II. SEPA Compliance
  - III. Complete Audit Trail
  - IV. Regional Accounting Separation
  - V. Duplicate Prevention
  - Data Integrity Standards
  - Development Workflow & Quality Gates
  - Governance

Modified principles: none (first population from template)
Removed sections: none

Templates requiring updates:
  ✅ .specify/templates/plan-template.md  — Constitution Check gate syntax is generic; no update needed
  ✅ .specify/templates/spec-template.md  — No principle-specific references; no update needed
  ✅ .specify/templates/tasks-template.md — No principle-specific references; no update needed
  ✅ migration/plan.md                    — Constitution Check table already validated against these principles

Follow-up TODOs: none. All placeholders resolved.
-->

# MYFIN – Manual Payment Processing Portal Constitution

## Core Principles

### I. Validation-First Processing

Every payment submission MUST pass an eight-step validation pipeline that is strictly ordered and fail-fast.
Steps 1–7 MUST all succeed before any `PaymentRecord` is persisted or any downstream bank instruction is issued.
A single validation failure MUST immediately return a bilingual rejection diagnostic (`RejectionRecord`) and halt
further pipeline execution — no subsequent validation steps run after a failure.
The pipeline execution order is non-negotiable and mirrors the FR-001 → FR-003 → FR-002 → FR-004 → FR-005
validation hierarchy defined in the functional requirements.

**Rationale**: The COBOL predecessor enforced a fixed check order to avoid costly external calls on already-invalid
input and to preserve a deterministic audit trail. The web portal MUST retain these semantics.

### II. SEPA Compliance

IBAN validation (step 5) MUST run before any `PaymentRecord` is persisted or any BIC is extracted.
If the IBAN validation service is unavailable, the system MUST fail-closed: the payment MUST be rejected, not
silently accepted (FR-019).
Regional payments (accounting types 3–6) MUST be routed exclusively to Belfius regardless of the supplied IBAN.
A failed IBAN step MUST produce no `PaymentRecord` — only a `RejectionRecord` with the bilingual diagnostic
"IBAN FOUTIEF / IBAN ERRONE".

**Rationale**: SEPA compliance is a regulatory obligation. An invalid or unverified IBAN that results in a payment
record creates an irrecoverable audit anomaly. Fail-closed behaviour on service outage is mandatory.

### III. Complete Audit Trail

Every `PaymentRequest` received by the system MUST yield exactly one outcome record: either a `PaymentRecord`
(ACCEPTED) or a `RejectionRecord` (REJECTED). No request may be silently discarded (SC-002).
A `BankAccountDiscrepancy` record MUST be created whenever the submitted IBAN differs from the member's known
bank account, regardless of whether the payment is ultimately accepted or rejected.
Outcome records MUST be immutable once written; corrections require a new request, not record mutation.

**Rationale**: The system replaces a mainframe batch process subject to Belgian mutuality and financial regulation.
Regulators and internal audit teams MUST be able to trace every submitted payment to a deterministic outcome.

### IV. Regional Accounting Separation

After all validation steps pass, `RegionalTagStep` (step 8) MUST assign a `regional_tag` and `bank_routing`
derived from the payment's `accounting_type`.
Accounting types 3–6 MUST be forced to Belfius routing; types 1–2 use the IBAN-derived BIC.
All payment and rejection list API endpoints MUST support filtering by `regional_tag`.
JPA entities and the database schema MUST include `regional_tag` as a non-nullable indexed column on
`PaymentRecord` and `RejectionRecord`.

**Rationale**: Belgian mutuality accountancy separates General, Flemish, Walloon, Brussels, and German-speaking
accounting streams. Mixing regional records in queries or reports is a compliance error.

### V. Duplicate Prevention

`DuplicateDetectionStep` (step 4) MUST query `PaymentHistoryPort` before any `PaymentRecord` or bank instruction
is created.
A payment is a duplicate when the combination of `(member_rnr, constant_id, amount)` already exists in the
history for the current processing period.
Detected duplicates MUST produce a `RejectionRecord` with the bilingual diagnostic
"DUBBELE BETALING / DOUBLE PAIEMENT" (FR-002) and MUST halt further pipeline execution.
The duplicate check MUST run before IBAN validation to avoid issuing external IBAN lookups for known-duplicate
input.

**Rationale**: The COBOL predecessor explicitly detected duplicate payments before costly external calls. In a
web portal where the same administrator may inadvertently re-submit the same form, duplicate suppression protects
against double payments of regulated member benefits.

## Data Integrity Standards

- COBOL copybook field widths (`BFN51GZR`, `BFN54GZR`, `SEPAAUKU`, `TRBFNCXP`, etc.) MUST inform JPA entity
  column definitions (`@Column(length=...)`) and validation annotations (`@Size`). No field MUST exceed its
  legacy counterpart's width.
- Bilingual diagnostic messages (Dutch / French) MUST be stored verbatim in varchar columns and serialised
  without transformation in DTO responses.
- All Flyway migrations MUST be written as PostgreSQL-compatible SQL from day 0. H2 compatibility mode
  (`MODE=PostgreSQL`) is permitted in the `dev` profile only and MUST NOT mask PostgreSQL-incompatible DDL.
- Passwords MUST be hashed with BCrypt strength 10. Password hashes MUST NOT appear in DTO responses, log
  output, or any serialised representation.
- The `XSRF-TOKEN` cookie MUST be issued as `HttpOnly=false` to allow Angular to read and forward it as the
  `X-XSRF-TOKEN` request header; session cookies MUST remain `HttpOnly=true`.

## Development Workflow & Quality Gates

- **Phase gates**: Each implementation phase MUST produce a documented working checkpoint (as defined in
  `migration/tasks.md`) before the next phase begins.
- **API contract primacy**: `migration/contracts/*.md` (auth-api.md, payments-api.md, admin-api.md) are the
  single source of truth for endpoint signatures, payloads, and status codes. Implementations MUST NOT deviate
  from contracts without a prior contract amendment committed to the repository.
- **Adapter isolation**: Stub adapter implementations MUST be scoped to `@Profile("stub")` and MUST NOT be
  referenced directly by domain services. Domain services MUST depend on port interfaces only.
- **Scope discipline**: Backend changes MUST be scoped to `migration/backend/src/main` unless build or
  configuration files explicitly require broader changes. Frontend changes MUST be scoped to
  `migration/frontend/src` unless Angular workspace configuration requires otherwise.
- **Test coverage**: Each pull request introducing a new API endpoint MUST include at minimum one MockMvc or
  integration test covering the happy path and one primary rejection scenario.
- **Performance gates**: The payment validation endpoint MUST respond within 5 s (SC-001). List retrieval
  endpoints MUST respond within 3 s for historical search scopes (SC-004). Gates MUST be verified in integration
  test suites before merging.

## Governance

This constitution supersedes all other conventions and guidelines in scope for the MYFIN Manual Payment Processing
Portal. In cases of conflict, this document takes precedence.

**Amendment procedure**:

1. Identify the principle(s) affected and document the change rationale.
2. Increment `CONSTITUTION_VERSION` following semantic versioning:
   - **MAJOR**: removal or incompatible redefinition of an existing principle.
   - **MINOR**: addition of a new principle or section.
   - **PATCH**: wording clarification, typo fix, or non-semantic refinement.
3. Update `LAST_AMENDED_DATE` to today (ISO 8601: YYYY-MM-DD).
4. Update the "Constitution Check" table in `migration/plan.md` to reflect the amended principle(s).
5. Commit using the message format: `docs: amend constitution to vX.Y.Z (<summary>)`.

**Compliance review**: All pull requests modifying `migration/plan.md`, `migration/contracts/`, or any agent
definition that touches a constitutional principle MUST re-validate the Constitution Check gate before merge.
The reviewing author is responsible for confirming compliance.

**Version**: 1.0.0 | **Ratified**: 2026-03-25 | **Last Amended**: 2026-03-25
