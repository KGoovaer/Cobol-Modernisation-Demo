# Data Structure: TRBFNCXP - GIRBET Payment Input Record

**ID**: DS_TRBFNCXP  
**Type**: Input Record  
**Source**: Created by TRBFNCXB program  
**Used By**: MYFIN (GIRBETPP entry point)  
**Record Code**: 42  
**Record Name**: GIRBET  
**Last Updated**: 2026-01-29

## Overview

TRBFNCXP is the primary input record structure for manual GIRBET payment processing. This record contains payment information manually entered through the GIRBET system, including member identification, payment destination, amount, bank account details, and payment descriptions.

## Record Specification

**Copybook**: [copy/trbfncxp.cpy](../../../copy/trbfncxp.cpy)  
**Base Length**: 152 bytes (pre-SEPA) / 140 bytes (variant)  
**SEPA Length**: 186 bytes / 174 bytes (with IBAN field)  
**Record Type**: Fixed-length sequential  
**Encoding**: EBCDIC (mainframe)

## Historical Context

### SEPA Modifications (IBAN10 Project)
- **Date**: February 2011
- **Impact**: Added IBAN field support (34 bytes)
- **Length Change**: Base record extended by 34 bytes
- **Backward Compatibility**: Legacy bank account field (TRBFN-REKNR) retained
- **Marker**: Changes indicated with 'SEPA' or 'IBAN10' in source

## Field-Level Documentation

### Record Header (Control Fields)

#### TRBFN-LENGTH
```cobol
05 TRBFN-LENGTH    PIC S9(04) COMP.
```
- **Purpose**: Record length indicator
- **Type**: Binary signed integer (2 bytes)
- **Values**: 152, 140, 186, or 174 depending on variant
- **Usage**: Used by record processing framework to determine record boundaries
- **Validation**: Must match expected length for GIRBET record type

#### TRBFN-CODE
```cobol
05 TRBFN-CODE      PIC S9(04) COMP.
```
- **Purpose**: Record type identifier
- **Type**: Binary signed integer (2 bytes)
- **Value**: 42 (constant for GIRBET records)
- **Usage**: Identifies this as a GIRBET payment record
- **Validation**: Must equal 42

#### TRBFN-NUMBER
```cobol
05 TRBFN-NUMBER    PIC 9(08).
```
- **Purpose**: Record sequence number or batch identifier
- **Type**: Numeric (8 digits)
- **Range**: 00000000-99999999
- **Usage**: Tracks record sequence within batch processing
- **Example**: 00001234

### PPR (Pre-Processing Record) Identification

#### TRBFN-PPR-NAME
```cobol
05 TRBFN-PPR-NAME  PIC X(06).
```
- **Purpose**: Pre-processing record name/identifier
- **Type**: Alphanumeric (6 characters)
- **Usage**: Identifies the source PPR system or process
- **Example**: "GIRBET"

#### TRBFN-PPR-FED
```cobol
05 TRBFN-PPR-FED   PIC 9(03).
```
- **Purpose**: Federation (mutuality) code from PPR source
- **Type**: Numeric (3 digits)
- **Range**: 101-169 (valid mutuality codes)
- **Usage**: Identifies originating mutuality federation
- **Valid Values**:
  - 101-126, 131: Flemish mutualities (MUT-NL)
  - 109, 116, 127-130, 132-136, 167-168: French mutualities (MUT-FR)
  - 106, 107, 150, 166: Bilingual mutualities (MUT-BILINGUE)
  - 137: Verviers (special handling)
  - 169: Dutch (6th State Reform - CDU001)
- **Example**: 109 (French mutuality)

