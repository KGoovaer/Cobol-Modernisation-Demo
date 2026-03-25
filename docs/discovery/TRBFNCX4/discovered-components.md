# Discovered Components - MYFIN

## Component Inventory

### Batch Programs

#### **MYFIN**
- **Purpose**: Batch program for processing manual GIRBET payment inputs - creates payment files and generates payment lists (500001, 500004, 500006)
- **Entry Point**: `GIRBETPP` (called via ENTRY statement)
- **Type**: Batch processing program
- **Input**: TRBFNCXP record structure (payment request records)
- **Output Files/Lists**: 
  - 500001 (BFN51GZR) - Payment detail list
  - 500004 (BFN54GZR) - Rejection/error list
  - 500006 (BFN56CXR) - Bank account discrepancy list
- **Files/Tables Accessed**:
  - MUTF08 database (member data)
  - UAREA database
  - BBF module (payment module)
  - LIDVZ (member insurance data)
  - PAR (parameter data)
- **Called Programs**:
  - CGACVXD9 (date conversion)
  - SEBNKUK9 (IBAN/bank validation)
  - SCHRKCX9 (member account search via SEPAKCXD copybook)
- **Key Processing**:
  - Manual payment input validation
  - Member lookup and validation
  - Bank account/IBAN validation and verification
  - Payment type handling (circular cheques, transfers)
  - Multi-language support (FR/NL/DE with bilingual handling)
  - SEPA/IBAN compliance
  - Regional accounting support (6th State Reform - JGO001, CDU001)

### Program Sections

The program is organized into the following logical sections:

#### **TRAITEMENT-BTM SECTION** (Main Processing)
- Main batch processing workflow
- Member lookup and validation
- Language code determination
- Payment processing coordination
- Output generation control

#### **ROUTINES SECTION** (Business Logic)
Key paragraphs:
- **VOIR-DOUBLES**: Duplicate payment detection
- **VOIR-BANQUE-DEBIT**: Bank account validation and IBAN processing
- **CREER-BBF**: Create BBF module record
- **CREER-USER-500001**: Generate user payment record (SEPAAUKU)
- **CREER-REMOTE-500001**: Generate payment detail list (BFN51GZR)
- **CREER-REMOTE-500004**: Generate rejection/error list (BFN54GZR)
- **CREER-REMOTE-500006**: Generate bank account discrepancy list (BFN56CXR)
- **RECH-NO-BANCAIRE**: Search for member bank account number
- **WELKE-BANK**: Determine which bank to use (Belfius/KBC)
- **ZOEK-RIJKSNUMMER**: Locate national registry number

#### **RECHERCHE-SECTION** (Member Section Lookup)
- Searches through member insurance records to find active section
- Checks: Open holder data (OT), Open PAC data (OP), Closed holder data (AT), Closed PAC data (AP)
- Excludes certain product codes (609, 659, 679, 689)
- Determines member section and language preference

#### **PAR-MUT SECTION** (Database Access)
Database access paragraphs:
- **SCH-LID08**: Search member in MUTF08 database
- **GET-PAR**: Retrieve parameter data
- **SCH-LID**: Search member in main database
- **GET-ADM**: Retrieve administrative data
- **GET-MUT**: Retrieve mutuality data
- **GET-PTL**: Retrieve partial data
- **GET-BBF**: Retrieve BBF payment data
- **ADD-BBF**: Add BBF payment record

### Copybooks

#### **TRBFNCXP** - Input Record Structure
- **Purpose**: Payment request record from TRBFNCXB
- **Record Code**: 42
- **Name**: GIRBET
- **Length**: 186/174 bytes (with SEPA/IBAN)
- **Key Fields**:
  - TRBFN-NUMBER: Record number
  - TRBFN-PPR-RNR: National registry number (binary)
  - TRBFN-DEST: Destination mutuality code
  - TRBFN-CONSTANTE: Constant identifier (10 digits)
  - TRBFN-NO-SUITE: Sequence number
  - TRBFN-RNR: National registry number (alphanumeric)
  - TRBFN-MONTANT: Payment amount
  - TRBFN-CODE-LIBEL: Payment description code
  - TRBFN-REKNR: Bank account number
  - TRBFN-IBAN: IBAN bank account
  - TRBFN-BETWYZ: Payment method indicator
  - TRBFN-TYPE-COMPTA: Accounting type (regional support)

