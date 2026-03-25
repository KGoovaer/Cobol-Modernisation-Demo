# Data Structure: SEPAAUKU - SEPA User Record

**ID**: DS_SEPAAUKU  
**Type**: Output Record Structure  
**Purpose**: User records for SEPA payment tape generation (BAC, CERA/KBC, and other financial institutions)  
**Source Copybook**: [copy/sepaauku.cpy](../../../copy/sepaauku.cpy)  
**Last Updated**: 2026-01-29

## Overview

SEPAAUKU defines the user record structure for generating payment tapes (3N0001, 2N0001, 5N0001, etc.) for financial institutions including BAC (Belfius) and CERA (KBC). These records are used for processing payments through the financial channel (langs financiele weg). The structure supports multiple payment types: benefits (UITKREC), healthcare reimbursements (GEZOREC), maternity/marriage allowances (VHSREC), and hospitalization (HOSPREC).

The record has evolved through the 6th State Reform to include regional TAG fields (TAGREG-OP, TAGREG-LEG) and expanded ALOIS-REF values to support new payment categories (EATTEST, CORREG, BULK-INPUT, AFHOUDING-GEZO).

## Record Layout

### Record Header

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| REC-LENGTE | S9(4) COMP | 4 bytes | 1-4 | Record length in bytes |
| REC-CODE | S9(4) COMP | 4 bytes | 5-8 | Record type code |
| REC-NUM | 9(8) | 8 bytes | 9-16 | Record sequence number |
| USERCOD | X(6) | 6 bytes | 17-22 | User record code (3N0001, 2N0001, 5N0001, etc.) |
| USERFED | 9(3) | 3 bytes | 23-25 | Federation (mutuality) code |
| USERRNR | S9(8) COMP | 4 bytes | 26-29 | National registry number (binary) |
| USERMY | 9(3) | 3 bytes | 30-32 | Mutuality code |
| REC-DV | X(1) | 1 byte | 33 | Record division/version |
| FILLER | X(10) | 10 bytes | 34-43 | Reserved |

### USERCOD Values and Types

**88-Level Conditions**:
- **UITKREC**: VALUE "3N0001" - Benefits payment record
- **GEZOREC**: VALUE "2N0001", "5N0001", "9N0001" - Healthcare reimbursement record
- **VHSREC**: VALUE "4N0001" - Maternity/marriage allowance record
- **HOSPREC**: VALUE "1N0001" - Hospitalization record

### EIGENL-REC (Proprietary Record Structure)

#### KEY2 - Bank Code

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **U-BAC-KODE** | 9(4) | 4 bytes | 44-47 | Bank code identifier |

#### KEY-REC - Composite Key Structure

##### KEY1 - Bank and Payment Type

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **WELKEBANK** | 9(1) | 1 byte | 48 | Bank selection indicator |
| HOOFDBANK | (88-level) | | | VALUE ZERO - Main bank |
| ALTERNATIEVEBANK | (88-level) | | | VALUE 1 - Alternative bank |
| **ALOIS-RAF** | 9(1) | 1 byte | 49 | ALOIS reference/payment category |
| **VRBOND** | 9(3) | 3 bytes | 50-52 | Federation bond number |

**ALOIS-RAF Values (88-Level Conditions)**:
- **VERGOED**: VALUE ZERO - Reimbursement
- **BETFIN**: VALUE 1 - BETFIN payment (manual GIRBET)
- **REISVERZ**: VALUE 2 - Travel insurance
- **VOORHUW**: VALUE 3 - Marriage/maternity allowance
- **HOSPVZ**: VALUE 4 - Hospitalization insurance
- **EATTEST**: VALUE 5 - E-attestation (added IDB)
- **CORREG**: VALUE 6 - Corrective regulation (added IDB)
- **BULK-INPUT**: VALUE 7 - Bulk input processing (added IDB1)
- **AFHOUDING-GEZO**: VALUE 8 - Healthcare deduction

**KEY4** (composite of ALOIS-RAF and VRBOND): Used for categorizing payment type and federation.

