# Data Structure: BBFPRGZP - BBF Payment Record

**ID**: DS_BBFPRGZP  
**Type**: Output Record Structure  
**Purpose**: BBF module payment records for magnetic tape exchange (BETFIN system)  
**Source Copybook**: [copy/bbfprgzp.cpy](../../../copy/bbfprgzp.cpy)  
**Last Updated**: 2026-01-29

## Overview

BBFPRGZP is the output record structure for BBF (Bruxelles Betalingen Financieel / Brussels Financial Payments) module payment records. These records are created by MYFIN for processing manual GIRBET payments through the BETFIN (Betalingen Financieel) magnetic tape exchange system. The record format has evolved through multiple SEPA and 6th State Reform modifications.

## Record Layout

### Record Header

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| BF-LENGTH | S9(04) COMP | 4 bytes | 1-4 | Record length (192/180 bytes) - not included in record length calculation |
| BF-CODE | S9(04) COMP | 4 bytes | 5-8 | Record code = 42 - not included in record length calculation |
| BF-NUMBER | 9(08) | 8 bytes | 9-16 | Sequence number starting from 1 - not included in record length calculation |
| BF-PPR-NAME | X(06) | 6 bytes | 17-22 | PPR name = "PPRBBF" |
| BF-PPR-FED | 9(03) | 3 bytes | 23-25 | Federation (mutuality) code |
| BF-PPR-RNR | S9(08) COMP | 4 bytes | 26-29 | National registry number (binary) |

**Note**: BF-LENGTH, BF-CODE, and BF-NUMBER are metadata fields not counted in the total record length.

### Payment Data (BF-DATA)

#### Location and Administrative Fields

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-VBOND** | 9(02) | 2 bytes | 30-31 | Federation number (mutuality group) |
| **BF-AFDEL** | 9(03) | 3 bytes | 32-34 | Department/section number |
| **BF-KASSIER** | 9(03) | 3 bytes | 35-37 | Cashier number |
| **BF-DATZIT-DM** | 9(04) | 4 bytes | 38-41 | Session date in DDMM format |

**BF-KONST** (composite of BF-AFDEL, BF-KASSIER, BF-DATZIT-DM):
- Historical code 88 level: BRUGGE-BVR (values 006, 016, 026, 036, 046, 056, 066, 076, 086, 096) - suppressed 26/11/98

#### Payment Method and Identification

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-BETWYZ** | X(01) | 1 byte | 42 | Residual payment method: 'C' = Circular check (for Brussels) |
| **BF-RNR** | X(13) | 13 bytes | 43-55 | National registry number (alphanumeric) |
| **BF-BETKOD** | 9(02) | 2 bytes | 56-57 | Payment reason code |
| **BF-BEDRAG** | 9(05) | 5 bytes | 58-62 | Amount (max 50,000 BEF - legacy) |
| **BF-BEDRAG-RMG** | 9(09) COMP | (redefines) | 58-62 | Amount in computational format |

#### Bank Account Information (Legacy Format)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-REKNUM** | 9(12) | 12 bytes | 63-74 | Bank account number (may be 12 zeros if not applicable) |
| **BF-REKNR** | (redefines BF-REKNUM) | | | Structured bank account number |
| BF-REKNR-PART1 | 9(03) | 3 bytes | 63-65 | Account part 1 (bank code) |
| BF-REKNR-PART2 | 9(07) | 7 bytes | 66-72 | Account part 2 (account number) |
| BF-REKNR-PART3 | 9(02) | 2 bytes | 73-74 | Account part 3 (check digit) |

**Format**: XXX-XXXXXXX-XX (Belgian bank account format pre-SEPA)

#### Description and Reference Fields

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-VOLGNR-M30** | 9(03) | 3 bytes | 75-77 | M30 sequence number |
| **BF-OMSCHR1** | X(14) | 14 bytes | 78-91 | Description line 1 |
| **BF-OMSCHR1R** | (redefines BF-OMSCHR1) | | | Structured message variant |
| BF-GESTRUK-MEDE | X(12) | 12 bytes | 78-89 | Structured message |
| FILLER | X(02) | 2 bytes | 90-91 | Reserved |
| **BF-OMSCHR2** | X(14) | 14 bytes | 92-105 | Description line 2 |
| **FILLER** | 9(03) | 3 bytes | 106-108 | Reserved |

#### Euro Amount Fields (Post-Euro Implementation)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-BEDRAG-EUR** | 9(08) | 8 bytes | 109-116 | Amount in euro cents (8 digits) |
| **BF-BEDRAG-RMG-EUR** | 9(11) COMP | (redefines) | 109-116 | Amount in euro computational format |
| **BF-BEDRAG-DV** | X(01) | 1 byte | 117 | Amount decimal/verification field |
| **BF-BEDRAG-RMG-DV** | X(01) | (redefines) | 117 | Decimal field redefine |