#### TRBFN-PPR-RNR
```cobol
05 TRBFN-PPR-RNR   PIC S9(08) COMP.
```
- **Purpose**: National registry number (binary format) of payment beneficiary
- **Type**: Binary signed integer (4 bytes)
- **Range**: 1-99999999
- **Usage**: Primary key for member lookup in MUTF08 database
- **Validation**: Must exist in member database
- **Processing**: Used in [SCH-LID](../../../cbl/MYFIN.cbl#L190) paragraph
- **Example**: 12345678

### Payment Data (TRBFN-DATA Group)

#### TRBFN-DEST
```cobol
10 TRBFN-DEST      PIC 9(3).
```
- **Purpose**: Destination mutuality code for payment
- **Type**: Numeric (3 digits)
- **Range**: 101-169
- **Usage**: Determines payment routing and language selection
- **Business Rule**: Used to set TEST-MUTUALITE variable for language determination
- **Processing**: Critical for mutuality-specific processing logic
- **Example**: 116

#### TRBFN-DATMEMO / TRBFN-DATMEMO2 (Date Field)
```cobol
10 TRBFN-DATMEMO              PIC 9(8).
10 TRBFN-DATMEMO2 REDEFINES TRBFN-DATMEMO.
   15 TRBFN-DATMEMO-CC        PIC 9(02).
   15 TRBFN-DATMEMO-YMD       PIC 9(6).
   15 TRBFN-DATMEMO-YMD2 REDEFINES TRBFN-DATMEMO-YMD.
      20 TRBFN-DATMEMO-YY     PIC 9(2).
      20 TRBFN-DATMEMO-MM     PIC 9(2).
      20 TRBFN-DATMEMO-DD     PIC 9(2).
```
- **Purpose**: Payment memo date or reference date
- **Type**: Numeric (8 digits) with multiple redefinitions
- **Format**: CCYYMMDD
- **Components**:
  - CC: Century (19 or 20)
  - YY: Year (00-99)
  - MM: Month (01-12)
  - DD: Day (01-31)
- **Usage**: Used in payment descriptions and date-based validations
- **Example**: 20260129 (January 29, 2026)

#### TRBFN-TYPE-COMPTA
```cobol
10 TRBFN-TYPE-COMPTA          PIC 9.
```
- **Purpose**: Accounting type or regional designation
- **Type**: Numeric (1 digit)
- **Valid Values**:
  - 1: General/National accounting
  - 3: Regional accounting (Flanders)
  - 4: Regional accounting (Wallonia)
  - 5: Regional accounting (Brussels)
  - 6: Regional accounting (German community)
- **Usage**: Determines list routing (500001 vs. 500071/500091/500061/500081)
- **Processing**: Affects TAG-REG-OP and TAG-REG-LEG fields in output
- **Example**: 1 (General)

#### TRBFN-CONSTANTE
```cobol
10 TRBFN-CONSTANTE            PIC 9(10).
```
- **Purpose**: Payment constant/reference identifier
- **Type**: Numeric (10 digits)
- **Range**: 0000000001-9999999999
- **Usage**: Unique payment tracking identifier combined with sequence number
- **Business Rule**: Part of composite key for duplicate detection
- **Example**: 1234567890

#### TRBFN-NO-SUITE
```cobol
10 TRBFN-NO-SUITE             PIC 9(4).
```
- **Purpose**: Payment sequence number within constant group
- **Type**: Numeric (4 digits)
- **Range**: 0001-9999
- **Usage**: Completes unique payment identifier (CONSTANTE + NO-SUITE)
- **Business Rule**: Used in duplicate detection logic
- **Example**: 0001

#### TRBFN-RNR
```cobol
10 TRBFN-RNR                  PIC X(13).
```
- **Purpose**: National registry number (alphanumeric format)
- **Type**: Alphanumeric (13 characters)
- **Format**: "YY.MM.DD-NNN.CC" or "YYMMDDSSSNNCC"
- **Usage**: Display format of member's national registry number
- **Relationship**: Corresponds to TRBFN-PPR-RNR but in formatted text
- **Incident #279363**: Modified to use WS-RIJKSNUMMER for display purposes
- **Example**: "00.01.01-567.89" or "000101056789-10"

#### TRBFN-MONTANT
```cobol
10 TRBFN-MONTANT              PIC S9(8).
```
- **Purpose**: Payment amount in Euro cents
- **Type**: Signed numeric (8 digits)
- **Range**: -99999999 to +99999999 cents
- **Currency**: EUR (implicit)
- **Example**: 12500 (represents €125.00)
- **Validation**: Must be non-zero for valid payment

#### TRBFN-CODE-LIBEL
```cobol
10 TRBFN-CODE-LIBEL           PIC 9(2).
```
- **Purpose**: Payment description/label code
- **Type**: Numeric (2 digits)
- **Range**: 01-99
- **Usage**: References parameter table (LIBPNCXW) for payment description text
- **Valid Codes**:
  - 1-49: Standard payment descriptions
  - 50-51: Date-based descriptions
  - 52-57: Special payment types
  - 60: Period-based description
  - 70-89: Various payment categories
  - 90-99: Database-sourced descriptions (MUTF08)
- **Special Handling**:
  - Code >= 90: Retrieves description from LIBP-NRLIB in MUTF08 database
  - Code < 90: Uses standard parameter table
- **Processing**: Used in [GET-PAR](../../../cbl/MYFIN.cbl#L233) paragraph
- **MTU01 Modification**: Code 70 was retired (SC229498)
- **Example**: 01, 50, 92

#### TRBFN-LIBELLE1
```cobol
10 TRBFN-LIBELLE1             PIC X(14).
```
- **Purpose**: First line of payment description/label
- **Type**: Alphanumeric (14 characters)
- **Usage**: Custom payment description or date information
- **Special Processing**:
  - For code 50: Contains date in DD/MM/YY format (SAV-LIB1)
  - For code 60: Contains period start date
- **Language**: May contain FR/NL/DE text depending on mutuality
- **Example**: "01/12/25" or "HONORAIRES   "

#### TRBFN-LIBELLE2
```cobol
10 TRBFN-LIBELLE2             PIC X(14).
```
- **Purpose**: Second line of payment description/label
- **Type**: Alphanumeric (14 characters)
- **Usage**: Continuation of payment description or additional date
- **Special Processing**:
  - For code 50: Contains continuation text like "TOT/AU/BIS"
  - For code 60: Contains period end date
- **Language**: May contain FR/NL/DE text depending on mutuality
- **Example**: " TOT 31/12/25" or "FRANCHISE    "

### Bank Account Information

#### TRBFN-REKNR (Legacy Bank Account - Pre-SEPA)
```cobol
10 TRBFN-REKNR                PIC 9(12).
10 TRBFN-REKNR-RED REDEFINES TRBFN-REKNR.
   15 TRBFN-REKNR-TEN         PIC 9(10).
   15 TRBFN-REKNR-TEN2 REDEFINES TRBFN-REKNR-TEN.
      20 TRBFN-REKNR-FIN      PIC 9(03).
      20 TRBFN-REKNR-7        PIC 9(07).
   15 TRBFN-REKNR-TST         PIC 9(02).
```
- **Purpose**: Legacy Belgian bank account number (pre-SEPA era)
- **Type**: Numeric (12 digits)
- **Format**: BBB-NNNNNNN-CC
  - BBB (TRBFN-REKNR-FIN): Bank institution code (3 digits)
  - NNNNNNN (TRBFN-REKNR-7): Account number (7 digits)
  - CC (TRBFN-REKNR-TST): Check digits (2 digits)
- **Status**: Retained for backward compatibility, superseded by IBAN
- **Usage**: Used when TRBFN-BETWYZ = 'C' (circular cheque) or pre-SEPA records
- **Validation**: Modulo 97 check digit validation
- **Example**: 539007547034 (539-0075470-34)

#### TRBFN-COMPTE-MEMBRE
```cobol
10 TRBFN-COMPTE-MEMBRE        PIC 9(1).
```
- **Purpose**: Member account indicator flag
- **Type**: Numeric (1 digit)
- **Valid Values**:
  - 0: Different account (payment to different account than known)
  - 1: Same account (payment to known member account)
- **Usage**: Controls bank account discrepancy checking
- **Business Rule**: If = 0 and accounts differ, generate list 500006
- **Example**: 1

#### TRBFN-MONTANT-DV
```cobol
10 TRBFN-MONTANT-DV           PIC X.
```
- **Purpose**: Amount currency indicator
- **Type**: Alphanumeric (1 character)
- **Valid Values**: Typically space or currency code
- **Usage**: Reserved for multi-currency support (currently unused)
- **Example**: ' ' (space)

### SEPA-Specific Fields

#### TRBFN-FILLER-DETAIL / TRBFN-FILLER-DET-RED
```cobol
10 TRBFN-FILLER-DETAIL        PIC X(12).
10 TRBFN-FILLER-DET-RED REDEFINES TRBFN-FILLER-DETAIL.
   20 TRBFN-BETWYZ            PIC X(01).
   20 TRBFN-REST              PIC X(11).
```
- **Purpose**: SEPA payment method indicator and reserved space
- **Type**: Alphanumeric (12 characters total)
- **Added**: SEPA/IBAN10 project (2011)

**TRBFN-BETWYZ** (Payment Method):
- **Type**: Alphanumeric (1 character)
- **Valid Values**:
  - Space or blank: SEPA bank transfer (use IBAN)
  - 'C': Circular cheque (chèque circulaire)
- **Usage**: Determines payment processing method
- **Processing**: Controls IBAN vs. legacy account number usage
- **Example**: ' ' or 'C'

**TRBFN-REST**:
- **Type**: Alphanumeric (11 characters)
- **Purpose**: Reserved for future use
- **Value**: Typically spaces

#### TRBFN-IBAN
```cobol
10 TRBFN-IBAN                 PIC X(34).
```
- **Purpose**: International Bank Account Number (SEPA requirement)
- **Type**: Alphanumeric (34 characters)
- **Format**: ISO 13616 IBAN format
- **Country**: Primarily Belgian (BE) IBANs
- **Structure**: CCNN BBBB BBBB BBBB (where CC=country, NN=check, B=BBAN)
- **Belgian Format**: BE + 2 check digits + 12 digit account number
- **Added**: SEPA/IBAN10 project (February 2011)
- **Validation**:
  - IBAN modulo 97 check digit
  - Country code validation
  - Length validation (max 34 characters)
- **Usage**:
  - Required when TRBFN-BETWYZ = space
  - Validated via SEPAAUKU copybook routines
  - Used for SEPA payment generation
- **Processing**: 
  - Stored in SAV-IBAN for duplicate checking
  - Validated in IBAN validation paragraph
  - Used to populate U-IBAN in SEPA user record
- **Example**: "BE68539007547034" (Belgian IBAN)
- **Related Fields**: WS-IBAN (working storage), SAV-IBAN (saved for comparison)

## Data Relationships

### Input → Processing Flow

1. **Record Reception**
   - TRBFNCXP record received via GIRBETPP entry point
   - Copied to PPR-RECORD in linkage section
   - Source: [cbl/MYFIN.cbl#L168](../../../cbl/MYFIN.cbl#L168)

2. **Member Identification**
   - TRBFN-PPR-RNR → RNRBIN → Member database lookup
   - TRBFN-DEST → TEST-MUTUALITE → Language determination
   - TRBFN-RNR → WS-RIJKSNUMMER → Display purposes

3. **Payment Processing**
   - TRBFN-CONSTANTE + TRBFN-NO-SUITE → Duplicate detection
   - TRBFN-CODE-LIBEL → Parameter lookup → SAV-LIBELLE
   - TRBFN-IBAN or TRBFN-REKNR → Bank account validation

4. **Output Generation**
   - TRBFNCXP fields → SEPAAUKU (user record)
   - TRBFNCXP fields → BFN51GZR (list 500001)
   - TRBFNCXP fields → BFN54GZR (rejection list)
   - TRBFNCXP fields → BFN56CXR (discrepancy list)

### Related Data Structures

- **INFPRGZP**: Alternative input format (not directly used in MYFIN)
- **SEPAAUKU**: SEPA user output record
- **BFN51GZR**: Payment list output (500001)
- **BFN54GZR**: Rejection list output (500004)
- **BFN56CXR**: Discrepancy list output (500006)
- **BBFPRGZP**: BBF module payment record (internal)

## Validation Rules

### Critical Validations (FUREQ_MYFIN_001)

| Field | Validation Rule | Error Response | Reference |
|-------|----------------|----------------|-----------|
| TRBFN-CODE | Must = 42 | Reject record | Record type check |
| TRBFN-PPR-RNR | Must exist in MUTF08 | "LIDNR ONBEKEND/AFFILIE INCONNU" | [FUREQ_001](../requirements/FUREQ_MYFIN_001_input_validation.md) |
| TRBFN-DEST | Must be valid mutuality (101-169) | Invalid mutuality | Mutuality validation |
| TRBFN-CODE-LIBEL | Must exist in parameter table | "CODE OMSCHR ONBEK/CODE LIBEL INCON" | [FUREQ_001](../requirements/FUREQ_MYFIN_001_input_validation.md) |
| TRBFN-MONTANT | Must be non-zero | Amount validation | Payment amount check |
| TRBFN-IBAN | Required if BETWYZ blank, valid IBAN format | IBAN validation error | [FUREQ_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md) |
| TRBFN-BETWYZ | Must be space or 'C' | Payment method validation | Payment type check |

### Business Rule Validations

1. **Duplicate Detection** (FUREQ_MYFIN_002)
   - Check: TRBFN-CONSTANTE + TRBFN-NO-SUITE + TRBFN-IBAN
   - Action: If duplicate found, reject payment
   - Reference: [FUREQ_002](../requirements/FUREQ_MYFIN_002_duplicate_detection.md)

2. **Bank Account Validation** (FUREQ_MYFIN_003)
   - Check: IBAN format and check digits
   - Check: Account number vs. known member account (if COMPTE-MEMBRE = 1)
   - Action: Generate list 500006 if mismatch
   - Reference: [FUREQ_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md)

3. **Language Determination**
   - Based on: TRBFN-DEST (mutuality code)
   - MUT-FR (French): 109, 116, 127-130, 132-136, 167-168
   - MUT-NL (Dutch): 101-102, 104-105, 108, 110-122, 126, 131, 169
   - MUT-BILINGUE: 106, 107, 150, 166 (check ADM-TAAL)
   - Reference: [cbl/MYFIN.cbl#L89-L99](../../../cbl/MYFIN.cbl#L89-L99)

## Usage Examples

### Example 1: Standard SEPA Payment

```cobol
* Input record from GIRBET system
01 PPR-RECORD.
   05 TRBFN-LENGTH           PIC S9(04) COMP VALUE 186.
   05 TRBFN-CODE             PIC S9(04) COMP VALUE 42.
   05 TRBFN-NUMBER           PIC 9(08) VALUE 00012345.
   05 TRBFN-PPR-NAME         PIC X(06) VALUE 'GIRBET'.
   05 TRBFN-PPR-FED          PIC 9(03) VALUE 109.
   05 TRBFN-PPR-RNR          PIC S9(08) COMP VALUE 12345678.
   05 TRBFN-DATA.
      10 TRBFN-DEST          PIC 9(3) VALUE 109.
      10 TRBFN-DATMEMO       PIC 9(8) VALUE 20260129.
      10 TRBFN-TYPE-COMPTA   PIC 9 VALUE 1.
      10 TRBFN-CONSTANTE     PIC 9(10) VALUE 1234567890.
      10 TRBFN-NO-SUITE      PIC 9(4) VALUE 0001.
      10 TRBFN-RNR           PIC X(13) VALUE '00.01.01-567.89'.
      10 TRBFN-MONTANT       PIC S9(8) VALUE 12500.
      10 TRBFN-CODE-LIBEL    PIC 9(2) VALUE 01.
      10 TRBFN-LIBELLE1      PIC X(14) VALUE 'HONORAIRES    '.
      10 TRBFN-LIBELLE2      PIC X(14) VALUE 'MEDICAUX      '.
      10 TRBFN-REKNR         PIC 9(12) VALUE 539007547034.
      10 TRBFN-COMPTE-MEMBRE PIC 9(1) VALUE 1.
      10 TRBFN-MONTANT-DV    PIC X VALUE ' '.
      10 TRBFN-FILLER-DET-RED.
         20 TRBFN-BETWYZ     PIC X(01) VALUE ' '.
         20 TRBFN-REST       PIC X(11) VALUE SPACES.
      10 TRBFN-IBAN          PIC X(34) VALUE 'BE68539007547034'.
```

### Example 2: Circular Cheque Payment (Pre-SEPA)

```cobol
* Circular cheque payment using legacy account format
   05 TRBFN-DATA.
      10 TRBFN-BETWYZ        PIC X(01) VALUE 'C'.
      10 TRBFN-REKNR         PIC 9(12) VALUE 539007547034.
      10 TRBFN-IBAN          PIC X(34) VALUE SPACES.
      * No IBAN required for circular cheque
```

### Example 3: Date-Based Description (Code 50)

```cobol
* Payment with date range in description
   05 TRBFN-DATA.
      10 TRBFN-CODE-LIBEL    PIC 9(2) VALUE 50.
      10 TRBFN-LIBELLE1      PIC X(14) VALUE '01/01/26      '.
      10 TRBFN-LIBELLE2      PIC X(14) VALUE ' TOT 31/01/26 '.
      * Description: "From 01/01/26 to 31/01/26"
```

## Implementation Notes

### Code References

- **Copybook Definition**: [copy/trbfncxp.cpy](../../../copy/trbfncxp.cpy)
- **Record Reception**: [cbl/MYFIN.cbl#L168](../../../cbl/MYFIN.cbl#L168) - COPY TRBFNCXP REPLACING
- **Entry Point**: [cbl/MYFIN.cbl#L176](../../../cbl/MYFIN.cbl#L176) - ENTRY "GIRBETPP"
- **Member Lookup**: [cbl/MYFIN.cbl#L190](../../../cbl/MYFIN.cbl#L190) - SCH-LID paragraph
- **Validation Processing**: [cbl/MYFIN.cbl#L180](../../../cbl/MYFIN.cbl#L180) - TRAITEMENT-BTM section

### Processing Sequence

1. **Record Input**: ENTRY "GIRBETPP" USING USAREA1 PPR-RECORD
2. **Member Search**: TRBFN-PPR-RNR → RNRBIN → PERFORM SCH-LID
3. **Section Search**: PERFORM RECHERCHE-SECTION
4. **Language Setup**: ADM-TAAL determination with fallback logic
5. **Payment Validation**: Description code lookup, IBAN validation
6. **Duplicate Check**: CONSTANTE + NO-SUITE + IBAN comparison
7. **Output Generation**: Create user record (5N0001) and list records

### Special Considerations

1. **SEPA Migration**: System supports both IBAN (SEPA) and legacy account numbers
2. **Multi-Language**: Payment descriptions in FR/NL/DE based on mutuality
3. **6th State Reform** (JGO001, CDU001): New mutuality codes 166-169
4. **Historical Tracking**: Multiple modification markers (MTU01, MIS01, IBAN10, etc.)
5. **Regional Accounting**: TRBFN-TYPE-COMPTA determines list routing

### Dependencies

- **Database**: MUTF08 (member data)
- **Copybooks**: SEPAAUKU, BFN51GZR, BFN54GZR, BFN56CXR
- **Parameters**: LIBPNCXW (description texts), SEPAKCXW (SEPA validation)
- **Utilities**: IBAN validation routines, duplicate detection logic

## Testing Scenarios

### Positive Tests

1. **Valid SEPA Payment**
   - Input: Complete TRBFNCXP with valid IBAN, BETWYZ=space
   - Expected: Payment accepted, user record created, list 500001 entry

2. **Valid Circular Cheque**
   - Input: TRBFNCXP with BETWYZ='C', valid REKNR
   - Expected: Payment accepted using legacy account format

3. **Bilingual Mutuality**
   - Input: DEST=106, ADM-TAAL determined from member preference
   - Expected: Correct language selection for output

### Negative Tests

1. **Invalid Member**
   - Input: TRBFN-PPR-RNR not in database
   - Expected: Rejection with "LIDNR ONBEKEND/AFFILIE INCONNU"

2. **Invalid Description Code**
   - Input: TRBFN-CODE-LIBEL not in parameter table
   - Expected: Rejection with "CODE OMSCHR ONBEK/CODE LIBEL INCON"

3. **Invalid IBAN**
   - Input: Malformed IBAN, failed check digit
   - Expected: Rejection with IBAN validation error

4. **Duplicate Payment**
   - Input: Same CONSTANTE + NO-SUITE + IBAN as previous record
   - Expected: Rejection as duplicate

## Change History

| Date | Project/Incident | Description | Marker |
|------|------------------|-------------|--------|
| 1996-11-01 | Initial | Original GIRBET payment record | - |
| 2002-02-15 | INFOREK (MTU) | Enhanced information tracking | MTU |
| 2005-06-23 | JVE | Extended BBF module fields | - |
| 2011-02-01 | SEPA/IBAN10 | Added IBAN field, BETWYZ indicator | SEPA, IBAN10 |
| 2018-10-15 | JGO001 | 6th State Reform - new mutualities | JGO001 |
| 2019-07-01 | CDU001 | 6th State Reform - mutuality 169 | CDU001 |
| 2023-05-02 | JIRA-4224 (KVS001) | CSV output instead of Papyrus | KVS001 |
| 2023-06-16 | JIRA-4311 (KVS002) | PAIFIN-Belfius adaptation | KVS002 |
| 2024-07-23 | JIRA-4837 (MSA001) | CORREG corrections | MSA001 |
| 2025-01-30 | JIRA-???? (MSA002) | BULK processing | MSA002 |

## Related Documentation

- **Functional Requirements**:
  - [FUREQ_MYFIN_001: Input Validation](../requirements/FUREQ_MYFIN_001_input_validation.md)
  - [FUREQ_MYFIN_002: Duplicate Detection](../requirements/FUREQ_MYFIN_002_duplicate_detection.md)
  - [FUREQ_MYFIN_003: Bank Account Validation](../requirements/FUREQ_MYFIN_003_bank_account_validation.md)
  
- **Use Cases**:
  - [UC_MYFIN_001: Process Manual Payment](../../business/use-cases/UC_MYFIN_001_process_manual_payment.md)
  - [UC_MYFIN_002: Validate Payment Data](../../business/use-cases/UC_MYFIN_002_validate_payment_data.md)

- **Discovery**:
  - [Discovered Components](../../discovery/MYFIN/discovered-components.md)
  - [Discovered Domain Concepts](../../discovery/MYFIN/discovered-domain-concepts.md)
