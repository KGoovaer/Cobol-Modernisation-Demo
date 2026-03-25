# Discovered Flows - MYFIN

## Overview
This document describes the execution flows, data transformations, and integration points discovered in the MYFIN batch program, which processes manual GIRBET payment records.

---

## Flow: Manual GIRBET Payment Processing
- **ID**: FLOW_MYFIN_MAIN_001
- **Entry Point**: `GIRBETPP` entry point (LINKAGE SECTION receives USAREA1 and PPR-RECORD)
- **Trigger**: Batch job execution - processes TRBFNCXP records from input file
- **Input**: TRBFNCXP record structure (payment request with national registry number, payment amount, bank details, IBAN)
- **Output**: 
  - BBF database record (payment module record)
  - SEPAAUKU user record (500001/5N0001 - bank payment instruction)
  - BFN51GZR list record (500001 or regional variants - payment detail list)
  - BFN54GZR list record (500004 or regional variants - rejection/error list)
  - BFN56CXR list record (500006 or regional variants - bank account discrepancy list)
- **Batch Info**: 
  - Type: Batch payment processing
  - Processing Pattern: Record-by-record processing of manual payment inputs
  - Integration: Part of GIRBET manual payment system

### Flow Steps

1. **Entry & Member Lookup** (TRAITEMENT-BTM Section)
   - Entry point receives USAREA1 database context and PPR-RECORD input
   - Extract national registry number from `TRBFN-PPR-RNR`
   - Initialize language tracking variables `WS-LIDVZ-OP-TAAL` and `WS-LIDVZ-AP-TAAL`
   - Perform `SCH-LID` to search member in main database
   - If member not found (STAT1 ≠ 0), perform `PPRNVW` error handling and exit

2. **Section & Language Determination** (RECHERCHE-SECTION)
   - Search for active member section using `LIDVZASD` copybook
   - Check multiple insurance data categories in priority order:
     a. Open holder data (OT - LIDVZ-OT-DATOND, LIDVZ-OT-KOD1)
     b. Open PAC data (OP - LIDVZ-OP-DATINS, LIDVZ-OP-KOD1, LIDVZ-OP-TAAL)
     c. Closed holder data (AT - LIDVZ-AT-DATOND, LIDVZ-AT-KOD1)
     d. Closed PAC data (AP - LIDVZ-AP-DATINS, LIDVZ-AP-KOD1, LIDVZ-AP-TAAL)
   - Exclude certain product codes: 609, 659, 679, 689
   - Store found section in `SECTION-TROUVEE` and language in `WS-LIDVZ-OP-TAAL` or `WS-LIDVZ-AP-TAAL`
   - Set switch `SW-TROUVE = "OK"` when match found

3. **Administrative Data Retrieval**
   - Perform `GET-ADM` to retrieve administrative member data
   - Handle language code determination (ADM-TAAL):
     - If ADM-TAAL = 0, use language from section search (WS-LIDVZ-AP-TAAL or WS-LIDVZ-OP-TAAL)
     - If no language code found, create rejection record with "TAALCODE ONBEKEND/CODE LANGUE INCONNU" diagnostic
     - Execute `CREER-REMOTE-500004` to generate error list entry
     - Perform `FIN-BTM` to exit processing

4. **National Registry Number Resolution** (ZOEK-RIJKSNUMMER)
   - Determine which national registry number to use in priority order:
     a. ADM-RNR2 if ADM-RNR2-MUT = space (primary RNR)
     b. ADM-NRNR2 if ADM-NRNR2-MUT = space and ADM-NRNR2G not blank (national RNR)
     c. TRBFN-RNR from input record (fallback)
   - Store selected value in `WS-RIJKSNUMMER`

5. **Payment Description Retrieval** (Code Libel >= 90)
   - If `TRBFN-CODE-LIBEL >= 90`:
     - Access MUTF08 database: add 6000000 + destination federation to RNRBIN
     - Perform `SCH-LID08` to search MUTF08 member data
     - Perform `GET-PAR` to retrieve parameter/description library
     - Loop through parameters until `LIBP-NRLIB = TRBFN-CODE-LIBEL`
     - Extract `LIBP-TYPE-COMPTE` into `SAV-TYPE-COMPTE`
     - Select language-specific description into `SAV-LIBELLE`:
       * French mutuality (109, 116, 127-136, 167-168): Use LIBP-LIBELLE-FR
       * Dutch mutuality (101-102, 104-105, 108, 110-122, 126, 131, 169): Use LIBP-LIBELLE-NL
       * Bilingual mutuality (106-107, 150, 166): Use LIBP-LIBELLE-NL if ADM-TAAL=1, else LIBP-LIBELLE-FR
       * Verviers mutuality (137): Use LIBP-LIBELLE-AL if ADM-TAAL=3, else LIBP-LIBELLE-FR
     - If description not found (STAT1 ≠ 0), reject with "ONBEK. OMSCHR./LIBELLE INCONNU"
   - Else if `TRBFN-CODE-LIBEL < 90`:
     - Use table TBLIBCXW: `TBLIB-LIBELLE(TRBFN-CODE-LIBEL, ADM-TAAL)` → SAV-LIBELLE
     - Use table TBLIBCXW: `TBLIB-TYPE(TRBFN-CODE-LIBEL)` → SAV-TYPE-COMPTE

6. **Duplicate Payment Detection** (VOIR-DOUBLES)
   - Perform `GET-BBF` (GETTP = 1) to access existing BBF payment records
   - Loop through all BBF records for this member
   - For each record, check if:
     * `TRBFN-MONTANT = BBF-BEDRAG` (same amount)
     * `TRBFN-CONSTANTE = BBF-KONST` (same payment constant)
   - If duplicate found:
     * Create rejection: "DUBBELE BETALING/DOUBLE PAIEMENT"
     * Execute `CREER-REMOTE-500004`
     * Execute `FIN-BTM` to exit