#### MAF Payment Extensions (Added 2005)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-CODE-MAF** | X(01) | 1 byte | 118 | MAF payment code |
| **BF-JAAR-MAF** | 9(04) | 4 bytes | 119-122 | MAF payment year (numeric) |
| **BF-JAAR-MAF-X** | X(04) | (redefines) | 119-122 | MAF payment year (alphanumeric) |

#### SEPA/IBAN Fields (Added 2010-2011)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-IBAN** | X(34) | 34 bytes | 123-156 | IBAN bank account number (SEPA format) |
| **BF-OMSCHR3** | X(40) | 40 bytes | 157-196 | Additional description line 3 |

#### 6th State Reform Fields (Added 2018)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **BF-TAGREG-OP** | 9(02) | 2 bytes | 197-198 | TAG region OP (Openstaande Pakket / Open Package) |
| **BF-TAGREG-LEG** | 9(02) | 2 bytes | 199-200 | TAG region LEG (Legger / Ledger) |

## Record Length Evolution

| Date | Modification | Length | Note |
|------|--------------|--------|------|
| Original | Initial BBF format | 106 bytes | Base format |
| 2005 | MAF payments | +6 bytes | Added BF-CODE-MAF, BF-JAAR-MAF |
| 2010-10-14 | SEPA/IBAN (JGO) | 152/140 bytes | Added IBAN support |
| 2010-10-24 | SEPA extension (MIS) | 192/180 bytes | Extended SEPA fields |
| 2018-10-15 | 6th State Reform (JGO/R224154) | 192/180 bytes | Added TAG region fields |

**Current Length**: 192 bytes (including metadata) / 180 bytes (data only)

## Field-Level Specifications

### BF-PPR-NAME
- **Purpose**: Identifies record type as BBF payment processing record
- **Fixed Value**: "PPRBBF"
- **Usage**: Record identification and validation

### BF-PPR-FED
- **Purpose**: Mutuality federation code
- **Valid Values**: 101-169 (various Belgian mutualities)
- **Source**: TRBFN-DEST from input record (TRBFNCXP)

### BF-PPR-RNR
- **Purpose**: Member national registry number in binary format
- **Format**: Binary S9(08) COMP
- **Source**: TRBFN-PPR-RNR from input record
- **Usage**: Member identification for payment processing

### BF-VBOND (Federation Number)
- **Purpose**: Two-digit federation identifier
- **Values**: 01-99
- **Relationship**: Part of organizational hierarchy (Federation > Department > Cashier)

### BF-BETWYZ (Payment Method)
- **Purpose**: Identifies residual payment methods
- **Values**: 
  - 'C': Circular check (Brussels)
  - Blank/Space: SEPA transfer (default)
- **Note**: Legacy field, SEPA now primary method

### BF-RNR (National Registry Number)
- **Purpose**: Alphanumeric representation of member identification
- **Format**: XX.XX.XX-XXX.XX (13 characters)
- **Source**: Converted from TRBFN-RNR
- **Usage**: Member identification in human-readable format

### BF-BETKOD (Payment Reason Code)
- **Purpose**: Identifies reason for payment
- **Valid Values**: 01-99 (specific codes defined in parameter table)
- **Source**: TRBFN-CODE-LIBEL from input record
- **Usage**: Links to payment description in LIBPNC parameter table

### BF-BEDRAG and BF-BEDRAG-EUR
- **Purpose**: Payment amount in legacy BEF and current EUR
- **BF-BEDRAG**: Max 50,000 BEF (legacy, 5 digits)
- **BF-BEDRAG-EUR**: Amount in euro cents (8 digits, max €9,999,999.99)
- **Source**: TRBFN-MONTANT from input record
- **Validation**: Must be > 0

### BF-REKNUM / BF-REKNR (Legacy Bank Account)
- **Purpose**: Pre-SEPA Belgian bank account number
- **Format**: XXX-XXXXXXX-XX (12 digits)
- **Parts**:
  - Part 1: Bank code (3 digits)
  - Part 2: Account number (7 digits)
  - Part 3: Check digit (2 digits)
- **Special Value**: 000000000000 (12 zeros) indicates IBAN used instead
- **Source**: TRBFN-REKNR from input record

### BF-IBAN (SEPA Bank Account)
- **Purpose**: International Bank Account Number for SEPA payments
- **Format**: ISO 13616 IBAN format (max 34 characters)
- **Example**: BE68539007547034
- **Source**: TRBFN-IBAN or converted from bank account via UAREA database
- **Validation**: IBAN structure and check digit validation required