##### KEY3 - Language, Date, and Member Identification

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **TAAL** | 9(1) | 1 byte | 53 | Language code (1=FR, 2=NL, 3=DE) |
| **BAC-DATM61** | 9(8) | 8 bytes | 54-61 | Bank date in YYYYMMDD format |
| **RIJKSNR** | | 15 bytes | 62-76 | National registry number (structured) |
| EEUW | 9(2) | 2 bytes | 62-63 | Century (19 or 20) |
| RESTNR | X(13) | 13 bytes | 64-76 | Remainder of registry number |
| **REFNR** | (redefines RIJKSNR) | | | Reference number variant |
| FILLER | XX | 2 bytes | 62-63 | (in REFNR redefine) |
| REF | 9(13) | 13 bytes | 64-76 | Numeric reference |

#### REST-REC - Remainder of Record

##### Administrative Data

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **U-ACTDAT** | 9(8) | 8 bytes | 77-84 | Action/transaction date (YYYYMMDD) |
| **FILLER** | X(12) | 12 bytes | 85-96 | Reserved |

##### U-BNK-ADRES - Bank Account Holder Address

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **U-BNK-REKHOUDER** | X(30) | 30 bytes | 97-126 | Bank account holder name |
| **U-BNK-LND** | X(3) | 3 bytes | 127-129 | Bank country code |
| **U-BNK-POSTNR** | S9(8) COMP | 4 bytes | 130-133 | Bank postal code (binary) |
| **U-BNK-GEM** | X(15) | 15 bytes | 134-148 | Bank municipality |

##### U-ADM-ADRES - Administrative Address (Member or Beneficiary)

**Purpose**: Name and address of the sick person or partially reimbursed party.

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **U-ADM-NAAM** | X(18) | 18 bytes | 149-166 | Last name |
| **U-ADM-VNAAM** | X(12) | 12 bytes | 167-178 | First name |
| **U-ADM-STR** | X(21) | 21 bytes | 179-199 | Street name |
| **U-ADM-HUIS** | S9(4) COMP | 2 bytes | 200-201 | House number (binary) |
| **U-ADM-INDEX** | X(3) | 3 bytes | 202-204 | Address index/suffix |
| **U-ADM-BUS** | 9(4) | 4 bytes | 205-208 | Box/apartment number |
| **U-ADM-LND** | X(3) | 3 bytes | 209-211 | Country code |
| **U-ADM-POST** | S9(8) COMP | 4 bytes | 212-215 | Postal code (binary) |
| **U-ADM-GEM** | X(15) | 15 bytes | 216-230 | Municipality |

**U-ADM-NAAM-VNAAM** (composite of U-ADM-NAAM and U-ADM-VNAAM): Full name structure (30 bytes total).

##### COMMENTAAR - Communication/Comment Field (106 bytes)

**Purpose**: Multi-purpose field with multiple redefines for different payment types.

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **COMMENTAAR** | X(106) | 106 bytes | 231-336 | Base comment field |

###### COMMENTUITK (Redefines COMMENTAAR) - Benefits Payment Details

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| BERICHT | 9(1) | 1 byte | 231 | Message indicator |
| DAT-BERICHT | 9(8) | 8 bytes | 232-239 | Message date (YYYYMMDD) |
| DATVAN | 9(8) | 8 bytes | 240-247 | Period from date |
| DATTOT | 9(8) | 8 bytes | 248-255 | Period to date |
| BAC-VGD | 9(3) | 3 bytes | 256-258 | BAC reimbursed days |
| BAC-DBDR | 9(4) | 4 bytes | 259-262 | BAC day amount |
| GUTKOM | X(18) | 18 bytes | 263-280 | Benefit amount |
| GUTINDIKATIE | X(1) | 1 byte | 281 | Benefit indicator |
| NAAMZIEKE | X(18) | 18 bytes | 282-299 | Sick person name |
| **VNAAMZIEKE** | | 12 bytes | 300-311 | Sick person first name |
| VNGEWOON | | 10 bytes | 300-309 | Common first name |
| VNCQ | X(1) | 1 byte | 300 | First name qualifier |
| FILLER | X(9) | 9 bytes | 301-309 | Reserved |
| FILLER | X(2) | 2 bytes | 310-311 | Reserved |
| BAC-VADADO | X(1) | 1 byte | 312 | BAC parent/guardian flag |
| BAC-DBDR-U | X(5) | 5 bytes | 313-317 | BAC day amount (unit) |
| FILLER | X(19) | 19 bytes | 318-336 | Reserved |