7. **Bank Account Validation** (VOIR-BANQUE-DEBIT)
   - Initialize BIC code: `MOVE SPACES TO WS-BIC`
   - Prepare IBAN validation inputs:
     * `WS-SEBNK-IBAN-IN` ← TRBFN-IBAN
     * `WS-SEBNK-BETWYZ-IN` ← TRBFN-BETWYZ
   - Perform `WELKE-BANK` (calls SEBNKUK9 program for IBAN/bank validation)
   - Set bank selection to Belfius (0) for all payments (KVS002 modification)
   - Validate IBAN result:
     * If `WS-SEBNK-WELKEBANK = 0` AND `WS-SEBNK-STAT-OUT = 0, 1, or 2`:
       - Valid IBAN: Store `WS-SEBNK-BIC-OUT` → WS-BIC
     * Else:
       - Invalid IBAN: Create rejection "IBAN FOUTIEF/IBAN ERRONE"
       - Execute `CREER-REMOTE-500004` and exit
   - Determine bank routing based on payment type code:
     * Codes 90-99, 1-49, 52-57, 71, 73, 74, 76, 78:
       - If WS-SEBNK-WELKEBANK = 0, set SAV-WELKEBANK = 1 (Belfius)
     * Code 50, 51, 60, 80: Force SAV-WELKEBANK = 1 (Belfius)
     * Other codes: Default SAV-WELKEBANK = 1 (Belfius)

8. **BBF Module Record Creation** (CREER-BBF)
   - Initialize BBF-REC structure
   - Populate core fields:
     * `BBF-TYPE` = 9 (payment type indicator)
     * `BBF-LIBEL` ← TRBFN-CODE-LIBEL (payment description code)
     * `BBF-BEDRAG` ← TRBFN-MONTANT (amount in cents)
     * `BBF-BEDRAG-DV` ← TRBFN-MONTANT-DV (currency indicator)
     * `BBF-VOLGNR` ← TRBFN-NO-SUITE (sequence number)
     * `BBF-KONST` ← TRBFN-CONSTANTE (payment constant)
     * `BBF-DATINB` ← SP-ACTDAT (processing date)
   - Handle date range for codes 50 and 60:
     * Extract dates from TRBFN-LIBELLE1 and TRBFN-LIBELLE2
     * Convert 2-digit years to 4-digit using CGACVXD9 date conversion
     * Store in BBF-DATVAN (from date) and BBF-DATTOT (to date)
   - Process IBAN to legacy bank account:
     * If TRBFN-IBAN not spaces:
       - Extract Belgian IBAN: If WS-IBAN(1:2) = "BE", move WS-IBAN(5:12) → BBF-REKNR
       - Else: Set BBF-REKNR = zeroes
     * Store full IBAN: BBF-IBAN ← TRBFN-IBAN
   - Set payment method: `BBF-BETWY` ← TRBFN-BETWYZ
   - Initialize tracking fields: BBF-INFOREK, BBF-LINKNR = zeroes; BBF-CODE-MAF, BBF-JAAR-MAF = spaces
   - Handle regional accounting (6th State Reform):
     * Type 3: BBF-TAGREG-OP = 1, BBF-VERB = 167
     * Type 4: BBF-TAGREG-OP = 2, BBF-VERB = 169
     * Type 5: BBF-TAGREG-OP = 4, BBF-VERB = 166
     * Type 6: BBF-TAGREG-OP = 7, BBF-VERB = 168
     * Other: BBF-TAGREG-OP = 9, BBF-VERB = TRBFN-DEST
   - Execute `ADD-BBF` to write record to database

9. **Circular Check Country Validation** (IBAN10)
   - If payment method is circular check (TRBFN-BETWYZ = "C", "D", "E", or "F"):
     * Check if member address country is Belgium (ADM-LND = "B  ")
     * If not Belgium:
       - Create rejection: "CC - PAYS/LAND NOT = B"
       - Execute `CREER-REMOTE-500004`
       - Skip payment processing (no CREER-USER-500001 or CREER-REMOTE-500001)
   - Else (valid country or bank transfer):
     * Continue to payment output generation

10. **SEPA User Record Generation** (CREER-USER-500001)
    - Initialize SEPAAUKU record structure
    - Set record header:
      * REC-LENGTE = 475 bytes
      * REC-CODE = 41
      * USERCOD = "5N0001" (SEPA user code)
      * USERRNR ← TRBFN-PPR-RNR (member national registry)
      * USERMY ← SECTION-TROUVEE (member section)
    - Determine bank routing and account code:
      * Bank 1 (Belfius):
        - WELKEBANK = 0
        - General/regional accounting (type 1, 3-6): U-BAC-KODE = 13 (AO account)
        - Other accounting (type 2): U-BAC-KODE = 23 (AL account)
      * Bank 2 (KBC) - for regional accounts, force Belfius:
        - If type 3-6: WELKEBANK = 0, U-BAC-KODE = 13 (regional only at Belfius)
        - Else: WELKEBANK = 0 (KVS002), U-BAC-KODE = 113/123 (KBC codes)
    - Set payment category:
      * ALOIS-RAF = 1 (Betfin payment)
      * TAAL ← ADM-TAAL (language)
    - Set date indicator based on payment code:
      * Code 60: BAC-DATM61 = 1
      * Type 1, 3-6: BAC-DATM61 = 0
      * Other: BAC-DATM61 = 2
    - Populate bank account holder information:
      * U-BNK-REKHOUDER: Concatenate ADM-NAAM + ADM-VOORN
      * U-BNK-LND ← ADM-LND, U-BNK-POSTNR ← ADM-POSTNR, U-BNK-GEM ← ADM-GEM
    - Populate member administrative address:
      * U-ADM-NAAM ← ADM-NAAM, U-ADM-VNAAM ← ADM-VOORN
      * U-ADM-STR ← ADM-STRAAT, U-ADM-HUIS ← ADM-HUISNR
      * U-ADM-INDEX ← ADM-INDEX, U-ADM-BUS ← ADM-BUS
      * U-ADM-LND ← ADM-LND, U-ADM-POST ← ADM-POSTNR, U-ADM-GEM ← ADM-GEM
    - Build payment communication/reference (COMMENT → COMMENTAAR):
      * Code 35: "SAV-LIBELLE - ADM-NAAM ADM-VOORN"
      * Code 50/60: "SAV-LIBELLE DATE1 AU/TOT/BIS DATE2"
      * Other codes: Use SAV-LIBELLE directly
      * Append reference: "O.REF:"/"N.REF:"/"U.KENZ:" + KONSTANTE + VOLGNR
      * Append descriptions:
        - If code 50/60: Leave OMSCH1/OMSCH2 blank
        - Else: OMSCH1 = WS-RIJKSNUMMER if LIBELLE1 position 11 = "M", else TRBFN-LIBELLE1
        - OMSCH2 ← TRBFN-LIBELLE2
    - Set payment details:
      * NETBEDRAG ← TRBFN-MONTANT, REC-DV ← TRBFN-MONTANT-DV
      * U-IBAN ← TRBFN-IBAN, U-BIC ← WS-BIC
      * U-BETWYZ ← TRBFN-BETWYZ
    - Set regional tags (6th State Reform):
      * Type 3: TAG-REG-OP/LEG = 1, USERFED/VRBOND = 167
      * Type 4: TAG-REG-OP/LEG = 2, USERFED/VRBOND = 169
      * Type 5: TAG-REG-OP/LEG = 4, USERFED/VRBOND = 166
      * Type 6: TAG-REG-OP/LEG = 7, USERFED/VRBOND = 168
      * Other: TAG-REG-OP/LEG = 9, USERFED/VRBOND = TRBFN-DEST
    - Execute `ADLOGDBD` (write log record) with SEPAAUKU structure