#### **BFN51GZR** - Payment Detail Output
- **Purpose**: Remote printing record for payment list 500001
- **Record Code**: 40 or 43
- **Used In**: CREER-REMOTE-500001
- **Key Fields**:
  - BBF-N51-VERB: Mutuality number
  - BBF-N51-AFK: Payment type (LOKET, PAIFIN-AO, PAIFIN-AL, FRANCHISE, EATTEST, CORREG, BULK-INPUT)
  - BBF-N51-KONST: Constant identifier
  - BBF-N51-VOLGNR: Sequence number
  - BBF-N51-RNR: National registry number
  - BBF-N51-NAAM/VOORN: Name and first name
  - BBF-N51-LIBEL: Payment description code
  - BBF-N51-REKNR: Bank account number
  - BBF-N51-BEDRAG: Payment amount
  - BBF-N51-BANK: Bank indicator (BACCOB=1, CERA=2, BVR=3)
  - BBF-N51-IBAN: IBAN account
  - BBF-N51-BETWY: Payment method
  - BBF-N51-TAGREG-OP: Regional accounting indicator

#### **BFN54GZR** - Rejection/Error Output
- **Purpose**: Remote record for rejection list 500004
- **Record Code**: 40 or 43
- **Used In**: CREER-REMOTE-500004
- **Key Fields**:
  - BBF-N54-VERB: Mutuality number
  - BBF-N54-KONST/KONSTA: Constant identifier
  - BBF-N54-VOLGNR: Sequence number
  - BBF-N54-TAAL: Language code
  - BBF-N54-BETWYZ: Payment method
  - BBF-N54-RNR: National registry number
  - BBF-N54-BETKOD: Payment reason code
  - BBF-N54-BEDRAG: Payment amount
  - BBF-N54-REKNR: Bank account number
  - BBF-N54-DIAG: Error diagnosis message (32 characters)
  - BBF-N54-IBAN: IBAN account
  - BBF-N54-TAGREG-OP: Regional accounting indicator

#### **BFN56CXR** - Bank Account Discrepancy Output
- **Purpose**: Remote record for discrepancy list 500006 (mismatch between known and provided bank account)
- **Record Code**: 40 or 43
- **Used In**: CREER-REMOTE-500006
- **Key Fields**:
  - BBF-N56-VERB: Mutuality number
  - BBF-N56-AFK: Payment type
  - BBF-N56-KONST: Constant identifier
  - BBF-N56-VOLGNR: Sequence number
  - BBF-N56-RNR: National registry number
  - BBF-N56-NAAM/VOORN: Name and first name
  - BBF-N56-BEDRAG: Payment amount
  - BBF-N56-LIBEL: Payment description code
  - BBF-N56-IBAN: IBAN provided in input
  - BBF-N56-REKNR: Account number provided
  - BBF-N56-IBAN-MUT: IBAN known in database
  - BBF-N56-REKNR-MUT: Account number known in database
  - BBF-N56-BETWY: Payment method
  - BBF-N56-TAGREG-OP: Regional accounting indicator

