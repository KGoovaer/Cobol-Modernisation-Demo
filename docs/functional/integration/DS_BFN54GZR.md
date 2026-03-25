# Data Structure: BFN54GZR - Rejection List 500004

**ID**: DS_BFN54GZR  
**Type**: Output List Record Structure  
**Purpose**: Remote printing record for list 500004 - Rejected payments with diagnostic messages  
**Source Copybook**: [copy/bfn54gzr.cpy](../../../copy/bfn54gzr.cpy)  
**Program Reference**: [cbl/MYFIN.cbl](../../../cbl/MYFIN.cbl) - CREER-REMOTE-500004 (lines 920-978)  
**Last Updated**: 2026-01-29

## Overview

BFN54GZR is the output record structure for list 500004 (GRBBFN54/G8GR5004), which contains all **rejected payments** discovered during batch processing. This list captures payments that failed validation checks, including duplicate detection failures, bank account validation errors, input data errors, and other processing anomalies. Each rejected record includes a 32-character diagnostic message explaining the reason for rejection.

### Business Purpose

List 500004 serves as the **error/rejection report** for manual GIRBET payments:
- Failed validation payments (mandatory field errors, format errors)
- Duplicate payments detected in the database
- Invalid bank account numbers or IBANs
- Member data retrieval failures
- Any payment that cannot be processed successfully

This list is critical for:
- **Error correction**: Allows administrators to identify and fix payment issues
- **Audit trail**: Tracks all rejected transactions with reasons
- **Reconciliation**: Ensures all input records are accounted for (valid or rejected)

### Related Lists

- **List 500001** (BFN51GZR): Valid payments ready for processing
- **List 500006** (BFN56CXR): IBAN discrepancy report (mismatch between input and member database)

## Record Layout

### Record Metadata (Not Included in Length)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| BBF-N54-LENGTH | S9(04) COMP | 4 bytes | 1-4 | Record length in bytes (not included in length calculation) |
| BBF-N54-CODE | S9(04) COMP | 4 bytes | 5-8 | Record code = 40 (standard rejection code) |
| BBF-N54-NUMBER | 9(08) | 8 bytes | 9-16 | Sequential number from ADD-LOG (not included in length calculation) |

### Remote Printing Header

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N54-DEVICE-OUT** | X(01) | 1 byte | 17 | Output device type | 'L' = List (standard) |
| **BBF-N54-DESTINATION** | 9(03) | 3 bytes | 18-20 | Destination federation code | 106 (Brussels - VERBOND 106) |
| **BBF-N54-SWITCHING** | X(01) | 1 byte | 21 | Switching indicator | SPACE (blank) |
| **BBF-N54-PRIORITY** | X(01) | 1 byte | 22 | Priority indicator | 'Z' = Low priority (rejection list) |
| **BBF-N54-NAME** | X(06) | 6 bytes | 23-28 | List name (NEP-NAME) | "500004" (rejection list) |

### Record Key (BBF-N54-KEY)

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N54-VERB** | 9(03) | 3 bytes | 29-31 | Federation number | 106 (Brussels) for all rejections |
| **BBF-N54-KONSTA** | 9(10) | 10 bytes | 32-41 | Constant identifier | From TRBFN-CONSTANTE |
| **BBF-N54-VOLGNR** | 9(04) | 4 bytes | 42-45 | Sequence number | From TRBFN-NO-SUITE (M30) |
| **BBF-N54-TAAL** | 9(01) | 1 byte | 46 | Language code | Member's language preference |
| **BBF-N54-INF** | 9(01) | 1 byte | 47 | INFOREK indicator | MTU modification |
| **BBF-N54-INF-VOL** | 9(02) | 2 bytes | 48-49 | INFOREK volume | MTU modification |
| **FILLER** | X(59) | 59 bytes | 50-108 | Reserved for future use | SPACES |

### Rejection Data (BBF-N54-DATA)

#### Administrative Fields