11. **Payment Detail List Generation** (CREER-REMOTE-500001)
    - Set record header:
      * BBF-N51-LENGTH = 213 bytes
      * BBF-N51-DEVICE-OUT = "C" if destination 153 (console), else "L" (list)
      * BBF-N51-SWITCHING = "*"
      * BBF-N51-PRIORITY = space
    - Determine list name and code by accounting type:
      * Type 3: "500071", code 43, destination 151
      * Type 4: "500091", code 43, destination 151
      * Type 5: "500061", code 43, destination 151
      * Type 6: "500081", code 43, destination 151
      * Other types:
        - Code 40
        - If destination 141: "541001", destination 116
        - Else: "500001", destination TRBFN-DEST
        - Set switch SW-CREA-CODE-43 for CSV export
    - Build record key:
      * BBF-N51-VERB calculated by accounting type (167/169/166/168 or TRBFN-DEST)
      * BBF-N51-AFK = 2 if type 1/3/4/5/6 (general/regional), else 3 (AL account)
      * BBF-N51-KONST ← TRBFN-CONSTANTE
      * BBF-N51-VOLGNR ← TRBFN-NO-SUITE
    - Populate payment details:
      * BBF-N51-RNR ← WS-RIJKSNUMMER
      * BBF-N51-NAAM ← ADM-NAAM, BBF-N51-VOORN ← ADM-VOORN
      * BBF-N51-LIBEL ← TRBFN-CODE-LIBEL
      * BBF-N51-REKNR = zeroes (IBAN replaces legacy number)
      * BBF-N51-BEDRAG ← TRBFN-MONTANT
      * BBF-N51-DV ← TRBFN-MONTANT-DV, BBF-N51-DN = 2 if Euro, else 0
      * BBF-N51-BANK ← SAV-WELKEBANK
      * BBF-N51-INFOREK = zeroes
    - Handle account type for codes 90-99:
      * Perform `P-RECHERCHE-TYPE-COMPTE` to lookup type from MUTF08/parameter library
      * Store result in BBF-N51-TYPE-COMPTE
      * Else: BBF-N51-TYPE-COMPTE = spaces
    - Set IBAN and payment method:
      * BBF-N51-IBAN ← TRBFN-IBAN
      * BBF-N51-BETWY ← TRBFN-BETWYZ
    - Set regional tag by accounting type (same logic as BBF-N51-VERB)
    - Execute `ADLOGDBD` with BFN51GZR structure to write list record
    - If SW-CREA-CODE-43 = TRUE (KVS001 - JIRA-4224):
      * Create CSV export version:
        - BBF-N51-NAME = "5DET01"
        - BBF-N51-CODE = 43
        - BBF-N51-DESTINATION = 151
        - Execute `ADLOGDBD` with BFN51GZR structure again

12. **Bank Account Discrepancy Check** (TRBFN-COMPTE-MEMBRE = 0)
    - If input record indicates non-member account:
      * Execute `CREER-REMOTE-500006` to report discrepancy

13. **Normal Completion**
    - Execute `FIN-BTM` to exit program normally

### Key Components

- **MYFIN**: Main batch payment processing program
- **GIRBETPP**: Entry point for payment processing
- **TRAITEMENT-BTM**: Main control section
- **ROUTINES**: Business logic section with payment processing paragraphs
- **RECHERCHE-SECTION**: Member section and insurance lookup
- **PAR-MUT**: Database access section
- **SEPAAUKU**: SEPA bank payment user record structure
- **BFN51GZR**: Payment detail list output record
- **BFN54GZR**: Payment rejection list output record
- **BFN56CXR**: Bank account discrepancy list output record
- **SEBNKUK9**: External IBAN/bank validation program
- **CGACVXD9**: External date conversion program
- **SCHRKCX9**: External member account search program (via SEPAKCXD copybook)

### Data Transformations

- **Input (TRBFNCXP)** → **Member Lookup (MUTF08)** → **Validation** → **Output (BBF, SEPAAUKU, BFN51GZR)**
  * TRBFN-PPR-RNR (binary registry number) → SCH-LID database lookup → ADM record (administrative data)
  * TRBFN-IBAN → SEBNKUK9 validation → WS-BIC extraction → SEPAAUKU U-IBAN and U-BIC
  * TRBFN-CODE-LIBEL → Language-specific description lookup (MUTF08/LIBP or TBLIBCXW) → SAV-LIBELLE
  * TRBFN-CONSTANTE + TRBFN-NO-SUITE → Payment reference key (BBF-KONST, BBF-VOLGNR)
  * ADM-NAAM + ADM-VOORN → String concatenation → U-BNK-REKHOUDER (account holder name)
  * TRBFN-LIBELLE1/2 → Date extraction for codes 50/60 → 2-digit year → CGACVXD9 conversion → 4-digit year → BBF-DATVAN/DATTOT
  * TRBFN-TYPE-COMPTA → Regional accounting mapping → BBF-VERB, TAG-REG-OP, TAG-REG-LEG, USERFED, VRBOND
  * TRBFN-IBAN(5:12) → Belgian IBAN account number extraction → BBF-REKNR (for "BE" prefix only)

