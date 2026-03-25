# Functional Requirement: Duplicate Payment Detection

**ID**: FUREQ_MYFIN_002  
**Status**: Draft  
**Priority**: Critical  
**Last Updated**: 2026-01-28

## Traceability

### Business Requirements
- **BUREQ_MYFIN_002**: Payment Uniqueness
- **BUREQ_MYFIN_006**: Comprehensive Validation

### Use Cases
- **UC_MYFIN_001**: Process Manual GIRBET Payment
- **UC_MYFIN_002**: Validate Payment Data

## Requirement Statement

The system must prevent duplicate payments by checking if the same payment (matching both amount and constant identifier) already exists in the BBF payment module database, rejecting duplicates with a bilingual diagnostic message.

## Detailed Description

### Functional Behavior

After successful input validation, the system performs a duplicate check by querying the BBF (payment module) database for existing payments with the same TRBFN-CONSTANTE and TRBFN-MONTANT combination. This check prevents accidental double payments to members, protecting the organization from financial loss.

The duplicate check iterates through all BBF records for the member, comparing both the payment amount and the constant identifier. If a match is found, the payment is immediately rejected without creating any payment records or bank instructions.

### Input Specification

| Parameter | Type | Required | Format/Constraints | Example |
|-----------|------|----------|-------------------|---------|
| TRBFN-CONSTANTE | 9(10) | Yes | Payment constant identifier | 1234567890 |
| TRBFN-MONTANT | S9(08) | Yes | Payment amount in cents | 12500 (= €125.00) |
| RNRBIN | S9(08) COMP | Yes | Member's binary national registry number | 12345678 |

### Processing Logic

