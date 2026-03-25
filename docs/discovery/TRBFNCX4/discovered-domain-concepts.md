# Discovered Data Structures - MYFIN

## Overview
This document catalogs all data structures, record layouts, copybooks, and programs discovered in the MYFIN system, which processes manual GIRBET payment records for the Belgian mutual insurance system.

---

## Record Layouts

### TRBFNCXP - Input Payment Record (PPR Record)
- **Purpose**: Input record created by TRBFNCXB for manual payment processing
- **Source**: Copybook `trbfncxp.cpy`
- **Record Code**: 42
- **Record Name**: GIRBET
- **Length**: 186/174 bytes (with SEPA/IBAN extensions)
- **Key Fields**: 
  - TRBFN-PPR-RNR: Member's national registry number (binary)
  - TRBFN-CONSTANTE: Unique payment identifier (10 digits)
  - TRBFN-NO-SUITE: Sequence number within payment batch (4 digits)
- **Attributes**:
  - `TRBFN-LENGTH`: Record length (S9(4) COMP)
  - `TRBFN-CODE`: Record code = 42 (S9(4) COMP)
  - `TRBFN-NUMBER`: Record sequence number (9(8))
  - `TRBFN-PPR-NAME`: PPR identifier = "GIRBET" (X(6))
  - `TRBFN-PPR-FED`: Federation number (9(3))
  - `TRBFN-PPR-RNR`: National registry number (S9(8) COMP)
  - **Payment Data**:
    - `TRBFN-DEST`: Destination mutual/federation (9(3))
    - `TRBFN-DATMEMO`: Memo date CCYYMMDD (9(8))
    - `TRBFN-TYPE-COMPTA`: Accounting type (9) - 1=General, 2=AL, 3-6=Regional accounts
    - `TRBFN-CONSTANTE`: Payment constant/identifier (9(10))
    - `TRBFN-NO-SUITE`: Sequential number (9(4))
    - `TRBFN-RNR`: National registry number text format (X(13))
    - `TRBFN-MONTANT`: Payment amount in cents (S9(8))
    - `TRBFN-CODE-LIBEL`: Payment type/reason code (9(2))
    - `TRBFN-LIBELLE1`: Description line 1 (X(14))
    - `TRBFN-LIBELLE2`: Description line 2 (X(14))
    - `TRBFN-REKNR`: Bank account number legacy format (9(12))
    - `TRBFN-COMPTE-MEMBRE`: Member account indicator (9(1))
    - `TRBFN-MONTANT-DV`: Currency indicator E=Euro, others (X)
    - `TRBFN-BETWYZ`: Payment method (X) - B=Bank, C=Circular check, D-F=Other methods
    - `TRBFN-IBAN`: International bank account number (X(34))
- **Used In Programs**: MYFIN
- **Database**: Temporary processing record, not stored

### BBFPRGZP - Financial Payment Input Record
- **Purpose**: Input record for batch payment processing from Betfin cassette processing
- **Source**: Copybook `bbfprgzp.cpy`
- **Record Code**: 42
- **Record Name**: PPRBBF
- **Length**: 192/180 bytes
- **Key Fields**:
  - BF-PPR-RNR: National registry number (binary)
  - BF-KONST: Payment constant (section, cashier, session date)
- **Attributes**:
  - `BF-LENGTH`: Record length (S9(4) COMP)
  - `BF-CODE`: Record code = 42 (S9(4) COMP)
  - `BF-NUMBER`: Record sequence number (9(8))
  - `BF-PPR-NAME`: PPR name = "PPRBBF" (X(6))
  - `BF-PPR-FED`: Federation number (9(3))
  - `BF-PPR-RNR`: National registry number (S9(8) COMP)
  - **Payment Data**:
    - `BF-VBOND`: Federation number (9(2))
    - `BF-KONST`: Constant structure
      - `BF-AFDEL`: Section number (9(3))
      - `BF-KASSIER`: Cashier number (9(3))
      - `BF-DATZIT-DM`: Session date DDMM (9(4))
    - `BF-BETWYZ`: Payment method C=Circular check (X)
    - `BF-RNR`: National registry number (X(13))
    - `BF-BETKOD`: Payment reason code (9(2))
    - `BF-BEDRAG`: Amount in old currency format (9(5))
    - `BF-REKNUM`: Bank account number (9(12))
    - `BF-VOLGNR-M30`: M30 sequence number (9(3))
    - `BF-OMSCHR1`: Description 1 (X(14))
    - `BF-OMSCHR2`: Description 2 (X(14))
    - `BF-BEDRAG-EUR`: Amount in Euro cents (9(8))
    - `BF-BEDRAG-DV`: Currency indicator (X)
    - `BF-CODE-MAF`: MAF payment code (X)
    - `BF-JAAR-MAF`: MAF payment year (9(4))
    - `BF-IBAN`: International bank account (X(34))
    - `BF-OMSCHR3`: Extended description (X(40))
    - `BF-TAGREG-OP`: Regional tag operation (9(2))
    - `BF-TAGREG-LEG`: Regional tag legal entity (9(2))
- **Used By**: BBFPRGZ4 (financial payment batch processor)
- **Database**: Input from Betfin cassette system

### SEPAAUKU - SEPA Bank Payment User Record
- **Purpose**: SEPA-compliant bank payment instruction record for BAC/CERA/KBC banks
- **Source**: Copybook `sepaauku.cpy`
- **User Codes**: 
  - "3N0001" (UITKREC - Benefits)
  - "2N0001", "5N0001", "9N0001" (GEZOREC - Health)
  - "4N0001" (VHSREC - Marriage insurance)
  - "1N0001" (HOSPREC - Hospital insurance)
- **Length**: 475 bytes (after 6th state reform)
- **Key Fields**:
  - WELKEBANK: Bank selection (0=Belfius, 1=KBC)
  - U-IBAN: International bank account number
  - U-BIC: Bank identification code
- **Attributes**:
  - `REC-LENGTE`: Record length (S9(4) COMP)
  - `REC-CODE`: Record code (S9(4) COMP)
  - `REC-NUM`: Record number (9(8))
  - `USERCOD`: User record code identifier (X(6))
  - `USERFED`: Federation number (999)
  - `USERRNR`: National registry number (S9(8) COMP)
  - `USERMY`: Section/mutual number (999)
  - `REC-DV`: Currency indicator (X)
  - **Bank Routing**:
    - `U-BAC-KODE`: Bank account code (9(4)) - 13=AO, 23=AL, 113/123=KBC variants
    - `WELKEBANK`: Bank selection 0=Belfius/1=KBC (9)
    - `ALOIS-RAF`: Payment category (9) - 0=Vergoed, 1=Betfin, 2=Reisverz, 3=Voorhuw, 4=Hospvz, 5=Eattest, 6=Correg, 7=Bulk, 8=Afhouding
    - `VRBOND`: Federation number (999)
    - `TAAL`: Language code (9) - 1=NL, 2=FR, 3=DE
    - `BAC-DATM61`: Account date indicator (9(8))
  - **Account Holder Address**:
    - `U-BNK-REKHOUDER`: Account holder name (X(30))
    - `U-BNK-LND`: Country code (XXX)
    - `U-BNK-POSTNR`: Postal code (S9(8) COMP)
    - `U-BNK-GEM`: City (X(15))
  - **Member Administrative Address**:
    - `U-ADM-NAAM`: Last name (X(18))
    - `U-ADM-VNAAM`: First name (X(12))
    - `U-ADM-STR`: Street (X(21))
    - `U-ADM-HUIS`: House number (S9(4) COMP)
    - `U-ADM-INDEX`: Address index (XXX)
    - `U-ADM-BUS`: Bus/box number (9(4))
    - `U-ADM-LND`: Country (XXX)
    - `U-ADM-POST`: Postal code (S9(8) COMP)
    - `U-ADM-GEM`: Municipality (X(15))
  - **Payment Details**:
    - `COMMENTAAR`: Communication/reference (X(106)) - Multiple redefines for different payment types
    - `BEDRAGEN-UITK`: Benefit amounts structure
    - `U-IBAN`: IBAN account number (X(34))
    - `U-BIC`: Bank identification code (X(11))
    - `U-BETWYZ`: Payment method (X) - A=Inhouding, B=Bank, C=Debt MLCD, D=Credit MLCD, E=Debt MLDB, F=Credit MLDB
    - `TAG-REG-OP`: Regional tag operation (X(2))
    - `TAG-REG-LEG`: Regional tag legal entity (X(2))
