# Data Model: MYFIN Web Application

**Phase**: 1 — Design  
**Date**: 2026-03-23

---

## Entity Relationship Overview

```
users ──< user_mutuality_codes
  │
  └──< payment_requests ──< payment_records
                        ──< rejection_records
                        ──< bank_account_discrepancies

payment_descriptions  (lookup, no FK to payment_requests — code value referenced)
```

---

## Entities

### `users`

```sql
CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    username      VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(72)  NOT NULL,       -- BCrypt output is ≤ 60 chars; 72 is safe
    role          VARCHAR(20)  NOT NULL CHECK (role IN ('SUBMITTER','READ_ONLY','ADMIN')),
    active        BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP    NOT NULL DEFAULT now()
);
```

**JPA**: `@Entity`, `@Table(name = "users")`, `implements UserDetails`

| Field | Java Type | Constraints |
|-------|-----------|-------------|
| id | `UUID` | `@Id @GeneratedValue` |
| username | `String` | `@Column(unique=true, length=100)` `@NotBlank` |
| passwordHash | `String` | `@Column(length=72)` — never exposed in DTO |
| role | `Role` (enum) | `@Enumerated(STRING)` |
| active | `boolean` | `@Column(nullable=false)` |
| createdAt | `Instant` | `@Column(nullable=false)` `@CreationTimestamp` |

---

### `user_mutuality_codes`

```sql
CREATE TABLE user_mutuality_codes (
    user_id        UUID    NOT NULL REFERENCES users(id),
    mutuality_code SMALLINT NOT NULL CHECK (mutuality_code BETWEEN 101 AND 169),
    PRIMARY KEY (user_id, mutuality_code)
);
```

**JPA**: `@ElementCollection` on `User.mutualityCodes` (Set\<Integer\>)

---

### `payment_requests`

```sql
CREATE TABLE payment_requests (
    id                      UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    member_rnr              BIGINT       NOT NULL,
    destination_mutuality   SMALLINT     NOT NULL CHECK (destination_mutuality BETWEEN 101 AND 169),
    constant_id             VARCHAR(10)  NOT NULL,
    sequence_no             VARCHAR(4),
    amount_cents            BIGINT       NOT NULL CHECK (amount_cents > 0),
    currency                CHAR(1)      NOT NULL CHECK (currency IN ('E','B')),
    payment_desc_code       SMALLINT     NOT NULL CHECK (payment_desc_code BETWEEN 1 AND 99),
    iban                    VARCHAR(34)  NOT NULL,
    payment_method          CHAR(1)      NOT NULL DEFAULT ' ' CHECK (payment_method IN (' ','C','D','E','F')),
    accounting_type         SMALLINT     NOT NULL CHECK (accounting_type IN (1,3,4,5,6)),
    submitted_by            UUID         NOT NULL REFERENCES users(id),
    submitted_at            TIMESTAMP    NOT NULL DEFAULT now(),
    status                  VARCHAR(10)  NOT NULL CHECK (status IN ('ACCEPTED','REJECTED'))
);
```

**JPA**: `@Entity`, `@Table(name = "payment_requests")`

| Field | Java Type | Notes |
|-------|-----------|-------|
| memberRnr | `long` | national registry number |
| destinationMutuality | `int` | 101–169 |
| constantId | `String` | `@Column(length=10)` copybook TRBFN-CSTE-ID |
| sequenceNo | `String` | `@Column(length=4)` nullable; copybook TRBFN-VOLGNO |
| amountCents | `long` | stored in euro cents; copybook TRBFN-BEDRAG |
| currency | `char` | `'E'` = euro, `'B'` = Belgian franc (legacy) |
| paymentDescCode | `int` | 1–99; copybook TRBFN-CODE-OMSCHR |
| iban | `String` | `@Column(length=34)` |
| paymentMethod | `char` | `' '` = SEPA transfer, `'C'/'D'/'E'/'F'` = circular cheque types |
| accountingType | `int` | 1=General, 3=Flemish, 4=Walloon, 5=Brussels, 6=German |
| submittedBy | `User` | `@ManyToOne` |
| status | `PaymentStatus` (enum) | ACCEPTED \| REJECTED |

---

