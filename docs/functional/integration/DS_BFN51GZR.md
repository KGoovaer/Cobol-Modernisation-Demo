# Data Structure: BFN51GZR - Payment List 500001

**ID**: DS_BFN51GZR  
**Type**: Output List Record Structure  
**Purpose**: Remote printing record for list 500001 - Valid payments to be processed  
**Source Copybook**: [copy/bfn51gzr.cpy](../../../copy/bfn51gzr.cpy)  
**Program Reference**: [cbl/MYFIN.cbl](../../../cbl/MYFIN.cbl) - CREER-REMOTE-500001 (lines 820-915)  
**Last Updated**: 2026-01-29

## Overview

BFN51GZR is the output record structure for list 500001 (GBBF1/GR5001), which contains all validated payments ready for processing. This list is created by MYFIN for each successfully validated manual GIRBET payment that passes all validation checks (duplicate detection, bank account validation, etc.). The record format includes SEPA/IBAN fields and support for multiple account types and payment methods.

### Business Purpose

List 500001 serves as the primary output for **valid payments**:
- Successfully validated manual payments
- Payments with complete and correct bank account information (IBAN or legacy account number)
- Payments that passed duplicate detection
- Ready for further processing in the payment system

### Related Lists

- **List 500004** (BFN54GZR): Rejected payments with diagnostic messages
- **List 500006** (BFN56CXR): Discrepancy report (IBAN mismatch between input and member database)

## Record Layout

### Record Metadata (Not Included in Length)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| BBF-N51-LENGTH | S9(04) COMP | 4 bytes | 1-4 | Record length in bytes (not included in length calculation) |
| BBF-N51-CODE | S9(04) COMP | 4 bytes | 5-8 | Record code = 40 (not included in length calculation) |
| BBF-N51-NUMBER | 9(08) | 8 bytes | 9-16 | Sequential number from ADD-LOG (not included in length calculation) |

### Remote Printing Header

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N51-DEVICE-OUT** | X(01) | 1 byte | 17 | Output device type | 'L' = List (standard), 'C' = Console (for destination 153) |
| **BBF-N51-DESTINATION** | 9(03) | 3 bytes | 18-20 | Destination federation code | From TRBFN-DEST (109-169) |
| **BBF-N51-SWITCHING** | X(01) | 1 byte | 21 | Switching indicator | SPACE (blank) |
| **BBF-N51-PRIORITY** | X(01) | 1 byte | 22 | Priority indicator | 'Z' = Normal priority |
| **BBF-N51-NAME** | X(06) | 6 bytes | 23-28 | List name | "500001" (standard payment list) |

### Record Key (BBF-N51-KEY)

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N51-VERB** | 9(03) | 3 bytes | 29-31 | Federation number | From TRBFN-DEST (mutuality group 109-169) |
| **BBF-N51-AFK** | 9(01) | 1 byte | 32 | Account type indicator | See Account Type Values below |
| **BBF-N51-KONST** | 9(10) | 10 bytes | 33-42 | Constant identifier | From TRBFN-CONSTANTE |
| **BBF-N51-VOLGNR** | 9(04) | 4 bytes | 43-46 | Sequence number | From TRBFN-NO-SUITE |
| **BBF-N51-INFOREK** | 9(01) | 1 byte | 47 | INFOREK indicator | MTU modification |
| **FILLER** | X(61) | 61 bytes | 48-108 | Reserved for future use | SPACES |

#### Account Type Values (BBF-N51-AFK)

| Value | Constant | Description | Business Context |
|-------|----------|-------------|------------------|
| 1 | LOKET | Counter/window payment | Physical location payment |
| 2 | PAIFIN-AO | PAIFIN old account | Legacy payment system |
| 3 | PAIFIN-AL | PAIFIN other account | Alternative payment account |
| 4 | FRANCHISE | Franchise payment | Franchise-related transaction |
| 5 | EATTEST | E-attestation | Electronic attestation (EATT modification) |
| 6 | CORREG | Correction | Correction entry (MSA001 modification) |
| 7 | BULK-INPUT | Bulk input | Bulk processing (MSA002 modification) |

### Payment Data (BBF-N51-DATA)

| Field | Type | Length | Position | Description | Source/Transformation |
|-------|------|--------|----------|-------------|----------------------|
| **BBF-N51-RNR** | X(13) | 13 bytes | 109-121 | National registry number | From WS-RIJKSNUMMER |
| **BBF-N51-NAAM** | X(18) | 18 bytes | 122-139 | Member last name | From ADM-NAAM |
| **BBF-N51-VOORN** | X(12) | 12 bytes | 140-151 | Member first name | From ADM-VOORN |
| **BBF-N51-LIBEL** | 9(02) | 2 bytes | 152-153 | Payment label code | From TRBFN-CODE-LIBEL |
| **BBF-N51-REKNR** | X(14) | 14 bytes | 154-167 | Account number | Legacy bank account format (MTU modification changed from 9(14) to X(14)) |
| **BBF-N51-BEDRAG** | 9(06) | 6 bytes | 168-173 | Payment amount | From TRBFN-MONTANT (max 999,999) |
| **BBF-N51-BANK** | 9(01) | 1 byte | 174 | Bank code | 1=BACCOB, 2=CERA, 3=BVR |

