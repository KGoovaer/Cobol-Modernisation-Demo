# API Contract: Payments, Rejections & Discrepancies

**Base path**: `/api`  
**Authentication required**: Yes (session cookie). HTTP 401 if not authenticated.  
**Mutuality scoping**: SUBMITTER and READ_ONLY users only see records for their assigned mutuality codes. Requests outside their codes return HTTP 403.

---

## POST /api/payments

Submit a payment request for validation and processing.

**Roles allowed**: SUBMITTER only. ADMIN and READ_ONLY → 403.

**Request**:

```
POST /api/payments
Content-Type: application/json
X-XSRF-TOKEN: <token>
```

```json
{
  "memberRnr": 12345678901,
  "destinationMutuality": 101,
  "constantId": "TEST000001",
  "sequenceNo": "0001",
  "amountCents": 12345,
  "currency": "E",
  "paymentDescCode": 5,
  "iban": "BE68539007547034",
  "paymentMethod": " ",
  "accountingType": 1
}
```

**Field validation** (`@Valid`):

| Field | Constraint |
|-------|-----------|
| memberRnr | `@NotNull`, positive long |
| destinationMutuality | `@Min(101)` `@Max(169)` |
| constantId | `@NotBlank` `@Size(max=10)` |
| sequenceNo | `@Size(max=4)` (nullable) |
| amountCents | `@Positive` |
| currency | `@Pattern(regexp="[EB]")` |
| paymentDescCode | `@Min(1)` `@Max(99)` |
| iban | `@NotBlank` `@Size(max=34)` |
| paymentMethod | `@Pattern(regexp="[ CDEF]")` |
| accountingType | `@Pattern` (1,3,4,5,6 only) |

**Responses**:

| Status | Body | Condition |
|--------|------|-----------|
| 200 OK | `PaymentResultDto` (ACCEPTED) | Validation passed; PaymentRecord created |
| 200 OK | `PaymentResultDto` (REJECTED) | Validation failed; RejectionRecord created |
| 400 Bad Request | `ValidationErrorDto` | Bean validation failure (malformed input) |
| 401 Unauthorized | — | Not authenticated |
| 403 Forbidden | — | Role not SUBMITTER, or destinationMutuality not in user's codes |

**PaymentResultDto**:

```json
{
  "status": "ACCEPTED",
  "diagnosticNl": null,
  "diagnosticFr": null,
  "recordId": "550e8400-e29b-41d4-a716-446655440001"
}
```

```json
{
  "status": "REJECTED",
  "diagnosticNl": "IBAN FOUTIEF",
  "diagnosticFr": "IBAN ERRONE",
  "recordId": "550e8400-e29b-41d4-a716-446655440002"
}
```

Note: `recordId` refers to the `payment_requests.id` in both cases (not `payment_records.id`).

---

## GET /api/payments

List accepted payment records (paginated, filterable).

**Roles allowed**: SUBMITTER, READ_ONLY. ADMIN → 403.

**Query parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `accountingType` | int (1,3,4,5,6) | Filter by accounting type |
| `dateFrom` | ISO date (`2026-01-01`) | Inclusive lower bound on `created_at` |
| `dateTo` | ISO date | Inclusive upper bound on `created_at` |
| `mutualityCode` | int (101–169) | Filter by destination mutuality |
| `page` | int (default: 0) | Page number (0-based) |
| `size` | int (default: 20) | Page size (max: 100) |
| `sort` | string (default: `createdAt,desc`) | Sort field and direction |

Mutuality codes are always intersected with the authenticated user's assigned codes.

**Response**:

```json
{
  "content": [
    {
      "id": "...",
      "memberName": "Jan Janssen",
      "memberRnr": 12345678901,
      "amountCents": 12345,
      "iban": "BE68539007547034",
      "bic": "GKCCBEBB",
      "bankRouting": "KBC",
      "regionalTag": 9,
      "accountingType": 1,
      "destinationMutuality": 101,
      "paymentDescNl": "Bijdrage terugbetaling",
      "paymentDescFr": "Remboursement cotisation",
      "createdAt": "2026-03-23T09:15:00Z"
    }
  ],
  "totalElements": 42,
  "totalPages": 3,
  "number": 0,
  "size": 20
}
```

---

## GET /api/payments/{id}

Retrieve a single payment record by ID.

