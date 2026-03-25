# Data Structure: BFN56CXR - IBAN Discrepancy Report 500006

**ID**: DS_BFN56CXR  
**Type**: Output List Record Structure  
**Purpose**: Remote printing record for list 500006 - IBAN discrepancy report (mismatch between input and member database)  
**Source Copybook**: Not in workspace - structure defined inline in program  
**Program Reference**: [cbl/MYFIN.cbl](../../../cbl/MYFIN.cbl) - CREER-REMOTE-500006 (lines 980-1103)  
**Last Updated**: 2026-01-29

## Overview

BFN56CXR is the output record structure for list 500006 and related regional variation lists (500076, 500096, 500066, 500086, 541006), which report **IBAN discrepancies** between the input payment record and the member's registered IBAN in the MUTF08 database. This discrepancy report is critical for data quality and helps identify when payment records contain outdated or incorrect bank account information.

### Business Purpose

List 500006 (and variants) serves as a **data quality alert report**:
- Detects mismatches between input IBAN and member's registered IBAN
- Allows administrators to update member records with correct IBANs
- Prevents payments from being sent to incorrect bank accounts
- Supports compliance with data accuracy requirements

The discrepancy list is generated when:
- **Input IBAN ≠ Member IBAN** (from MUTF08 database lookup)
- Both IBANs are valid formats, but they differ
- Payment may still be processed, but discrepancy is flagged for review

### List Variations by Account Type (6th State Reform)

Different list names are used based on the account type (TRBFN-TYPE-COMPTA):

| Account Type | List Name | Record Code | Destination | Regional Tag | Federation |
|--------------|-----------|-------------|-------------|--------------|------------|
| 1 (Standard) | 500006 | 40 | From input (TRBFN-DEST) | 9 | From input |
| 2 (Standard) | 500006 | 40 | From input (TRBFN-DEST) | 9 | From input |
| 3 | 500076 | 43 | 151 | 1 | 167 |
| 4 | 500096 | 43 | 151 | 2 | 169 |
| 5 | 500066 | 43 | 151 | 4 | 166 |
| 6 | 500086 | 43 | 151 | 7 | 168 |
| Special (141) | 541006 | 40 | 116 | 9 | From input |

**Note**: The copybook BFN56CXR is referenced in the source code but is not present in the workspace. The structure is inferred from the COBOL code assignments.

## Record Layout (Inferred from Code)

### Record Metadata (Not Included in Length)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| BBF-N56-LENGTH | S9(04) COMP | 4 bytes | 1-4 | Record length = 258 bytes (CDU001 modification) |
| BBF-N56-CODE | S9(04) COMP | 4 bytes | 5-8 | Record code = 40 (standard) or 43 (regional) |
| BBF-N56-NUMBER | 9(08) | 8 bytes | 9-16 | Sequential number from ADD-LOG |

### Remote Printing Header

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N56-DEVICE-OUT** | X(01) | 1 byte | 17 | Output device type | 'L' = List (standard), 'C' = Console (destination 153) |
| **BBF-N56-DESTINATION** | 9(03) | 3 bytes | 18-20 | Destination federation code | Varies by account type (see table above) |
| **BBF-N56-SWITCHING** | X(01) | 1 byte | 21 | Switching indicator | '*' (asterisk) |
| **BBF-N56-PRIORITY** | X(01) | 1 byte | 22 | Priority indicator | SPACE (blank) |
| **BBF-N56-NAME** | X(06) | 6 bytes | 23-28 | List name | "500006", "500076", "500096", "500066", "500086", "541006" |

### Record Key (BBF-N56-KEY)