- **Used In Programs**: MYFIN, various payment processing programs
- **Output**: Bank payment instruction file (500001/5N0001)

### BFN51GZR - Payment Detail List Output Record
- **Purpose**: Detail line for payment list output (document 500001)
- **Source**: Copybook `bfn51gzr.cpy`
- **Record Code**: 40 (standard payments) or 43 (regional payments, CSV format per JIRA-4224)
- **List Names**: 
  - "500001" (general payments)
  - "541001" (mutual 141)
  - "500071", "500091", "500061", "500081" (regional payments types 3,4,5,6)
  - "5DET01" (CSV detail export per JIRA-4224)
- **Length**: 213 bytes (after 6th state reform)
- **Key Fields**:
  - BBF-N51-VERB: Federation number
  - BBF-N51-KONST: Payment constant
  - BBF-N51-VOLGNR: Sequence number
- **Attributes**:
  - `BBF-N51-LENGTH`: Record length (S9(4) COMP)
  - `BBF-N51-CODE`: Record code 40 or 43 (S9(4) COMP)
  - `BBF-N51-NUMBER`: Record number (9(8))
  - `BBF-N51-DEVICE-OUT`: Output device C=Console/L=List (X)
  - `BBF-N51-DESTINATION`: Destination mutual (999)
  - `BBF-N51-SWITCHING`: Switching indicator (X)
  - `BBF-N51-PRIORITY`: Priority (X)
  - `BBF-N51-NAME`: List name identifier (X(6))
  - **Key Structure**:
    - `BBF-N51-VERB`: Federation number (999)
    - `BBF-N51-AFK`: Payment source (9) - 1=Loket, 2=Paifin-AO, 3=Paifin-AL, 4=Franchise, 5=Eattest, 6=Correg, 7=Bulk
    - `BBF-N51-KONST`: Payment constant (9(10))
    - `BBF-N51-VOLGNR`: Sequence number (9(4))
    - `BBF-N51-INFOREK`: Info record indicator (9)
  - **Payment Data**:
    - `BBF-N51-RNR`: National registry number (X(13))
    - `BBF-N51-NAAM`: Last name (X(18))
    - `BBF-N51-VOORN`: First name (X(12))
    - `BBF-N51-LIBEL`: Payment type code (99)
    - `BBF-N51-REKNR`: Bank account number (X(14))
    - `BBF-N51-BEDRAG`: Amount (9(6))
    - `BBF-N51-BANK`: Bank code 1=Baccob/2=Cera/3=BVR (9)
    - `BBF-N51-DV`: Currency indicator (X)
    - `BBF-N51-DN`: Currency numeric (9)
    - `BBF-N51-TYPE-COMPTE`: Account type (X(4))
    - `BBF-N51-IBAN`: IBAN account (X(34))
    - `BBF-N51-BETWY`: Payment method (X)
    - `BBF-N51-TAGREG-OP`: Regional tag operation (9(2))
- **Used In Programs**: MYFIN
- **Output**: Payment detail list for member/bank processing

### BFN54GZR - Payment Rejection List Output Record
- **Purpose**: Rejection/error report for payments that failed validation
- **Source**: Copybook `bfn54gzr.cpy`
- **Record Code**: 40 (standard) or 43 (regional)
- **List Names**: 
  - "500004" (general rejections)
  - "541004" (mutual 141)
  - "500074", "500094", "500064", "500084" (regional rejection types 3,4,5,6)
- **Length**: 259 bytes (after 6th state reform)
- **Key Fields**:
  - BBF-N54-VERB: Federation number
  - BBF-N54-KONSTA: Payment constant
  - BBF-N54-VOLGNR: Sequence number
  - BBF-N54-TAAL: Language for error message
- **Attributes**:
  - `BBF-N54-LENGTH`: Record length (S9(4) COMP)
  - `BBF-N54-CODE`: Record code 40 or 43 (S9(4) COMP)
  - `BBF-N54-NUMBER`: Record number (9(8))
  - `BBF-N54-DEVICE-OUT`: Output device C=Console/L=List (X)
  - `BBF-N54-DESTINATION`: Destination mutual (9(3))
  - `BBF-N54-SWITCHING`: Switching (X)
  - `BBF-N54-PRIORITY`: Priority (X)
  - `BBF-N54-NAME`: List name (X(6))
  - **Key Structure**:
    - `BBF-N54-VERB`: Federation number (9(3))
    - `BBF-N54-KONSTA`: Payment constant (9(10))
    - `BBF-N54-VOLGNR`: Sequence number (9(4))
    - `BBF-N54-TAAL`: Language code (9)
    - `BBF-N54-INF`: Info indicator (9)
    - `BBF-N54-INF-VOL`: Info volume (9(2))
  - **Payment Data**:
    - `BBF-N54-VBOND`: Federation (9(2))
    - `BBF-N54-KONST`: Constant structure
      - `BBF-N54-AFDEL`: Section (9(3))
      - `BBF-N54-KASSIER`: Cashier (9(3))
      - `BBF-N54-DATZIT-DM`: Session date DDMM (9(4))
    - `BBF-N54-BETWYZ`: Payment method (X)
    - `BBF-N54-RNR`: National registry number (X(13))
    - `BBF-N54-BETKOD`: Payment code (9(2))
    - `BBF-N54-BEDRAG`: Amount (9(8))
    - `BBF-N54-REKNUM`: Account number (9(12))
    - `BBF-N54-VOLGNR-M30`: M30 sequence (9(3))
  - **Error Information**:
    - `BBF-N54-DIAG`: Error diagnosis message (X(32))
    - `BBF-N54-DV`: Currency indicator (X)
    - `BBF-N54-DN`: Currency numeric (9)
    - `BBF-N54-PREST`: Service code (9)
    - `BBF-N54-SPEC`: Specialty (9(3))
    - `BBF-N54-AANT`: Quantity (9(2))
    - `BBF-N54-DATE`: Service date (9(6))
    - `BBF-N54-HONOR`: Honor amount (9(6))
    - `BBF-N54-RNR2`: Alternate registry number (X(13))
    - `BBF-N54-IBAN`: IBAN (X(34))
    - `BBF-N54-TAGREG-OP`: Regional tag (9(2))