- **Mutuality Code → Language Selection**
  * Codes 109, 116, 127-136, 167-168 → French (MUT-FR) → LIBP-LIBELLE-FR
  * Codes 101-102, 104-105, 108, 110-122, 126, 131, 169 → Dutch (MUT-NL) → LIBP-LIBELLE-NL
  * Codes 106-107, 150, 166 → Bilingual (MUT-BILINGUE) → LIBP-LIBELLE-NL if ADM-TAAL=1, else LIBP-LIBELLE-FR
  * Code 137 → Verviers (MUT-VERVIERS) → LIBP-LIBELLE-AL if ADM-TAAL=3, else LIBP-LIBELLE-FR

- **IBAN Validation Flow**
  * TRBFN-IBAN → WS-SEBNK-IBAN-IN → SEBNKUK9 program → WS-SEBNK-STAT-OUT (0, 1, 2 = valid) → WS-SEBNK-BIC-OUT → WS-BIC

- **Bank Routing Transformation**
  * SAV-WELKEBANK = 1 → WELKEBANK = 0 (Belfius) → U-BAC-KODE = 13 (general/regional) or 23 (AL)
  * SAV-WELKEBANK = 2 + Regional type → Force WELKEBANK = 0, U-BAC-KODE = 13 (regional accounts only at Belfius)
  * SAV-WELKEBANK = 2 + Non-regional → WELKEBANK = 0 (KVS002 modification), U-BAC-KODE = 113/123

- **Payment Communication Structure**
  * BANK-VELD1 (53 chars) + REF-VELD1 ("O.REF:"/etc.) + KONSTANTE-VELD1 (10 digits) + VOLGNR-VELD1 (3 digits) + OMSCH1-VELD1 (14 chars) + OMSCH2-VELD1 (14 chars) → COMMENTAAR (106 chars)

### Decision Points

- **Decision**: Is member found in database?
  - **Condition**: `STAT1 = ZEROES` after SCH-LID
  - **Path A (Found)**: Continue with RECHERCHE-SECTION to find member section
  - **Path B (Not Found)**: Execute PPRNVW error handling and exit

- **Decision**: Is active section found?
  - **Condition**: `SW-TROUVE = "OK"` after searching OT/OP/AT/AP data
  - **Path A (Found)**: Store SECTION-TROUVEE and language code, continue processing
  - **Path B (Not Found)**: SECTION-TROUVEE remains zeroes, may cause issues in later processing

- **Decision**: Is language code known?
  - **Condition**: `ADM-TAAL = 0` and no language from section search
  - **Path A (Known)**: Use ADM-TAAL or section language for description selection
  - **Path B (Unknown)**: Create rejection "TAALCODE ONBEKEND/CODE LANGUE INCONNU", exit via FIN-BTM

- **Decision**: Which description source to use?
  - **Condition**: `TRBFN-CODE-LIBEL >= 90`
  - **Path A (≥ 90)**: Lookup from MUTF08 database parameter library (LIBP-LIBELLE-FR/NL/AL), validate existence
  - **Path B (< 90)**: Use internal table TBLIBCXW indexed by code and language

- **Decision**: Which language variant of description?
  - **Condition**: Mutuality code (TEST-MUTUALITE) and ADM-TAAL
  - **Path A (MUT-FR)**: Use French description (LIBP-LIBELLE-FR)
  - **Path B (MUT-NL)**: Use Dutch description (LIBP-LIBELLE-NL)
  - **Path C (MUT-BILINGUE)**: Use NL if ADM-TAAL=1, else FR
  - **Path D (MUT-VERVIERS)**: Use AL if ADM-TAAL=3, else FR

- **Decision**: Is this a duplicate payment?
  - **Condition**: BBF record exists with same `BBF-BEDRAG = TRBFN-MONTANT` AND `BBF-KONST = TRBFN-CONSTANTE`
  - **Path A (Duplicate)**: Create rejection "DUBBELE BETALING/DOUBLE PAIEMENT", exit via FIN-BTM
  - **Path B (Not Duplicate)**: Continue with VOIR-BANQUE-DEBIT

- **Decision**: Is IBAN valid?
  - **Condition**: `WS-SEBNK-WELKEBANK = 0` AND `WS-SEBNK-STAT-OUT = 0, 1, or 2` after SEBNKUK9 call
  - **Path A (Valid)**: Store BIC code, continue with bank routing logic
  - **Path B (Invalid)**: Create rejection "IBAN FOUTIEF/IBAN ERRONE", exit via FIN-BTM

- **Decision**: Is payment method circular check with non-Belgian address?
  - **Condition**: `TRBFN-BETWYZ = "C"/"D"/"E"/"F"` AND `ADM-LND ≠ "B  "`
  - **Path A (Invalid)**: Create rejection "CC - PAYS/LAND NOT = B", skip CREER-USER-500001 and CREER-REMOTE-500001
  - **Path B (Valid)**: Proceed with payment output generation

- **Decision**: Which bank routing code to use?
  - **Condition**: SAV-WELKEBANK value and TRBFN-TYPE-COMPTA
  - **Path A (SAV-WELKEBANK = 1)**: WELKEBANK = 0 (Belfius), U-BAC-KODE = 13 (type 1/3/4/5/6) or 23 (type 2)
  - **Path B (SAV-WELKEBANK = 2, regional)**: Force WELKEBANK = 0, U-BAC-KODE = 13 (regional accounts only at Belfius per CDU001)
  - **Path C (SAV-WELKEBANK = 2, non-regional)**: WELKEBANK = 0 (KVS002), U-BAC-KODE = 113 (type 1) or 123 (type 2)

- **Decision**: Which payment list to generate?
  - **Condition**: TRBFN-TYPE-COMPTA value
  - **Path A (Type 3)**: List "500071", code 43, destination 151
  - **Path B (Type 4)**: List "500091", code 43, destination 151
  - **Path C (Type 5)**: List "500061", code 43, destination 151
  - **Path D (Type 6)**: List "500081", code 43, destination 151
  - **Path E (Other, destination 141)**: List "541001", code 40, destination 116
  - **Path F (Other)**: List "500001", code 40, destination TRBFN-DEST, create CSV export "5DET01" code 43

- **Decision**: Should bank account discrepancy be reported?
  - **Condition**: `TRBFN-COMPTE-MEMBRE = ZEROES`
  - **Path A (Not member account)**: Execute CREER-REMOTE-500006 to report discrepancy
  - **Path B (Member account)**: Skip discrepancy report