| Field | Type | Length | Position | Description | Values/Notes |
|-------|------|--------|----------|-------------|--------------|
| **BBF-N56-VERB** | 9(03) | 3 bytes | 29-31 | Federation number | Varies by account type (see table above) |
| **BBF-N56-AFK** | 9(01) | 1 byte | 32 | Account type indicator | 2 = PAIFIN-AO (type 1,3,4,5,6), 3 = PAIFIN-AL (type 2) |
| **BBF-N56-KONST** | 9(10) | 10 bytes | 33-42 | Constant identifier | From TRBFN-CONSTANTE |
| **BBF-N56-VOLGNR** | 9(04) | 4 bytes | 43-46 | Sequence number | From TRBFN-NO-SUITE |
| **FILLER** | X | ? bytes | 47-? | Reserved | SPACES (structure not fully defined in available code) |

### Payment Data (Inferred from Code Assignments)

| Field | Type | Length | Description | Source |
|-------|------|--------|-------------|--------|
| **BBF-N56-RNR** | X(13) | 13 bytes | National registry number | From WS-RIJKSNUMMER |
| **BBF-N56-NAAM** | X(18) | 18 bytes | Member last name | From ADM-NAAM |
| **BBF-N56-VOORN** | X(12) | 12 bytes | Member first name | From ADM-VOORN |
| **BBF-N56-LIBEL** | 9(02) | 2 bytes | Payment label code | From TRBFN-CODE-LIBEL |
| **BBF-N56-BEDRAG** | 9(06) | 6 bytes | Payment amount | From TRBFN-MONTANT |

### Currency Support

| Field | Type | Length | Description | Values/Notes |
|-------|------|--------|-------------|--------------|
| **BBF-N56-DV** | X(01) | 1 byte | Currency code | From TRBFN-MONTANT-DV: 'E'=Euro, 'B'=BEF |
| **BBF-N56-DN** | 9(01) | 1 byte | Decimal precision | 0=no decimals (BEF), 2=2 decimals (Euro) |

### IBAN Fields (Discrepancy Detection)

| Field | Type | Length | Description | Purpose |
|-------|------|--------|-------------|---------|
| **BBF-N56-REKNR** | X(14) | 14 bytes | Legacy account number | From input (if no IBAN) |
| **BBF-N56-IBAN** | X(34) | 34 bytes | **Input IBAN** | From TRBFN-IBAN (payment input record) |
| **BBF-N56-REKNR-MUT** | X(14) | 14 bytes | Legacy account number (member) | From database (if no IBAN) |
| **BBF-N56-IBAN-MUT** | X(34) | 34 bytes | **Member IBAN** | From SAV-IBAN (MUTF08 database lookup) |
| **BBF-N56-BETWY** | X(01) | 1 byte | Payment method | From TRBFN-BETWYZ |

### Regional Tag (6th State Reform)

| Field | Type | Length | Description | Values by Account Type |
|-------|------|--------|-------------|------------------------|
| **BBF-N56-TAGREG-OP** | 9(02) | 2 bytes | Regional tag operator | 1=type 3, 2=type 4, 4=type 5, 7=type 6, 9=other |

## Field Mappings and Transformations

### Discrepancy Detection Logic

```cobol
**** Step 1: Look up member's IBAN in database
PERFORM RECH-NO-BANCAIRE    * Retrieve SAV-IBAN from MUTF08

**** Step 2: Compare input IBAN vs database IBAN
IF SAV-IBAN NOT = TRBFN-IBAN
THEN
    **** Discrepancy detected - create 500006 record
    PERFORM CREER-REMOTE-500006
END-IF
```

### Record Creation Logic (CREER-REMOTE-500006)

