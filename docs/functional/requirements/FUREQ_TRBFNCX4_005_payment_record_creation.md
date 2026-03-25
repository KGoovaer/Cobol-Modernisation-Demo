# Functional Requirement: BBF Payment Record and SEPA Instruction Creation

**ID**: FUREQ_MYFIN_005  
**Status**: Draft  
**Priority**: Critical  
**Last Updated**: 2026-01-28

## Traceability

### Business Requirements
- **BUREQ_MYFIN_001**: Member Validation
- **BUREQ_MYFIN_003**: IBAN Validation
- **BUREQ_MYFIN_004**: Multi-Language Support
- **BUREQ_MYFIN_005**: Regional Accounting

### Use Cases
- **UC_MYFIN_001**: Process Manual GIRBET Payment

## Requirement Statement

The system must create payment module (BBF) records and SEPA user payment instructions (SEPAAUKU) for successfully validated payments, populating all required fields including regional accounting tags, bank routing information, and member/payment details for downstream banking systems.

## Detailed Description

### Functional Behavior

After successful validation (member, duplicate, IBAN checks), the system creates two critical records:
1. **BBF Payment Record**: Internal payment module record for tracking and reconciliation
2. **SEPA User Payment Instruction**: Bank-ready payment instruction file (500001/5N0001) for transmission to Belfius/KBC

These records contain complete payment information including member identity, bank account details, payment description, amount, and regional accounting tags required for 6th State Reform compliance.

### Input Specification

All inputs are from previously validated TRBFNCXP record and derived working storage:

| Parameter | Type | Source | Example |
|-----------|------|--------|---------|
| TRBFN-CODE-LIBEL | 9(02) | Input record | 35, 50, 60 |
| TRBFN-MONTANT | S9(08) | Input record | 12500 (= €125.00) |
| TRBFN-MONTANT-DV | X(01) | Input record | "E" (Euro) or "B" (BEF) |
| TRBFN-NO-SUITE | 9(04) | Input record | 0001 |
| TRBFN-CONSTANTE | 9(10) | Input record | 1234567890 |
| TRBFN-IBAN | X(34) | Input record | "BE68539007547034" |
| TRBFN-BETWYZ | X(01) | Input record | ' ' or 'C' |
| TRBFN-TYPE-COMPTA | 9(01) | Input record | 1, 3-6 |
| SP-ACTDAT | 9(08) | System date | 20260128 |
| SAV-WELKEBANK | 9(01) | Derived | 1=Belfius, 2=KBC |
| WS-BIC | X(11) | Derived from IBAN | "GKCCBEBB" |
| SECTION-TROUVEE | 9(03) | Derived | 109, 116, 167 |
| ADM-* fields | Various | Member admin data | Name, address, language |

### Processing Logic

#### 1. BBF Payment Record Creation (CREER-BBF)

**Record Initialization:**
```cobol
INITIALIZE BBF-REC
MOVE 9                TO BBF-TYPE        * Type 9 = Manual GIRBET
MOVE TRBFN-CODE-LIBEL TO BBF-LIBEL       * Payment description code
MOVE TRBFN-MONTANT    TO BBF-BEDRAG      * Amount in cents
MOVE TRBFN-MONTANT-DV TO BBF-BEDRAG-DV   * Currency indicator
MOVE TRBFN-NO-SUITE   TO BBF-VOLGNR      * Sequence number
MOVE TRBFN-CONSTANTE  TO BBF-KONST       * Payment constant
MOVE SP-ACTDAT        TO BBF-DATINB      * Processing date
```