- **Decision**: Which national registry number to use in output?
  - **Condition**: ADM-RNR2-MUT, ADM-NRNR2-MUT values
  - **Path A**: ADM-RNR2 if ADM-RNR2-MUT = space
  - **Path B**: ADM-NRNR2 if ADM-NRNR2-MUT = space and ADM-NRNR2G not blank
  - **Path C**: TRBFN-RNR (input value) as fallback

- **Decision**: Which bank account value for output list?
  - **Condition**: Payment type code range
  - **Path A (Codes 90-99)**: Perform P-RECHERCHE-TYPE-COMPTE to lookup from MUTF08
  - **Path B (Other codes)**: Leave BBF-N51-TYPE-COMPTE = spaces

- **Decision**: Date handling for payment description codes 50 and 60
  - **Condition**: `TRBFN-CODE-LIBEL = 50 OR = 60`
  - **Path A (Code 50/60)**: Extract dates from TRBFN-LIBELLE1/2, convert 2-digit to 4-digit year via CGACVXD9, store in BBF-DATVAN and BBF-DATTOT
  - **Path B (Other codes)**: Set BBF-DATVAN and BBF-DATTOT to zeroes

- **Decision**: How to build payment reference (OMSCH1-VELD1)?
  - **Condition**: Code 50/60 vs other, and TRBFN-LIBELLE1(11:1) = "M"
  - **Path A (Code 50/60)**: Leave OMSCH1-VELD1 and OMSCH2-VELD1 blank
  - **Path B (LIBELLE1 position 11 = "M")**: Use WS-RIJKSNUMMER
  - **Path C (Other)**: Use TRBFN-LIBELLE1; if blank, default to WS-RIJKSNUMMER

### Dependencies

- **Database**: 
  - MUTF08 (member data for codes >= 90, accessed via SCH-LID08)
  - Main member database (accessed via SCH-LID, GET-ADM, GET-MUT, GET-PTL)
  - BBF module (payment data, accessed via GET-BBF, ADD-BBF)
  - PAR (parameter library, accessed via GET-PAR)
  - LIDVZ (member insurance data, accessed via LIDVZASD copybook)
  - UAREA (database context area)

- **External Programs**:
  - CGACVXD9: Date conversion (2-digit to 4-digit year)
  - SEBNKUK9: IBAN validation and BIC extraction (via SEBNKUKW copybook)
  - SCHRKCX9: Member account search (via SEPAKCXD copybook)

- **External Files/Outputs**:
  - 500001 (BFN51GZR): Payment detail list for Belfius/KBC
  - 5DET01 (BFN51GZR code 43): CSV detail export (JIRA-4224)
  - 500004 (BFN54GZR): Rejection/error list
  - 500006 (BFN56CXR): Bank account discrepancy list
  - 500071, 500091, 500061, 500081 (regional variants): Regional accounting payment lists
  - 500074, 500094, 500064, 500084 (regional variants): Regional accounting rejection lists
  - 500076, 500096, 500066, 500086 (regional variants): Regional accounting discrepancy lists
  - 541001, 541004, 541006: Special lists for mutual 141
  - 5N0001 (SEPAAUKU): SEPA user payment instruction file

- **Config/Copybooks**:
  - TBLIBCXW: Payment description table for codes < 90
  - TRBFNCXP: Input payment record structure
  - BBFPRGZP: Financial payment input (reference structure)
  - INFPRGZP: Info record structure
  - SEPAAUKU: SEPA bank payment user record
  - BFN51GZR, BFN54GZR, BFN56CXR: Output list record structures
  - SEPAKCXW: Member account search working storage
  - SEBNKUKW: IBAN/bank validation working storage

---

## Flow: Payment Rejection Processing
- **ID**: FLOW_MYFIN_REJECT_002
- **Entry Point**: Various validation failure points in main flow
- **Trigger**: Validation error or business rule violation
- **Input**: Current processing context (PPR-RECORD, member data, validation results)
- **Output**: BFN54GZR rejection list record (500004 or regional variants)

### Flow Steps

1. **Error Detected** (Various paragraphs)
   - Multiple trigger points:
     * Member not found (STAT1 ≠ 0 after SCH-LID)
     * Language code unknown (ADM-TAAL = 0 and no section language)
     * Description not found (STAT1 ≠ 0 after parameter lookup)
     * Duplicate payment (BBF-BEDRAG = TRBFN-MONTANT AND BBF-KONST = TRBFN-CONSTANTE)
     * Invalid IBAN (WS-SEBNK-STAT-OUT invalid after SEBNKUK9)
     * Circular check with non-Belgian address (TRBFN-BETWYZ circular AND ADM-LND ≠ "B")
   - Set diagnostic message in BBF-N54-DIAG:
     * "TAALCODE ONBEKEND/CODE LANGUE INCONNU"
     * "ONBEK. OMSCHR./LIBELLE INCONNU"
     * "DUBBELE BETALING/DOUBLE PAIEMENT"
     * "IBAN FOUTIEF/IBAN ERRONE"
     * "CC - PAYS/LAND NOT = B"

2. **Rejection Record Creation** (CREER-REMOTE-500004)
   - Set record header:
     * BBF-N54-LENGTH = 259 bytes
     * BBF-N54-DEVICE-OUT = "C" if destination 153, else "L"
     * BBF-N54-SWITCHING = "*"
     * BBF-N54-PRIORITY = space
   - Determine rejection list name by accounting type:
     * Type 3: "500074", code 43, destination 151
     * Type 4: "500094", code 43, destination 151
     * Type 5: "500064", code 43, destination 151
     * Type 6: "500084", code 43, destination 151
     * Other, destination 141: "541004", code 40, destination 116
     * Other: "500004", code 40, destination TRBFN-DEST
   - Build record key:
     * BBF-N54-KONST, BBF-N54-KONSTA ← TRBFN-CONSTANTE
     * BBF-N54-VOLGNR, BBF-N54-VOLGNR-M30 ← TRBFN-NO-SUITE
   - Populate rejection details:
     * BBF-N54-TAAL ← ADM-TAAL
     * BBF-N54-BETWYZ ← TRBFN-BETWYZ
     * BBF-N54-RNR ← WS-RIJKSNUMMER
     * BBF-N54-BEDRAG ← TRBFN-MONTANT
     * BBF-N54-DV ← TRBFN-MONTANT-DV, BBF-N54-DN = 2 if Euro, else 0
     * BBF-N54-BETKOD ← TRBFN-CODE-LIBEL
     * BBF-N54-REKNR = zeroes
     * BBF-N54-IBAN ← TRBFN-IBAN
   - Initialize technical fields to zeroes: BBF-N54-INF, BBF-N54-INF-VOL, BBF-N54-PREST, BBF-N54-SPEC, BBF-N54-AANT, BBF-N54-DATE, BBF-N54-HONOR
   - Set BBF-N54-RNR2 to spaces
   - Set regional accounting tags (same logic as main flow):
     * Type 3-6: TAG-REG-OP and corresponding VERB/VBOND
     * Other: TAG-REG-OP = 9, VERB/VBOND = TRBFN-DEST
   - Execute `ADLOGDBD` with BFN54GZR structure