###### KOM-GESTRUK-MEDE (Redefines COMMENTAAR) - Structured Communication

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| GESTRUK-MEDE | X(12) | 12 bytes | 231-242 | Structured message (e.g., "+++123/4567/89012+++") |
| FILLER | X(94) | 94 bytes | 243-336 | Reserved |

###### KOM-GEZO-BANK (Redefines COMMENTAAR) - Healthcare Bank Transfer

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| TEKST-GROOT | X(53) | 53 bytes | 231-283 | Large text field |
| TEKST-KENMERK | X(9) | 9 bytes | 284-292 | Text identifier |
| REF-NUMMER | 9(10) | 10 bytes | 293-302 | Reference number |
| FILLER | X(1) | 1 byte | 303 | Reserved |
| VOLG-NUMMER | 9(4) | 4 bytes | 304-307 | Sequence number |
| FILLER | X(1) | 1 byte | 308 | Reserved |
| OMSCHRIJVING1 | X(14) | 14 bytes | 309-322 | Description line 1 |
| OMSCHRIJVING2 | X(14) | 14 bytes | 323-336 | Description line 2 |

###### KOM-GEZO-POST (Redefines COMMENTAAR) - Healthcare Postal Transfer

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| ROF-JEF | X(28) | 28 bytes | 231-258 | ROF/JEF identifier |
| TEKST-KLEIN | X(28) | 28 bytes | 259-286 | Small text field |
| OMSCHRIJVING-P | X(14) | 14 bytes | 287-300 | Postal description |
| REFNUMMER-P | 9(10) | 10 bytes | 301-310 | Postal reference number |
| VOLGNUMMER-P | 9(4) | 4 bytes | 311-314 | Postal sequence number |
| FILLER | X(22) | 22 bytes | 315-336 | Reserved |

###### BEDRAGEN-UITK (Redefines COMMENTAAR) - Benefits Amounts

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| DOSSIER | S9(8) COMP | 4 bytes | 231-234 | Dossier number (binary) |
| UITGIFTE | 9(8) | 8 bytes | 235-242 | Issuance number |
| NETBEDRAG | S9(8) COMP | 4 bytes | 243-246 | Net amount (binary) |
| BDR-C21 | S9(8) COMP | 4 bytes | 247-250 | Amount C21 |
| BDR-C23 | S9(8) COMP | 4 bytes | 251-254 | Amount C23 |
| BDR-PIAR | S9(8) COMP | 4 bytes | 255-258 | Amount PIAR |
| BDR-PI23 | S9(8) COMP | 4 bytes | 259-262 | Amount PI23 |
| BDR-MIP | S9(8) COMP | 4 bytes | 263-266 | Amount MIP |
| BDR-C421 | S9(8) COMP | 4 bytes | 267-270 | Amount C421 |
| BDR-PIZLF | S9(8) COMP | 4 bytes | 271-274 | Amount PIZLF |
| BDR-RWP | S9(8) COMP | 4 bytes | 275-278 | Amount RWP |
| BDR-GUT | S9(8) COMP | 4 bytes | 279-282 | Benefit amount |
| BDR-PI3 | S9(8) COMP | 4 bytes | 283-286 | Amount PI3 |
| BDR-C423 | S9(8) COMP | 4 bytes | 287-290 | Amount C423 |
| BDR-PI423 | S9(8) COMP | 4 bytes | 291-294 | Amount PI423 |
| BDR-B23 | S9(8) COMP | 4 bytes | 295-298 | Amount B23 |
| BDR-VH | S9(8) COMP | 4 bytes | 299-302 | Amount VH |