#### **SEPAAUKU** - User Payment Record
- **Purpose**: User record for SEPA payment output (5N0001)
- **Record Code**: 41
- **Length**: 475 bytes
- **Used In**: CREER-USER-500001
- **Key Fields**:
  - USERCOD: User code (5N0001 for GEZOREC)
  - USERFED: Mutuality federation
  - USERRNR: National registry number (binary)
  - USERMY: Member section
  - WELKEBANK: Bank indicator (0=Belfius, 1=Alternative)
  - U-BAC-KODE: Bank account code (13=AO, 23=AL, 113/123=KBC)
  - ALOIS-RAF: Payment type (BETFIN=1)
  - VRBOND: Mutuality number
  - TAAL: Language code
  - U-IBAN: IBAN account
  - U-BNK-REKHOUDER: Account holder name
  - U-BNK-LND/POSTNR/GEM: Bank address
  - U-ADM-NAAM/VNAAM: Beneficiary name
  - U-ADM-STR/HUIS/GEM: Beneficiary address
  - COMMENTAAR: Payment communication (106 bytes)
  - NETBEDRAG: Net payment amount
  - U-BETWYZ: Payment method
  - U-BIC: Bank BIC code
  - TAG-REG-OP/TAG-REG-LEG: Regional tags

#### **BBFPRGZP** - BBF Payment Input (Reference)
- **Purpose**: Standard BBF payment input record structure
- **Record Code**: 42
- **Note**: Not directly used by MYFIN but related input format

#### **INFPRGZP** - Inforek Payment Input (Reference)
- **Purpose**: Inforek payment input record with detailed information
- **Record Code**: Not specified
- **Note**: Related input format with extended information fields

#### **SEPAAUKU** (Copybook)
- **Purpose**: SEPA user record structure for bank payment files
- **Key Definitions**:
  - UITKREC: Benefit payments (3N0001)
  - GEZOREC: Health payments (2N0001, 5N0001, 9N0001)
  - VHSREC: Pre-marriage (4N0001)
  - HOSPREC: Hospital (1N0001)

### Working Storage Copybooks

#### **LIDVZASW** - Member Insurance Data
- **Purpose**: Member insurance coverage data
- **Used By**: RECHERCHE-SECTION, member section lookup
- **Key Fields**: OT/OP/AT/AP data (Open/Closed Titulaire/PAC insurance)

#### **VBONDASW** - Mutuality Data
- **Purpose**: Mutuality/federation data structures

#### **TBLIBCXW** - Payment Description Table
- **Purpose**: Table of payment description texts by language
- **Used By**: Payment description lookup for codes 1-89

#### **LIBPNCXW** - Payment Library
- **Purpose**: Payment type and description data from MUTF08
- **Key Fields**: LIBP-NRLIB (description code), LIBP-TYPE-COMPTE (account type), LIBP-LIBELLE-FR/NL/AL (descriptions)

#### **SEPAKCXW** - SEPA Account Search
- **Purpose**: Member account search working storage
- **Used By**: RECHERCHE-CPTE-MEMBRE paragraph

#### **SEBNKUKW** - SEPA Bank Validation
- **Purpose**: IBAN/BIC validation working storage
- **Used By**: WELKE-BANK paragraph
- **Key Fields**: WS-SEBNK-IBAN-IN, WS-SEBNK-BETWYZ-IN, WS-SEBNK-WELKEBANK, WS-SEBNK-BIC-OUT, WS-SEBNK-STAT-OUT

#### **Standard Working Storage**
- **WRNRSXDW**: National registry number utilities
- **WDATEXDW**: Date handling utilities
- **ABX00XSW**: ABX utilities
- **CGACVXSW**: Date conversion (Y2000 compliance)

## Data Structures

### Mutuality Code Classifications

The program handles multiple mutuality federations with language-specific processing:

- **MUT-FR** (French): 109, 116, 127, 128, 129, 130, 132, 133, 134, 135, 136, 167, 168
- **MUT-NL** (Dutch): 101, 102, 104, 105, 108, 110, 111, 112, 113, 114, 115, 117, 118, 119, 120, 121, 122, 126, 131, 169
- **MUT-BILINGUE** (Bilingual): 106, 107, 150, 166
- **MUT-VERVIERS**: 137 (supports German/AL)

### Payment Type Codes (TRBFN-TYPE-COMPTA)