### BF-OMSCHR1, BF-OMSCHR2, BF-OMSCHR3
- **Purpose**: Payment description lines
- **OMSCHR1**: 14 characters (may contain structured message)
- **OMSCHR2**: 14 characters
- **OMSCHR3**: 40 characters (SEPA extended description)
- **Source**: Derived from parameter table (LIBPNC) based on BF-BETKOD and language
- **Special Handling**: Date replacement for codes 50 and 60

### BF-GESTRUK-MEDE (Structured Message)
- **Purpose**: Structured communication for bank transfers
- **Format**: 12 characters (numeric with formatting)
- **Usage**: Redefines BF-OMSCHR1 for structured payments
- **Example**: "+++123/4567/89012+++"

### BF-CODE-MAF and BF-JAAR-MAF
- **Purpose**: MAF (Maximale Aanvaardbare Factuur / Maximum Acceptable Invoice) payment identification
- **BF-CODE-MAF**: Single character code
- **BF-JAAR-MAF**: 4-digit year (numeric or alphanumeric)
- **Added**: 2005 for MAF payment processing
- **Source**: TRBFN-CODE-MAF, TRBFN-JAAR-MAF from input record

### BF-TAGREG-OP and BF-TAGREG-LEG
- **Purpose**: TAG region codes for 6th State Reform administration
- **Format**: 2-digit region codes
- **OP**: Openstaande Pakket (Open Package) region
- **LEG**: Legger (Ledger) region
- **Added**: 2018 (R224154)
- **Usage**: Regional accounting and reporting post-6th State Reform

## Usage in MYFIN

### Record Creation Context

The BBFPRGZP record is created by MYFIN when processing validated manual GIRBET payments:

```cobol
* Initialize BBF record header
MOVE 42 TO BBF-CODE
MOVE sequence-number TO BBF-NUMBER
MOVE "PPRBBF" TO BBF-PPR-NAME

* Populate from input record (TRBFNCXP)
MOVE TRBFN-DEST TO BBF-PPR-FED
MOVE TRBFN-PPR-RNR TO BBF-PPR-RNR
MOVE TRBFN-RNR TO BF-RNR
MOVE TRBFN-CODE-LIBEL TO BF-BETKOD
MOVE TRBFN-MONTANT TO BF-BEDRAG-EUR

* Bank account handling
IF TRBFN-BETWYZ = SPACES
    MOVE TRBFN-IBAN TO BF-IBAN
    MOVE ZEROES TO BF-REKNUM
ELSE
    MOVE TRBFN-REKNR TO BF-REKNUM
END-IF
```