### Currency and Euro Support

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N51-DV** | X(01) | 1 byte | 175 | Currency code | From TRBFN-MONTANT-DV: 'E'=Euro, 'B'=BEF |
| **BBF-N51-DN** | 9(01) | 1 byte | 176 | Decimal precision | 0=no decimals (BEF), 2=2 decimals (Euro) |

### SEPA/IBAN Fields (MTU1/SEPA Modifications)

| Field | Type | Length | Position | Description | Source/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N51-TYPE-COMPTE** | X(04) | 4 bytes | 177-180 | Account type | MTU1 modification |
| **BBF-N51-IBAN** | X(34) | 34 bytes | 181-214 | IBAN account number | From TRBFN-IBAN (SEPA modification) |
| **BBF-N51-BETWY** | X(01) | 1 byte | 215 | Payment method | From TRBFN-BETWYZ (SEPA modification) |
| **BBF-N51-TAGREG-OP** | 9(02) | 2 bytes | 216-217 | Regional tag operator | 6th State Reform (224154 modification) |

## Field Mappings and Transformations

### Source: TRBFNCXP Input → BFN51GZR Output

```cobol
**** Key mapping from input to output
MOVE 40                 TO BBF-N51-CODE
MOVE "500001"           TO BBF-N51-NAME
MOVE TRBFN-DEST         TO BBF-N51-DESTINATION
MOVE TRBFN-DEST         TO BBF-N51-VERB
MOVE TRBFN-CONSTANTE    TO BBF-N51-KONST
MOVE TRBFN-NO-SUITE     TO BBF-N51-VOLGNR

**** Payment data mapping
MOVE WS-RIJKSNUMMER     TO BBF-N51-RNR
MOVE ADM-NAAM           TO BBF-N51-NAAM
MOVE ADM-VOORN          TO BBF-N51-VOORN
MOVE TRBFN-CODE-LIBEL   TO BBF-N51-LIBEL
MOVE TRBFN-MONTANT      TO BBF-N51-BEDRAG

**** Currency handling
MOVE TRBFN-MONTANT-DV   TO BBF-N51-DV
IF TRBFN-MONTANT-DV = "E"
   MOVE 2 TO BBF-N51-DN
ELSE
   MOVE 0 TO BBF-N51-DN
END-IF

**** IBAN/Bank account handling
IF TRBFN-IBAN NOT = SPACES
   MOVE SPACES         TO BBF-N51-REKNR
   MOVE TRBFN-IBAN     TO BBF-N51-IBAN
ELSE
   MOVE TRBFN-NO-BANCAIRE TO BBF-N51-REKNR
   MOVE SPACES            TO BBF-N51-IBAN
END-IF

MOVE TRBFN-BETWYZ       TO BBF-N51-BETWY
```

### Account Type Assignment Logic

```cobol
**** Account type (AFK) assignment based on account type (TRBFN-TYPE-COMPTA)
IF TRBFN-TYPE-COMPTA = 1
   MOVE 2 TO BBF-N51-AFK    * PAIFIN-AO
ELSE
   MOVE 3 TO BBF-N51-AFK    * PAIFIN-AL
END-IF
```

### Device Output Logic

```cobol
**** Output device determination
IF TRBFN-DEST = 153
   MOVE "C" TO BBF-N51-DEVICE-OUT    * Console for destination 153
ELSE
   MOVE "L" TO BBF-N51-DEVICE-OUT    * List for all other destinations
END-IF
```

## Business Rules

### Record Creation Conditions

List 500001 records are created ONLY when:

1. **Input validation passes** ([FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md))
   - All mandatory fields present
   - National registry number valid format
   - Amount within acceptable range

2. **Duplicate check passes** ([FUREQ_MYFIN_002](../requirements/FUREQ_MYFIN_002_duplicate_detection.md))
   - No duplicate found in database (UAREA table)
   - Unique combination of: federation + constant + sequence number

3. **Bank account validation passes** ([FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md))
   - Valid IBAN format (if IBAN provided)
   - Valid legacy account number (if no IBAN)
   - Bank account exists and is active

4. **Member data retrieved successfully**
   - Member exists in MUTF08 database
   - Member name and first name populated

### Record Not Created When

Records are **NOT** written to list 500001 if:

- Input validation fails → Record written to **list 500004** (BFN54GZR) with diagnostic
- Duplicate detected → Record written to **list 500004** with diagnostic "DUBBEL"
- Bank account validation fails → Record written to **list 500004** with appropriate diagnostic
- IBAN mismatch detected → Record written to **list 500006** (BFN56CXR) discrepancy report

## Related Functional Requirements