### `payment_records`

```sql
CREATE TABLE payment_records (
    id                    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_request_id    UUID         NOT NULL REFERENCES payment_requests(id),
    member_name           VARCHAR(50)  NOT NULL,
    member_rnr            BIGINT       NOT NULL,
    amount_cents          BIGINT       NOT NULL,
    iban                  VARCHAR(34)  NOT NULL,
    bic                   VARCHAR(11),
    bank_routing          VARCHAR(10)  NOT NULL CHECK (bank_routing IN ('BELFIUS','KBC')),
    regional_tag          SMALLINT     NOT NULL CHECK (regional_tag IN (1,2,4,7,9)),
    accounting_type       SMALLINT     NOT NULL CHECK (accounting_type IN (1,3,4,5,6)),
    destination_mutuality SMALLINT     NOT NULL,
    payment_desc_nl       VARCHAR(50),
    payment_desc_fr       VARCHAR(50),
    created_at            TIMESTAMP    NOT NULL DEFAULT now()
);
```

| Field | Notes |
|-------|-------|
| bankRouting | BELFIUS for all regional types (3–6); KBC otherwise |
| regionalTag | Derived: acctType 1→9, 3→1, 4→2, 5→4, 6→7 |
| paymentDescNl / Fr | Fetched from `payment_descriptions` during validation |

---

### `rejection_records`

```sql
CREATE TABLE rejection_records (
    id                 UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_request_id UUID         NOT NULL REFERENCES payment_requests(id),
    diagnostic_nl      VARCHAR(32)  NOT NULL,
    diagnostic_fr      VARCHAR(32)  NOT NULL,
    created_at         TIMESTAMP    NOT NULL DEFAULT now()
);
```

Standard bilingual diagnostic messages:

| Rejection reason | `diagnostic_nl` | `diagnostic_fr` |
|-----------------|-----------------|-----------------|
| Unknown member | LIDNR ONBEKEND | AFFILIE INCONNU |
| Unresolvable language | TAALCODE ONBEK | CODE LING INCON |
| Unknown payment code | CODE OMSCHR ONBEK | CODE LIBEL INCON |
| Duplicate payment | DUBBELE BETALING | DOUBLE PAIEMENT |
| Invalid IBAN | IBAN FOUTIEF | IBAN ERRONE |
| IBAN service outage | IBAN validation service unavailable, please retry | IBAN validation service unavailable, please retry |
| Circular cheque ineligible | (step-specific message) | (step-specific message) |

---

### `bank_account_discrepancies`

```sql
CREATE TABLE bank_account_discrepancies (
    id                 UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_request_id UUID         NOT NULL REFERENCES payment_requests(id),
    provided_iban      VARCHAR(34)  NOT NULL,
    known_iban         VARCHAR(34)  NOT NULL,
    created_at         TIMESTAMP    NOT NULL DEFAULT now()
);
```

Created by `AccountDiscrepancyStep` (step 7 — non-blocking). A payment can have a discrepancy record AND be ACCEPTED.

---

### `payment_descriptions`

```sql
CREATE TABLE payment_descriptions (
    code            SMALLINT     PRIMARY KEY CHECK (code BETWEEN 1 AND 89),
    description_nl  VARCHAR(50)  NOT NULL,
    description_fr  VARCHAR(50)  NOT NULL,
    description_de  VARCHAR(50)
);
```

Codes 1–89 are seeded by Flyway `V3__seed_payment_descriptions.sql`. Codes 90–99 are fetched dynamically from `MemberPort` (MUTF08) at validation time and are NOT stored here.

---

## Validation Pipeline — Step Contracts

Each step implements:

```java
public interface ValidationStep {
    void execute(ValidationContext ctx) throws ValidationException;
}
```

`ValidationContext` carries mutable state across steps:

| Field | Populated by step |
|-------|------------------|
| `memberDto` | MemberValidationStep |
| `languageCode` | LanguageResolutionStep |
| `paymentDescNl` / `paymentDescFr` | PaymentDescriptionStep |
| `ibanValid`, `bic` | IBANValidationStep |
| `memberAddress` | CircularChequeStep (conditionally) |
| `bankRoutingDiscrepancy` | AccountDiscrepancyStep (stored, non-blocking) |
| `regionalTag`, `bankRouting` | RegionalTagStep |