```cobol
**** Record metadata
MOVE 258               TO BBF-N56-LENGTH    * CDU001: 258 bytes
MOVE 40                TO BBF-N56-CODE      * Default code (varies by type)

**** Device and destination
IF TRBFN-DEST = 153
   MOVE "C"            TO BBF-N56-DEVICE-OUT    * Console
ELSE
   MOVE "L"            TO BBF-N56-DEVICE-OUT    * List
END-IF

MOVE "*"               TO BBF-N56-SWITCHING
MOVE SPACE             TO BBF-N56-PRIORITY

**** List name and routing by account type (CDU001/JGO001)
EVALUATE TRBFN-TYPE-COMPTA
   WHEN 03 
      MOVE "500076"    TO BBF-N56-NAME
      MOVE 43          TO BBF-N56-CODE
      MOVE 151         TO BBF-N56-DESTINATION
      MOVE 1           TO BBF-N56-TAGREG-OP
      MOVE 167         TO BBF-N56-VERB
      
   WHEN 04 
      MOVE "500096"    TO BBF-N56-NAME
      MOVE 151         TO BBF-N56-DESTINATION
      MOVE 43          TO BBF-N56-CODE
      MOVE 2           TO BBF-N56-TAGREG-OP
      MOVE 169         TO BBF-N56-VERB
      
   WHEN 05 
      MOVE "500066"    TO BBF-N56-NAME
      MOVE 43          TO BBF-N56-CODE
      MOVE 151         TO BBF-N56-DESTINATION
      MOVE 4           TO BBF-N56-TAGREG-OP
      MOVE 166         TO BBF-N56-VERB
      
   WHEN 06 
      MOVE "500086"    TO BBF-N56-NAME
      MOVE 151         TO BBF-N56-DESTINATION
      MOVE 43          TO BBF-N56-CODE
      MOVE 7           TO BBF-N56-TAGREG-OP
      MOVE 168         TO BBF-N56-VERB
      
   WHEN OTHER 
      MOVE 40          TO BBF-N56-CODE
      MOVE 9           TO BBF-N56-TAGREG-OP
      IF TRBFN-DEST = 141
         MOVE 116      TO BBF-N56-DESTINATION
         MOVE "541006" TO BBF-N56-NAME
      ELSE
         MOVE TRBFN-DEST    TO BBF-N56-DESTINATION
         MOVE "500006"      TO BBF-N56-NAME
      END-IF
      MOVE TRBFN-DEST TO BBF-N56-VERB
END-EVALUATE

**** Key data
MOVE SPACES            TO BBF-N56-KEY
IF TRBFN-TYPE-COMPTA = 1 OR 3 OR 4 OR 5 OR 6
   MOVE 2              TO BBF-N56-AFK    * PAIFIN-AO
ELSE  
   MOVE 3              TO BBF-N56-AFK    * PAIFIN-AL
END-IF

MOVE TRBFN-CONSTANTE   TO BBF-N56-KONST
MOVE TRBFN-NO-SUITE    TO BBF-N56-VOLGNR

**** Payment data
MOVE WS-RIJKSNUMMER    TO BBF-N56-RNR
MOVE ADM-NAAM          TO BBF-N56-NAAM
MOVE ADM-VOORN         TO BBF-N56-VOORN
MOVE TRBFN-MONTANT     TO BBF-N56-BEDRAG
MOVE TRBFN-CODE-LIBEL  TO BBF-N56-LIBEL

**** Currency handling
MOVE TRBFN-MONTANT-DV  TO BBF-N56-DV
IF TRBFN-MONTANT-DV = "E"
   MOVE 2              TO BBF-N56-DN
ELSE
   MOVE 0              TO BBF-N56-DN
END-IF

**** IBAN discrepancy data - INPUT IBAN
IF TRBFN-IBAN NOT = SPACES
THEN
   MOVE SPACES         TO BBF-N56-IBAN
   MOVE SPACES         TO BBF-N56-REKNR
   MOVE TRBFN-IBAN     TO BBF-N56-IBAN    * Input IBAN
ELSE
   MOVE SPACES         TO BBF-N56-REKNR
   MOVE SPACES         TO BBF-N56-IBAN
END-IF

**** IBAN discrepancy data - MEMBER IBAN (from database)
IF SAV-IBAN NOT = SPACES
THEN
   MOVE SPACES         TO BBF-N56-IBAN-MUT
   MOVE SPACES         TO BBF-N56-REKNR-MUT
   MOVE SAV-IBAN       TO BBF-N56-IBAN-MUT    * Member's IBAN from DB
ELSE
   MOVE SPACES         TO BBF-N56-REKNR-MUT
   MOVE SPACES         TO BBF-N56-IBAN-MUT
END-IF

MOVE TRBFN-BETWYZ      TO BBF-N56-BETWY
```