**Date Range Handling (Codes 50, 60):**
- Extract dates from TRBFN-LIBELLE1 and TRBFN-LIBELLE2
- Convert 2-digit years to 4-digit via CGACVXD9 service
- Populate BBF-DATVAN (from date) and BBF-DATTOT (to date)
- Code: [cbl/MYFIN.cbl#L403-L426](../../../cbl/MYFIN.cbl#L403-L426)

**IBAN Processing:**
- Store full IBAN in BBF-IBAN
- If Belgian IBAN (prefix "BE"), extract account number (positions 5-12) to BBF-REKNR
- If non-Belgian IBAN, set BBF-REKNR = ZEROES
- Code: [cbl/MYFIN.cbl#L431-L442](../../../cbl/MYFIN.cbl#L431-L442)

**Regional Accounting Tags:**
```cobol
EVALUATE TRBFN-TYPE-COMPTA
    WHEN 3  * Flemish Community
        MOVE 1   TO BBF-TAGREG-OP
        MOVE 167 TO BBF-VERB
    WHEN 4  * Walloon Community
        MOVE 2   TO BBF-TAGREG-OP
        MOVE 169 TO BBF-VERB
    WHEN 5  * Brussels-Capital Region
        MOVE 4   TO BBF-TAGREG-OP
        MOVE 166 TO BBF-VERB
    WHEN 6  * German-speaking Community
        MOVE 7   TO BBF-TAGREG-OP
        MOVE 168 TO BBF-VERB
    WHEN OTHER  * General accounting
        MOVE 9   TO BBF-TAGREG-OP
        MOVE TRBFN-DEST TO BBF-VERB
END-EVALUATE
```
- Code: [cbl/MYFIN.cbl#L444-L457](../../../cbl/MYFIN.cbl#L444-L457)

**Database Write:**
- Execute PERFORM ADD-BBF to write record to BBF database
- Code: [cbl/MYFIN.cbl#L457](../../../cbl/MYFIN.cbl#L457)

#### 2. SEPA User Payment Instruction Creation (CREER-USER-500001)

**Record Initialization:**
```cobol
INITIALIZE SEPAAUKU
MOVE 475            TO REC-LENGTE        * Record length
MOVE 41             TO REC-CODE          * Record code for SEPA instruction
MOVE "5N0001"       TO USERCOD           * User code for file 500001
MOVE TRBFN-PPR-RNR  TO USERRNR           * Member national registry number
MOVE SECTION-TROUVEE TO USERMY           * Member's mutuality code
```

**Bank Routing Logic:**
```cobol
EVALUATE SAV-WELKEBANK
    WHEN 1  * Belfius routing
        MOVE 0 TO WELKEBANK                    * 0 = Belfius
        IF TRBFN-TYPE-COMPTA = 1 OR 3 OR 4 OR 5 OR 6
            MOVE 13 TO U-BAC-KODE              * AO (General account)
        ELSE
            MOVE 23 TO U-BAC-KODE              * AL (Alternative account)
        END-IF
    WHEN 2  * KBC routing (commented out - regional must use Belfius)
        IF TRBFN-TYPE-COMPTA = 3 OR 4 OR 5 OR 6
            MOVE 0  TO WELKEBANK               * Regional = Belfius only
            MOVE 13 TO U-BAC-KODE
        ELSE
            MOVE 0  TO WELKEBANK               * Also Belfius per KVS002
            IF TRBFN-TYPE-COMPTA = 1
                MOVE 113 TO U-BAC-KODE
            ELSE
                MOVE 123 TO U-BAC-KODE
            END-IF
        END-IF
END-EVALUATE
```
- Code: [cbl/MYFIN.cbl#L485-L523](../../../cbl/MYFIN.cbl#L485-L523)

**Payment Control Fields:**
```cobol
MOVE 1 TO ALOIS-RAF                     * ALOIS reference flag
MOVE ADM-TAAL TO TAAL                   * Language code
IF TRBFN-CODE-LIBEL = 60
    MOVE 1 TO BAC-DATM61                * Special handling for code 60
ELSE
    IF TRBFN-TYPE-COMPTA = 1 OR 3 OR 4 OR 5 OR 6
        MOVE ZEROES TO BAC-DATM61       * Normal processing
    ELSE
        MOVE 2 TO BAC-DATM61            * Alternative processing
    END-IF
END-IF
MOVE SP-ACTDAT TO U-ACTDAT              * Processing date
```
- Code: [cbl/MYFIN.cbl#L524-L539](../../../cbl/MYFIN.cbl#L524-L539)

**Member Information:**
- Bank account holder: Concatenate ADM-NAAM + ADM-VOORN
- Bank account country: ADM-LND
- Bank postal code/city: ADM-POSTNR, ADM-GEM
- Member administrative address: Full address from ADM fields
- Code: [cbl/MYFIN.cbl#L540-L556](../../../cbl/MYFIN.cbl#L540-L556)

**Payment Description (COMMENTAAR field):**
- Code 35: "[Description] - [Member name]"
- Codes 50, 60: "[Description] [FromDate] AU/TOT/BIS [ToDate]"
- Other codes: Direct payment description (SAV-LIBELLE)
- Reference field: "O.REF:" (FR), "N.REF:" (NL), or "U.KENZ:" (DE)
- Constant and sequence number included
- Code: [cbl/MYFIN.cbl#L557-L599](../../../cbl/MYFIN.cbl#L557-L599)

**Regional Accounting Tags:**
```cobol
EVALUATE TRBFN-TYPE-COMPTA
    WHEN 3  MOVE 1   TO TAG-REG-OP TAG-REG-LEG
            MOVE 167 TO USERFED VRBOND
    WHEN 4  MOVE 2   TO TAG-REG-OP TAG-REG-LEG
            MOVE 169 TO USERFED VRBOND
    WHEN 5  MOVE 4   TO TAG-REG-OP TAG-REG-LEG
            MOVE 166 TO USERFED VRBOND
    WHEN 6  MOVE 7   TO TAG-REG-OP TAG-REG-LEG
            MOVE 168 TO USERFED VRBOND
    WHEN OTHER MOVE 9   TO TAG-REG-OP TAG-REG-LEG
            MOVE TRBFN-DEST TO USERFED VRBOND
END-EVALUATE
```
- Code: [cbl/MYFIN.cbl#L602-L616](../../../cbl/MYFIN.cbl#L602-L616)

**File Write:**
- Execute COPY ADLOGDBD to write SEPAAUKU record to file 500001/5N0001
- Code: [cbl/MYFIN.cbl#L617-L618](../../../cbl/MYFIN.cbl#L617-L618)

### Output Specification

**Success Output:**
- BBF-REC written to payment module database
- SEPAAUKU record written to file 500001 (or 5N0001)
- Both records contain matching payment information
- Regional accounting tags correctly populated for 6th State Reform compliance
- Bank routing correctly set (Belfius for regional, Belfius or KBC for general)

## Technical Constraints

- **Performance**: Record creation must not significantly impact batch processing time
- **Database Transaction**: BBF record creation participates in transaction (rollback on error)
- **Regional Mandate**: Types 3-6 MUST use Belfius (WELKEBANK = 0), no KBC option
- **Date Conversion**: 2-digit year conversion requires CGACVXD9 service
- **IBAN Length**: Maximum 34 characters per SEPA standard

## Data Structures

### BBF-REC (Payment Module Record)

```cobol
      * BBF Payment Module Record (from BBFPRGZP copybook)
       01  BBF-REC.
           05  BBF-TYPE            PIC 9.         * Payment type: 9=Manual GIRBET
           05  BBF-LIBEL           PIC 9(02).     * Payment description code
           05  BBF-BEDRAG          PIC S9(08).    * Amount in cents
           05  BBF-BEDRAG-DV       PIC X(01).     * Currency: "E"=Euro, "B"=BEF
           05  BBF-VOLGNR          PIC 9(04).     * Sequence number
           05  BBF-KONST           PIC 9(10).     * Payment constant
           05  BBF-DATINB          PIC 9(08).     * Processing date (CCYYMMDD)
           05  BBF-DATVAN.                        * From date (for codes 50, 60)
               10  BBF-DATVAN-DD   PIC 9(02).
               10  BBF-DATVAN-MM   PIC 9(02).
               10  BBF-DATVAN-CCYY PIC 9(04).
           05  BBF-DATTOT.                        * To date (for codes 50, 60)
               10  BBF-DATTOT-DD   PIC 9(02).
               10  BBF-DATTOT-MM   PIC 9(02).
               10  BBF-DATTOT-CCYY PIC 9(04).
           05  BBF-INFOREK         PIC 9(08).     * INFOREK reference (zeroes)
           05  BBF-LINKNR          PIC 9(08).     * Link number (zeroes)
           05  BBF-CODE-MAF        PIC X(06).     * MAF code (spaces)
           05  BBF-JAAR-MAF        PIC 9(04).     * MAF year (zeroes)
           05  BBF-IBAN            PIC X(34).     * Full IBAN
           05  BBF-REKNR           PIC 9(12).     * Belgian account number (from IBAN)
           05  BBF-BETWY           PIC X(01).     * Payment method
           05  BBF-TAGREG-OP       PIC 9(01).     * Regional tag (1,2,4,7,9)
           05  BBF-VERB            PIC 9(03).     * Federation code
      
      * Regional tag values (6th State Reform):
      * - 1: Flemish Community (federation 167)
      * - 2: Walloon Community (federation 169)
      * - 4: Brussels-Capital Region (federation 166)
      * - 7: German-speaking Community (federation 168)
      * - 9: General accounting (federation = TRBFN-DEST)
```

### SEPAAUKU (SEPA User Payment Instruction)

```cobol
      * SEPA User Payment Instruction (from SEPAAUKU copybook)
       01  SEPAAUKU.
           05  REC-LENGTE          PIC S9(04) COMP.  * Record length: 475 bytes
           05  REC-CODE            PIC S9(04) COMP.  * Record code: 41
           05  USERCOD             PIC X(06).        * "5N0001"
           05  USERRNR             PIC S9(08) COMP.  * Member national registry
           05  USERFED             PIC 9(03).        * Federation code
           05  USERMY              PIC 9(03).        * Mutuality code
           05  WELKEBANK           PIC 9(01).        * Bank: 0=Belfius, 1=KBC
           05  U-BAC-KODE          PIC 9(03).        * Bank account code
           05  ALOIS-RAF           PIC 9(01).        * ALOIS reference flag
           05  VRBOND              PIC 9(03).        * Federation bond
           05  TAAL                PIC 9(01).        * Language: 1=FR, 2=NL, 3=DE
           05  BAC-DATM61          PIC 9(01).        * Payment control flag
           05  U-ACTDAT            PIC 9(08).        * Processing date
           05  U-IBAN              PIC X(34).        * IBAN
           05  U-BNK-REKHOUDER     PIC X(70).        * Account holder name
           05  U-BNK-LND           PIC X(02).        * Country code
           05  U-BNK-POSTNR        PIC X(08).        * Postal code
           05  U-BNK-GEM           PIC X(40).        * City/municipality
           05  U-ADM-NAAM          PIC X(30).        * Member last name
           05  U-ADM-VNAAM         PIC X(20).        * Member first name
           05  U-ADM-STR           PIC X(30).        * Street
           05  U-ADM-HUIS          PIC X(06).        * House number
           05  U-ADM-INDEX         PIC X(01).        * Index
           05  U-ADM-BUS           PIC X(06).        * Box number
           05  U-ADM-LND           PIC X(02).        * Country
           05  U-ADM-POST          PIC X(08).        * Postal code
           05  U-ADM-GEM           PIC X(40).        * City
           05  COMMENTAAR          PIC X(106).       * Payment description
           05  NETBEDRAG           PIC S9(08).       * Net amount in cents
           05  REC-DV              PIC X(01).        * Currency indicator
           05  U-BETWYZ            PIC X(01).        * Payment method
           05  U-BIC               PIC X(11).        * BIC code
           05  TAG-REG-OP          PIC 9(01).        * Regional tag (operations)
           05  TAG-REG-LEG         PIC 9(01).        * Regional tag (legal)
      
      * Bank account codes:
      * - 13/113: AO account (General/Regional)
      * - 23/123: AL account (Alternative)
```

### Working Storage Variables

```cobol
       01  SAV-LIB1.                          * Date extraction from LIBELLE1
           05  SAV-DATE1-DMY.
               10  SAV-DATE1-DD    PIC 99.
               10  SAV-DATE1-MM    PIC 99.
               10  SAV-DATE1-YY    PIC 99.
           05  FILLER              PIC X(8).

       01  SAV-LIB2.                          * Date extraction from LIBELLE2
           05  SAV-DATE2-DMY.
               10  SAV-DATE2-DD    PIC 99.
               10  SAV-DATE2-MM    PIC 99.
               10  SAV-DATE2-YY    PIC 99.
           05  FILLER              PIC X(8).

       01  COMMENT                 PIC X(106). * SEPA comment field construction
       01  COMMENT1 REDEFINES COMMENT.
           05  BANK-VELD1          PIC X(53).
           05  REF-VELD1           PIC X(07).
           05  KONSTANTE-VELD1     PIC 9(10).
           05  VOLGNR-VELD1        PIC 9(03).
           05  FILLER              PIC X.
           05  OMSCH1-VELD1        PIC X(14).
           05  FILLER              PIC X.
           05  OMSCH2-VELD1        PIC X(14).
           05  FILLER              PIC X(03).
```

## Validation Rules

| Field | Rule | Error Code | Error Message |
|-------|------|------------|---------------|
| BBF-TYPE | Must be 9 | N/A | (Hardcoded in program) |
| TRBFN-TYPE-COMPTA | Regional (3-6) must use Belfius | N/A | (Enforced in bank routing) |
| REC-CODE | Must be 41 | N/A | (Hardcoded in program) |

## Error Handling

### Error Scenarios

1. **BBF Database Write Failure**
   - **Trigger**: ADD-BBF operation fails (database error)
   - **Action**: Transaction rollback, payment not recorded
   - **Logging**: Database error logged to system logs
   - **Recovery**: Depends on system configuration (may ABEND)

2. **SEPA File Write Failure**
   - **Trigger**: COPY ADLOGDBD operation fails (file write error)
   - **Action**: System error, file not written
   - **Logging**: Error logged to system logs
   - **Recovery**: Depends on system configuration

3. **Date Conversion Failure (CGACVXD9)**
   - **Trigger**: Invalid 2-digit year in TRBFN-LIBELLE1/2
   - **Action**: Conversion service error
   - **Logging**: Error logged
   - **Recovery**: May use default date or reject payment

## Integration Points

### Database

**Files/Records:**
- BBF (Payment Module Database): WRITE operations
  - Source: [cbl/MYFIN.cbl#L457](../../../cbl/MYFIN.cbl#L457) - PERFORM ADD-BBF
  - Copybook: [copy/bbfprgzp.cpy](../../../copy/bbfprgzp.cpy)
  - Purpose: Store payment record for tracking and reconciliation
  - Transaction: Participates in database transaction

### External Systems

**CGACVXD9 (Date Conversion Service):**
- **Type**: External CALL for date conversion
- **Purpose**: Convert 2-digit years to 4-digit (Y2K compliance)
- **Interface**: CGACVT-AREA working storage
- **Usage**: Only for payment codes 50 and 60 with date ranges
- **Code**: [cbl/MYFIN.cbl#L410](../../../cbl/MYFIN.cbl#L410), [cbl/MYFIN.cbl#L417](../../../cbl/MYFIN.cbl#L417)

**SEPA Payment File (500001/5N0001):**
- **Type**: Sequential file output via COPY ADLOGDBD
- **Purpose**: SEPA payment instructions for bank transmission
- **Interface**: SEPAAUKU copybook structure
- **Destination**: Belfius or KBC banking systems
- **Code**: [cbl/MYFIN.cbl#L617-L618](../../../cbl/MYFIN.cbl#L617-L618)

## Configuration

| Parameter | Source | Required | Default | Description |
|-----------|--------|----------|---------|-------------|
| SP-ACTDAT | System date | Yes | Current date | Processing date (CCYYMMDD) |
| SAV-WELKEBANK | Derived earlier | Yes | 1 | Bank selection: 1=Belfius, 2=KBC |
| WS-BIC | Extracted from IBAN | Yes | N/A | BIC code for SEPA instruction |

## Implementation Notes

### Code References

- **BBF Record Creation**: 
  - Source: [cbl/MYFIN.cbl#L389-L458](../../../cbl/MYFIN.cbl#L389-L458) - CREER-BBF paragraph
- **SEPA Instruction Creation**: 
  - Source: [cbl/MYFIN.cbl#L464-L619](../../../cbl/MYFIN.cbl#L464-L619) - CREER-USER-500001 paragraph
- **Date Conversion**: 
  - Source: [cbl/MYFIN.cbl#L410-L423](../../../cbl/MYFIN.cbl#L410-L423) - CGACVXD9 calls
- **Regional Accounting Tags**: 
  - BBF: [cbl/MYFIN.cbl#L444-L456](../../../cbl/MYFIN.cbl#L444-L456)
  - SEPA: [cbl/MYFIN.cbl#L602-L616](../../../cbl/MYFIN.cbl#L602-L616)

### Design Patterns Used

- **Record Initialization**: INITIALIZE statement clears all fields before population
- **Conditional Date Handling**: Special processing for payment codes 50 and 60
- **Regional Enforcement**: EVALUATE logic ensures correct regional tags and federation codes
- **Bank Routing Enforcement**: Regional payments (3-6) forced to Belfius regardless of other logic
- **Multilingual Comment Construction**: Language-specific reference labels (O.REF, N.REF, U.KENZ)

### Dependencies

- **Copybooks**: 
  - BBFPRGZP.cpy: BBF payment module record structure
  - SEPAAUKU.cpy: SEPA user payment instruction structure
  - ADLOGDBD: File write operation template
  - CGACVXSW: Date conversion working storage
- **Called Programs**: 
  - CGACVXD9: Y2K-compliant date conversion service
- **System Services**: 
  - Database access for BBF record writes
  - File I/O for SEPA instruction file

## Test Scenarios

### Positive Tests

1. **Standard payment - general accounting**
   - Input: TRBFN-TYPE-COMPTA = 1, all fields valid
   - Expected: BBF-REC created with BBF-TAGREG-OP = 9, BBF-VERB = TRBFN-DEST; SEPAAUKU created with TAG-REG-OP = 9

2. **Regional payment - Flemish**
   - Input: TRBFN-TYPE-COMPTA = 3, valid payment
   - Expected: BBF-REC with BBF-TAGREG-OP = 1, BBF-VERB = 167; SEPAAUKU with TAG-REG-OP = 1, USERFED = 167, WELKEBANK = 0

3. **Payment with date range (code 50)**
   - Input: TRBFN-CODE-LIBEL = 50, TRBFN-LIBELLE1 = "01012300000000", TRBFN-LIBELLE2 = "31012300000000"
   - Expected: BBF-DATVAN = 01/01/2023, BBF-DATTOT = 31/01/2023 (after CGACVXD9 conversion)

4. **Belgian IBAN account number extraction**
   - Input: TRBFN-IBAN = "BE68539007547034"
   - Expected: BBF-REKNR = 539007547034 (extracted from positions 5-12)

5. **Non-Belgian IBAN**
   - Input: TRBFN-IBAN = "FR7630006000011234567890189"
   - Expected: BBF-REKNR = ZEROES (no extraction)

### Negative Tests

1. **BBF database write fails**
   - Scenario: Database unavailable during ADD-BBF
   - Expected: Transaction rollback, error logged, payment not processed

2. **SEPA file write fails**
   - Scenario: File system error during COPY ADLOGDBD
   - Expected: Error logged, payment may be inconsistent (BBF created but SEPA not)

3. **Date conversion service unavailable**
   - Input: TRBFN-CODE-LIBEL = 50, CGACVXD9 service fails
   - Expected: Conversion error, may use default or reject payment

## Acceptance Criteria

- [x] BBF payment record created with all required fields populated
- [x] SEPA user payment instruction created with matching payment information
- [x] Regional accounting tags correctly set based on TRBFN-TYPE-COMPTA
- [x] Regional payments (types 3-6) routed to Belfius (WELKEBANK = 0)
- [x] Belgian IBAN account numbers extracted to BBF-REKNR
- [x] Date range processing for codes 50 and 60 with Y2K-compliant conversion
- [x] Multilingual comment field constructed with appropriate language markers
- [x] Bank routing logic correctly implements Belfius vs. KBC selection
- [x] Payment constant and sequence number included for traceability
- [x] Member administrative information populated in SEPA instruction

## Open Issues

- [ ] Confirm transaction scope (does SEPA file write participate in BBF transaction?)
- [ ] Document KBC routing conditions (currently commented out, Belfius only per KVS002)
- [ ] Clarify BAC-DATM61 flag values and their meaning (0, 1, 2)
- [ ] Confirm INFOREK, LINKNR, CODE-MAF, JAAR-MAF always zeroes/spaces