3. **Processing Termination**
   - Execute `FIN-BTM` to exit program
   - EXIT PROGRAM statement returns control to caller

### Key Components

- **CREER-REMOTE-500004**: Rejection record creation paragraph
- **BFN54GZR**: Rejection list output record structure
- **BBF-N54-DIAG**: Diagnostic message field (populated before calling paragraph)
- **FIN-BTM**: Program termination paragraph

### Data Transformations

- **Error Context** → **Rejection Record (BFN54GZR)**
  * Diagnostic message → BBF-N54-DIAG (error description in FR/NL)
  * TRBFN-CONSTANTE → BBF-N54-KONST, BBF-N54-KONSTA (payment identifier)
  * TRBFN-NO-SUITE → BBF-N54-VOLGNR, BBF-N54-VOLGNR-M30 (sequence number)
  * ADM-TAAL → BBF-N54-TAAL (language for error message)
  * WS-RIJKSNUMMER → BBF-N54-RNR (national registry number)
  * TRBFN-MONTANT → BBF-N54-BEDRAG (rejected amount)
  * TRBFN-TYPE-COMPTA → Regional tag logic → BBF-N54-VERB, BBF-N54-VBOND, BBF-N54-TAGREG-OP

### Decision Points

- **Decision**: Which rejection list to use?
  - **Condition**: TRBFN-TYPE-COMPTA and TRBFN-DEST values
  - **Path A (Type 3)**: "500074" regional rejection list
  - **Path B (Type 4)**: "500094" regional rejection list
  - **Path C (Type 5)**: "500064" regional rejection list
  - **Path D (Type 6)**: "500084" regional rejection list
  - **Path E (Destination 141)**: "541004" mutual-specific list
  - **Path F (Other)**: "500004" standard rejection list

---

## Flow: Bank Account Discrepancy Reporting
- **ID**: FLOW_MYFIN_DISCREPANCY_003
- **Entry Point**: After successful payment processing (CREER-REMOTE-500001)
- **Trigger**: Input payment indicates non-member account (TRBFN-COMPTE-MEMBRE = 0)
- **Input**: Input payment record, member bank account from database
- **Output**: BFN56CXR discrepancy list record (500006 or regional variants)

### Flow Steps