| Field | Type | Length | Position | Description | Source/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N54-VBOND** | 9(02) | 2 bytes | 109-110 | Federation number (2 digits) | From TRBFN-DEST |
| **BBF-N54-KONST** | - | 10 bytes | 111-120 | Constant composite field | See breakdown below |
| &nbsp;&nbsp;&nbsp;BBF-N54-AFDEL | 9(03) | 3 bytes | 111-113 | Department/section number | From TRBFN-CONSTANTE |
| &nbsp;&nbsp;&nbsp;BBF-N54-KASSIER | 9(03) | 3 bytes | 114-116 | Cashier number | From TRBFN-CONSTANTE |
| &nbsp;&nbsp;&nbsp;BBF-N54-DATZIT-DM | 9(04) | 4 bytes | 117-120 | Session date (DDMM format) | From TRBFN-CONSTANTE |

#### Payment Details

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N54-BETWYZ** | X(01) | 1 byte | 121 | Residual payment method | 'C' = Circular check (for Brussels) |
| **BBF-N54-RNR** | X(13) | 13 bytes | 122-134 | National registry number | From WS-RIJKSNUMMER |
| **BBF-N54-BETKOD** | 9(02) | 2 bytes | 135-136 | Payment reason code | "26" or other code |
| **BBF-N54-BEDRAG** | 9(08) | 8 bytes | 137-144 | Amount | Max 50,000 BEF (legacy), expanded for Euro |
| **BBF-N54-REKNUM** | 9(12) | 12 bytes | 145-156 | Bank account number (numeric) | See redefines below |

**BBF-N54-REKNR** (redefines BBF-N54-REKNUM):
- **BBF-N54-REKNR-PART1** | 9(03) | 3 bytes | 145-147 | Account part 1
- **BBF-N54-REKNR-PART2** | 9(07) | 7 bytes | 148-154 | Account part 2
- **BBF-N54-REKNR-PART3** | 9(02) | 2 bytes | 155-156 | Account part 3

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N54-VOLGNR-M30** | 9(03) | 3 bytes | 157-159 | M30 sequence number | From TRBFN-NO-SUITE |

### Diagnostic Information

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BBF-N54-DIAG** | X(32) | 32 bytes | 160-191 | **Error diagnostic message** - explains rejection reason |

**Common Diagnostic Messages**:
- "DUBBEL" - Duplicate payment detected
- "ONGELDIG REKENING NUMMER" - Invalid bank account number
- "ONGELDIG IBAN" - Invalid IBAN format
- "LID NIET GEVONDEN" - Member not found in database
- "VERPLICHT VELD ONTBREEKT" - Mandatory field missing
- "BEDRAG TE HOOG" - Amount exceeds maximum

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **FILLER** | 9(03) | 3 bytes | 192-194 | Reserved |

### Currency and Euro Support

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N54-DV** | X(01) | 1 byte | 195 | Currency code | 'E'=Euro, 'B'=BEF |
| **BBF-N54-DN** | 9(01) | 1 byte | 196 | Decimal precision | 0=no decimals (BEF), 2=2 decimals (Euro) |

### INFOREK Additional Data (BBF-N54-INF0)

| Field | Type | Length | Position | Description | MTU Modification |
|-------|------|--------|----------|-------------|------------------|
| **BBF-N54-PREST** | 9(01) | 1 byte | 197 | Prestation type | MTU |
| **BBF-N54-SPEC** | 9(03) | 3 bytes | 198-200 | Specialty code | MTU |
| **BBF-N54-AANT** | 9(02) | 2 bytes | 201-202 | Quantity/amount | MTU |
| **BBF-N54-DATE** | 9(06) | 6 bytes | 203-208 | Date (YYMMDD) | MTU |
| **BBF-N54-HONOR** | 9(06) | 6 bytes | 209-214 | Honorarium/fee | MTU |
| **BBF-N54-RNR2** | X(13) | 13 bytes | 215-227 | Secondary national registry number | MTU |

### SEPA/IBAN Fields (SEPA Modification)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BBF-N54-IBAN** | X(34) | 34 bytes | 228-261 | IBAN account number (if applicable) |
| **BBF-N54-TAGREG-OP** | 9(02) | 2 bytes | 262-263 | Regional tag operator (6th State Reform - 224154) |

## Field Mappings and Transformations

### Source: TRBFNCXP Input → BFN54GZR Output (Rejection)