1. **Initialize Database Search**
   - Set GETTP = 1 (get first BBF record for member)
   - Use RNRBIN as search key (set in earlier validation)
   - Execute: [PERFORM GET-BBF](../../../cbl/MYFIN.cbl#L324)

2. **Iterate Through Existing Payments**
   - Loop through all BBF payment records for the member
   - For each record, compare:
     - BBF-BEDRAG (existing payment amount) = TRBFN-MONTANT (new payment amount)
     - BBF-KONST (existing constant) = TRBFN-CONSTANTE (new constant)
   - Continue until STAT1 NOT = ZEROES (no more records found)

3. **Duplicate Detection Logic**
   ```cobol
   IF TRBFN-MONTANT = BBF-BEDRAG AND
      TRBFN-CONSTANTE = BBF-KONST
   THEN
      * Duplicate found - reject payment
      MOVE "DUBBELE BETALING/DOUBLE PAIEMENT" TO BBF-N54-DIAG
      PERFORM CREER-REMOTE-500004
      PERFORM FIN-BTM
   END-IF
   ```

4. **Continue to Next Record**
   - Set GETTP = 2 (get next BBF record)
   - Execute: [PERFORM GET-BBF](../../../cbl/MYFIN.cbl#L335)
   - Repeat until all records checked

### Output Specification

**Success Output:**
- No duplicate found
- Processing continues to bank account validation (VOIR-BANQUE-DEBIT)
- No records created at this stage

**Error Output:**
- Duplicate found
- Rejection record written to list 500004 (or regional variant)
- Diagnostic message: "DUBBELE BETALING/DOUBLE PAIEMENT"
- Processing terminates via FIN-BTM paragraph
- No BBF record created
- No SEPA payment instruction generated
- No payment detail list entry created

## Technical Constraints

- **Performance**: Database query must complete within 200ms per member
- **Database Locking**: No locking required (read-only query)
- **Transaction**: No transaction required for duplicate check (query only)
- **Uniqueness Key**: Combination of member RNR + amount + constant

## Data Structures

### BBF-REC (Payment Module Record)

```cobol
      * BBF Payment Module Record (from BBFPRGZP copybook)
       01  BBF-REC.
           05  BBF-BEDRAG          PIC S9(08).    * Payment amount in cents
           05  BBF-KONST           PIC 9(10).     * Payment constant identifier
           05  BBF-TYPE            PIC 9.         * Payment type (9=manual GIRBET)
           05  BBF-LIBEL           PIC 9(02).     * Payment description code
           05  BBF-VOLGNR          PIC 9(04).     * Sequence number
           05  BBF-DATINB          PIC 9(08).     * Processing date
      
      * Validation rules:
      * - BBF-BEDRAG + BBF-KONST must be unique per member
      * - Duplicate check compares both fields simultaneously
```

### Working Storage Variables

```cobol
       01  GETTP               PIC 9.         * Get type: 1=first, 2=next
       01  STAT1               PIC S9(04).    * Database status: 0=success, non-zero=no more records
```

## Validation Rules

| Field | Rule | Error Code | Error Message |
|-------|------|------------|---------------|
| TRBFN-MONTANT + TRBFN-CONSTANTE | Must not exist in BBF for same member | DUP_001 | "DUBBELE BETALING/DOUBLE PAIEMENT" |

## Error Handling

### Error Scenarios

1. **Duplicate Payment Found**
   - **Trigger**: BBF-BEDRAG = TRBFN-MONTANT AND BBF-KONST = TRBFN-CONSTANTE
   - **Action**: Set BBF-N54-DIAG = "DUBBELE BETALING/DOUBLE PAIEMENT"
   - **Logging**: Write rejection record to list 500004 (or regional variant)
   - **Recovery**: PERFORM CREER-REMOTE-500004 to create rejection record, then PERFORM FIN-BTM to terminate processing
   - **Code**: [cbl/MYFIN.cbl#L324-L336](../../../cbl/MYFIN.cbl#L324-L336)

2. **Database Access Error**
   - **Trigger**: Database unavailable during GET-BBF operation
   - **Action**: System error handling (not shown in provided code)
   - **Logging**: Database error logged to system logs
   - **Recovery**: Depends on system configuration (may ABEND or log error)

## Integration Points

### Database

**Files/Records:**
- BBF (Payment Module Database): READ operations
  - Source: [cbl/MYFIN.cbl#L324](../../../cbl/MYFIN.cbl#L324)
  - Copybook: [copy/bbfprgzp.cpy](../../../copy/bbfprgzp.cpy)
  - Purpose: Search for existing payments with matching amount and constant
  - Key: RNRBIN (member's national registry number)
  - Access Method: Sequential read through all member's BBF records
  - Operations: GET-BBF (paragraph performs database read)

### External Systems

**Rejection List Generation:**
- **Type**: File output (remote printing record)
- **Purpose**: Record duplicate payment attempts for administrator review
- **Interface**: BFN54GZR copybook structure
- **Error Handling**: Record created with bilingual diagnostic message
- **List Variants**: 500004 (general), 500074 (Flemish), 500094 (Walloon), 500064 (Brussels), 500084 (German)

## Configuration

| Parameter | Source | Required | Default | Description |
|-----------|--------|----------|---------|-------------|
| GETTP | Program variable | Yes | 1 | Type of BBF retrieval: 1=first record, 2=next record |
| RNRBIN | Set in input validation | Yes | N/A | Member's national registry number (search key) |

## Implementation Notes

### Code References

- **Main Implementation**: 
  - Source: [cbl/MYFIN.cbl#L322-L336](../../../cbl/MYFIN.cbl#L322-L336)
  - Paragraph: VOIR-DOUBLES
- **Database Access**: 
  - Source: [cbl/MYFIN.cbl#L324](../../../cbl/MYFIN.cbl#L324) - PERFORM GET-BBF
  - First record retrieval (GETTP=1)
  - Source: [cbl/MYFIN.cbl#L335](../../../cbl/MYFIN.cbl#L335) - PERFORM GET-BBF
  - Subsequent record retrieval (GETTP=2)
- **Rejection Handling**: 
  - Source: [cbl/MYFIN.cbl#L331-L332](../../../cbl/MYFIN.cbl#L331-L332) - CREER-REMOTE-500004 and FIN-BTM

### Design Patterns Used

- **Sequential Search**: Iterate through all existing payments for member
- **Early Termination**: Stop immediately when duplicate found
- **Composite Key Matching**: Match both amount AND constant (not just one field)
- **Read-Only Query**: No database updates during duplicate check

### Dependencies

- **Copybooks**: 
  - BBFPRGZP.cpy: BBF payment module record structure
  - BFN54GZR.cpy: Rejection list output structure
- **Called Programs**: None (uses inline database access via GET-BBF paragraph)
- **System Services**: 
  - Database access for BBF payment module queries

## Test Scenarios

### Positive Tests

1. **No duplicate exists**
   - Input: Payment with unique amount/constant combination
   - Expected: Duplicate check passes, processing continues to bank account validation

2. **Different amount, same constant**
   - Input: Payment with TRBFN-MONTANT = 10000, TRBFN-CONSTANTE = 1234567890
   - Existing: BBF record with BBF-BEDRAG = 5000, BBF-KONST = 1234567890
   - Expected: Not a duplicate (amount differs), processing continues

3. **Same amount, different constant**
   - Input: Payment with TRBFN-MONTANT = 10000, TRBFN-CONSTANTE = 1234567890
   - Existing: BBF record with BBF-BEDRAG = 10000, BBF-KONST = 9999999999
   - Expected: Not a duplicate (constant differs), processing continues

4. **No existing BBF records for member**
   - Input: Payment for member with no previous payments
   - Expected: STAT1 NOT = ZEROES immediately, no duplicates found, processing continues

### Negative Tests

1. **Exact duplicate found**
   - Input: Payment with TRBFN-MONTANT = 10000, TRBFN-CONSTANTE = 1234567890
   - Existing: BBF record with BBF-BEDRAG = 10000, BBF-KONST = 1234567890
   - Expected: Duplicate detected, rejection with "DUBBELE BETALING/DOUBLE PAIEMENT"

2. **Multiple BBF records with one duplicate**
   - Input: Payment with TRBFN-MONTANT = 10000, TRBFN-CONSTANTE = 1234567890
   - Existing: 5 BBF records, third record matches amount and constant
   - Expected: Duplicate detected on third iteration, rejection generated

## Acceptance Criteria

- [x] All BBF payment records for member are checked for duplicates
- [x] Both amount (BBF-BEDRAG) and constant (BBF-KONST) must match for duplicate detection
- [x] Duplicate payment rejected with bilingual message "DUBBELE BETALING/DOUBLE PAIEMENT"
- [x] Rejection record written to appropriate list (500004 or regional variant)
- [x] Processing terminates immediately upon finding duplicate
- [x] No BBF record, SEPA instruction, or payment list entry created for duplicates
- [x] Original payment (existing BBF record) remains unchanged

## Open Issues

- [ ] Confirm whether duplicate check should consider BBF-TYPE field (currently only checks amount + constant)
- [ ] Document whether duplicate check should include date range (e.g., duplicates within same month only)
- [ ] Clarify handling if member has hundreds of BBF records (performance optimization needed?)
