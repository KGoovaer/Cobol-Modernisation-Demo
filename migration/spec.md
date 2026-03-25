# Feature Specification: MYFIN Web Application – Manual Payment Processing Portal

**Feature Branch**: `001-spring-angular-app`  
**Created**: 2026-03-23  
**Status**: Draft  
**Input**: User description: "i want to create a new application based on the existing /docs - spring boot backend and angular front end"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 – Submit and Validate a Manual Payment (Priority: P1)

A mutuality administrator wants to submit a manual payment request for a member and receive immediate feedback on whether the payment is valid or why it was rejected.

**Why this priority**: This is the core workflow of the system. Without the ability to submit and validate a payment, no other feature delivers value. It directly replaces the COBOL batch processing entry point (GIRBETPP) with an interactive, real-time experience.

**Independent Test**: Can be fully tested by entering a payment request form and verifying that valid payments are accepted and invalid ones are rejected with a clear bilingual diagnostic message, without needing list generation or reporting features.

**Acceptance Scenarios**:

1. **Given** a logged-in mutuality administrator, **When** they submit a payment form with a valid member national registry number, valid IBAN, valid payment description code, and valid amount, **Then** the system confirms the payment is accepted and shows a success confirmation.
2. **Given** a payment form submission with an unknown member national registry number, **When** the administrator submits, **Then** the system rejects the payment and displays the message "LIDNR ONBEKEND / AFFILIE INCONNU" in both Dutch and French.
3. **Given** a payment where the same amount and constant identifier already exist for the member, **When** the administrator submits, **Then** the system rejects it as a duplicate and displays "DUBBELE BETALING / DOUBLE PAIEMENT".
4. **Given** a payment with an invalid IBAN, **When** the administrator submits, **Then** the system rejects it with "IBAN FOUTIEF / IBAN ERRONE".
5. **Given** a payment with an unrecognized payment description code, **When** the administrator submits, **Then** the system rejects it with "CODE OMSCHR ONBEK / CODE LIBEL INCON".
6. **Given** a payment for a member whose language code cannot be determined, **When** the administrator submits, **Then** the system rejects it with "TAALCODE ONBEK / CODE LING INCON".

---

### User Story 2 – Review Payment and Rejection Lists (Priority: P2)

A mutuality administrator or finance department staff member wants to view the current batch's payment detail list and rejection list so they can reconcile payments and investigate errors.

**Why this priority**: This is the primary reporting output of the system. Finance staff and administrators rely on these lists for reconciliation and audit. Without them, accepted payments cannot be verified and rejections cannot be investigated or corrected.

**Independent Test**: Can be tested independently by loading a set of processed payments and verifying that the payment detail list and rejection list are accessible, filterable by accounting region, and display correct bilingual diagnostic messages for rejections.

**Acceptance Scenarios**:

1. **Given** a set of processed payments, **When** a finance staff member views the payment detail list, **Then** it displays all accepted payments with member details, amount, IBAN, BIC, bank destination, and payment description.
2. **Given** rejected payments exist, **When** the administrator views the rejection list, **Then** it shows each rejected payment with the bilingual diagnostic message explaining the reason.
3. **Given** payments from multiple accounting regions (General, Flemish, Walloon, Brussels, German-speaking), **When** the user filters by region, **Then** only payments matching the selected region are displayed.
4. **Given** a payment where the provided IBAN differs from the member's known bank account, **When** the administrator views the bank account discrepancy list, **Then** the discrepancy record is shown.

---

### User Story 3 – Export Payment Data (Priority: P3)

A finance department staff member wants to export payment data in a structured format for use in downstream reconciliation or modern integration systems.

**Why this priority**: The CSV export (5DET01) is a secondary output used for modern integrations. The core payment processing and list viewing features take priority, but export enables broader adoption and automation.

**Independent Test**: Can be tested independently by filtering a set of standard (non-regional) accepted payments and downloading a CSV export, then verifying the data matches the processed payments.

**Acceptance Scenarios**:

1. **Given** a set of successfully processed standard payments, **When** the finance staff member requests a CSV export, **Then** the file is downloaded with complete payment records in structured format.
2. **Given** the user filters by date range and accounting type before exporting, **When** the export is triggered, **Then** only payments matching the filter criteria are included in the CSV.

---

### User Story 4 – Audit Payment Processing History (Priority: P4)

An audit team member wants to trace any payment from input to acceptance or rejection to verify control effectiveness and regulatory compliance.