- **Used In Programs**: MYFIN
- **Output**: Error/rejection list (500004)

### INFPRGZP - InfoRek Payment Input Record
- **Purpose**: Input record for InfoRek payment details processing
- **Source**: Copybook `infprgzp.cpy`
- **Length**: Variable, contains up to 14 detail records
- **Key Fields**:
  - IN-PPR-RNR: National registry number
  - IN-KONST: Payment constant
- **Attributes**:
  - `IN-LENGTH`: Record length (S9(4) COMP)
  - `IN-CODE`: Record code (S9(4) COMP)
  - `IN-NUMBER`: Record number (9(8))
  - `IN-PPR-NAME`: PPR name (X(6))
  - `IN-PPR-FED`: Federation (9(3))
  - `IN-PPR-RNR`: National registry number (S9(8) COMP)
  - **Payment Header**:
    - `IN-VBOND`: Federation (9(2))
    - `IN-KONST`: Constant (section, cashier, date)
    - `IN-BETWYZ`: Payment method (X)
    - `IN-RNR`: National registry number (X(13))
    - `IN-BETKOD`: Payment code (9(2))
    - `IN-REKNUM`: Account number (9(12))
    - `IN-VOLGNR-M30`: M30 sequence (9(3))
    - `IN-INFOREK`: InfoRek indicator (9)
    - `IN-AANT-INF`: Number of info records (9(2))
    - `IN-BEDRAG-EUR`: Total amount (9(8))
    - `IN-BEDRAG-DV`: Currency (X)
    - `IN-REKNUM-IBAN`: IBAN (X(34))
  - **Detail Records** (occurs 14 times):
    - `IN-VOL-INF`: Info sequence (9(2))
    - `IN-PREST`: Service code structure (9(12))
    - `IN-AVR`: AVR code (9(2))
    - `IN-AANT-PREST`: Quantity (9(2))
    - `IN-LAST-DATE`: Service date (9(6))
    - `IN-HONOR`: Honor amount (9(6))
    - `IN-RIJKSNR`: Provider registry number (X(13))
    - `IN-BEDRAG`: Detail amount (9(8))
    - `IN-OMSCHR3-AVR`: Description (X(40))
    - `IN-PRESTATIE`: Service code (9(6))
  - `IN-TAGREG-OP`: Regional tag operation (9(2))
  - `IN-TAGREG-LEG`: Regional tag legal entity (9(2))
- **Used By**: INFPRCX4 (InfoRek payment processor)
- **Database**: Supplementary payment detail information

---

## Copybooks

### trbfncxp.cpy
- **Purpose**: Defines the PPR (pre-processed record) structure for manual GIRBET payments
- **Fields**: Complete payment record with member info, amount, bank details, payment codes
- **Used By**: MYFIN (main program), TRBFNCXB (creator program)
- **Dependencies**: None
- **Business Function**: Input interface for manual payment transactions

### trbfncxk.cpy
- **Purpose**: Business exit code placeholder (currently empty)
- **Fields**: Comment structure only, no active fields
- **Used By**: MYFIN (potentially for future customization)
- **Dependencies**: None
- **Business Function**: Reserved for custom business logic extensions

### bbfprgzp.cpy
- **Purpose**: Financial payment batch processing input record from Betfin cassette system
- **Fields**: Payment data from cash collection points, session information
- **Used By**: BBFPRGZ4 (batch processor)
- **Dependencies**: None
- **Business Function**: Processes counter/cassette payments for Brussels federation

### sepaauku.cpy
- **Purpose**: SEPA-compliant user record for bank payment file generation
- **Fields**: Complete SEPA payment instruction with IBAN, BIC, beneficiary details
- **Used By**: MYFIN, UITKCX4, GEZOCX4, VHSCX4, HOSPCX4 (various payment programs)
- **Dependencies**: None
- **Business Function**: Generates standardized bank payment files (list 500001)

### bfn51gzr.cpy
- **Purpose**: Remote printing record for payment detail list (document 500001)
- **Fields**: Payment confirmation details for member and bank
- **Used By**: MYFIN, GR5001 (list processor)
- **Dependencies**: None
- **Business Function**: Member payment notification and bank payment list

### bfn54gzr.cpy
- **Purpose**: Remote printing record for rejection/error list (document 500004)
- **Fields**: Payment error information with diagnostic message
- **Used By**: MYFIN, G8GR5004 (error list processor)
- **Dependencies**: None
- **Business Function**: Reports validation failures and processing errors

### infprgzp.cpy
- **Purpose**: InfoRek payment detail input record with service breakdowns
- **Fields**: Payment with up to 14 detail lines of service information
- **Used By**: INFPRCX4 (InfoRek processor)
- **Dependencies**: None
- **Business Function**: Detailed service-level payment information for member statements

---

## Programs

### MYFIN
- **Purpose**: Process manual GIRBET payment records from PPR input
- **Type**: Batch
- **Entry Point**: "GIRBETPP" USING USAREA1 PPR-RECORD
- **Operations**:
  - Validate payment input data
  - Look up member information (MUTF08, UAREA databases)
  - Determine bank routing (Belfius/KBC) based on IBAN and federation
  - Validate IBAN and payment method
  - Check for duplicate payments
  - Verify member bank account against database
  - Generate BBF master record
  - Create list 500001 (payment details via SEPAAUKU)
  - Create list 500004 (rejections via BFN54GZR)
  - Create list 500006 (bank account discrepancies)
- **Called Programs**: 
  - SEBNKUK9 (IBAN validation and bank routing)
  - SCHRKCX9 (search member bank account)
  - CGACVXD9 (year 2000 date conversion)
- **Files Accessed**:
  - MUTF08 database (member administrative data)
  - UAREA database (user area)
  - BBF file (payment master file)
  - PAR file (payment type parameters)
  - LIDVZ (member insurance coverage)
- **Database Tables**:
  - LID (member master)
  - ADM (administrative data)
  - MUT (mutual data)
  - PTL (payment type library)
  - BBF (financial payment batch)
  - PAR (parameters)
- **Used In Flows**: 
  - FLOW_GIRBET_001 (manual payment processing)
  - FLOW_GIRBET_002 (payment validation)
  - FLOW_GIRBET_003 (bank routing determination)

---

## Data Transformations

### Input PPR to Payment Lists
- **Purpose**: Transform manual payment input into standardized bank payment and reporting formats
- **Input Structure**: TRBFNCXP (PPR-RECORD)
- **Output Structures**: 
  - SEPAAUKU (bank payment file 500001)
  - BFN51GZR (payment detail list)
  - BFN54GZR (rejection list 500004)