###### GEG-VHSP (Redefines BEDRAGEN-UITK) - Maternity/Marriage Data

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| FILLER | X(12) | 12 bytes | 231-242 | Reserved |
| VHSNET | S9(8) COMP | 4 bytes | 243-246 | VHS net amount (binary) |
| VHSNRM61 | 9(3) | 3 bytes | 247-249 | VHS number M61 |
| VHSBETM61 | 9(4) | 4 bytes | 250-253 | VHS payment M61 |
| VHS-NRBANK | 9(12) | 12 bytes | 254-265 | VHS bank number |
| FILLER | X(33) | 33 bytes | 266-298 | Reserved |

##### Additional Fields (Post-COMMENTAAR)

| Field | Type | Length | Position | Description |
|-------|------|--------|----------|-------------|
| **FILLER** | X(20) | 20 bytes | 337-356 | Reserved |
| **CODE-GESTRUK-MEDE** | X(1) | 1 byte | 357 | Structured message code |
| MEDE-101 | (88-level) | | | VALUE "1" - Message type 101 |
| **U-IBAN** | X(34) | 34 bytes | 358-391 | IBAN bank account number |
| **U-BIC** | X(11) | 11 bytes | 392-402 | BIC (Bank Identifier Code) |
| **U-BETWYZ** | X(1) | 1 byte | 403 | Payment method code |
| INHOUDING | (88-level) | | | VALUE "A" - Deduction |
| BANK | (88-level) | | | VALUE "B" - Bank transfer |
| DEBT_MLCD_NA | (88-level) | | | VALUE "C" - Debit MLCD NA |
| CRED_MLCD_CR | (88-level) | | | VALUE "D" - Credit MLCD CR |
| DEBT_MLDB_NA | (88-level) | | | VALUE "E" - Debit MLDB NA |
| CRED_MLDB_CR | (88-level) | | | VALUE "F" - Credit MLDB CR |
| **TAG-REG-OP** | X(2) | 2 bytes | 404-405 | TAG region OP (6th State Reform) |
| **TAG-REG-LEG** | X(2) | 2 bytes | 406-407 | TAG region LEG (6th State Reform) |

**Total Record Length**: Approximately 407 bytes (varies based on REC-LENGTE)

## Field-Level Specifications

### USERCOD (User Record Code)
- **Purpose**: Identifies the type of payment record for financial institution processing
- **Values**:
  - "3N0001": Benefits (UITKREC)
  - "2N0001", "5N0001", "9N0001": Healthcare reimbursements (GEZOREC)
  - "4N0001": Maternity/marriage allowances (VHSREC)
  - "1N0001": Hospitalization (HOSPREC)
- **Usage**: Determines which COMMENTAAR redefine structure applies

### USERFED and USERMY
- **USERFED**: Federation code (mutuality group identifier)
- **USERMY**: Specific mutuality code (101-169)
- **Relationship**: USERMY is more granular than USERFED
- **Usage**: Organizational hierarchy for payment routing

### WELKEBANK (Bank Selection)
- **Purpose**: Indicates which bank account to use for payment
- **Values**:
  - 0 (HOOFDBANK): Main bank account
  - 1 (ALTERNATIEVEBANK): Alternative bank account
- **Usage**: R140562 modification - supports dual bank processing (Belfius and KBC)

### ALOIS-RAF (Payment Category)
- **Purpose**: Categorizes the payment type for ALOIS system
- **Values**:
  - 0 (VERGOED): Standard reimbursement
  - 1 (BETFIN): Manual GIRBET payment (MYFIN primary usage)
  - 2 (REISVERZ): Travel insurance
  - 3 (VOORHUW): Marriage/maternity allowance
  - 4 (HOSPVZ): Hospitalization insurance
  - 5 (EATTEST): E-attestation
  - 6 (CORREG): Corrective regulation
  - 7 (BULK-INPUT): Bulk input processing
  - 8 (AFHOUDING-GEZO): Healthcare deduction
- **MYFIN Usage**: Typically set to 1 (BETFIN) for manual GIRBET payments

### TAAL (Language Code)
- **Purpose**: Language for payment communication
- **Values**:
  - 1: French
  - 2: Dutch
  - 3: German
- **Usage**: Determines language for payment descriptions and communications

### RIJKSNR / REFNR (National Registry Number)
- **Purpose**: Member identification
- **RIJKSNR Format**: EEUW (century) + RESTNR (13 chars) = 15 bytes
- **REFNR Format**: 2-byte filler + REF (13-digit numeric)
- **Usage**: Both redefines provide flexibility in member identification