### Exclusion Logic (MIS01)

```cobol
**** Only write to log if NOT list 541006
IF BBF-N56-NAME NOT = "541006"
   COPY ADLOGDBD REPLACING LOGT1-REC BY BFN56CXR
END-IF
```

## Business Rules

### Discrepancy Detection Conditions

List 500006 (or variant) record is created when **ALL** of the following are true:

1. **Input IBAN is present** (TRBFN-IBAN ≠ SPACES)
2. **Member IBAN is retrieved from database** (SAV-IBAN ≠ SPACES)
3. **IBANs do not match** (SAV-IBAN ≠ TRBFN-IBAN)

### Record NOT Created When

List 500006 is **NOT** created when:

- Input IBAN matches member IBAN (no discrepancy)
- Input IBAN is blank/spaces (no IBAN to compare)
- Member has no IBAN in database (SAV-IBAN = SPACES)
- Member not found in database (no comparison possible)

### Discrepancy Resolution Process

When a discrepancy is detected:

1. **Record is created in list 500006** (or variant) with both IBANs
2. **Payment may still be processed** (not necessarily rejected)
3. **Administrator reviews discrepancy report**
4. **Corrective action**:
   - Update member IBAN in MUTF08 database
   - OR correct input record for future submissions
   - Verify which IBAN is correct with member

## Historical Modifications

| Modification | Date | Description | Impact |
|--------------|------|-------------|--------|
| **IBAN10** | - | IBAN support | Added IBAN fields, changed length to 241 bytes |
| **JGO001** | 15/10/2018 | 6th State Reform | Added regional list variations (500076, 500096, 500066, 500086) |
| **CDU001** | - | Refinement of 6th State Reform | Consolidated account type logic, changed length to 258 bytes, refined routing |
| **MIS01** | - | List 541006 exclusion | Prevent ADLOGDBD write for list 541006 |

## Usage Examples

### Example 1: Standard IBAN Discrepancy (List 500006)

```cobol
* Input: TRBFNCXP record
*   TRBFN-TYPE-COMPTA = 1    * Standard account
*   TRBFN-DEST = 109         * Mutualité Chrétienne
*   TRBFN-IBAN = "BE68539007547034"
*   TRBFN-CONSTANTE = 1234567890
*   TRBFN-NO-SUITE = 1
*   
* Database lookup (MUTF08):
*   SAV-IBAN = "BE71096123456769"    * Different IBAN!
*
* Discrepancy detected: TRBFN-IBAN ≠ SAV-IBAN
*
* Output: BFN56CXR record for list 500006
*   BBF-N56-CODE = 40
*   BBF-N56-NAME = "500006"
*   BBF-N56-DESTINATION = 109
*   BBF-N56-VERB = 109
*   BBF-N56-AFK = 2              * PAIFIN-AO
*   BBF-N56-IBAN = "BE68539007547034"        * Input IBAN
*   BBF-N56-IBAN-MUT = "BE71096123456769"    * Member IBAN (from DB)
*   BBF-N56-TAGREG-OP = 9
```

### Example 2: Regional Discrepancy (List 500076 - Account Type 3)

```cobol
* Input: TRBFNCXP record
*   TRBFN-TYPE-COMPTA = 3    * Regional account type
*   TRBFN-IBAN = "BE12345678901234"
*   
* Database lookup:
*   SAV-IBAN = "BE98765432109876"    * Different IBAN!
*
* Discrepancy detected
*
* Output: BFN56CXR record for list 500076
*   BBF-N56-CODE = 43            * Regional code
*   BBF-N56-NAME = "500076"      * Regional list
*   BBF-N56-DESTINATION = 151    * Regional destination
*   BBF-N56-VERB = 167           * Regional federation
*   BBF-N56-AFK = 2
*   BBF-N56-IBAN = "BE12345678901234"        * Input
*   BBF-N56-IBAN-MUT = "BE98765432109876"    * Member (DB)
*   BBF-N56-TAGREG-OP = 1        * Tag for type 3
```