```cobol
**** Rejection record creation
MOVE 40                 TO BBF-N54-CODE
MOVE "500004"           TO BBF-N54-NAME
MOVE "L"                TO BBF-N54-DEVICE-OUT
MOVE 106                TO BBF-N54-DESTINATION   * Fixed: Brussels
MOVE SPACE              TO BBF-N54-SWITCHING
MOVE "Z"                TO BBF-N54-PRIORITY

**** Key mapping
MOVE 106                TO BBF-N54-VERB          * Fixed: Brussels
MOVE TRBFN-CONSTANTE    TO BBF-N54-KONSTA
MOVE TRBFN-NO-SUITE     TO BBF-N54-VOLGNR
MOVE TRBFN-NO-SUITE     TO BBF-N54-VOLGNR-M30

**** Payment data
MOVE TRBFN-DEST         TO BBF-N54-VBOND
MOVE TRBFN-BETWYZ       TO BBF-N54-BETWYZ
MOVE WS-RIJKSNUMMER     TO BBF-N54-RNR
MOVE TRBFN-CODE-BETALING TO BBF-N54-BETKOD
MOVE TRBFN-MONTANT      TO BBF-N54-BEDRAG

**** Bank account handling
IF TRBFN-IBAN NOT = SPACES
   MOVE TRBFN-IBAN      TO BBF-N54-IBAN
   MOVE ZEROS           TO BBF-N54-REKNUM
ELSE
   MOVE TRBFN-NO-BANCAIRE TO BBF-N54-REKNUM
   MOVE SPACES            TO BBF-N54-IBAN
END-IF

**** Currency handling
MOVE TRBFN-MONTANT-DV   TO BBF-N54-DV
IF TRBFN-MONTANT-DV = "E"
   MOVE 2 TO BBF-N54-DN
ELSE
   MOVE 0 TO BBF-N54-DN
END-IF

**** Diagnostic message (set based on error type)
MOVE "DUBBEL"           TO BBF-N54-DIAG    * If duplicate detected
* OR
MOVE "ONGELDIG REKENING NUMMER" TO BBF-N54-DIAG  * If invalid account
```

## Business Rules

### Record Creation Conditions

List 500004 records are created when:

1. **Input Validation Fails** ([FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md))
   - Mandatory field missing
   - Invalid data format (e.g., non-numeric in numeric field)
   - Amount exceeds maximum allowed
   - Invalid national registry number format

2. **Duplicate Detected** ([FUREQ_MYFIN_002](../requirements/FUREQ_MYFIN_002_duplicate_detection.md))
   - Exact match found in UAREA database table
   - Same federation + constant + sequence number combination
   - Diagnostic: "DUBBEL"

3. **Bank Account Validation Fails** ([FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md))
   - Invalid IBAN format or checksum
   - Invalid legacy account number structure
   - Bank account not found or inactive
   - Diagnostic varies: "ONGELDIG REKENING NUMMER", "ONGELDIG IBAN"

4. **Member Data Retrieval Fails**
   - Member not found in MUTF08 database
   - National registry number does not match any member
   - Diagnostic: "LID NIET GEVONDEN"

5. **Database Access Errors**
   - SQL errors during processing
   - Database unavailable
   - Diagnostic: technical error message

### Diagnostic Message Standards

| Error Type | Diagnostic Message | Business Context |
|------------|-------------------|------------------|
| Duplicate payment | "DUBBEL" | Payment already exists in database |
| Invalid account | "ONGELDIG REKENING NUMMER" | Legacy account number format/checksum error |
| Invalid IBAN | "ONGELDIG IBAN" | IBAN format or checksum validation failure |
| Member not found | "LID NIET GEVONDEN" | National registry number not in MUTF08 |
| Missing field | "VERPLICHT VELD ONTBREEKT" | Mandatory field is blank or zero |
| Amount too high | "BEDRAG TE HOOG" | Exceeds maximum allowed (50,000 BEF or Euro equivalent) |
| Database error | "DATABASE FOUT: [details]" | SQL error or database unavailable |

## Historical Modifications

| Modification | Date | Description | Impact |
|--------------|------|-------------|--------|
| **MTU** | - | INFOREK project | Added BBF-N54-INF, BBF-N54-INF-VOL, BBF-N54-INF0 section |
| **SEPA** | - | SEPA/IBAN compliance | Added BBF-N54-IBAN field (34 bytes) |
| **224154** | 15/10/2018 | 6th State Reform | Added BBF-N54-TAGREG-OP field |

## Usage Examples

### Example 1: Duplicate Payment Rejection