### U-IBAN and U-BIC
- **U-IBAN**: International Bank Account Number (ISO 13616, max 34 chars)
- **U-BIC**: Bank Identifier Code (Swift code, 11 chars)
- **Purpose**: SEPA-compliant bank account identification
- **Validation**: IBAN check digit validation required
- **Source**: Retrieved from UAREA database based on member's registered bank account

### U-BETWYZ (Payment Method)
- **Purpose**: Specifies payment execution method
- **Values**:
  - "A" (INHOUDING): Deduction/withholding
  - "B" (BANK): Standard bank transfer
  - "C" (DEBT_MLCD_NA): Debit MLCD NA
  - "D" (CRED_MLCD_CR): Credit MLCD CR
  - "E" (DEBT_MLDB_NA): Debit MLDB NA
  - "F" (CRED_MLDB_CR): Credit MLDB CR
- **Default**: "B" (BANK) for most MYFIN payments

### TAG-REG-OP and TAG-REG-LEG (6th State Reform Regional Tags)
- **Purpose**: Regional accounting tags for post-2018 state reform
- **TAG-REG-OP**: Openstaande Pakket (Open Package) region code
- **TAG-REG-LEG**: Legger (Ledger) region code
- **Added**: R224154 (2018-10-15)
- **Usage**: Regional financial reporting and accountability

### COMMENTAAR and Redefines
- **Purpose**: Flexible communication field adapted to payment type
- **Size**: 106 bytes
- **Redefines**:
  - **COMMENTUITK**: Benefits payment details (dates, amounts, sick person info)
  - **KOM-GESTRUK-MEDE**: Structured communication (12-char formatted message)
  - **KOM-GEZO-BANK**: Healthcare bank transfer details
  - **KOM-GEZO-POST**: Healthcare postal transfer details
  - **BEDRAGEN-UITK**: Detailed benefits amount breakdown
  - **GEG-VHSP**: Maternity/marriage payment details
- **Usage Selection**: Based on USERCOD and payment context

## Usage in MYFIN

### Record Creation for BETFIN Payments

MYFIN creates SEPAAUKU records for manual GIRBET payments that are routed to financial institutions via SEPA transfer:

```cobol
* Initialize SEPA user record
MOVE record-length TO REC-LENGTE
MOVE record-code TO REC-CODE
MOVE sequence-number TO REC-NUM

* Set user code for BETFIN payment type
MOVE "3N0001" TO USERCOD    * Or appropriate code

* Populate identification
MOVE TRBFN-DEST TO USERFED
MOVE TRBFN-PPR-RNR TO USERRNR
MOVE SECTION-TROUVEE TO USERMY

* Set payment category
MOVE 1 TO ALOIS-RAF         * BETFIN
MOVE 0 TO WELKEBANK         * Main bank

* Language and date
MOVE ADM-TAAL TO TAAL
MOVE current-date TO BAC-DATM61
MOVE TRBFN-RNR TO RIJKSNR

* Bank account information (from UAREA)
MOVE member-iban TO U-IBAN
MOVE member-bic TO U-BIC
MOVE "B" TO U-BETWYZ        * Bank transfer

* Build communication field
PERFORM BUILD-COMMENTAAR
```