Regional accounting types (6th State Reform):
- **1**: Standard accounting - Administrative Office (AO)
- **2**: Standard accounting - Liaison Office (AL)
- **3**: Regional accounting (Walloon) - Code 167, TAGREG-OP=1
- **4**: Regional accounting (Flemish) - Code 169, TAGREG-OP=2
- **5**: Regional accounting (Brussels) - Code 166, TAGREG-OP=4
- **6**: Regional accounting (German) - Code 168, TAGREG-OP=7

### Payment Description Codes (TRBFN-CODE-LIBEL)

- **1-49**: Standard payments (Belfius bank)
- **50**: Date-range payment with special formatting
- **51**: Specific bank type
- **52-57**: EATTEST payments
- **60**: Date-range payment variant
- **71**: MSA002 bulk payment
- **73**: MSA001 correg payment
- **74, 76, 78**: EATTEST variants
- **80**: Specific bank type
- **90-99**: Payments requiring MUTF08 lookup for description and account type

### Bank Selection (SAV-WELKEBANK / WELKEBANK)

- **0**: Belfius (formerly DEXIA/BAC)
- **1**: KBC (formerly CERA) - currently disabled per KVS002
- Bank codes in output:
  - **U-BAC-KODE 13**: Administrative Office account at Belfius
  - **U-BAC-KODE 23**: Liaison Office account at Belfius
  - **U-BAC-KODE 113**: Administrative Office account at KBC
  - **U-BAC-KODE 123**: Liaison Office account at KBC

### Payment Methods (TRBFN-BETWYZ / BBF-N51-BETWY)

- **"C"**: Circular cheque (requires Belgian address)
- **"D", "E", "F"**: Other payment variants (require Belgian address)
- **Other**: Standard bank transfer

### Error Diagnostics (BBF-N54-DIAG)

Common rejection reasons documented in program:
- "DUBBELE BETALING/DOUBLE PAIEMENT" - Duplicate payment detected
- "IBAN FOUTIEF/IBAN ERRONE" - Invalid IBAN
- "CC - PAYS/LAND NOT = B" - Circular cheque requires Belgian address
- "ONBEK. OMSCHR./LIBELLE INCONNU" - Unknown payment description
- "TAALCODE ONBEKEND/CODE LANGUE INCONNU" - Unknown language code
- "ERROR CONVERT RNR" - National registry number conversion error
- "ERROR SCHLID RNR" - Member lookup error
- "ERREUR ROUTINE SCHRKCX9 STATUS: X" - Account search error

## Component Dependencies

### Database Access
- **MUTF08**: Member parameter database (accessed via SCH08DBD, GTPARDBD)
- **UAREA**: User area database
- **LID**: Member database (accessed via SCHLDDBD, GTADMDBD, GTMUTDBD, GTPTLDBD)
- **BBF**: Payment module database (accessed via GTBBFDBD, ADBBFDBD)
- **LIDVZ**: Member insurance data (accessed via LIDVZASD copybook)
- **LOK**: Location/municipality data (accessed via GTLOKDRD)

### External Program Calls
- **CGACVXD9**: Date conversion utility (Y2000 compliance)
- **SEBNKUK9**: SEPA/IBAN bank validation utility
- **SCHRKCX9**: Member account search (via SEPAKCXD copybook)

### Output Generation (via ADLOGDBD)
- **SEPAAUKU**: User payment record (5N0001) - SEPA payment file
- **BFN51GZR**: Payment detail list (500001) and CSV detail (5DET01 - code 43)
- **BFN54GZR**: Rejection list (500004)
- **BFN56CXR**: Bank account discrepancy list (500006)

### Configuration Dependencies
- Multi-language support (FR/NL/DE/AL via ADM-TAAL)
- Regional accounting configuration (6th State Reform)
- SEPA/IBAN compliance settings
- Bank routing (Belfius vs KBC)

## Historical Modifications

Key modifications documented in the program:

- **Y2000**: Year 2000 compliance (date handling)
- **MTU01**: SC229498 - Removal of description code 70
- **MIS01**: DOCSOL - Stop generating document 541006
- **IBAN10**: SEPA project - IBAN support implementation
- **EVP**: Addition of CERA => KBC bank codes (CR-20046151)
- **R140562**: Daily payment via 2 banks (Belfius and KBC), removal of document 500002
- **JGO004**: Handle ADM-TAAL = 0 case
- **279363**: Display national registry number instead of M-number
- **EATT**: EATTEST support (payment type 5)
- **JGO001**: 6th State Reform - regional accounting
- **CDU001**: 6th State Reform continuation (regional codes 166-169)
- **KVS001**: JIRA-4224 - CSV output instead of Papyrus for flux 500001 (code 43 - 5DET01)
- **KVS002**: JIRA-4311 - PAIFIN-Belfius adaptation
- **MSA001**: JIRA-4837 - CORREG support (payment type 6)
- **MSA002**: JIRA-???? - BULK input support (payment type 7)

## Integration Points

### Input Sources
- **TRBFNCXP records**: Manual payment requests from TRBFNCXB program
- **MUTF08 database**: Member parameter and payment description data
- **Member databases**: Administrative, mutuality, insurance data

### Output Destinations
- **User file (5N0001)**: SEPA payment records for bank processing
- **List 500001**: Payment detail list for administrators
- **List 500004**: Rejection/error list for correction
- **List 500006**: Bank account discrepancy list for verification
- **Code 43 lists**: Regional accounting variants (500061, 500071, 500081, 500091, etc.)
- **5DET01**: CSV detail file (code 43) per JIRA-4224

### External Systems
- **Bank systems**: SEPA payment file processing (Belfius, KBC)
- **IBAN validation**: SEPA bank validation utility
- **Scheduler**: Batch job scheduling (not specified in code)

## Special Considerations

1. **Multi-language Support**: Handles FR/NL/DE/AL languages with bilingual mutualities
2. **SEPA/IBAN Compliance**: Full IBAN validation and BIC code handling
3. **Regional Accounting**: 6th State Reform support with regional codes (166-169) and TAGREG indicators
4. **Payment Type Handling**: Circular cheques vs transfers with country validation
5. **Duplicate Detection**: Prevents duplicate payments based on amount and constant
6. **Age Validation**: Minimum age check (16 for men, 14 for women) for account holder
7. **Account Discrepancy Handling**: Generates list 500006 when input account differs from database
8. **Historical Data**: Tracks modifications from multiple projects (MTU01, MIS01, IBAN10, JGO001, etc.)
9. **CSV Output**: JIRA-4224 introduced CSV output (5DET01) instead of Papyrus format
10. **Bank Routing**: Belfius primary, KBC currently disabled per KVS002 modification

## Processing Flow Summary

1. **Entry**: Program called via GIRBETPP entry point with TRBFNCXP record
2. **Member Lookup**: Search member by national registry number
3. **Section Search**: Find active insurance section
4. **Language Determination**: Resolve language code (handle ADM-TAAL=0)
5. **National Registry**: Locate correct national registry number variant
6. **Payment Description**: Lookup from table (codes 1-89) or MUTF08 (codes 90-99)
7. **Duplicate Check**: Verify no duplicate payment exists
8. **Bank Validation**: Validate IBAN, determine bank (Belfius/KBC), get BIC
9. **Create BBF Record**: Add payment to BBF module
10. **Country Validation**: For circular cheques (C/D/E/F), verify Belgian address
11. **Generate Outputs**:
    - User payment record (SEPAAUKU - 5N0001)
    - Payment detail list (BFN51GZR - 500001, optionally 5DET01 code 43)
    - Rejection list if errors (BFN54GZR - 500004)
    - Discrepancy list if account mismatch (BFN56CXR - 500006)
12. **Exit**: Exit program

## Code Organization Metrics

- **Total Lines**: ~1394
- **Sections**: 4 (TRAITEMENT-BTM, ROUTINES, RECHERCHE-SECTION, PAR-MUT)
- **Copybooks Referenced**: 20+
- **Database Access Paragraphs**: 8
- **Business Logic Paragraphs**: 10+
- **Output Formats**: 3 main lists (500001, 500004, 500006) plus variants