| Requirement ID | Title | Relationship |
|----------------|-------|--------------|
| [FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md) | Input Validation | Prerequisite - validation must pass |
| [FUREQ_MYFIN_002](../requirements/FUREQ_MYFIN_002_duplicate_detection.md) | Duplicate Detection | Prerequisite - no duplicates allowed |
| [FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md) | Bank Account Validation | Prerequisite - account must be valid |
| [FUREQ_MYFIN_004](../requirements/FUREQ_MYFIN_004_payment_list_generation.md) | Payment List Generation | Direct implementation |
| [FUREQ_MYFIN_005](../requirements/FUREQ_MYFIN_005_payment_record_creation.md) | Payment Record Creation | Direct implementation |

## Historical Modifications

| Modification | Date | Description | Impact |
|--------------|------|-------------|--------|
| **MTU** | - | INFOREK project | Added BBF-N51-INFOREK field |
| **MTU** | - | Account number format | Changed BBF-N51-REKNR from 9(14) to X(14) |
| **MTU1** | - | Account type support | Added BBF-N51-TYPE-COMPTE field |
| **SEPA** | - | SEPA/IBAN compliance | Added BBF-N51-IBAN, BBF-N51-BETWY fields |
| **EATT** | - | E-attestation support | Added BBF-N51-AFK value 5 (EATTEST) |
| **224154** | 15/10/2018 | 6th State Reform | Added BBF-N51-TAGREG-OP field |
| **MSA001** | 26/07/2023 | JIRA-4334 | Added BBF-N51-AFK value 6 (CORREG) |
| **MSA002** | 23/01/2025 | JIRA-891 | Added BBF-N51-AFK value 7 (BULK-INPUT) |

## Usage Examples

### Example 1: Standard Payment with IBAN

```cobol
* Input: TRBFNCXP record
*   TRBFN-DEST = 109 (Mutualité Chrétienne)
*   TRBFN-CONSTANTE = 1234567890
*   TRBFN-NO-SUITE = 1
*   TRBFN-IBAN = "BE68539007547034"
*   TRBFN-MONTANT = 12500 (125.00 EUR)
*   TRBFN-MONTANT-DV = "E"

* Output: BFN51GZR record
*   BBF-N51-CODE = 40
*   BBF-N51-NAME = "500001"
*   BBF-N51-DESTINATION = 109
*   BBF-N51-VERB = 109
*   BBF-N51-KONST = 1234567890
*   BBF-N51-VOLGNR = 1
*   BBF-N51-IBAN = "BE68539007547034"
*   BBF-N51-REKNR = SPACES
*   BBF-N51-BEDRAG = 12500
*   BBF-N51-DV = "E"
*   BBF-N51-DN = 2
```

### Example 2: Legacy Payment without IBAN

```cobol
* Input: TRBFNCXP record
*   TRBFN-DEST = 141
*   TRBFN-NO-BANCAIRE = "73100512345678"
*   TRBFN-IBAN = SPACES
*   TRBFN-MONTANT = 5000 (50.00 BEF - legacy)
*   TRBFN-MONTANT-DV = "B"

* Output: BFN51GZR record
*   BBF-N51-IBAN = SPACES
*   BBF-N51-REKNR = "73100512345678"
*   BBF-N51-BEDRAG = 5000
*   BBF-N51-DV = "B"
*   BBF-N51-DN = 0
```

## Testing Considerations

### Validation Tests

- Verify record structure matches copybook definition (217 bytes total)
- Verify all mandatory fields are populated
- Verify IBAN format is correct (up to 34 characters)
- Verify amount does not exceed 999,999
- Verify currency code is either 'E' or 'B'
- Verify decimal precision matches currency (0 for BEF, 2 for Euro)

### Integration Tests

- Verify list 500001 contains only valid payments (no validation errors)
- Verify rejected payments appear in list 500004 (not in 500001)
- Verify IBAN mismatches appear in list 500006 (not in 500001)
- Verify sequential numbering (BBF-N51-NUMBER) is correct
- Verify output device routing works correctly (L vs C)

### Business Scenario Tests

- Process multiple payments for same mutuality (verify grouping)
- Process payments with various account types (AFK values 1-7)
- Process Euro vs BEF payments (verify currency handling)
- Process IBAN vs legacy account numbers
- Process payments for destination 153 (verify console output)

## Performance Considerations

- Record size: 217 bytes per payment record
- Volume: Typical batch processes 1000-5000 payment records
- List 500001 typically contains 60-80% of input records (valid payments)
- List 500004 contains 15-30% (rejected)
- List 500006 contains 5-10% (IBAN discrepancies)

## Related Data Structures

- **[DS_TRBFNCXP](DS_TRBFNCXP.md)**: Primary input record structure
- **[DS_INFPRGZP](DS_INFPRGZP.md)**: Alternative input record structure
- **[DS_BFN54GZR](DS_BFN54GZR.md)**: Rejected payment list (500004)
- **[DS_BFN56CXR](DS_BFN56CXR.md)**: IBAN discrepancy report (500006)
- **[DS_BBFPRGZP](DS_BBFPRGZP.md)**: BBF payment record for magnetic tape
- **[DS_SEPAAUKU](DS_SEPAAUKU.md)**: SEPA validation record