**Roles allowed**: SUBMITTER, READ_ONLY. ADMIN → 403.  
**Scoping**: 403 if destinationMutuality not in user's codes.

**Path parameter**: `id` — UUID of `payment_records.id`

**Response**: Single `PaymentRecordDto` (same as content item above)  
**404** if not found. **403** if out of scope.

---

## GET /api/payments/search

Search for any payment request (accepted or rejected) by constant identifier or sequence number.

**Roles allowed**: SUBMITTER, READ_ONLY. ADMIN → 403.  
**Scoping**: results filtered to user's mutuality codes.

**Query parameters**:

| Parameter | Description |
|-----------|-------------|
| `constantId` | Exact match against `payment_requests.constant_id` |
| `sequenceNo` | Exact match against `payment_requests.sequence_no` |

At least one parameter required.

**Response**: Array of `PaymentSearchResultDto`:

```json
[
  {
    "requestId": "...",
    "memberRnr": 12345678901,
    "constantId": "TEST000001",
    "sequenceNo": "0001",
    "amountCents": 12345,
    "status": "ACCEPTED",
    "submittedAt": "2026-03-23T09:15:00Z",
    "recordId": "..."
  }
]
```

---

## GET /api/payments/export/csv

Download accepted payment records as CSV. Applies the same filter parameters as `GET /api/payments` (except `page`/`size`/`sort` — export is unbounded but streamed).

**Roles allowed**: SUBMITTER, READ_ONLY. ADMIN → 403.

**Response**:

```
HTTP/1.1 200 OK
Content-Type: text/csv
Content-Disposition: attachment; filename="payments-export-20260323.csv"
```

CSV columns (in order): `id`, `memberName`, `memberRnr`, `amountCents`, `iban`, `bic`, `bankRouting`, `regionalTag`, `accountingType`, `destinationMutuality`, `paymentDescNl`, `paymentDescFr`, `createdAt`

Implementation: `StreamingResponseBody` to avoid loading all rows into memory.

---

## GET /api/rejections

List rejection records (paginated, filterable).

**Roles allowed**: SUBMITTER, READ_ONLY. ADMIN → 403.

**Query parameters**: Same as `GET /api/payments` (accountingType, dateFrom, dateTo, mutualityCode, page, size, sort). Applied to the underlying `payment_request` fields.

**Response**:

```json
{
  "content": [
    {
      "id": "...",
      "paymentRequestId": "...",
      "memberRnr": 99999999999,
      "constantId": "TEST000002",
      "amountCents": 5000,
      "diagnosticNl": "LIDNR ONBEKEND",
      "diagnosticFr": "AFFILIE INCONNU",
      "destinationMutuality": 101,
      "createdAt": "2026-03-23T09:20:00Z"
    }
  ],
  "totalElements": 7,
  "totalPages": 1,
  "number": 0,
  "size": 20
}
```

---

## GET /api/rejections/{id}

Retrieve a single rejection record by its UUID.

**Roles allowed**: SUBMITTER, READ_ONLY. ADMIN → 403.  
**404** if not found. **403** if outside user's codes.

---

## GET /api/discrepancies

List bank account discrepancy records (paginated).

**Roles allowed**: SUBMITTER, READ_ONLY. ADMIN → 403.

**Query parameters**: `page`, `size`, `sort`, `mutualityCode`, `dateFrom`, `dateTo`

**Response**:

```json
{
  "content": [
    {
      "id": "...",
      "paymentRequestId": "...",
      "memberRnr": 12345678901,
      "providedIban": "BE68539007547034",
      "knownIban":   "BE12345678901234",
      "createdAt": "2026-03-23T09:15:00Z"
    }
  ],
  "totalElements": 3,
  "totalPages": 1,
  "number": 0,
  "size": 20
}
```

---

## Error Response Format

All error responses follow a consistent structure:

```json
{
  "status": 403,
  "error": "Forbidden",
  "message": "Destination mutuality 105 is not in your assigned codes",
  "timestamp": "2026-03-23T09:00:00Z",
  "path": "/api/payments"
}
```

Bean validation errors (HTTP 400) include a `fieldErrors` array:

```json
{
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "fieldErrors": [
    {"field": "iban", "message": "size must be between 1 and 34"},
    {"field": "paymentDescCode", "message": "must be between 1 and 99"}
  ]
}
```