1. **Member Bank Account Lookup** (RECH-NO-BANCAIRE)
   - Initialize: `MOVE SPACES TO SAV-IBAN`
   - Check member age (minimum 16 for men, 14 for women):
     * Extract birth date from TRBFN-RNR
     * Convert EBCDIC RNR to date using RREBBXDD copybook
     * Add 16 or 14 years to birth date (WS-DATEBC-CONSTANT)
     * Use DWYERXDD date calculation copybook
     * If calculated date > SP-ACTDAT: Set SW-TROP-JEUNE = 1 (too young)
   - If member is old enough (SW-TROP-JEUNE = 0):
     * Perform `RECHERCHE-CPTE-MEMBRE` directly
   - Else (member too young):
     * Search for account holder (parent/guardian) in LIDVZ insurance data:
       - Loop through OP (open PAC) records
       - Find records with product codes 600-699 (excluding 609, 659, 679, 689)
       - Extract LIDVZ-OP-RNRTIT2 (holder's RNR)
     * If holder found:
       - Convert holder RNR to binary (RREBBXDD)
       - Perform SCH-LID to lookup holder
       - Perform RECHERCHE-CPTE-MEMBRE to get holder's account
       - Restore original member context (SAV-RNRBIN → RNRBIN, GET-ADM)

2. **Account Search** (RECHERCHE-CPTE-MEMBRE)
   - Prepare search parameters:
     * SCHRK-CODE-LIBEL ← TRBFN-CODE-LIBEL
     * SCHRK-BKF-TIERS = 0
     * SCHRK-DAT-VAL ← SP-ACTDAT (processing date)
     * SCHRK-FED ← TRBFN-DEST
   - Execute `SEPAKCXD` copybook to call SCHRKCX9 program
   - Handle results:
     * SCHRK-STATUS = 0: Account found, store SCHRK-IBAN → SAV-IBAN
     * SCHRK-STATUS = 1: Account not found, SAV-IBAN = spaces
     * SCHRK-STATUS other: Error condition, generate PPRNVW error message

3. **Discrepancy Detection**
   - Compare: `SAV-IBAN NOT = TRBFN-IBAN`
   - If different, indicates bank account mismatch

4. **Discrepancy Record Creation** (CREER-REMOTE-500006)
   - Only execute if: `SAV-IBAN NOT = TRBFN-IBAN`
   - Set record header:
     * BBF-N56-LENGTH = 258 bytes
     * BBF-N56-CODE determined by accounting type
     * BBF-N56-DEVICE-OUT = "C" if destination 153, else "L"
     * BBF-N56-SWITCHING = "*"
     * BBF-N56-PRIORITY = space
   - Determine discrepancy list name by accounting type:
     * Type 3: "500076", code 43, destination 151
     * Type 4: "500096", code 43, destination 151
     * Type 5: "500066", code 43, destination 151
     * Type 6: "500086", code 43, destination 151
     * Other, destination 141: "541006", code 40, destination 116
     * Other: "500006", code 40, destination TRBFN-DEST
   - Build record key:
     * BBF-N56-AFK = 2 if type 1/3/4/5/6, else 3
     * BBF-N56-KONST ← TRBFN-CONSTANTE
     * BBF-N56-VOLGNR ← TRBFN-NO-SUITE
   - Populate discrepancy details:
     * BBF-N56-RNR ← WS-RIJKSNUMMER
     * BBF-N56-NAAM ← ADM-NAAM, BBF-N56-VOORN ← ADM-VOORN
     * BBF-N56-BEDRAG ← TRBFN-MONTANT
     * BBF-N56-DV ← TRBFN-MONTANT-DV, BBF-N56-DN = 2 if Euro, else 0
     * BBF-N56-LIBEL ← TRBFN-CODE-LIBEL
   - Handle input IBAN:
     * If TRBFN-IBAN not spaces:
       - BBF-N56-IBAN ← TRBFN-IBAN
       - BBF-N56-REKNR = spaces
     * Else: Both BBF-N56-REKNR and BBF-N56-IBAN = spaces
   - Handle database IBAN:
     * If SAV-IBAN not spaces:
       - BBF-N56-IBAN-MUT ← SAV-IBAN
       - BBF-N56-REKNR-MUT = spaces
     * Else: Both BBF-N56-REKNR-MUT and BBF-N56-IBAN-MUT = spaces
   - Set payment method: BBF-N56-BETWY ← TRBFN-BETWYZ
   - Set regional accounting tags (same logic as main flow)
   - Exception: If BBF-N56-NAME = "541006" (mutual 141), skip ADLOGDBD write (MIS01)
   - Otherwise: Execute `ADLOGDBD` with BFN56CXR structure

### Key Components

- **RECH-NO-BANCAIRE**: Bank account number research paragraph
- **RECHERCHE-CPTE-MEMBRE**: Member account search paragraph
- **CREER-REMOTE-500006**: Discrepancy record creation paragraph
- **BFN56CXR**: Discrepancy list output record structure
- **SCHRKCX9**: External member account search program (via SEPAKCXD copybook)
- **RREBBXDD**: RNR to date conversion copybook
- **DWYERXDD**: Date calculation copybook

### Data Transformations

- **Member RNR** → **Age Calculation** → **Account Holder Lookup**
  * TRBFN-RNR → WS-RNREBC (extract YY, MM, DD components) → RREBBXDD conversion → WS-RNREBCDIC-CC (century)
  * Birth date + 16/14 years → DWYERXDD calculation → WS-DATEBC-2
  * Compare WS-DATEBC-2 vs SP-ACTDAT → SW-TROP-JEUNE flag

- **Account Search** → **IBAN Comparison** → **Discrepancy Detection**
  * TRBFN-CODE-LIBEL → SCHRK-CODE-LIBEL input → SEPAKCXD execution → SCHRK-IBAN output → SAV-IBAN
  * Compare SAV-IBAN vs TRBFN-IBAN → If different, create BFN56CXR record

- **Discrepancy Record Fields**
  * Input IBAN: TRBFN-IBAN → BBF-N56-IBAN (what was provided)
  * Database IBAN: SAV-IBAN → BBF-N56-IBAN-MUT (what's in member record)
  * Shows both values for manual reconciliation

### Decision Points

- **Decision**: Is member old enough to have own account?
  - **Condition**: `SW-TROP-JEUNE = 0` (birth date + 16/14 years ≤ processing date)
  - **Path A (Old enough)**: Search member's own account directly
  - **Path B (Too young)**: Search for parent/guardian account holder in LIDVZ insurance data

- **Decision**: Is account holder (parent) found?
  - **Condition**: `WS-RNREBC NOT = SPACES AND NOT = ZEROES` after LIDVZ search
  - **Path A (Found)**: Lookup holder's member record and account
  - **Path B (Not found)**: No account search performed, SAV-IBAN remains spaces

- **Decision**: Is account found in database?
  - **Condition**: `SCHRK-STATUS = 0` after SEPAKCXD call
  - **Path A (Found)**: Store SCHRK-IBAN → SAV-IBAN
  - **Path B (Not found, status 1)**: SAV-IBAN = spaces
  - **Path C (Error)**: Generate error message via PPRNVW

- **Decision**: Does bank account match?
  - **Condition**: `SAV-IBAN NOT = TRBFN-IBAN`
  - **Path A (Mismatch)**: Create BFN56CXR discrepancy record
  - **Path B (Match)**: No discrepancy record created

- **Decision**: Should discrepancy be logged?
  - **Condition**: `BBF-N56-NAME NOT = "541006"`
  - **Path A (Normal list)**: Execute ADLOGDBD to write record
  - **Path B (List 541006)**: Skip ADLOGDBD (MIS01 - modification per DOCSOL project)

### Dependencies

- **Database**:
  - LIDVZ (member insurance data for account holder lookup)
  - Member database (via SCH-LID, GET-ADM for holder lookup)

- **External Programs**:
  - SCHRKCX9: Member account search (via SEPAKCXD copybook)

- **Copybooks**:
  - SEPAKCXW: Member account search working storage
  - SEPAKCXD: Member account search database call
  - RREBBXDD: RNR to date conversion
  - DWYERXDD: Date year calculation
  - BFN56CXR: Discrepancy list output record structure

---

## Integration Points Summary

### Input Integration
- **TRBFNCXP Records**: Batch input from TRBFNCXB program (PPR records with code 42, name "GIRBET")
- **Member Database**: Real-time lookups during batch processing (MUTF08, main member DB)
- **Parameter Library**: Payment description and type lookup (PAR database)

### Output Integration
- **BBF Database**: Payment module records for tracking and reconciliation
- **Bank Payment Files**: 
  - SEPAAUKU (5N0001): SEPA-compliant bank payment instructions for Belfius/KBC
  - Output routing: Belfius (WELKEBANK=0) for most payments, KBC support deprecated (KVS002)
- **Payment Lists**: 
  - 500001 (BFN51GZR): Successful payment details for processing
  - 5DET01 (BFN51GZR code 43): CSV export for detail flux (JIRA-4224)
  - Regional variants: 500071, 500091, 500061, 500081 for 6th State Reform accounting
- **Rejection Lists**: 
  - 500004 (BFN54GZR): Validation failures and business rule violations
  - Regional variants: 500074, 500094, 500064, 500084
- **Discrepancy Lists**: 
  - 500006 (BFN56CXR): Bank account mismatches between input and member database
  - Regional variants: 500076, 500096, 500066, 500086
- **Special Lists**: 541001, 541004, 541006 for mutual 141

### External Program Integration
- **SEBNKUK9**: IBAN validation and BIC extraction - validates international bank account format and extracts bank identification code
- **CGACVXD9**: Date conversion - converts 2-digit years to 4-digit format (Y2K compliance)
- **SCHRKCX9**: Member account search - retrieves member's registered bank account based on payment type

### Database Integration
- **MUTF08**: Federation member database (accessed by adding 6000000 + federation code to RNRBIN)
  - Used for payment description lookup when code >= 90
  - Parameter library (PAR) contains descriptions and account types
- **Main Member Database**: 
  - SCH-LID: Member search by national registry number
  - GET-ADM: Administrative data (name, address, language)
  - GET-MUT: Mutuality/federation data
  - GET-PTL: Partial data
- **BBF Module**: 
  - GET-BBF: Retrieve existing payment records (for duplicate detection)
  - ADD-BBF: Add new payment record
- **LIDVZ**: Member insurance data (sections, product codes, language preferences, account holders)
- **UAREA**: Database context area (connection and status information)

### Regional Accounting Integration (6th State Reform - JGO001, CDU001)
- **Accounting Type Routing**:
  - Type 1 (General): Standard processing
  - Type 2 (AL): Alternative legal entity accounting
  - Type 3 (Regional OP 1): Federation 167, TAG-REG-OP = 1
  - Type 4 (Regional OP 2): Federation 169, TAG-REG-OP = 2
  - Type 5 (Regional OP 4): Federation 166, TAG-REG-OP = 4
  - Type 6 (Regional OP 7): Federation 168, TAG-REG-OP = 7
- **List Segregation**: Separate output lists for each regional accounting type

### Multi-Language Integration
- **Language Codes**: 1=Dutch, 2=French, 3=German
- **Mutuality-Based Logic**: 
  - French mutualities: 109, 116, 127-136, 167-168
  - Dutch mutualities: 101-102, 104-105, 108, 110-122, 126, 131, 169
  - Bilingual mutualities: 106-107, 150, 166
  - Verviers (trilingual): 137
- **Dynamic Description Selection**: Payment descriptions retrieved in member's preferred language

### SEPA/IBAN Compliance Integration (IBAN10)
- **IBAN Validation**: All bank accounts validated through SEBNKUK9 program
- **BIC Extraction**: Bank identification codes extracted and stored
- **Circular Check Country Validation**: Circular checks (payment methods C/D/E/F) require Belgian address
- **Legacy Account Number**: Belgian IBANs (BE prefix) converted to legacy 12-digit format for compatibility

### Error Handling Integration
- **Database Errors**: All database access operations (SCH-LID, GET-ADM, etc.) check STAT1 status
  - STAT1 = 0: Success
  - STAT1 = 1, 3, 4: Specific conditions (not found, end of file)
  - Other values: Fatal errors trigger PPRNVW error handling and BTMMSG logging
- **Validation Errors**: Business rule violations create rejection records (500004) with diagnostic messages
- **PPRNVW Error Handler**: Centralized error processing and logging mechanism

### Historical Modifications Tracked
- **MTU01**: SC229498 - Removal of description code 70
- **MIS01**: 101222 - DOCSOL project - No longer generate document 541006
- **IBAN10**: 02/2011 - SEPA project adaptations
- **JGO004**: Handle ADM-TAAL = 0 condition
- **Incident #279363**: Use national registry number instead of M-number
- **EVP**: 29/12/2004 - Add CERA → KBC codes (CR-20046151)
- **R140562**: Daily payment via 2 banks (Belfius and KBC) - document 500002 removed
- **EATT**: 20160628 - E-attestation modifications
- **JGO001/CDU001**: 6th State Reform (01/07/2019)
- **KVS001**: JIRA-4224 (02/05/2023) - Detail lines flux 500001 in CSV instead of Papyrus
- **KVS002**: JIRA-4311 (16/06/2023) - PAIFIN-Belfius adaptation
- **MSA001**: JIRA-4837 (20240723) - Correg
- **MSA002**: JIRA-???? (20250130) - Bulk

---

## Coverage Metrics

### Programs Analyzed
- **MYFIN**: Main batch program - 100% analyzed (1,394 lines)

### Copybooks Analyzed
- **TRBFNCXP**: Input payment record - 100%
- **SEPAAUKU**: SEPA user record - 100%
- **BFN51GZR**: Payment detail list - 100%
- **BFN54GZR**: Rejection list - 100%
- **BFN56CXR**: Discrepancy list - 100%
- **BBFPRGZP**: Financial input reference - 100%
- **INFPRGZP**: Info record reference - 100%
- **SEPAKCXW**: Account search working storage - Referenced
- **SEBNKUKW**: IBAN validation working storage - Referenced

### Operations Documented
- **Member Lookup**: SCH-LID, SCH-LID08, GET-ADM - ✓
- **Section Search**: RECHERCHE-SECTION with LIDVZ data - ✓
- **Validation**: Duplicate detection, IBAN validation, age check - ✓
- **Payment Creation**: CREER-BBF, CREER-USER-500001, CREER-REMOTE-500001 - ✓
- **Rejection Handling**: CREER-REMOTE-500004 - ✓
- **Discrepancy Reporting**: CREER-REMOTE-500006, RECH-NO-BANCAIRE - ✓
- **External Calls**: SEBNKUK9, CGACVXD9, SCHRKCX9 - ✓

### Business Logic Patterns
- **Multi-language Support**: Language selection by mutuality code - ✓
- **Regional Accounting**: 6th State Reform routing logic - ✓
- **SEPA Compliance**: IBAN validation and BIC extraction - ✓
- **Duplicate Detection**: Amount and constant matching - ✓
- **Age-Based Account Lookup**: Parent/guardian account for minors - ✓
- **Payment Method Validation**: Circular check country restriction - ✓
- **Date Handling**: Y2K conversion for codes 50/60 - ✓

### Coverage Summary
- **Main Flow**: 100% documented (entry to completion)
- **Rejection Flow**: 100% documented (all error paths)
- **Discrepancy Flow**: 100% documented (account mismatch detection)
- **Database Operations**: 100% documented (all DB access patterns)
- **External Integrations**: 100% documented (all external program calls)
- **Decision Points**: 14+ decision points fully documented with conditions and paths
- **Data Transformations**: 10+ transformation patterns documented with mappings

