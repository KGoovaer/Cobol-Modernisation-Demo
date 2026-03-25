# Functional Requirement: IBAN and Bank Account Validation

**ID**: FUREQ_MYFIN_003  
**Status**: Draft  
**Priority**: Critical  
**Last Updated**: 2026-01-28

## Traceability

### Business Requirements
- **BUREQ_MYFIN_003**: IBAN Validation
- **BUREQ_MYFIN_005**: Regional Accounting
- **BUREQ_MYFIN_011**: Bank Account Discrepancy List

### Use Cases
- **UC_MYFIN_001**: Process Manual GIRBET Payment
- **UC_MYFIN_002**: Validate Payment Data

## Requirement Statement

The system must validate all bank account information for SEPA compliance, including IBAN format validation, BIC code extraction, payment method eligibility (circular cheque vs. SEPA transfer), and member bank account verification, generating discrepancy records when the provided account differs from the member's known account.

## Detailed Description

### Functional Behavior

After duplicate payment detection, the system performs comprehensive bank account validation using the external IBAN validation service (SEBNKUK9). This includes:
1. IBAN format validation and BIC extraction
2. Payment method validation (circular cheque eligibility for non-Belgian accounts)
3. Bank selection (Belfius vs. KBC) based on payment type and regional accounting
4. Member's known bank account lookup for comparison
5. Discrepancy reporting when accounts differ

### Input Specification

| Parameter | Type | Required | Format/Constraints | Example |
|-----------|------|----------|-------------------|---------|
| TRBFN-IBAN | X(34) | Yes (for SEPA) | SEPA IBAN format | "BE68539007547034" |
| TRBFN-BETWYZ | X(01) | No | 'C'=Circular cheque, ' '=SEPA transfer | 'C' or ' ' |
| TRBFN-CODE-LIBEL | 9(02) | Yes | Payment description code | 01-99 |
| TRBFN-DEST | 9(03) | Yes | Mutuality code | 109, 116, 167 |
| TRBFN-TYPE-COMPTA | 9(01) | Yes | 1=General, 3=Flemish, 4=Walloon, 5=Brussels, 6=German | 1, 3-6 |
| TRBFN-COMPTE-MEMBRE | 9(01) | No | 0=Different account, 1=Same account | 0 or 1 |

### Processing Logic