- **Processing**:
  1. Extract member national registry number (TRBFN-PPR-RNR) → USERRNR
  2. Retrieve member administrative data → ADM-* fields
  3. Determine language from ADM-TAAL or LIDVZ coverage data
  4. Map payment amount TRBFN-MONTANT → NETBEDRAG / BBF-N51-BEDRAG
  5. Resolve payment description from TRBFN-CODE-LIBEL:
     - If >= 90: lookup from MUTF08 PAR table (multi-lingual descriptions)
     - If < 90: lookup from TBLIBCXW table
  6. Format bank communication/reference:
     - Construct COMMENTAAR with reference number (CONSTANTE + VOLGNR)
     - Add payment descriptions (LIBELLE1, LIBELLE2 or from lookup)
     - Include member registry number (WS-RIJKSNUMMER)
  7. Determine bank routing:
     - Call SEBNKUK9 with TRBFN-IBAN and TRBFN-BETWYZ
     - Set WELKEBANK (0=Belfius, 1=KBC) based on result
     - Extract BIC code (WS-BIC)
  8. Set account code based on payment type and bank:
     - U-BAC-KODE: 13=AO Belfius, 23=AL Belfius, 113=AO KBC, 123=AL KBC
  9. Map regional accounting codes (6th state reform):
     - TYPE-COMPTA 3 → TAG-REG 1, VERB 167 (Wallonia)
     - TYPE-COMPTA 4 → TAG-REG 2, VERB 169 (Flanders)
     - TYPE-COMPTA 5 → TAG-REG 4, VERB 166 (Brussels)
     - TYPE-COMPTA 6 → TAG-REG 7, VERB 168 (German community)
- **Used In**: MYFIN main processing flow

### Member Database Lookup to Payment Enrichment
- **Purpose**: Enrich payment record with member demographic and address data
- **Input Structure**: TRBFN-PPR-RNR (national registry number)
- **Output Structure**: ADM-* fields (administrative data)
- **Processing**:
  1. Convert TRBFN-PPR-RNR → RNRBIN
  2. Search LID database (SCHLDDBD)
  3. Retrieve ADM record (GTADMDBD)
  4. Extract:
     - Name: ADM-NAAM, ADM-VOORN → U-BNK-REKHOUDER, U-ADM-NAAM, U-ADM-VNAAM
     - Address: ADM-STRAAT, ADM-HUISNR, ADM-INDEX, ADM-BUS → U-ADM-STR, U-ADM-HUIS, etc.
     - Postal: ADM-POSTNR, ADM-GEM, ADM-LND → U-ADM-POST, U-ADM-GEM, U-ADM-LND
     - Language: ADM-TAAL → TAAL
     - Registry numbers: ADM-RNR2, ADM-NRNR2 → WS-RIJKSNUMMER (with mutation handling)
  5. For underage members (< 16 for men, < 14 for women):
     - Search LIDVZ for titulaire (holder) record
     - Retrieve holder's bank account instead
- **Used In**: MYFIN member lookup section