**Code References**:
- Record creation: [cbl/MYFIN.cbl#L600-L750](../../../cbl/MYFIN.cbl#L600-L750) (approximate section)
- Database write: BBF module output section

### Data Flow

```
Input (TRBFNCXP) → Validation → BBFPRGZP Creation → BBF Database → Magnetic Tape
```

1. **Input Validation**: Payment record validated (FUREQ_MYFIN_001)
2. **Member Enrichment**: Member data retrieved from MUTF08
3. **IBAN Processing**: Bank account validated and IBAN derived if needed
4. **Description Lookup**: Payment descriptions retrieved from parameter table
5. **BBF Record Creation**: All fields populated into BBFPRGZP structure
6. **Database Write**: Record written to BBF module database
7. **Tape Generation**: Records extracted for magnetic tape exchange

### Integration Points

**Input Sources**:
- [TRBFNCXP](DS_TRBFNCXP.md): Primary input record structure
- MUTF08 Database: Member data for enrichment
- UAREA Database: Bank account and IBAN data
- LIBPNC Parameter Table: Payment descriptions

**Output Destinations**:
- BBF Module Database: Intermediate storage
- Magnetic Tape (BETFIN): Financial institution exchange
- Payment Lists: 500001, 500004 (via BFN51GZR, BFN54GZR copybooks)

## Validation Rules

### Field Validation

| Field | Rule | Error Handling |
|-------|------|----------------|
| BF-PPR-FED | Must be valid mutuality code (101-169) | Reject record, diagnostic on 500004 |
| BF-PPR-RNR | Must correspond to existing member | Reject record: "LIDNR ONBEKEND/AFFILIE INCONNU" |
| BF-BEDRAG-EUR | Must be > 0, max 9999999.99 | Reject record: amount validation error |
| BF-IBAN | Must be valid IBAN if BF-BETWYZ blank | Reject record: "REKNR ONGELDIG/NO COMPTE INVALID" |
| BF-REKNUM | Must be valid Belgian account if BF-BETWYZ='C' | Reject record: account validation error |
| BF-BETKOD | Must exist in parameter table | Reject record: "CODE OMSCHR ONBEK/CODE LIBEL INCON" |

### Business Rules

1. **SEPA Compliance**:
   - If BF-BETWYZ = SPACES, BF-IBAN must be populated
   - BF-REKNUM set to zeroes for SEPA payments
   - IBAN validated against ISO 13616 standard

2. **Legacy Account Handling**:
   - If BF-BETWYZ = 'C', BF-REKNUM must be valid Belgian account
   - BF-IBAN may be populated from UAREA conversion

3. **Description Construction**:
   - BF-OMSCHR1 and BF-OMSCHR2 built from parameter table
   - Date substitution for codes 50 (period) and 60 (single date)
   - Language-specific descriptions (FR/NL/DE)

4. **MAF Payment Handling**:
   - BF-CODE-MAF and BF-JAAR-MAF populated only for MAF payments
   - Requires special processing in downstream systems

5. **Regional Accounting** (6th State Reform):
   - BF-TAGREG-OP and BF-TAGREG-LEG populated from member insurance data
   - Used for regional financial reporting

## Error Scenarios

### Creation Failures

1. **Missing Member Data**:
   - **Trigger**: BF-PPR-RNR not found in MUTF08
   - **Action**: No BBF record created
   - **Recovery**: Rejection record to 500004

2. **Invalid IBAN**:
   - **Trigger**: BF-IBAN fails validation
   - **Action**: No BBF record created
   - **Recovery**: Rejection record to 500004 with diagnostic

3. **Missing Bank Account**:
   - **Trigger**: BF-BETWYZ blank and BF-IBAN empty
   - **Action**: No BBF record created
   - **Recovery**: Rejection record to 500004

4. **Parameter Lookup Failure**:
   - **Trigger**: BF-BETKOD not found in LIBPNC
   - **Action**: No BBF record created
   - **Recovery**: Rejection record to 500004

## Performance Considerations

- **Record Size**: 192 bytes (relatively compact)
- **Creation Rate**: Thousands of records per batch run
- **Database Impact**: One write per validated payment
- **Magnetic Tape**: Buffered I/O for efficient tape generation

## Security and Compliance

- **Data Sensitivity**: Contains member national registry numbers and bank accounts
- **Encryption**: Not specified in copybook (handled at system level)
- **Audit Trail**: Sequence numbers (BF-NUMBER) for tracking
- **SEPA Compliance**: IBAN format and validation per ISO 13616
- **GDPR**: Personal data (BF-PPR-RNR, BF-RNR) subject to privacy regulations

## Related Documentation

- **Input Structure**: [DS_TRBFNCXP](DS_TRBFNCXP.md)
- **Output Lists**: DS_BFN51GZR (list 500001), DS_BFN54GZR (list 500004)
- **Functional Requirements**:
  - [FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md): Input validation
  - [FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md): Bank account validation
  - [FUREQ_MYFIN_005](../requirements/FUREQ_MYFIN_005_payment_record_creation.md): BBF record creation

## Modification History

| Date | Modifier | Reference | Change |
|------|----------|-----------|--------|
| Original | VVE | Initial | Base BBF record format (106 bytes) |
| 1998-11-26 | VVE | BVR suppression | Removed BRUGGE-BVR codes |
| 2005-06-23 | JVE | MAF extension | Added BF-CODE-MAF, BF-JAAR-MAF (6 bytes) |
| 2010-10-14 | JGO | SEPA/IBAN10 | Added IBAN fields (152/140 bytes) |
| 2010-10-24 | MIS | SEPA extension | Extended to 192/180 bytes |
| 2018-10-15 | JGO | R224154 | Added BF-TAGREG-OP, BF-TAGREG-LEG (6th State Reform) |
| 2019-07-01 | CDU | CDU001 | 6th State Reform adjustments |
| 2023-05-02 | KVS | JIRA-4224 | CSV output instead of Papyrus |
| 2023-06-16 | KVS | JIRA-4311 | PAIFIN-Belfius adaptation |
| 2024-07-23 | MSA | JIRA-4837 | CORREG handling |
| 2025-01-30 | MSA | JIRA-???? | BULK processing |

## Notes

- Record format has evolved significantly through SEPA adoption and 6th State Reform
- Multiple redefines allow flexible interpretation of fields (computational vs display)
- IBAN10 project introduced major changes to support SEPA compliance
- Regional TAG fields essential for post-2018 accounting requirements
- Backward compatibility maintained through redefines and optional fields