**Code References**:
- Record creation: [cbl/MYFIN.cbl#L800-L950](../../../cbl/MYFIN.cbl#L800-L950) (approximate section)
- IBAN retrieval: [cbl/MYFIN.cbl#L400-L500](../../../cbl/MYFIN.cbl#L400-L500) (UAREA lookup)

### Data Flow

```
Input (TRBFNCXP) → Validation → Member Data → IBAN Lookup → SEPAAUKU Creation → Payment Tape
```

1. **Input Processing**: Payment record validated (FUREQ_MYFIN_001)
2. **Member Enrichment**: Administrative and insurance data retrieved
3. **IBAN Resolution**: Bank account and IBAN retrieved from UAREA
4. **SEPA Record Creation**: Fields populated into SEPAAUKU structure
5. **Communication Building**: COMMENTAAR field populated with payment details
6. **Tape Generation**: Record written to financial institution tape (3N0001, etc.)

### Integration Points

**Input Sources**:
- [TRBFNCXP](DS_TRBFNCXP.md): Primary input for payment details
- MUTF08 Database: Member administrative data
- UAREA Database: Bank account (IBAN, BIC) data
- LIDVZ Records: Insurance section and language data

**Output Destinations**:
- Payment Tape Files: 3N0001 (benefits), 2N0001/5N0001/9N0001 (healthcare)
- Financial Institutions: BAC (Belfius), CERA/KBC
- List 500001: Successful payment records (BFN51GZR)

## Validation Rules

### Field Validation

| Field | Rule | Error Handling |
|-------|------|----------------|
| USERCOD | Must be valid record type | System error - invalid record type |
| USERFED, USERMY | Must be valid mutuality codes | Reject record |
| WELKEBANK | Must be 0 or 1 | System error - invalid bank selection |
| ALOIS-RAF | Must be 0-8 | System error - invalid payment category |
| TAAL | Must be 1, 2, or 3 | Reject record: "TAALCODE ONBEK/CODE LING INCON" |
| U-IBAN | Must be valid IBAN if U-BETWYZ='B' | Reject record: "REKNR ONGELDIG/NO COMPTE INVALID" |
| U-BIC | Must be valid BIC if IBAN present | Reject record: bank code validation error |
| RIJKSNR | Must match USERRNR | Data consistency error |

### Business Rules

1. **SEPA Compliance**:
   - U-IBAN and U-BIC must be populated for SEPA transfers (U-BETWYZ='B')
   - IBAN validated against ISO 13616 standard
   - BIC validated against Swift code format

2. **Bank Selection** (R140562):
   - WELKEBANK determines primary vs. alternative bank
   - Supports dual bank processing (Belfius and KBC)
   - Member preference stored in UAREA

3. **Payment Type Routing**:
   - ALOIS-RAF=1 (BETFIN) for MYFIN manual payments
   - Different ALOIS-RAF values route to different processing systems
   - USERCOD must align with ALOIS-RAF category

4. **Language Handling**:
   - TAAL determined from ADM-TAAL or insurance section
   - Bilingual mutualities (106, 107, 150, 166) may have member preference
   - Affects COMMENTAAR content in payment communication

5. **Regional Accounting** (6th State Reform):
   - TAG-REG-OP and TAG-REG-LEG populated from insurance section
   - Required for post-2018 regional reporting
   - Links payment to specific regional authority

## Record Type Specifics

### BETFIN Payments (MYFIN Primary Usage)

**USERCOD**: Typically "3N0001" (benefits) or appropriate code  
**ALOIS-RAF**: 1 (BETFIN)  
**COMMENTAAR Redefine**: Usually KOM-GEZO-BANK

**Key Fields**:
- TEKST-GROOT: Payment description from parameter table (SAV-LIBELLE)
- REF-NUMMER: Payment reference constant (TRBFN-CONSTANTE)
- VOLG-NUMMER: Sequence number (TRBFN-NO-SUITE)
- OMSCHRIJVING1, OMSCHRIJVING2: Description lines from LIBPNC parameter

### Healthcare Reimbursements (GEZOREC)

**USERCOD**: "2N0001", "5N0001", "9N0001"  
**ALOIS-RAF**: 0 (VERGOED)  
**COMMENTAAR Redefine**: KOM-GEZO-BANK or KOM-GEZO-POST

**Key Fields**:
- U-BNK-ADRES: Bank account holder information
- U-ADM-ADRES: Patient/beneficiary address
- BEDRAGEN-UITK: Detailed amount breakdown (if applicable)

### Benefits (UITKREC)

**USERCOD**: "3N0001"  
**ALOIS-RAF**: Various (0, 1, etc.)  
**COMMENTAAR Redefine**: COMMENTUITK

**Key Fields**:
- DATVAN, DATTOT: Benefit period
- BAC-VGD, BAC-DBDR: Daily benefit amounts
- NAAMZIEKE, VNAAMZIEKE: Sick person identification
- BEDRAGEN-UITK: Amount details

### Maternity/Marriage Allowances (VHSREC)

**USERCOD**: "4N0001"  
**ALOIS-RAF**: 3 (VOORHUW)  
**COMMENTAAR Redefine**: GEG-VHSP

**Key Fields**:
- VHSNET: Net allowance amount
- VHS-NRBANK: Bank number for payment
- VHSNRM61, VHSBETM61: M61 reference data

## Error Scenarios

### Creation Failures

1. **Missing IBAN/BIC**:
   - **Trigger**: U-IBAN or U-BIC not found in UAREA
   - **Action**: No SEPA record created
   - **Recovery**: Rejection to 500004 or attempt legacy account

2. **Invalid Bank Selection**:
   - **Trigger**: WELKEBANK not 0 or 1
   - **Action**: System error
   - **Recovery**: Default to HOOFDBANK (0)

3. **Invalid Payment Category**:
   - **Trigger**: ALOIS-RAF value > 8 or < 0
   - **Action**: System error
   - **Recovery**: Program termination or default to BETFIN (1)

4. **Language Code Failure**:
   - **Trigger**: TAAL = 0 or invalid after all attempts
   - **Action**: No SEPA record created
   - **Recovery**: Rejection to 500004: "TAALCODE ONBEK"

5. **COMMENTAAR Build Failure**:
   - **Trigger**: Unable to populate COMMENTAAR fields
   - **Action**: Incomplete record
   - **Recovery**: Use default/blank values, log warning

## Performance Considerations

- **Record Size**: ~407 bytes (moderate size)
- **Creation Rate**: Thousands per batch run
- **Tape I/O**: Buffered sequential write for efficiency
- **IBAN Lookup**: Database access per record (potential bottleneck)
- **Redefine Overhead**: Minimal (compile-time structure, no runtime cost)

## Security and Compliance

- **Data Sensitivity**: Contains PII (national registry, name, address, bank account)
- **IBAN Security**: Bank account numbers must be protected
- **Encryption**: Tape encryption at system level (not specified in copybook)
- **SEPA Compliance**: IBAN and BIC format per ISO 13616 and Swift standards
- **GDPR**: Personal data subject to privacy regulations, retention policies apply
- **Audit Trail**: REC-NUM provides sequence tracking

## Related Documentation

- **Input Structure**: [DS_TRBFNCXP](DS_TRBFNCXP.md)
- **BBF Record**: [DS_BBFPRGZP](DS_BBFPRGZP.md) - Parallel output structure
- **Output Lists**: DS_BFN51GZR (list 500001), DS_BFN54GZR (list 500004)
- **Functional Requirements**:
  - [FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md): Input validation
  - [FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md): Bank account/IBAN validation
  - [FUREQ_MYFIN_004](../requirements/FUREQ_MYFIN_004_payment_list_generation.md): Payment list generation

## Modification History

| Date | Modifier | Reference | Change |
|------|----------|-----------|--------|
| Original | - | Initial | Base SEPA user record format |
| 2018-10-15 | JGO | R224154 | Added TAG-REG-OP, TAG-REG-LEG (6th State Reform) |
| - | IDB | ALOIS expansion | Added ALOIS-REF=5 (EATTEST), 6 (CORREG) |
| - | IDB1 | ALOIS expansion | Added ALOIS-REF=7 (BULK-INPUT) |
| 2019-07-01 | CDU | CDU001 | 6th State Reform adjustments |
| 2024-07-23 | MSA | JIRA-4837 | CORREG handling (ALOIS-RAF=6) |
| 2025-01-30 | MSA | JIRA-???? | BULK processing (ALOIS-RAF=7) |

## Notes

- Complex structure with multiple redefines provides flexibility for various payment types
- COMMENTAAR field is key differentiator - redefine selection based on USERCOD
- SEPA compliance critical - IBAN/BIC validation essential
- 6th State Reform (TAG fields) impacts regional accounting and reporting
- R140562 dual bank support allows payment routing to Belfius or KBC
- ALOIS-RAF expansion supports new payment categories (e-attestation, corrective regulation, bulk)
- Record type (UITKREC, GEZOREC, etc.) determines downstream processing path
- Tape format legacy but still in use for financial institution integration