### Payment Type Code to Description Mapping
- **Purpose**: Resolve numeric payment code to language-specific textual description
- **Input Structure**: TRBFN-CODE-LIBEL (9(2))
- **Output Structure**: SAV-LIBELLE (X(53))
- **Processing**:
  1. **If code >= 90 (dynamic federation-specific codes)**:
     - Add 6000000 + TRBFN-DEST → RNRBIN (federation's parameter RNR)
     - Search LID08 for federation parameter database
     - Retrieve PAR record where LIBP-NRLIB = TRBFN-CODE-LIBEL
     - Select description based on federation language regime:
       - French mutuals (109,116,127-130,132-136,167-168): LIBP-LIBELLE-FR
       - Dutch mutuals (101-102,104-105,108,110-122,126,131,169): LIBP-LIBELLE-NL
       - Bilingual mutuals (106-107,150,166): Use ADM-TAAL (1=NL, 2=FR)
       - Verviers (137): ADM-TAAL (3=AL/German, else FR)
     - Also extract: LIBP-TYPE-COMPTE → SAV-TYPE-COMPTE
  2. **If code < 90 (standard system codes)**:
     - Lookup in TBLIBCXW table: TBLIB-LIBELLE(code, ADM-TAAL) → SAV-LIBELLE
     - Lookup type: TBLIB-TYPE(code) → SAV-TYPE-COMPTE
  3. **Special formatting for codes 50 and 60 (period payments)**:
     - Extract dates from LIBELLE1 and LIBELLE2 (DDMMYY format)
     - Convert 2-digit year to 4-digit (Y2000 conversion via CGACVXD9)
     - Format description: "Description DD/MM/YYYY AU DD/MM/YYYY"
- **Used In**: MYFIN payment description resolution

### IBAN Validation and Bank Selection
- **Purpose**: Validate IBAN format and determine routing bank (Belfius or KBC)
- **Input Structure**: 
  - TRBFN-IBAN (X(34))
  - TRBFN-BETWYZ (X) - Payment method
- **Output Structure**:
  - WS-SEBNK-WELKEBANK (0=Belfius, 1=KBC, or error)
  - WS-SEBNK-BIC-OUT (X(11)) - Bank BIC code
  - WS-SEBNK-STAT-OUT (status code)
- **Processing**:
  1. Call SEBNKUK9 with IBAN and payment method
  2. Check returned status:
     - Status 0: Valid IBAN, bank determined
     - Status 1: Valid IBAN format, alternate bank available
     - Status 2: Valid IBAN, bank code extracted
     - Other: Invalid IBAN → rejection "IBAN FOUTIEF/IBAN ERRONE"
  3. Override bank selection for specific payment codes:
     - Codes 90-99, 1-49, 52-57, 71, 73, 74, 76, 78: Use determined bank
     - Codes 50, 51, 60, 80: Force Belfius (SAV-WELKEBANK = 1)
  4. After JIRA-4311 (KVS002): All payments route to Belfius (WS-SEBNK-WELKEBANK = 0)
  5. Set U-BAC-KODE based on bank and account type:
     - Belfius + AO account: 13
     - Belfius + AL account: 23
     - KBC + AO account: 113 (legacy, now routed to Belfius)
     - KBC + AL account: 123 (legacy, now routed to Belfius)
- **Used In**: MYFIN bank routing determination (VOIR-BANQUE-DEBIT section)

### Duplicate Payment Detection
- **Purpose**: Prevent duplicate payment processing by checking existing BBF records
- **Input Structure**: 
  - TRBFN-MONTANT (payment amount)
  - TRBFN-CONSTANTE (payment reference)
  - RNRBIN (member national registry number)
- **Output**: Rejection if duplicate found
- **Processing**:
  1. Position to BBF file by member (RNRBIN)
  2. Read all BBF records for member (GET-BBF loop)
  3. Compare each record:
     - If BBF-BEDRAG = TRBFN-MONTANT AND
     - BBF-KONST = TRBFN-CONSTANTE
     - Then: duplicate detected
  4. If duplicate: Create rejection record (500004) with diagnosis "DUBBELE BETALING/DOUBLE PAIEMENT"
  5. If duplicate: Terminate processing (FIN-BTM)
- **Used In**: MYFIN validation (VOIR-DOUBLES section)

### Member Bank Account Verification
- **Purpose**: Verify member's registered bank account matches payment IBAN
- **Input Structure**:
  - TRBFN-CODE-LIBEL (payment type code)
  - TRBFN-DEST (federation)
  - SP-ACTDAT (processing date)
- **Output Structure**:
  - SAV-IBAN (member's registered IBAN)
  - SCHRK-STATUS (search status)
- **Processing**:
  1. Call SEPAKCXD (SCHRKCX9) with:
     - SCHRK-CODE-LIBEL = TRBFN-CODE-LIBEL
     - SCHRK-BKF-TIERS = 0
     - SCHRK-DAT-VAL = SP-ACTDAT
     - SCHRK-FED = TRBFN-DEST
  2. Check SCHRK-STATUS:
     - 0: Account found → SCHRK-IBAN → SAV-IBAN
     - 1: No account on file → SAV-IBAN = SPACES
     - Other: Error → reject payment
  3. Compare SAV-IBAN vs TRBFN-IBAN:
     - If different and both non-blank: Create list 500006 (account discrepancy warning)
     - Warning shows both IBANs for manual verification
- **Used In**: MYFIN account verification (RECH-NO-BANCAIRE section)

### Registry Number Resolution (Incident #279363)
- **Purpose**: Determine correct national registry number to use (person vs mutated number)
- **Input Structure**: 
  - ADM-RNR2 (primary registry number X(13))
  - ADM-RNR2-MUT (mutation indicator)
  - ADM-NRNR2 (alternate registry number)
  - ADM-NRNR2-MUT (alternate mutation indicator)
  - TRBFN-RNR (input registry number from PPR)
- **Output Structure**: WS-RIJKSNUMMER (X(13)) - Selected registry number
- **Processing**:
  1. Initialize WS-RIJKSNUMMER to spaces
  2. **Priority 1**: If ADM-RNR2-MUT = " " (not mutated)
     - Use ADM-RNR2 → WS-RIJKSNUMMER
  3. **Priority 2**: Else if ADM-NRNR2-MUT = " " AND ADM-NRNR2G NOT = " "
     - Use ADM-NRNR2 → WS-RIJKSNUMMER
  4. **Priority 3**: Else
     - Use TRBFN-RNR → WS-RIJKSNUMMER (from input record)
- **Business Rule**: Always use non-mutated (current) registry number when available; fall back to input value if all are mutated
- **Used In**: MYFIN member identification (ZOEK-RIJKSNUMMER section)

### Age Validation for Bank Account (Under 16/14)
- **Purpose**: For underage members, use parent/guardian bank account instead of minor's account
- **Input Structure**:
  - TRBFN-RNR (member registry number with birth date encoded)
  - WS-RNREBC (parsed registry number)
  - SP-ACTDAT (current processing date)
- **Output**: SW-TROP-JEUNE (0=adult, 1=minor)
- **Processing**:
  1. Parse TRBFN-RNR into WS-RNREBC structure:
     - Extract birth year (YY), month (MM), day (DD)
     - Determine gender from month: odd=male, even=female
  2. Call date conversion (RREBBXDD) to get full 4-digit year
  3. Set minimum age threshold:
     - Male (odd month): 16 years
     - Female (even month): 14 years
  4. Calculate age: WS-DATEBC-CONSTANT added to birthdate → WS-DATEBC-2
  5. Compare WS-DATEBC-2 > SP-ACTDAT:
     - If true: Minor (SW-TROP-JEUNE = 1)
     - If false: Adult (SW-TROP-JEUNE = 0)
  6. If minor:
     - Search LIDVZ for open "OP" (PAC) coverage records (codes 600-699, excluding 609,659,679,689)
     - Extract LIDVZ-OP-RNRTIT2 (parent's registry number)
     - Re-search LID database with parent's registry number
     - Use parent's bank account (SCHRK search) → SAV-IBAN
- **Used In**: MYFIN bank account search (RECH-NO-BANCAIRE section)

### Regional Payment Routing (6th State Reform)
- **Purpose**: Route payments to correct regional entity and bank account based on accounting type
- **Input Structure**: TRBFN-TYPE-COMPTA (9)
- **Output Structures**:
  - TAG-REG-OP / BBF-N51-TAGREG-OP (regional tag operation)
  - USERFED / BBF-N51-VERB (federation/region code)
  - U-BAC-KODE (bank account code)
  - WELKEBANK (bank selection)
- **Processing**:
  1. Evaluate TRBFN-TYPE-COMPTA:
     - **Type 3** (Wallonia):
       - TAG-REG-OP = 1
       - USERFED/VERB = 167
       - WELKEBANK = 0 (Belfius only)
       - U-BAC-KODE = 13 (AO account)
     - **Type 4** (Flanders):
       - TAG-REG-OP = 2
       - USERFED/VERB = 169
       - WELKEBANK = 0 (Belfius only)
       - U-BAC-KODE = 13 (AO account)
     - **Type 5** (Brussels):
       - TAG-REG-OP = 4
       - USERFED/VERB = 166
       - WELKEBANK = 0 (Belfius only)
       - U-BAC-KODE = 13 (AO account)
     - **Type 6** (German Community):
       - TAG-REG-OP = 7
       - USERFED/VERB = 168
       - WELKEBANK = 0 (Belfius only)
       - U-BAC-KODE = 13 (AO account)
     - **Type 1** (General AO) or **Type 2** (General AL):
       - TAG-REG-OP = 9
       - USERFED/VERB = TRBFN-DEST (original federation)
       - Bank selection by payment code and IBAN validation
       - U-BAC-KODE = 13 (Type 1) or 23 (Type 2)
  2. Change list names for regional payments:
     - Type 3: Lists "500071" (details) and "500074" (errors)
     - Type 4: Lists "500091" and "500094"
     - Type 5: Lists "500061" and "500064"
     - Type 6: Lists "500081" and "500084"
  3. Set record code to 43 (instead of 40) for regional payments
  4. Set destination to 151 for all regional payments
- **Business Rule**: Regional entities only have Belfius accounts; KBC no longer used for new regional structure
- **Used In**: MYFIN multiple sections (CREER-BBF, CREER-USER-500001, CREER-REMOTE-500001, CREER-REMOTE-500004, CREER-REMOTE-500006)

---

## Working Storage Variables

### TEST-MUTUALITE - Mutual Language Classification
- **Purpose**: Classify mutual federation by linguistic regime for description selection
- **Type**: Condition name structure (PIC 9(3))
- **Values**:
  - **MUT-FR** (French mutuals): 109, 116, 127-130, 132-136, 167, 168
  - **MUT-NL** (Dutch mutuals): 101-102, 104-105, 108, 110-122, 126, 131, 169
  - **MUT-BILINGUE** (Bilingual): 106, 107, 150, 166
  - **MUT-VERVIERS** (Verviers trilingual): 137
- **Used In**: Payment description language selection, address formatting

### SAV-LIB1 / SAV-LIB2 - Period Date Parsing
- **Purpose**: Parse and validate period dates from payment descriptions (codes 50, 60)
- **Structure**:
  - SAV-DATE1-DD (PIC 99): Day
  - SAV-DATE1-MM (PIC 99): Month
  - SAV-DATE1-YY (PIC 99): Year (2-digit)
- **Processing**: Extract from TRBFN-LIBELLE1/2, convert YY to CCYY via CGACVXD9
- **Used In**: BBF record creation for period payments

### COMMENT - Bank Communication Structure
- **Purpose**: Format bank transfer communication/reference field (106 characters)
- **Structure (COMMENT1 redefines)**:
  - BANK-VELD1 (53 chars): Payment description text
  - REF-VELD1 (7 chars): Reference label ("O.REF:", "N.REF:", "U.KENZ:")
  - KONSTANTE-VELD1 (10 digits): Payment constant
  - VOLGNR-VELD1 (3 digits): Sequence number
  - OMSCH1-VELD1 (14 chars): Description line 1 or registry number
  - OMSCH2-VELD1 (14 chars): Description line 2
- **Processing**: Built via STRING operations based on payment code
- **Used In**: SEPAAUKU COMMENTAAR field, bank payment reference

### WS-RIJKSNUMMER - Resolved Registry Number
- **Purpose**: Hold final selected national registry number after mutation resolution
- **Type**: PIC X(13)
- **Source**: Determined by ZOEK-RIJKSNUMMER section logic (see Registry Number Resolution transformation)
- **Used In**: All output records (BBF-N51-RNR, BBF-N54-RNR, BBF-N56-RNR, payment lists)

### SAV-WELKEBANK - Bank Routing Decision
- **Purpose**: Store final bank selection for payment routing
- **Type**: PIC 9
- **Values**:
  - 0: Belfius (formerly BACCOB)
  - 1: KBC (formerly CERA) - legacy, now routed to Belfius per JIRA-4311
  - 2: BVR (legacy, no longer used)
- **Source**: Set by VOIR-BANQUE-DEBIT section based on payment code and IBAN validation
- **Used In**: SEPAAUKU WELKEBANK field, BBF-N51-BANK

### SAV-IBAN - Member Registered IBAN
- **Purpose**: Store member's bank account IBAN from database for comparison
- **Type**: PIC X(34)
- **Source**: Retrieved by SEPAKCXD call (SCHRKCX9)
- **Used In**: Comparison with TRBFN-IBAN for discrepancy detection (list 500006)

### WS-BIC - Bank Identification Code
- **Purpose**: Store BIC (Bank Identifier Code) returned from IBAN validation
- **Type**: PIC X(11)
- **Source**: Set by SEBNKUK9 call (WS-SEBNK-BIC-OUT)
- **Used In**: SEPAAUKU U-BIC field for SEPA payment instruction

### SAV-LIBELLE - Payment Description Text
- **Purpose**: Store resolved language-specific payment description
- **Type**: PIC X(53)
- **Source**: Retrieved from MUTF08 PAR table or TBLIBCXW table based on TRBFN-CODE-LIBEL
- **Used In**: Bank communication BANK-VELD1, payment list descriptions

### SAV-TYPE-COMPTE - Account Type Code
- **Purpose**: Store account type classification for payment
- **Type**: PIC X(4)
- **Source**: Retrieved with payment description from PAR or TBLIBCXW
- **Used In**: BBF-N51-TYPE-COMPTE in payment list

### SECTION-TROUVEE - Member Section Number
- **Purpose**: Store member's mutual section for payment routing
- **Type**: PIC 999
- **Source**: Retrieved from LIDVZ (member insurance coverage) via RECHERCHE-SECTION
- **Used In**: SEPAAUKU USERMY field

### SW-TROP-JEUNE - Underage Indicator
- **Purpose**: Flag whether member is below minimum age for own bank account
- **Type**: PIC 9
- **Values**: 0=Adult, 1=Minor
- **Source**: Calculated by age validation logic in RECH-NO-BANCAIRE
- **Used In**: Decision to use parent/guardian bank account

### WS-LIDVZ-OP-TAAL / WS-LIDVZ-AP-TAAL - Coverage Language Codes
- **Purpose**: Store language code from member's insurance coverage when ADM-TAAL unavailable
- **Type**: PIC 9(01)
- **Source**: Extracted from LIDVZ-OP-TAAL or LIDVZ-AP-TAAL during section search
- **Used In**: Fallback language determination when ADM-TAAL = 0 (per JGO004 modification)

### WS-CREATION-CODE-43 - CSV Export Switch (JIRA-4224)
- **Purpose**: Control creation of code 43 CSV detail export record
- **Type**: PIC 9(01) with 88-levels
- **Values**: 
  - SW-NO-CREA-CODE-43 (0): Don't create CSV export
  - SW-CREA-CODE-43 (1): Create CSV export
- **Source**: Set based on payment routing logic
- **Used In**: Conditional creation of "5DET01" list (code 43 CSV format)

---

## Database Tables and Views

### MUTF08 - Mutual Federation Database
- **Purpose**: Member administrative and parameter data organized by federation
- **Access**: Via SCH08DBD (search LID08), GTADMDBD (get ADM), GTPARDBD (get PAR)
- **Key**: RNRBIN (federation base number + 6000000)
- **Records Used**:
  - **ADM**: Member administrative data (name, address, language, registry numbers)
  - **PAR**: Payment type parameters (LIBP-NRLIB, descriptions by language, account types)
- **Relation to MYFIN**: 
  - Lookup member data when TRBFN-CODE-LIBEL >= 90
  - Retrieve federation-specific payment descriptions
  - Validate member existence

### UAREA - User Area Database
- **Purpose**: Primary member database with insurance coverage and administrative data
- **Access**: Via SCHLDDBD (search LID), GTADMDBD (get ADM), GTMUTDBD (get MUT), GTPTLDBD (get PTL)
- **Key**: RNRBIN (member national registry number)
- **Records Used**:
  - **LID**: Member lookup and validation (STAT1=0 found, STAT1=4 not found)
  - **ADM**: Administrative data (full name, address, language, postal, country, registry numbers)
  - **LIDVZ**: Member insurance coverage and section assignment
- **Relation to MYFIN**:
  - Primary member data source for all payments
  - Provides beneficiary information for bank payment
  - Source of language preference for descriptions

### BBF - Financial Payment Batch File
- **Purpose**: Master file of all financial payments processed
- **Access**: Via GTBBFDBD (get BBF), ADBBFDBD (add BBF)
- **Key**: RNRBIN (member registry number)
- **Record Structure**: See BBF-REC in working storage
- **Fields**:
  - BBF-TYPE: Record type = 9
  - BBF-LIBEL: Payment code
  - BBF-BEDRAG: Amount
  - BBF-KONST: Payment constant
  - BBF-VOLGNR: Sequence number
  - BBF-DATINB: Input date
  - BBF-DATVAN / BBF-DATTOT: Period dates for codes 50/60
  - BBF-IBAN: Beneficiary IBAN
  - BBF-REKNR: Legacy account number
  - BBF-BETWY: Payment method
  - BBF-TAGREG-OP: Regional tag (6th state reform)
  - BBF-VERB: Federation/region code
- **Relation to MYFIN**:
  - Duplicate payment detection (check existing BBF-BEDRAG and BBF-KONST)
  - Create new BBF record for each processed payment

### LIDVZ - Member Insurance Coverage
- **Purpose**: Member insurance coverage periods and section assignments
- **Access**: Via LIDVZASD (access LIDVZ)
- **Key**: RNRBIN (member registry number)
- **Record Fields**:
  - LIDVZ-STATUS: Coverage status (2=active)
  - **Open Titulaire (OT)**: LIDVZ-OT-DATOND, LIDVZ-OT-KOD1, LIDVZ-ADM-MY
  - **Open PAC (OP)**: LIDVZ-OP-DATINS, LIDVZ-OP-KOD1, LIDVZ-OP-MY, LIDVZ-OP-TAAL, LIDVZ-OP-RNRTIT2
  - **Closed Titulaire (AT)**: LIDVZ-AT-DATOND, LIDVZ-AT-KOD1
  - **Closed PAC (AP)**: LIDVZ-AP-DATINS, LIDVZ-AP-KOD1, LIDVZ-AP-MY, LIDVZ-AP-TAAL
- **Coverage Codes**: 600-699 (excluding 609, 659, 679, 689)
- **Relation to MYFIN**:
  - Determine member's section (SECTION-TROUVEE)
  - Fallback language determination when ADM-TAAL = 0
  - For minors: retrieve parent/guardian registry number (LIDVZ-OP-RNRTIT2)

### TBLIBCXW - Payment Type Library Table
- **Purpose**: Standard system-wide payment type descriptions (codes < 90)
- **Access**: Direct table lookup in working storage
- **Key**: Payment code (0-89), Language (1-3)
- **Fields**:
  - TBLIB-LIBELLE(code, language): Description text
  - TBLIB-TYPE(code): Account type code
- **Languages**: 1=Dutch, 2=French, 3=German
- **Relation to MYFIN**:
  - Provide payment descriptions for standard codes
  - Supply account type classification

---

## Error Messages and Diagnostics

### BBF-N54-DIAG - Rejection Reasons
- **Purpose**: Bilingual error messages written to rejection list 500004
- **Format**: X(32) - Dutch/French combined
- **Common Messages**:
  - "DUBBELE BETALING/DOUBLE PAIEMENT" - Duplicate payment detected (same amount + constant)
  - "IBAN FOUTIEF/IBAN ERRONE" - IBAN validation failed
  - "CC - PAYS/LAND NOT = B        " - Circular check payment for non-Belgian address (SEPA restriction)
  - "ONBEK. OMSCHR./LIBELLE INCONNU" - Payment description not found in PAR table
  - "TAALCODE ONBEKEND/CODE LANGUE INCONNU" - Language code unavailable (ADM-TAAL = 0 and no LIDVZ fallback)
- **Used In**: BFN54GZR record creation (CREER-REMOTE-500004)

### BTMMSG - System Error Messages
- **Purpose**: Technical error messages for system/database errors (terminates processing)
- **Format**: Variable length string
- **Common Messages**:
  - "ERREUR SCH08DBD STAT1 = nn" - Database search error in MUTF08
  - "ERREUR GET ADM STAT1 = nn" - Error retrieving administrative data
  - "ERREUR GET PAR STAT1 = nn" - Error retrieving parameter data
  - "ERREUR ADD BBF STAT1 = nn" - Error adding BBF record
  - "ERREUR ROUTINE SCHRKCX9 STATUS : n" - Error in bank account search
  - "ERROR CONVERT RNR" - Registry number conversion failed
  - "ERROR SCHLID RNR" - Member lookup failed for parent/guardian
- **Processing**: Calls PPRNVW (PPR not valid) to terminate with error
- **Used In**: All database access paragraphs (PAR-MUT section)

---

## Business Rules and Validations

### Language Determination Hierarchy
1. **Primary**: ADM-TAAL from member administrative record
   - 1 = Dutch (Nederlands)
   - 2 = French (Français)
   - 3 = German (Deutsch - Verviers only)
2. **Fallback (JGO004)**: If ADM-TAAL = 0
   - Try LIDVZ-AP-TAAL (closed PAC coverage language)
   - Else try LIDVZ-OP-TAAL (open PAC coverage language)
   - Else reject with "TAALCODE ONBEKEND/CODE LANGUE INCONNU"
3. **Override for Mutual Regime**: For codes >= 90, use mutual's language regime:
   - MUT-FR: Always French
   - MUT-NL: Always Dutch
   - MUT-BILINGUE: Respect ADM-TAAL choice
   - MUT-VERVIERS: German (3) or French (default)

### Payment Code Categories
- **1-49**: Standard individual payment types (from TBLIBCXW)
- **50**: Period payment with date range (special formatting)
- **51**: Force Belfius routing
- **52-57**: Standard codes (EATTEST eligible per MSA001)
- **60**: Period payment with date range, force Belfius, special date handling
- **71**: Standard code (MSA002 BULK eligible)
- **73**: CORREG payment (MSA001)
- **74, 76, 78**: EATTEST codes
- **80**: Force Belfius routing
- **90-99**: Federation-specific dynamic codes (from MUTF08 PAR table)

### Bank Routing Rules (Post JIRA-4311 KVS002)
1. **All payments**: Route to Belfius (WELKEBANK = 0)
2. **Regional payments** (TYPE-COMPTA 3,4,5,6): Belfius mandatory, U-BAC-KODE = 13
3. **General AO** (TYPE-COMPTA 1): Belfius, U-BAC-KODE = 13
4. **General AL** (TYPE-COMPTA 2): Belfius, U-BAC-KODE = 23
5. **IBAN validation**: Must pass SEBNKUK9 with status 0, 1, or 2

### Payment Method Restrictions
- **Method "C", "D", "E", "F"** (Circular check variants):
  - Beneficiary address MUST be Belgian (ADM-LND = "B  ")
  - Non-Belgian address: Reject with "CC - PAYS/LAND NOT = B"
- **Method "B"** (Bank transfer): No address restrictions

### Duplicate Payment Detection
- **Match Criteria**: Same member + Same amount + Same constant
- **Action**: Reject immediately with "DUBBELE BETALING/DOUBLE PAIEMENT"
- **Purpose**: Prevent accidental reprocessing of payment input

### Bank Account Discrepancy (List 500006)
- **Trigger**: Member's registered IBAN (SAV-IBAN) differs from payment IBAN (TRBFN-IBAN)
- **Condition**: Only when TRBFN-COMPTE-MEMBRE = 0 (not member's own account)
- **Action**: Create warning list 500006 showing both IBANs
- **Purpose**: Alert to potential data entry error or account change
- **Note**: Warning only, payment still processes

### Underage Member Handling
- **Age Threshold**: 
  - Male (odd birth month): 16 years
  - Female (even birth month): 14 years
- **Action**: Use parent/guardian bank account
- **Process**:
  1. Calculate age from registry number birth date
  2. If under threshold: Search LIDVZ for parent (titulaire)
  3. Extract parent's registry number (LIDVZ-OP-RNRTIT2)
  4. Lookup parent's LID and bank account
  5. Use parent's IBAN for payment

### Registry Number Mutation Handling (Incident #279363)
- **Priority**: Use non-mutated registry number when available
- **Sources** (in order):
  1. ADM-RNR2 (if not mutated)
  2. ADM-NRNR2 (if not mutated and not blank)
  3. TRBFN-RNR (from input record as fallback)
- **Purpose**: Ensure correct identification when registry number has changed (marriage, correction, etc.)

### Regional Accounting (6th State Reform JGO001/CDU001)
- **Enabled by**: TRBFN-TYPE-COMPTA values 3,4,5,6
- **Region Mapping**:
  - Type 3 → Wallonia (VERB 167, TAG-REG 1)
  - Type 4 → Flanders (VERB 169, TAG-REG 2)
  - Type 5 → Brussels (VERB 166, TAG-REG 4)
  - Type 6 → German Community (VERB 168, TAG-REG 7)
- **Output Changes**:
  - Different list names (500071, 500091, 500061, 500081)
  - Record code 43 instead of 40
  - Destination 151 instead of federation number
  - Belfius mandatory (no KBC option)

### CSV Export Generation (JIRA-4224 KVS001)
- **Trigger**: Standard non-regional payment (TYPE-COMPTA = 1 or 2) to federation other than 141
- **Output**: Additional list "5DET01" with record code 43
- **Purpose**: Provide payment details in CSV format for non-Papyrus systems
- **Condition**: SW-CREA-CODE-43 flag set during CREER-REMOTE-500001

---

## Integration Points

### External Programs Called
1. **SEBNKUK9** (IBAN Validation and Bank Routing)
   - Input: WS-SEBNK-IBAN-IN, WS-SEBNK-BETWYZ-IN
   - Output: WS-SEBNK-WELKEBANK, WS-SEBNK-BIC-OUT, WS-SEBNK-STAT-OUT
   - Purpose: Validate IBAN format and determine routing bank

2. **SCHRKCX9** (Member Bank Account Search)
   - Input: SCHRK-CODE-LIBEL, SCHRK-BKF-TIERS, SCHRK-DAT-VAL, SCHRK-FED
   - Output: SCHRK-IBAN, SCHRK-STATUS
   - Purpose: Retrieve member's registered bank account

3. **CGACVXD9** (Year 2000 Date Conversion)
   - Input: CGACVT-SUP1-N (2-digit year), CGACVT-POS1 (position)
   - Output: CGACVT-EXP1-N (4-digit year)
   - Purpose: Convert YY dates to CCYY for period payments

4. **RREBBXDD** (Registry Number to Date Conversion)
   - Input: WS-RNREBC (registry number structure)
   - Output: WS-RNREBCDIC-CC (century), WS-STAT1 (status)
   - Purpose: Extract full birth date from registry number

5. **DWYERXDD** (Date Math/Age Calculation)
   - Input: WS-DATEBC-1 (birthdate), WS-DATEBC-CONSTANT (years to add)
   - Output: WS-DATEBC-2 (calculated date)
   - Purpose: Calculate minimum age threshold date

### Database Access Modules
1. **SCH08DBD** - Search LID in MUTF08 (federation database)
2. **SCHLDDBD** - Search LID in UAREA (member database)
3. **GTADMDBD** - Get ADM (administrative data)
4. **GTMUTDBD** - Get MUT (mutual data)
5. **GTPTLDBD** - Get PTL (payment type library)
6. **GTPARDBD** - Get PAR (parameters from MUTF08)
7. **GTBBFDBD** - Get BBF (financial payment batch)
8. **ADBBFDBD** - Add BBF (create payment batch record)
9. **ADLOGDBD** - Add to output log (lists 500001, 500004, 500006)
10. **LIDVZASD** - Access LIDVZ (member insurance coverage)
11. **SEPAKCXD** - SEPA account search (SCHRKCX9 wrapper)
12. **GTLOKDRD** - Get municipality name from NIS code (commented out in 500002)

### Output Lists Generated
1. **500001 / 5N0001** (SEPAAUKU):
   - Bank payment instruction file (SEPA format)
   - One record per payment
   - Sent to Belfius for processing

2. **500001 / 500071/500091/500061/500081** (BFN51GZR):
   - Payment detail list for member notification
   - Device: L (list) or C (console) depending on mutual
   - Contains member name, amount, bank details

3. **5DET01** (BFN51GZR with code 43):
   - CSV format detail export (JIRA-4224)
   - For non-Papyrus systems
   - Same content as 500001 but different format

4. **500004 / 500074/500094/500064/500084** (BFN54GZR):
   - Rejection/error list
   - Contains diagnostic message (BBF-N54-DIAG)
   - Routed to appropriate mutual/region

5. **500006 / 500076/500096/500066/500086** (BFN56CXR):
   - Bank account discrepancy warning
   - Shows both input IBAN and database IBAN
   - Manual verification required
   - Not generated for mutual 141 list 541006 (MIS01 DOCSOL)

### Input Sources
1. **PPR Record** (TRBFNCXP):
   - Created by TRBFNCXB (batch input processor)
   - Source: Manual payment input files
   - Triggered by cassette processing or manual entry

2. **Member Databases**:
   - UAREA: Primary member administrative data
   - MUTF08: Federation-specific parameters and member data

3. **System Parameters**:
   - SP-ACTDAT: Current processing date
   - TBLIBCXW: Payment type descriptions table

---

## Version History and Modifications

### Major Changes
1. **Y2000** - Year 2000 remediation (CGA/ARC RENOVATOR)
2. **IBAN10** - SEPA/IBAN implementation (02/2011)
   - Added IBAN fields to all records
   - Implemented bank routing via IBAN validation
   - Circular check restriction for non-Belgian addresses
3. **MTU01** - SC229498: Removed code 70 support
4. **MIS01** - 101222: DOCSOL - Stop generating document 541006 for mutual 141
5. **JGO004** - Language code 0 handling (fallback to coverage data)
6. **279363** - Incident: Use registry number instead of M-number in references
7. **EVP** - 29/12/2004: Add CERA => KBC codes (CR-20046151)
8. **140562** - R140562: Daily payment via 2 banks (Belfius and KBC)
   - Removed document 500002 generation
   - Support both Belfius and KBC routing
9. **EATT** - 20160628: E-attest support
10. **JGO001** - 6th state reform: Regional payment routing
11. **CDU001** - 01/07/2019: 6th state reform completion
    - Regional entity mapping (167,168,169,166)
    - Regional list generation (500071,500091,500061,500081)
12. **KVS001** - 02/05/2023: JIRA-4224
    - Detail lines flux 500001 in CSV (not Papyrus)
    - Added code 43 record type
    - New list "5DET01" for CSV export
13. **KVS002** - 16/06/2023: JIRA-4311
    - Adaptation for PAIFIN - Belfius only
    - All payments now route to Belfius (WELKEBANK = 0)
14. **MSA001** - 20240723: JIRA-4837 CORREG
    - Added code 73 support
    - Added BBF-N51-AFK value 6 for CORREG
15. **MSA002** - 20250130: JIRA-???? BULK
    - Added code 71 support
    - Added BBF-N51-AFK value 7 for BULK-INPUT

### Database Structure Changes
- Length increases for SEPA fields (IBAN 34 chars, BIC 11 chars)
- Record length changes:
  - SEPAAUKU: 471 → 475 bytes (6th reform)
  - BFN51GZR: 199 → 213 bytes (6th reform)
  - BFN54GZR: 214 → 259 bytes (6th reform)
  - BFN56CXR: 241 → 258 bytes (6th reform)

---

## Notes and Observations

### Code Quality
- Extensive use of copybooks for standardization
- Well-documented change history with modification codes
- Y2000 compliant date handling
- SEPA/Euro conversion completed

### Business Context
- Belgian mutual insurance federation payment processing
- Multi-lingual support (Dutch, French, German)
- Regional complexity due to Belgian federal structure
- Integration with multiple bank systems (Belfius, historically KBC)
- Transition from legacy bank account format to IBAN

### Processing Patterns
- Batch-oriented processing model
- Defensive programming with extensive validation
- Error handling via rejection lists rather than transaction rollback
- Duplicate detection at processing time
- Account verification with warning system (not blocking)

### Data Privacy Considerations
- National registry number (NISS/RRN) used as primary key
- Age-based processing (underage handling)
- Parent/guardian linkage for minors
- Mutation handling for registry number changes

### Integration Complexity
- Multiple output formats (SEPA file, detail lists, error lists, CSV)
- Different routing based on payment type, region, and bank
- Federation-specific parameter tables
- Language-specific descriptions and messages