1. **IBAN Validation via External Service**
   - Move TRBFN-IBAN to WS-SEBNK-IBAN-IN
   - Move TRBFN-BETWYZ to WS-SEBNK-BETWYZ-IN
   - Call SEBNKUK9 program via [WELKE-BANK paragraph](../../../cbl/MYFIN.cbl#L1246)
   - Service returns: WS-SEBNK-STAT-OUT (validation status), WS-SEBNK-BIC-OUT (BIC code), WS-SEBNK-WELKEBANK (bank identifier)
   - Status codes: 0=Valid, 1=Valid with warning, 2=Valid alternative format
   - Code: [cbl/MYFIN.cbl#L340-L344](../../../cbl/MYFIN.cbl#L340-L344)

2. **Bank Selection Logic**
   - Set WS-SEBNK-WELKEBANK = "0" (default to Belfius)
   - Check validation status: WS-SEBNK-STAT-OUT = 0, 1, or 2
   - If valid, extract BIC: MOVE WS-SEBNK-BIC-OUT TO WS-BIC
   - If invalid (status NOT = 0, 1, or 2), reject with "IBAN FOUTIEF/IBAN ERRONE"
   - Code: [cbl/MYFIN.cbl#L346-L358](../../../cbl/MYFIN.cbl#L346-L358)

3. **Payment Method Eligibility**
   - Evaluate TRBFN-CODE-LIBEL for payment type
   - Specific codes eligible for Belfius routing:
     - Codes 90-99, 1-49, 52-57, 71, 73, 74, 76, 78: If WS-SEBNK-WELKEBANK = "0", set SAV-WELKEBANK = 1 (Belfius)
     - Codes 50, 51, 60, 80: Always set SAV-WELKEBANK = 1 (Belfius)
     - All other codes: Default SAV-WELKEBANK = 1
   - Code: [cbl/MYFIN.cbl#L360-L387](../../../cbl/MYFIN.cbl#L360-L387)

4. **Regional Accounting Bank Routing**
   - Regional payments (TRBFN-TYPE-COMPTA = 3, 4, 5, 6) must use Belfius only
   - Check in CREER-USER-500001 paragraph:
     - Type 3 (Flemish): WELKEBANK = 0 (Belfius), federation 167
     - Type 4 (Walloon): WELKEBANK = 0 (Belfius), federation 169
     - Type 5 (Brussels): WELKEBANK = 0 (Belfius), federation 166
     - Type 6 (German): WELKEBANK = 0 (Belfius), federation 168
   - Code: [cbl/MYFIN.cbl#L500-L523](../../../cbl/MYFIN.cbl#L500-L523)

5. **Member Bank Account Lookup**
   - Check member age (must be 14+ for women, 16+ for men) via [RECH-NO-BANCAIRE paragraph](../../../cbl/MYFIN.cbl#L1109-L1200)
   - Call SCHRKCX9 program (via COPY SEPAKCXD) to retrieve member's known bank account
   - Input: SCHRK-CODE-LIBEL, SCHRK-DAT-VAL, SCHRK-FED
   - Output: SCHRK-IBAN (member's known IBAN), SCHRK-STATUS
   - If SCHRK-STATUS = 0, move SCHRK-IBAN to SAV-IBAN
   - Code: [cbl/MYFIN.cbl#L1202-L1220](../../../cbl/MYFIN.cbl#L1202-L1220)

6. **Bank Account Discrepancy Detection**
   - Check TRBFN-COMPTE-MEMBRE flag
   - If TRBFN-COMPTE-MEMBRE = 0 (indicates different account), generate discrepancy record
   - Execute [CREER-REMOTE-500006 paragraph](../../../cbl/MYFIN.cbl#L308-L309)
   - Discrepancy does NOT block payment processing
   - Code: [cbl/MYFIN.cbl#L307-L310](../../../cbl/MYFIN.cbl#L307-L310)

### Output Specification

**Success Output:**
- IBAN validated, BIC code extracted and stored in WS-BIC
- Bank selected (SAV-WELKEBANK = 1 for Belfius, 2 for KBC)
- Member's known account retrieved and stored in SAV-IBAN (if found)
- Processing continues to BBF record creation
- Optional: Discrepancy record created if TRBFN-COMPTE-MEMBRE = 0

**Error Output:**
- IBAN validation failed (WS-SEBNK-STAT-OUT NOT = 0, 1, or 2)
- Rejection record written to list 500004 (or regional variant)
- Diagnostic message: "IBAN FOUTIEF/IBAN ERRONE"
- Processing terminates via FIN-BTM paragraph

## Technical Constraints

- **Performance**: IBAN validation service (SEBNKUK9) must complete within 500ms
- **External Dependency**: SEBNKUK9 program must be operational
- **SEPA Compliance**: IBAN format must conform to ISO 13616 standard
- **Regional Accounting**: Types 3-6 MUST route to Belfius only (no KBC option)
- **Age Validation**: Member must be 14+ (women) or 16+ (men) for own bank account

## Data Structures

### SEBNKUKW (IBAN Validation Service Interface)

```cobol
      * IBAN Validation Service Working Storage (from SEBNKUKW copybook)
       01  SEBNKUKW.
           05  WS-SEBNK-IBAN-IN        PIC X(34).    * Input: IBAN to validate
           05  WS-SEBNK-BETWYZ-IN      PIC X(01).    * Input: Payment method
           05  WS-SEBNK-STAT-OUT       PIC 9(01).    * Output: Validation status
           05  WS-SEBNK-BIC-OUT        PIC X(11).    * Output: Extracted BIC code
           05  WS-SEBNK-WELKEBANK      PIC X(01).    * Output: Bank identifier
      
      * Validation status codes:
      * - 0: Valid IBAN, standard format
      * - 1: Valid IBAN with minor warning
      * - 2: Valid IBAN, alternative format accepted
      * - Other: Invalid IBAN
```

### SEPAKCXW (Member Account Search Interface)

```cobol
      * Member Account Search Interface (from SEPAKCXW copybook)
       01  SCHRK-INTERFACE.
           05  SCHRK-CODE-LIBEL        PIC 9(02).    * Payment description code
           05  SCHRK-BKF-TIERS         PIC 9(08).    * Third party identifier
           05  SCHRK-DAT-VAL           PIC 9(08).    * Validation date
           05  SCHRK-FED               PIC 9(03).    * Federation code
           05  SCHRK-STATUS            PIC 9(02).    * Return status
           05  SCHRK-IBAN              PIC X(34).    * Member's known IBAN
      
      * Status codes:
      * - 0: Account found successfully
      * - 1: Account not found or not applicable
      * - Other: Error in search routine
```

### Working Storage Variables

```cobol
       01  SAV-WELKEBANK   PIC 9.         * Selected bank: 1=Belfius, 2=KBC
       01  SAV-IBAN        PIC X(34).     * Member's known IBAN (from lookup)
       01  WS-IBAN         PIC X(34).     * Working IBAN field
       01  WS-BIC          PIC X(11).     * Extracted BIC code
       01  SW-TROP-JEUNE   PIC 9.         * Age check flag: 0=OK, 1=Too young
```

## Validation Rules

| Field | Rule | Error Code | Error Message |
|-------|------|------------|---------------|
| TRBFN-IBAN | SEPA IBAN format | IBAN_001 | "IBAN FOUTIEF/IBAN ERRONE" |
| TRBFN-IBAN | Status 0, 1, or 2 from SEBNKUK9 | IBAN_002 | "IBAN FOUTIEF/IBAN ERRONE" |
| Member age | 14+ years (women) or 16+ (men) | AGE_001 | (Handled via holder lookup) |
| Regional payments | Types 3-6 must use Belfius | BANK_001 | (Enforced in CREER-USER-500001) |

## Error Handling

### Error Scenarios

1. **IBAN Validation Failure**
   - **Trigger**: WS-SEBNK-STAT-OUT NOT = 0, 1, or 2 after SEBNKUK9 call
   - **Action**: Set BBF-N54-DIAG = "IBAN FOUTIEF/IBAN ERRONE"
   - **Logging**: Write rejection record to list 500004 (or regional variant)
   - **Recovery**: PERFORM CREER-REMOTE-500004, processing terminates
   - **Code**: [cbl/MYFIN.cbl#L353-L355](../../../cbl/MYFIN.cbl#L353-L355)

2. **SEBNKUK9 Service Error**
   - **Trigger**: CA--PROG call fails or returns unexpected error
   - **Action**: System error handling (program may ABEND)
   - **Logging**: Error logged to system logs
   - **Recovery**: Depends on system configuration

3. **Member Account Search Error**
   - **Trigger**: SCHRK-STATUS NOT = 0 and NOT = 1 after SEPAKCXD
   - **Action**: Set BTMMSG = "ERREUR ROUTINE SCHRKCX9 STATUS : [status]"
   - **Logging**: Write message to log via PPRNVW
   - **Recovery**: Continue processing (non-fatal error), SAV-IBAN set to SPACES
   - **Code**: [cbl/MYFIN.cbl#L1207-L1215](../../../cbl/MYFIN.cbl#L1207-L1215)

4. **Bank Account Discrepancy (Non-Error)**
   - **Trigger**: TRBFN-COMPTE-MEMBRE = 0 (provided account differs from known account)
   - **Action**: Create discrepancy record on list 500006 (or regional variant)
   - **Logging**: Discrepancy record shows both accounts for review
   - **Recovery**: Payment processing continues normally (not a blocking error)
   - **Code**: [cbl/MYFIN.cbl#L307-L310](../../../cbl/MYFIN.cbl#L307-L310)

## Integration Points

### Database

**Files/Records:**
- LIDVZ (Member Insurance Data): READ operations
  - Source: [cbl/MYFIN.cbl#L1139-L1160](../../../cbl/MYFIN.cbl#L1139-L1160)
  - Purpose: Retrieve holder's national registry number for account lookup (if member too young)
  - Fields: LIDVZ-OP-RNRTIT2 (holder's RNR)

### External Systems

**SEBNKUK9 (IBAN Validation Service):**
- **Type**: External CALL to validation program
- **Purpose**: Validate IBAN format, extract BIC code, determine bank
- **Interface**: SEBNKUKW copybook
- **Error Handling**: Reject payment if validation status NOT = 0, 1, or 2
- **Timeout**: Service must respond within 500ms
- **Code**: [cbl/MYFIN.cbl#L1246-L1248](../../../cbl/MYFIN.cbl#L1246-L1248)

**SCHRKCX9 (Member Account Search):**
- **Type**: External service via COPY SEPAKCXD
- **Purpose**: Retrieve member's known bank account from database
- **Interface**: SEPAKCXW copybook (SCHRK-INTERFACE)
- **Error Handling**: Non-fatal - log error but continue processing
- **Code**: [cbl/MYFIN.cbl#L1206](../../../cbl/MYFIN.cbl#L1206)

**Bank Account Discrepancy List (500006):**
- **Type**: File output (remote printing record)
- **Purpose**: Report when payment uses different account than member's known account
- **Interface**: BFN56CXR copybook structure
- **List Variants**: 500006 (general), 500076 (Flemish), 500096 (Walloon), 500066 (Brussels), 500086 (German)
- **Special Case**: List 541006 not generated per MIS01 modification
- **Code**: [cbl/MYFIN.cbl#L1039-L1107](../../../cbl/MYFIN.cbl#L1039-L1107)

## Configuration

| Parameter | Source | Required | Default | Description |
|-----------|--------|----------|---------|-------------|
| WS-SEBNK-IBAN-IN | TRBFN-IBAN | Yes | N/A | IBAN to validate |
| WS-SEBNK-BETWYZ-IN | TRBFN-BETWYZ | Yes | ' ' | Payment method |
| WS-SEBNK-WELKEBANK | Program sets | Yes | "0" | Bank selection: "0"=Belfius, "1"=KBC |
| SCHRK-CODE-LIBEL | TRBFN-CODE-LIBEL | Yes | N/A | Payment description code for account search |
| SCHRK-DAT-VAL | SP-ACTDAT | Yes | Current date | Validation date for account search |

## Implementation Notes

### Code References

- **Main Implementation**: 
  - Source: [cbl/MYFIN.cbl#L338-L387](../../../cbl/MYFIN.cbl#L338-L387) - VOIR-BANQUE-DEBIT paragraph
- **IBAN Validation Service Call**: 
  - Source: [cbl/MYFIN.cbl#L1246-L1248](../../../cbl/MYFIN.cbl#L1246-L1248) - WELKE-BANK paragraph
- **Member Account Lookup**: 
  - Source: [cbl/MYFIN.cbl#L1109-L1200](../../../cbl/MYFIN.cbl#L1109-L1200) - RECH-NO-BANCAIRE paragraph
  - Source: [cbl/MYFIN.cbl#L1202-L1220](../../../cbl/MYFIN.cbl#L1202-L1220) - RECHERCHE-CPTE-MEMBRE paragraph
- **Bank Selection for Regional Accounting**: 
  - Source: [cbl/MYFIN.cbl#L485-L523](../../../cbl/MYFIN.cbl#L485-L523) - CREER-USER-500001 paragraph
- **Discrepancy List Creation**: 
  - Source: [cbl/MYFIN.cbl#L1039-L1107](../../../cbl/MYFIN.cbl#L1039-L1107) - CREER-REMOTE-500006 paragraph

### Design Patterns Used

- **External Service Integration**: Call SEBNKUK9 for IBAN validation (separation of concerns)
- **Fail-Fast Validation**: Reject immediately if IBAN invalid
- **Non-Blocking Discrepancy**: Account differences reported but don't prevent payment
- **Mandatory Bank Routing**: Regional payments (types 3-6) must use Belfius, no exceptions
- **Age-Based Account Holder Logic**: Young members use parent/holder's account

### Dependencies

- **Copybooks**: 
  - SEBNKUKW.cpy: IBAN validation service interface
  - SEPAKCXW.cpy: Member account search interface
  - SEPAAUKU.cpy: SEPA user payment instruction structure
  - BFN56CXR.cpy: Bank account discrepancy list structure
- **Called Programs**: 
  - SEBNKUK9: IBAN validation and BIC extraction service
  - SCHRKCX9: Member bank account search (via COPY SEPAKCXD)
- **System Services**: 
  - COPY SEPAKCXD: Database access for member account lookup
  - Date conversion utilities for age calculation

## Test Scenarios

### Positive Tests

1. **Valid Belgian IBAN**
   - Input: TRBFN-IBAN = "BE68539007547034", TRBFN-BETWYZ = ' '
   - Expected: WS-SEBNK-STAT-OUT = 0, BIC extracted, SAV-WELKEBANK = 1, processing continues

2. **Valid foreign IBAN with SEPA transfer**
   - Input: TRBFN-IBAN = "FR7630006000011234567890189", TRBFN-BETWYZ = ' '
   - Expected: IBAN validated, BIC extracted, payment processes normally

3. **Regional accounting - Flemish region**
   - Input: TRBFN-TYPE-COMPTA = 3, valid IBAN
   - Expected: WELKEBANK = 0 (Belfius), federation = 167, U-BAC-KODE = 13

4. **Bank account matches member's known account**
   - Input: TRBFN-COMPTE-MEMBRE = 1, TRBFN-IBAN matches SAV-IBAN
   - Expected: No discrepancy record created

5. **Member account found successfully**
   - Input: Valid member, SCHRK-CODE-LIBEL set
   - Expected: SCHRK-STATUS = 0, SAV-IBAN populated with member's account

### Negative Tests

1. **Invalid IBAN format**
   - Input: TRBFN-IBAN = "INVALID123", TRBFN-BETWYZ = ' '
   - Expected: WS-SEBNK-STAT-OUT NOT = 0/1/2, rejection with "IBAN FOUTIEF/IBAN ERRONE"

2. **IBAN validation service unavailable**
   - Scenario: SEBNKUK9 program not found or returns error
   - Expected: System error, possible ABEND (depends on configuration)

3. **Bank account discrepancy**
   - Input: TRBFN-COMPTE-MEMBRE = 0, TRBFN-IBAN differs from SAV-IBAN
   - Expected: Discrepancy record created on list 500006, payment processing continues

4. **Member account search fails**
   - Input: SCHRK-STATUS = 5 (error code)
   - Expected: Error message logged, SAV-IBAN = SPACES, processing continues

5. **Member too young for own account**
   - Input: Member age < 14 (women) or < 16 (men)
   - Expected: SW-TROP-JEUNE = 1, holder's account lookup performed instead

## Acceptance Criteria

- [x] IBAN format validated via SEBNKUK9 service (status 0, 1, or 2 accepted)
- [x] BIC code extracted and stored in WS-BIC
- [x] Invalid IBANs rejected with bilingual message "IBAN FOUTIEF/IBAN ERRONE"
- [x] Regional accounting payments (types 3-6) routed to Belfius only
- [x] Member's known bank account retrieved via SCHRKCX9
- [x] Bank account discrepancies reported on list 500006 (non-blocking)
- [x] Age validation performed (14+/16+ minimum)
- [x] Payment method eligibility checked based on TRBFN-CODE-LIBEL
- [x] Bank selection logic correctly implements Belfius vs. KBC routing

## Open Issues

- [ ] Confirm complete list of payment codes eligible for KBC routing (currently only Belfius documented)
- [ ] Document BIC code usage in downstream banking systems
- [ ] Clarify SEBNKUK9 service availability and fallback procedures
- [ ] Document handling of IBAN status code 1 vs. 2 (both accepted as valid)
- [ ] Confirm whether list 541006 suppression (MIS01) is permanent or conditional