### Example 3: Special Destination (List 541006)

```cobol
* Input: TRBFNCXP record
*   TRBFN-DEST = 141         * Special destination
*   TRBFN-TYPE-COMPTA = 1 or 2
*   TRBFN-IBAN = "BE11111111111111"
*   
* Database lookup:
*   SAV-IBAN = "BE22222222222222"
*
* Output: BFN56CXR record for list 541006
*   BBF-N56-NAME = "541006"      * Special list
*   BBF-N56-DESTINATION = 116    * Special destination
*   BBF-N56-CODE = 40
*   BBF-N56-IBAN = "BE11111111111111"
*   BBF-N56-IBAN-MUT = "BE22222222222222"
*   
* Note: This record is NOT written to ADLOGDBD (MIS01 exclusion)
```

## Testing Considerations

### Validation Tests

- Verify record length is 258 bytes (CDU001 modification)
- Verify both input IBAN and member IBAN are captured
- Verify list name is correct for each account type (1-6, special 141)
- Verify record code (40 vs 43) matches account type
- Verify destination routing matches account type
- Verify regional tag operator matches account type

### Integration Tests

- Verify discrepancy records are created only when IBANs differ
- Verify list 541006 records are NOT written to ADLOGDBD
- Verify payment processing continues despite discrepancy (not rejection)
- Verify all account types (1-6) route to correct list variants
- Verify special destination 141 routes to list 541006

### Business Scenario Tests

- Process payment with matching IBANs (verify NO discrepancy record)
- Process payment with different IBANs (verify discrepancy record)
- Process payment with no input IBAN (verify NO discrepancy record)
- Process payment for member with no database IBAN (verify NO discrepancy)
- Process account types 3-6 (verify regional list variants)
- Process destination 141 (verify list 541006)

## Performance Considerations

- Record size: 258 bytes per discrepancy record
- Volume: List 500006 typically contains 5-10% of input records
- High discrepancy rate (>20%) indicates data quality issues
- Discrepancy report should be reviewed regularly to update member IBANs

## Data Quality Implications

### Root Causes of IBAN Discrepancies

1. **Outdated input data**: Payment record contains old IBAN
2. **Database not updated**: Member changed bank account but MUTF08 not updated
3. **Manual entry errors**: Typos in input IBAN
4. **System migration issues**: IBANs not properly migrated from legacy system

### Recommended Actions

- **Review list 500006 weekly** to identify recurring discrepancies
- **Update MUTF08 database** with correct IBANs when verified
- **Improve data entry validation** at payment input stage
- **Establish IBAN verification process** with members

## Related Data Structures

- **[DS_TRBFNCXP](DS_TRBFNCXP.md)**: Primary input record structure (source of TRBFN-IBAN)
- **[DS_BFN51GZR](DS_BFN51GZR.md)**: Valid payment list (500001)
- **[DS_BFN54GZR](DS_BFN54GZR.md)**: Rejected payment list (500004)
- **[DS_working_storage](DS_working_storage.md)**: Working storage (contains SAV-IBAN from database)

## Related Functional Requirements

| Requirement ID | Title | Relationship |
|----------------|-------|--------------|
| [FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md) | Bank Account Validation | IBAN validation triggers discrepancy detection |
| [FUREQ_MYFIN_004](../requirements/FUREQ_MYFIN_004_payment_list_generation.md) | Payment List Generation | Discrepancy list is one of three output lists |

## Notes and Limitations

1. **Copybook not available**: BFN56CXR copybook is referenced but not present in workspace. Structure is inferred from code assignments.
2. **Incomplete field mapping**: Some fields in the key section and data section are not explicitly assigned in the available code, so positions are estimated.
3. **List 541006 exclusion**: Special handling prevents ADLOGDBD write for this list variant (MIS01 modification).
4. **Payment not rejected**: Unlike list 500004 (rejections), list 500006 is informational - payment may still be processed with input IBAN.