**Why this priority**: Audit traceability is a control requirement but does not need to be built simultaneously with the core features. It can leverage the payment and rejection lists already implemented.

**Independent Test**: Can be tested independently by searching for a payment by constant identifier or sequence number and verifying the full processing result record is retrievable with all relevant details.

**Acceptance Scenarios**:

1. **Given** a processed payment, **When** the auditor searches by constant identifier, **Then** the system returns the full payment record including member details, validation result, rejection reason (if any), and destination bank.
2. **Given** the auditor filters by mutuality code and date range, **Then** all matching payment records are returned.

---

### Edge Cases

- What happens when a member has an active insurance section but under an excluded product code (609, 659, 679, 689)?
- What happens when the IBAN validation service is unavailable? → The payment is rejected with the message "IBAN validation service unavailable, please retry"; no payment record is created (fail-closed).
- What happens when a member's administrative language is 0 and the insurance section language is also unresolvable?
- What happens when a payment uses a circular cheque method ('C') with a non-Belgian IBAN?
- What happens when a bilingual mutuality member (codes 106, 107, 150, 166) has no language preference set?
- What happens when a regional accounting type (3–6) payment is submitted for a non-Belfius routing?

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST validate that the member identified by the national registry number exists and has at least one active or closed insurance section before accepting a payment request.
- **FR-002**: The system MUST check for duplicate payments by detecting any existing payment with the same constant identifier and amount for the same member, and reject duplicates before creating any payment record.
- **FR-003**: The system MUST validate the IBAN for SEPA compliance and extract a valid BIC code; payments with invalid IBANs MUST be rejected.
- **FR-004**: The system MUST validate the payment description code against permitted values and return the appropriate multi-language payment description text.
- **FR-005**: The system MUST determine the member's language (French, Dutch, or German) from their administrative data or insurance section, and for bilingual mutuality members use their stated preference; payments with unresolvable language codes MUST be rejected.
- **FR-006**: The system MUST route accepted payments to the correct bank destination (Belfius or KBC) based on payment type and regional accounting type.
- **FR-007**: The system MUST support six accounting types: General (1), Flemish (3), Walloon (4), Brussels (5), and German-speaking (6), routing regional payments (3–6) exclusively through Belfius.
- **FR-008**: The system MUST generate a payment detail list for accepted payments, separated by accounting region, including complete payment details for bank reconciliation.
- **FR-009**: The system MUST generate a rejection list for failed payments, including a bilingual Dutch/French diagnostic message for each rejection reason.
- **FR-010**: The system MUST generate a bank account discrepancy record when the IBAN provided in a payment differs from the member's known bank account on file.
- **FR-011**: The system MUST support CSV export of accepted standard (non-regional) payment records for downstream integration.
- **FR-012**: The system MUST support filtering of payment and rejection lists by accounting region, date range, and mutuality code.
- **FR-013**: The system MUST provide search capability to retrieve any payment record by constant identifier or sequence number.
- **FR-014**: The system MUST support circular cheque payment method ('C') separately from SEPA transfer, and validate eligibility accordingly.
- **FR-015**: Rejected payments MUST NOT result in any bank payment instruction or payment module record being created.
- **FR-016**: The system MUST authenticate users via a local username and password stored in the application's own user store; unauthenticated requests to any protected endpoint MUST be rejected with an HTTP 401 response.
- **FR-017**: The system MUST enforce three distinct roles per user:
  - **Submitter**: may submit payment requests and view all payment, rejection, and discrepancy lists.
  - **Read-Only**: may view payment and rejection lists and download CSV exports only; may not submit payments.
  - **Admin**: may create user accounts, deactivate users, and reset passwords via an in-application management UI; may not submit payments.
- **FR-018**: The Admin role MUST be able to create new user accounts, assign roles, deactivate accounts, and trigger password resets through the application UI without requiring direct database access.
- **FR-019**: When the IBAN validation service (SEBNKUK9) is unreachable or returns an unexpected error, the system MUST reject the payment request with the message "IBAN validation service unavailable, please retry" and MUST NOT create any payment record or bank instruction (fail-closed behaviour).
- **FR-020**: The system MUST enforce mutuality-code scoping for Submitter and Read-Only users: a Submitter MUST only be able to submit payments with a destination (`TRBFN-DEST`) matching one of their assigned mutuality codes, and MUST only see payment and rejection list entries for those codes. Attempts to submit or view data outside the assigned codes MUST be rejected with HTTP 403.
- **FR-021**: The system MUST log all application errors and unhandled exceptions to a persistent log file. No additional audit trail beyond the payment detail list and rejection list (FR-008, FR-009) is required at this stage.