### Step 1 — MemberValidationStep
- Calls `MemberPort.findByRnr(memberRnr)`
- Validates: at least one active or closed insurance section, none with excluded product codes (609, 659, 679, 689)
- Failure → `ValidationException("LIDNR ONBEKEND", "AFFILIE INCONNU")`

### Step 2 — LanguageResolutionStep
- Reads `memberDto.adminLanguage` (ADM-TAAL); if 0, falls back to insurance section language
- Bilingual mutuality codes (106, 107, 150, 166) → require explicit language preference
- Failure → `ValidationException("TAALCODE ONBEK", "CODE LING INCON")`

### Step 3 — PaymentDescriptionStep
- Codes 1–89: lookup `payment_descriptions` table
- Codes 90–99: call `MemberPort.getPaymentDescription(code, memberRnr)`
- Sets `ctx.paymentDescNl` and `ctx.paymentDescFr`
- Failure → `ValidationException("CODE OMSCHR ONBEK", "CODE LIBEL INCON")`

### Step 4 — DuplicateDetectionStep
- Calls `PaymentHistoryPort.isDuplicate(memberRnr, constantId, amountCents)`
- Failure → `ValidationException("DUBBELE BETALING", "DOUBLE PAIEMENT")`

### Step 5 — IBANValidationStep
- Calls `IBANValidationPort.validate(iban)`
- `IBANServiceUnavailableException` → `ValidationException("IBAN validation service unavailable, please retry", ...)` (fail-closed, FR-019)
- Invalid IBAN → `ValidationException("IBAN FOUTIEF", "IBAN ERRONE")`
- Sets `ctx.bic` on success

### Step 6 — CircularChequeStep
- Skipped if `paymentMethod == ' '` (SEPA transfer)
- Calls `MemberPort.getAddress(memberRnr)`; verifies Belgian address (`countryCode == "BE"`)
- Failure → rejection (step-specific message)

### Step 7 — AccountDiscrepancyStep (non-blocking)
- Calls `MemberAccountPort.getKnownIban(memberRnr)`
- If returned IBAN ≠ submitted IBAN: creates `BankAccountDiscrepancy` record
- Does NOT throw; processing continues regardless

### Step 8 — RegionalTagStep
- No external call; pure mapping
- `accounting_type → regional_tag`: 1→9, 3→1, 4→2, 5→4, 6→7
- `accounting_type 3–6 → bank_routing = BELFIUS`; else `bank_routing = KBC`

---

## Flyway Migration Order

| Version | File | Description |
|---------|------|-------------|
| V1 | `V1__create_users.sql` | `users` + `user_mutuality_codes` |
| V2 | `V2__create_payment_tables.sql` | `payment_requests`, `payment_records`, `rejection_records`, `bank_account_discrepancies`, `payment_descriptions` |
| V3 | `V3__seed_payment_descriptions.sql` | INSERT codes 1–89 into `payment_descriptions` |

All migrations use PostgreSQL-compatible syntax (no H2-specific functions). H2 runs in PostgreSQL compatibility mode via JDBC URL: `jdbc:h2:mem:MYFIN;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE`.

---

## Role–Endpoint Matrix

| Endpoint | SUBMITTER | READ_ONLY | ADMIN |
|----------|-----------|-----------|-------|
| POST /api/payments | ✅ (own codes) | ❌ 403 | ❌ 403 |
| GET /api/payments | ✅ (own codes) | ✅ (own codes) | ❌ 403 |
| GET /api/payments/export/csv | ✅ | ✅ | ❌ 403 |
| GET /api/rejections | ✅ | ✅ | ❌ 403 |
| GET /api/discrepancies | ✅ | ✅ | ❌ 403 |
| GET/POST /api/admin/users | ❌ 403 | ❌ 403 | ✅ |
| PATCH /api/admin/users/{id}/deactivate | ❌ 403 | ❌ 403 | ✅ |
| POST /api/admin/users/{id}/reset-password | ❌ 403 | ❌ 403 | ✅ |
| GET /api/auth/me | ✅ | ✅ | ✅ |