```cobol
* Input: TRBFNCXP record (already exists in database)
*   TRBFN-DEST = 109
*   TRBFN-CONSTANTE = 1234567890
*   TRBFN-NO-SUITE = 1
*   
* Database check: Record already exists in UAREA table
*
* Output: BFN54GZR rejection record
*   BBF-N54-CODE = 40
*   BBF-N54-NAME = "500004"
*   BBF-N54-DESTINATION = 106    * Fixed: Brussels
*   BBF-N54-VERB = 106            * Fixed: Brussels
*   BBF-N54-VBOND = 109           * Original mutuality
*   BBF-N54-KONSTA = 1234567890
*   BBF-N54-VOLGNR = 1
*   BBF-N54-DIAG = "DUBBEL"       * Diagnostic: duplicate
*   BBF-N54-PRIORITY = "Z"        * Low priority (rejection)
```

### Example 2: Invalid IBAN Rejection

```cobol
* Input: TRBFNCXP record with invalid IBAN
*   TRBFN-IBAN = "BE99999999999999" (invalid checksum)
*   TRBFN-MONTANT = 15000 (150.00 EUR)
*   TRBFN-MONTANT-DV = "E"
*
* IBAN validation: Checksum fails
*
* Output: BFN54GZR rejection record
*   BBF-N54-IBAN = "BE99999999999999"
*   BBF-N54-BEDRAG = 15000
*   BBF-N54-DV = "E"
*   BBF-N54-DN = 2
*   BBF-N54-DIAG = "ONGELDIG IBAN"
*   BBF-N54-DESTINATION = 106
*   BBF-N54-PRIORITY = "Z"
```

### Example 3: Member Not Found Rejection

```cobol
* Input: TRBFNCXP record with unknown national registry number
*   TRBFN-RNR = "99123456789" (not in MUTF08 database)
*
* Database lookup: No member found
*
* Output: BFN54GZR rejection record
*   BBF-N54-RNR = "99123456789"
*   BBF-N54-DIAG = "LID NIET GEVONDEN"
*   BBF-N54-DESTINATION = 106
```

## Testing Considerations

### Validation Tests

- Verify record structure matches copybook definition (263 bytes total)
- Verify all rejection scenarios produce appropriate diagnostic messages
- Verify destination is always 106 (Brussels) for rejections
- Verify priority is always 'Z' (low priority)
- Verify device output is always 'L' (list)

### Integration Tests

- Verify rejected payments do NOT appear in list 500001 (valid payments)
- Verify all input records are accounted for (500001 + 500004 + 500006 = total input)
- Verify duplicate detection writes to 500004 with "DUBBEL" diagnostic
- Verify IBAN validation failures write to 500004 with appropriate diagnostic
- Verify sequential numbering (BBF-N54-NUMBER) is correct

### Business Scenario Tests

- Process duplicate payment (verify rejection with "DUBBEL")
- Process invalid IBAN (verify rejection with "ONGELDIG IBAN")
- Process invalid account number (verify rejection)
- Process payment for non-existent member (verify "LID NIET GEVONDEN")
- Process payment with missing mandatory field
- Process payment with amount exceeding maximum

## Performance Considerations

- Record size: 263 bytes per rejection record
- Volume: List 500004 typically contains 15-30% of input records
- High rejection rate (>50%) indicates data quality issues requiring investigation
- Diagnostic messages should be clear for efficient error correction

## Related Data Structures

- **[DS_TRBFNCXP](DS_TRBFNCXP.md)**: Primary input record structure
- **[DS_BFN51GZR](DS_BFN51GZR.md)**: Valid payment list (500001)
- **[DS_BFN56CXR](DS_BFN56CXR.md)**: IBAN discrepancy report (500006)
- **[DS_BBFPRGZP](DS_BBFPRGZP.md)**: BBF payment record for magnetic tape

## Related Functional Requirements

| Requirement ID | Title | Relationship |
|----------------|-------|--------------|
| [FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md) | Input Validation | Validation failures → list 500004 |
| [FUREQ_MYFIN_002](../requirements/FUREQ_MYFIN_002_duplicate_detection.md) | Duplicate Detection | Duplicates → list 500004 with "DUBBEL" |
| [FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md) | Bank Account Validation | Invalid accounts → list 500004 |
| [FUREQ_MYFIN_004](../requirements/FUREQ_MYFIN_004_payment_list_generation.md) | Payment List Generation | Rejection list implementation |