### Key Entities

- **Payment Request**: A manual payment instruction submitted for a specific member; has amount, constant identifier, sequence number, payment description code, IBAN, payment method, accounting type, and mutuality destination.
- **Member**: A Belgian mutual insurance member identified by national registry number; has language preference, mutuality affiliation, insurance sections, and known bank account.
- **Insurance Section**: A membership category (holder/PAC, open/closed) tied to a product code; determines member eligibility for payment processing.
- **Payment Record**: A confirmed, validated payment instruction stored in the payment module database; linked to member and traceable by constant and sequence number.
- **Rejection Record**: A record of a failed payment validation; contains bilingual diagnostic message and original payment reference.
- **Bank Account Discrepancy**: A record noting that the IBAN used in a payment differs from the member's registered account.
- **Payment List**: An aggregated collection of payment or rejection records, organized by accounting region and mutuality destination, for audit and reconciliation.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Mutuality administrators can submit a payment request and receive a clear acceptance or rejection result in under 5 seconds.
- **SC-002**: 100% of submitted payments that pass validation result in a payment detail list entry; 100% of rejected payments result in a rejection list entry — no payment is silently dropped.
- **SC-003**: Payment and rejection lists are available for review within 1 minute of the submission that generated them.
- **SC-004**: Administrators can retrieve any historical payment by constant identifier or sequence number in under 3 seconds.
- **SC-005**: The system correctly routes 100% of regional accounting payments (types 3–6) to the correct regional list variant.
- **SC-006**: All rejection messages are displayed bilingually (Dutch and French) in 100% of rejection cases.
- **SC-007**: CSV exports contain complete and accurate data matching the on-screen payment lists, with no data loss or mismatched records.
- **SC-008**: 90% of mutuality administrators report that the web interface is easier to use than the previous batch processing approach.

---

## Clarifications

### Session 2026-03-23

- Q: What is the authentication method for the web application? → A: Local username and password (standalone user store in the application database; no external IdP or SSO).
- Q: How many roles does the application need and what can each role do? → A: Three roles — Submitter (submit payments, view all lists), Read-Only (view lists and export only), Admin (create/deactivate users and reset passwords via in-app UI).
- Q: What happens when the IBAN validation service (SEBNKUK9) is unavailable? → A: Fail-closed — reject the payment and display a clear "IBAN validation service unavailable, please retry" message; no payment record is created.
- Q: Should Submitters be scoped to specific mutuality codes, or can any Submitter act on any mutuality? → A: Fully scoped — each Submitter account is assigned to one or more mutuality codes and can only submit and view payments for those assigned mutualities.
- Q: What observability (logging, audit trail, metrics) is required? → A: Error logging only — application errors and exceptions are logged to a log file; no dedicated audit trail beyond the payment and rejection lists already in the spec.

---

## Assumptions *(documented defaults)*

- The application supports multiple mutualities (codes 101–169) within a single deployment. Access to payment data is scoped per user: Submitter and Read-Only users are each assigned to one or more mutuality codes by an Admin, and can only submit or view data for their assigned codes.
- IBAN validation continues to rely on the same external validation service (SEBNKUK9) exposed as an API endpoint callable from the backend.
- Member database (MUTF08) and payment history database (BBF) are accessible via backend integration; the web application does not replace these data stores.
- Excluded product codes (609, 659, 679, 689) for insurance section validation remain the same as documented.
- Language resolution logic (bilingual mutualities 106, 107, 150, 166) and valid language codes (1=FR, 2=NL, 3=DE) follow the same rules as the existing COBOL system.
- User authentication uses a **local username and password** stored in the application's own user database (no external IdP or SSO integration). Three roles are supported: **Submitter** (mutuality administrators), **Read-Only** (finance staff, auditors), and **Admin** (user management via in-app UI). Passwords MUST be stored as salted hashes (e.g., BCrypt). User management (create, deactivate, reset password) is performed by Admin-role users through the application itself.
- Payment processing is performed synchronously via the web interface; batch file input mode is out of scope for this application.
- Bank routing rules (Belfius vs. KBC) remain unchanged from the existing documented logic.
