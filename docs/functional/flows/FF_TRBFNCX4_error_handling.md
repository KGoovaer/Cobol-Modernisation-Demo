# Functional Flow: MYFIN Error Handling

**ID**: FF_MYFIN_002  
**Related Use Case**: UC_MYFIN_002  
**Last Updated**: 2026-01-29

## Overview

This flow documents the comprehensive error handling mechanisms in the MYFIN batch program. The program implements a "fail-fast" validation strategy, terminating processing at the first validation failure and generating bilingual diagnostic messages on rejection lists. Error handling covers member validation, duplicate detection, IBAN validation, language code determination, payment description retrieval, circular check validation, and database operation failures.

## Error Classification

### Critical Errors (Program Termination)
- Database access failures (STAT1 errors)
- Member not found
- Invalid language code (unable to determine)
- Invalid payment description code (code >= 90 not found)

### Validation Errors (Record Rejection)
- Duplicate payment detected
- Invalid IBAN format
- Circular check for non-Belgian address
- Bank account discrepancy (informational - list 500006)

### System Errors
- Database operation errors (SCH-LID, GET-ADM, ADD-BBF, etc.)
- External program call failures (SEBNKUK9, SCHRKCX9)

## Error Flow Diagram

```mermaid
flowchart TD
    Start[Record Processing Start] --> MemberLookup{SCH-LID<br/>Member Found?}
    
    MemberLookup -->|STAT1 ≠ 0| MemberError[PPRNVW Error Handler]
    MemberError --> Exit1[EXIT PROGRAM]
    
    MemberLookup -->|STAT1 = 0| SectionSearch[RECHERCHE-SECTION]
    SectionSearch --> GetAdm[GET-ADM]
    
    GetAdm --> LangCheck{ADM-TAAL<br/>Valid?}
    LangCheck -->|ADM-TAAL = 0| SectionLang{Section<br/>Language<br/>Available?}
    
    SectionLang -->|Yes| UseSectionLang[Use WS-LIDVZ-xx-TAAL]
    SectionLang -->|No| LangError[BBF-N54-DIAG =<br/>"TAALCODE ONBEKEND/<br/>CODE LANGUE INCONNU"]
    LangError --> List500004_1[CREER-REMOTE-500004]
    List500004_1 --> Exit2[FIN-BTM]
    
    UseSectionLang --> CodeLibel{Code Libel<br/>Range?}
    LangCheck -->|ADM-TAAL ≠ 0| CodeLibel
    
    CodeLibel -->|>= 90| DBLookup[SCH-LID08 +<br/>GET-PAR Loop]
    DBLookup --> DescFound{Description<br/>Found?}
    
    DescFound -->|No<br/>STAT1 ≠ 0| DescError[BBF-N54-DIAG =<br/>"ONBEK. OMSCHR./<br/>LIBELLE INCONNU"]
    DescError --> List500004_2[CREER-REMOTE-500004]
    List500004_2 --> Exit3[FIN-BTM]
    
    DescFound -->|Yes| DuplicateCheck
    CodeLibel -->|< 90| TableLookup[TBLIBCXW Lookup]
    TableLookup --> DuplicateCheck[VOIR-DOUBLES]
    
    DuplicateCheck --> DupLoop{Loop through<br/>BBF Records}
    DupLoop --> DupCheck{Same Amount<br/>& Constant?}
    
    DupCheck -->|Yes| DupError[BBF-N54-DIAG =<br/>"DUBBELE BETALING/<br/>DOUBLE PAIEMENT"]
    DupError --> List500004_3[CREER-REMOTE-500004]
    List500004_3 --> Exit4[FIN-BTM]
    
    DupCheck -->|No| NextBBF[GET-BBF GETTP=2]
    NextBBF --> DupLoop
    
    DupLoop -->|STAT1 ≠ 0<br/>No more records| BankVal[VOIR-BANQUE-DEBIT]
    BankVal --> CallSebnk[Call SEBNKUK9]
    
    CallSebnk --> SebnkError{SCHRK-STATUS<br/>Valid?}
    SebnkError -->|NOT = 0<br/>AND NOT = 1| SebnkSysError[String error message<br/>to BTMMSG]
    SebnkSysError --> PPRNVW1[PPRNVW]
    PPRNVW1 --> Exit5[EXIT PROGRAM]
    
    SebnkError -->|= 0 or 1| IbanCheck{IBAN<br/>Valid?}
    
    IbanCheck -->|WS-SEBNK-WELKEBANK ≠ 0<br/>OR<br/>WS-SEBNK-STAT-OUT<br/>NOT = 0/1/2| IbanError[BBF-N54-DIAG =<br/>"IBAN FOUTIEF/<br/>IBAN ERRONE"]
    IbanError --> List500004_4[CREER-REMOTE-500004]
    List500004_4 --> Exit6[FIN-BTM]
    
    IbanCheck -->|Valid| BBFCreate[CREER-BBF]
    BBFCreate --> AddBBF[ADD-BBF]
    
    AddBBF --> BBFError{STAT1<br/>= 0?}
    BBFError -->|STAT1 ≠ 0| BBFSysError[String error message<br/>to BTMMSG]
    BBFSysError --> PPRNVW2[PPRNVW]
    PPRNVW2 --> Exit7[EXIT PROGRAM]
    
    BBFError -->|STAT1 = 0| CircCheck{Circular<br/>Check?}
    
    CircCheck -->|BETWYZ = C/D/E/F<br/>AND<br/>ADM-LND ≠ "B  "| CircError[BBF-N54-DIAG =<br/>"CC - PAYS/LAND<br/>NOT = B"]
    CircError --> List500004_5[CREER-REMOTE-500004]
    List500004_5 --> Exit8[FIN-BTM]
    
    CircCheck -->|Valid| AcctCheck{COMPTE-<br/>MEMBRE<br/>= 0?}
    
    AcctCheck -->|Yes| RecknrLookup[RECHERCHE-RECKNR<br/>Call SCHRKCX9]
    RecknrLookup --> RecknrError{SCHRK-STATUS<br/>Valid?}
    
    RecknrError -->|NOT = 0<br/>AND NOT = 1| RecknrSysError[String error message<br/>to BTMMSG]
    RecknrSysError --> PPRNVW3[PPRNVW]
    PPRNVW3 --> Exit9[EXIT PROGRAM]
    
    RecknrError -->|= 0 or 1| IbanCompare{Input IBAN<br/>≠<br/>Known IBAN?}
    
    IbanCompare -->|Yes| Discrepancy[CREER-REMOTE-500006<br/>Discrepancy Report]
    Discrepancy --> UserRecord
    
    IbanCompare -->|No| UserRecord
    AcctCheck -->|No| UserRecord[CREER-USER-500001]
    
    UserRecord --> List500001[CREER-REMOTE-500001]
    List500001 --> Success[Return Success]
    
    style Exit1 fill:#ff6b6b
    style Exit2 fill:#ff6b6b
    style Exit3 fill:#ff6b6b
    style Exit4 fill:#ff6b6b
    style Exit5 fill:#ff6b6b
    style Exit6 fill:#ff6b6b
    style Exit7 fill:#ff6b6b
    style Exit8 fill:#ff6b6b
    style Exit9 fill:#ff6b6b
    style Success fill:#51cf66
    style List500004_1 fill:#ffd43b
    style List500004_2 fill:#ffd43b
    style List500004_3 fill:#ffd43b
    style List500004_4 fill:#ffd43b
    style List500004_5 fill:#ffd43b
    style Discrepancy fill:#74c0fc
```

## Detailed Error Scenarios

### 1. Member Not Found Error

**Error Type**: Critical - Program Termination  
**Code Location**: [cbl/MYFIN.cbl#L190-L195](../../../cbl/MYFIN.cbl#L190)  
**Related Requirement**: FUREQ_MYFIN_001

**Trigger Condition**:
```cobol
MOVE TRBFN-PPR-RNR TO RNRBIN
PERFORM SCH-LID
IF STAT1 NOT = ZEROES
```

**Error Handling**:
```cobol
IF STAT1 NOT = ZEROES
THEN
    PERFORM PPRNVW
END-IF
```

**PPRNVW Error Handler** (conceptual - actual implementation in COPY statement):
- Writes error message to batch output log
- Potentially writes to error file
- Sets return code for batch job
- Triggers program termination (EXIT PROGRAM)

**Impact**: 
- Payment record is not processed
- No BBF record created
- No payment lists generated
- Batch job may continue with next record (framework-dependent)

**Recovery**: 
- Manual investigation required
- Verify national registry number (TRBFN-PPR-RNR) exists in MUTF08
- Correct input data and resubmit

---

### 2. Language Code Unknown Error

**Error Type**: Validation Error - Record Rejection  
**Code Location**: [cbl/MYFIN.cbl#L202-L217](../../../cbl/MYFIN.cbl#L202)  
**Related Requirement**: FUREQ_MYFIN_001

**Trigger Condition**:
```cobol
MOVE 1 TO GETTP
PERFORM GET-ADM
IF ADM-TAAL = 0
    IF WS-LIDVZ-AP-TAAL NOT = 0
        MOVE WS-LIDVZ-AP-TAAL TO ADM-TAAL
    ELSE
        IF WS-LIDVZ-OP-TAAL NOT = 0
            MOVE WS-LIDVZ-OP-TAAL TO ADM-TAAL
        ELSE
            * ERROR: No language code available
```

**Error Handling**:
```cobol
MOVE "TAALCODE ONBEKEND/CODE LANGUE INCONNU" TO BBF-N54-DIAG
PERFORM CREER-REMOTE-500004
PERFORM FIN-BTM
```

**Rejection List (500004) Record**:
- **BBF-N54-DIAG**: "TAALCODE ONBEKEND/CODE LANGUE INCONNU"
- **List Name**: "500004" (or regional variant based on TRBFN-TYPE-COMPTA)
- **Additional Data**: National registry, payment amount, constant, sequence number

**Root Cause**: 
- Member has no language code in administrative data (ADM-TAAL = 0)
- No language code found in active section data (WS-LIDVZ-AP-TAAL = 0)
- No language code found in open section data (WS-LIDVZ-OP-TAAL = 0)

**Recovery**: 
- Update member's administrative data with language preference
- Update member's section data with language code
- Resubmit payment after data correction

---

### 3. Payment Description Not Found Error

**Error Type**: Validation Error - Record Rejection  
**Code Location**: [cbl/MYFIN.cbl#L275-L281](../../../cbl/MYFIN.cbl#L275)  
**Related Requirement**: FUREQ_MYFIN_001

**Trigger Condition**:
```cobol
IF TRBFN-CODE-LIBEL NOT < 90
    MOVE TRBFN-DEST TO TEST-MUTUALITE
    MOVE RNRBIN TO SAV-RNRBIN
    ADD 6000000 TRBFN-DEST GIVING RNRBIN
    PERFORM SCH-LID08
    IF STAT1 = ZEROES OR = 4
        MOVE 1 TO GETTP
        PERFORM GET-PAR
        PERFORM WITH TEST BEFORE UNTIL
        STAT1 NOT = ZEROES OR
        LIBP-NRLIB = TRBFN-CODE-LIBEL
            MOVE 2 TO GETTP
            PERFORM GET-PAR
        END-PERFORM
    END-IF
    * If STAT1 ≠ 0 after loop, description not found
```

**Error Handling**:
```cobol
IF STAT1 = ZEROES
THEN
    * Description found - process normally
ELSE
    MOVE "ONBEK. OMSCHR./LIBELLE INCONNU" TO BBF-N54-DIAG
    PERFORM CREER-REMOTE-500004
    PERFORM FIN-BTM
END-IF
```

**Rejection List (500004) Record**:
- **BBF-N54-DIAG**: "ONBEK. OMSCHR./LIBELLE INCONNU"
- **Additional Context**: Payment code (TRBFN-CODE-LIBEL), destination federation

**Root Cause**: 
- Payment description code (TRBFN-CODE-LIBEL >= 90) not found in parameter library
- Configured RNRBIN (6000000 + TRBFN-DEST) does not exist in MUTF08
- LIBP-NRLIB table has no matching entry for this code

**Recovery**: 
- Verify payment description code is valid for the destination mutuality
- Add missing description to parameter library
- Use payment code < 90 if appropriate (uses TBLIBCXW table instead)
- Resubmit after data correction

---

### 4. Duplicate Payment Error

**Error Type**: Validation Error - Record Rejection  
**Code Location**: [cbl/MYFIN.cbl#L292](../../../cbl/MYFIN.cbl#L292) (VOIR-DOUBLES paragraph)  
**Related Requirement**: FUREQ_MYFIN_002

**Trigger Condition**:
```cobol
VOIR-DOUBLES.
    MOVE 1 TO GETTP
    PERFORM GET-BBF
    PERFORM WITH TEST BEFORE UNTIL STAT1 NOT = ZEROES
        IF (TRBFN-MONTANT = BBF-BEDRAG) AND
           (TRBFN-CONSTANTE = BBF-KONST)
            * DUPLICATE FOUND
```

**Error Handling**:
```cobol
IF (TRBFN-MONTANT = BBF-BEDRAG) AND
   (TRBFN-CONSTANTE = BBF-KONST)
THEN
    MOVE "DUBBELE BETALING/DOUBLE PAIEMENT" TO BBF-N54-DIAG
    PERFORM CREER-REMOTE-500004
    PERFORM FIN-BTM
END-IF
```

**Rejection List (500004) Record**:
- **BBF-N54-DIAG**: "DUBBELE BETALING/DOUBLE PAIEMENT"
- **Duplicate Criteria**: Same amount AND same payment constant
- **Additional Data**: Shows both input payment and existing payment details

**Business Impact**: 
- Prevents double payment to member
- Original payment remains in BBF database
- Duplicate request is rejected and documented

**Root Cause**: 
- Same payment already recorded in BBF database for this member
- Matching TRBFN-MONTANT (amount) and TRBFN-CONSTANTE (payment identifier)

**Recovery**: 
- Verify if duplicate is intentional (e.g., two different payments with same amount)
- If intentional, use different payment constant
- If error, remove duplicate input record
- If original was incorrect, delete BBF record first, then resubmit

---

### 5. Invalid IBAN Error

**Error Type**: Validation Error - Record Rejection  
**Code Location**: [cbl/MYFIN.cbl#L343-L358](../../../cbl/MYFIN.cbl#L343)  
**Related Requirement**: FUREQ_MYFIN_003

**Trigger Condition**:
```cobol
VOIR-BANQUE-DEBIT.
    MOVE SPACES TO WS-BIC
    MOVE TRBFN-IBAN TO WS-SEBNK-IBAN-IN
    MOVE TRBFN-BETWYZ TO WS-SEBNK-BETWYZ-IN
    PERFORM WELKE-BANK
    
    IF (WS-SEBNK-WELKEBANK = 0 AND 
        WS-SEBNK-STAT-OUT = (0 OR 1 OR 2))
    THEN
        MOVE WS-SEBNK-BIC-OUT TO WS-BIC
    ELSE
        * INVALID IBAN
```

**Error Handling**:
```cobol
IF (WS-SEBNK-WELKEBANK = 0 AND WS-SEBNK-STAT-OUT = (0 OR 1 OR 2))
THEN
    MOVE WS-SEBNK-BIC-OUT TO WS-BIC
ELSE
    MOVE "IBAN FOUTIEF/IBAN ERRONE" TO BBF-N54-DIAG
    PERFORM CREER-REMOTE-500004
END-IF
```

**Rejection List (500004) Record**:
- **BBF-N54-DIAG**: "IBAN FOUTIEF/IBAN ERRONE"
- **Invalid IBAN**: TRBFN-IBAN value included in rejection record
- **SEBNK Status**: WS-SEBNK-STAT-OUT and WS-SEBNK-WELKEBANK logged for diagnostic

**SEBNKUK9 Validation Results**:
- **WS-SEBNK-STAT-OUT = 0**: Valid IBAN, BIC extracted successfully
- **WS-SEBNK-STAT-OUT = 1**: Valid IBAN format, warning condition
- **WS-SEBNK-STAT-OUT = 2**: Valid IBAN format, informational
- **WS-SEBNK-STAT-OUT > 2**: Invalid IBAN format → Rejection
- **WS-SEBNK-WELKEBANK ≠ 0**: Invalid bank routing → Rejection

**Root Cause**: 
- IBAN format validation failed (checksum, length, country code)
- Bank routing could not be determined
- IBAN does not conform to SEPA standards

**Recovery**: 
- Verify IBAN format (correct country code, check digits, length)
- Validate IBAN with external tool or bank
- Correct TRBFN-IBAN in input record
- Resubmit payment with valid IBAN

---

### 6. Circular Check Country Validation Error

**Error Type**: Validation Error - Record Rejection  
**Code Location**: [cbl/MYFIN.cbl#L295-L301](../../../cbl/MYFIN.cbl#L295)  
**Related Requirement**: FUREQ_MYFIN_001

**Trigger Condition**:
```cobol
IF (TRBFN-BETWYZ = "C" OR "D" OR "E" OR "F") AND
   (ADM-LND <> "B  ")
```

**Error Handling**:
```cobol
IF (TRBFN-BETWYZ = "C" OR "D" OR "E" OR "F") AND
   (ADM-LND <> "B  ")
THEN
    MOVE "CC - PAYS/LAND NOT = B        " TO BBF-N54-DIAG
    PERFORM CREER-REMOTE-500004
    PERFORM FIN-BTM
END-IF
```

**Rejection List (500004) Record**:
- **BBF-N54-DIAG**: "CC - PAYS/LAND NOT = B        "
- **Payment Method**: TRBFN-BETWYZ value (C/D/E/F)
- **Country Code**: ADM-LND value (non-Belgian)

**Business Rule**: 
- Circular checks (BETWYZ = C/D/E/F) can only be issued to Belgian addresses
- SEPA payments (BETWYZ = space) have no country restriction

**Root Cause**: 
- Member's country code (ADM-LND) is not "B  " (Belgium)
- Payment method is circular check (C/D/E/F)
- Circular checks cannot be delivered to foreign addresses

**Recovery**: 
- Change payment method from circular check to SEPA transfer (TRBFN-BETWYZ = space)
- Update member's address to Belgian country if incorrect
- Cancel payment if circular check is required but member is abroad

---

### 7. Database Operation Errors

**Error Type**: Critical - Program Termination  
**Code Location**: Multiple locations (PAR-MUT section)  
**Related Requirement**: All requirements

#### SCH-LID Error (Member Search)
**Code**: [cbl/MYFIN.cbl#L1308-L1319](../../../cbl/MYFIN.cbl#L1308)

```cobol
SCH-LID.
    MOVE ZEROES TO STAT1
    COPY SCHLDDBD.
    IF STAT1 NOT = ZEROES AND NOT = 1 AND NOT = 4
    THEN
        MOVE SPACES TO BTMMSG
        STRING "ERREUR SCHLDDBD STAT1 = " DELIMITED BY SIZE
               STAT1 DELIMITED BY SIZE INTO BTMMSG
        END-STRING
        PERFORM PPRNVW
    END-IF
```

**Expected STAT1 Values**:
- **0**: Record found successfully
- **1**: Record not found (acceptable - triggers rejection logic)
- **4**: No more records (acceptable for search)
- **Other**: Database error → Program termination

#### GET-ADM Error (Administrative Data Retrieval)
**Code**: [cbl/MYFIN.cbl#L1322-L1332](../../../cbl/MYFIN.cbl#L1322)

```cobol
GET-ADM.
    COPY GTADMDBD.
    IF STAT1 NOT = ZEROES AND NOT = 3
    THEN
        MOVE SPACES TO BTMMSG
        STRING "ERREUR GET ADM STAT1 = " DELIMITED BY SIZE
               STAT1 DELIMITED BY SIZE INTO BTMMSG
        END-STRING
        PERFORM PPRNVW
    END-IF
```

**Expected STAT1 Values**:
- **0**: Data retrieved successfully
- **3**: No data available (acceptable - handled by logic)
- **Other**: Database error → Program termination

#### ADD-BBF Error (BBF Record Creation)
**Code**: [cbl/MYFIN.cbl#L1369-L1378](../../../cbl/MYFIN.cbl#L1369)

```cobol
ADD-BBF.
    COPY ADBBFDBD.
    IF STAT1 NOT = ZEROES
    THEN
        MOVE SPACES TO BTMMSG
        STRING "ERREUR ADD BBF STAT1 = " DELIMITED BY SIZE
               STAT1 DELIMITED BY SIZE INTO BTMMSG
        END-STRING
        PERFORM PPRNVW
    END-IF
```

**Expected STAT1 Values**:
- **0**: Record added successfully
- **Other**: Database error (duplicate key, constraint violation, I/O error) → Program termination

**Common Database Error Causes**:
- Database connection lost
- Table locked by another process
- Insufficient privileges
- Constraint violation (duplicate key, foreign key)
- Disk space exhausted
- Database corrupted or offline

**Recovery for Database Errors**:
- Check database connectivity and availability
- Verify user privileges (SELECT, INSERT permissions)
- Check for table locks or deadlocks
- Review database logs for specific error details
- Restart batch job after resolving database issue
- Contact database administrator if persistent

---

### 8. External Program Call Errors

**Error Type**: Critical - Program Termination  
**Code Location**: External program integration points

#### SEBNKUK9 IBAN Validation Error
**Code**: [cbl/MYFIN.cbl#L1257-L1261](../../../cbl/MYFIN.cbl#L1257) (WELKE-BANK paragraph)

```cobol
WELKE-BANK.
    MOVE "SEBNKUK9" TO CA--PROG
    CALL CA--PROG USING USAREA1 SEBNKUKW.
```

**Error Handling**: 
- No explicit error trap shown in code
- Assumes SEBNKUK9 always returns (no ABEND)
- Error detection via WS-SEBNK-STAT-OUT return code

**Potential Failure Modes**:
- SEBNKUK9 program not found → ABEND
- SEBNKUK9 ABEND during execution → Batch job terminates
- Invalid parameters passed → Unpredictable results

**Recovery**:
- Ensure SEBNKUK9 is in library search path
- Verify SEBNKUKW parameter structure is correct
- Check SEBNKUK9 program logs for internal errors

#### SCHRKCX9 Bank Account Retrieval Error
**Code**: [cbl/MYFIN.cbl#L1207-L1223](../../../cbl/MYFIN.cbl#L1207) (RECHERCHE-RECKNR)

```cobol
MOVE TRBFN-PPR-RNR TO SCHRK-NR-MUT
MOVE SP-ACTDAT TO SCHRK-DAT-VAL
MOVE TRBFN-DEST TO SCHRK-FED
COPY SEPAKCXD.
IF SCHRK-STATUS NOT = ZEROES AND NOT = 1
THEN
    MOVE SPACES TO BTMMSG
    STRING "ERREUR ROUTINE SCHRKCX9 STATUS : " DELIMITED BY SIZE
           SCHRK-STATUS DELIMITED BY SIZE INTO BTMMSG
    END-STRING
    PERFORM PPRNVW
END-IF
```

**Expected SCHRK-STATUS Values**:
- **0**: Bank account found successfully, SAV-IBAN populated
- **1**: Bank account not found (acceptable - no discrepancy check)
- **Other**: Error in SCHRKCX9 routine → Program termination

**Recovery**:
- Verify SCHRKCX9 program availability
- Check parameter values (SCHRK-NR-MUT, SCHRK-DAT-VAL, SCHRK-FED)
- Review SCHRKCX9 program logs
- Verify database connectivity from SCHRKCX9

---

### 9. Bank Account Discrepancy (Informational)

**Error Type**: Informational - Discrepancy Report  
**Code Location**: [cbl/MYFIN.cbl#L302-L310](../../../cbl/MYFIN.cbl#L302)  
**Related Requirement**: FUREQ_MYFIN_003

**Trigger Condition**:
```cobol
IF TRBFN-COMPTE-MEMBRE = 0
    PERFORM RECHERCHE-RECKNR
    IF SW-TROP-JEUNE = 1
        PERFORM CREER-REMOTE-500006
    END-IF
END-IF
```

**Processing**:
- **TRBFN-COMPTE-MEMBRE = 0**: Indicates input IBAN is different from known account
- **RECHERCHE-RECKNR**: Retrieves member's known IBAN from database
- **SW-TROP-JEUNE = 1**: Flag indicating discrepancy detected
- **CREER-REMOTE-500006**: Generates discrepancy report (list 500006)

**Discrepancy List (500006) Record**:
- **List Name**: "500006" (or regional variant 500066/500076/500086/500096)
- **BBF-N56-IBAN**: Input IBAN from payment record
- **BBF-N56-IBAN-MUT**: Member's known IBAN from database
- **BBF-N56-REKNR**: Input bank account number (if Belgian IBAN)
- **BBF-N56-REKNR-MUT**: Member's known account number
- **Additional Data**: National registry, name, payment amount, description code

**Important Note**: 
- This is **NOT an error** - payment processing continues
- List 500006 is informational for manual review
- BBF record is still created
- Payment lists (500001) are still generated
- Allows operations staff to verify account changes

**Business Purpose**: 
- Track changes in member bank accounts
- Detect potential data entry errors
- Identify unauthorized account changes
- Provide audit trail for account updates

**Follow-up Actions**:
- Review list 500006 periodically
- Contact member to verify new bank account
- Update member's known IBAN if change is legitimate
- Investigate if account change seems suspicious

---

## Error Message Catalog

### Bilingual Error Messages (List 500004)

| Error Code | Dutch Message | French Message | Trigger Condition |
|------------|---------------|----------------|-------------------|
| LANG_001 | TAALCODE ONBEKEND | CODE LANGUE INCONNU | ADM-TAAL = 0 and no section language |
| DESC_001 | ONBEK. OMSCHR. | LIBELLE INCONNU | Payment description code >= 90 not found |
| DUP_001 | DUBBELE BETALING | DOUBLE PAIEMENT | Same amount & constant in BBF database |
| IBAN_001 | IBAN FOUTIEF | IBAN ERRONE | IBAN validation failed (WS-SEBNK-STAT-OUT) |
| CC_001 | CC - PAYS/LAND NOT = B | CC - PAYS/LAND NOT = B | Circular check for non-Belgian address |

### System Error Messages (BTMMSG)

| Error Code | Message Template | Component | Action |
|------------|------------------|-----------|--------|
| DB_SCH_001 | "ERREUR SCHLDDBD STAT1 = " + STAT1 | SCH-LID | PPRNVW + EXIT |
| DB_ADM_001 | "ERREUR GET ADM STAT1 = " + STAT1 | GET-ADM | PPRNVW + EXIT |
| DB_PAR_001 | "ERREUR GET PAR STAT1 = " + STAT1 | GET-PAR | PPRNVW + EXIT |
| DB_MUT_001 | "ERREUR GET MUT STAT1 = " + STAT1 | GET-MUT | PPRNVW + EXIT |
| DB_PTL_001 | "ERREUR GET PTL STAT1 = " + STAT1 | GET-PTL | PPRNVW + EXIT |
| DB_BBF_001 | "ERREUR GET BBF STAT1 = " + STAT1 | GET-BBF | PPRNVW + EXIT |
| DB_ADD_001 | "ERREUR ADD BBF STAT1 = " + STAT1 | ADD-BBF | PPRNVW + EXIT |
| EXT_SEB_001 | "ERREUR ROUTINE SCHRKCX9 STATUS : " + SCHRK-STATUS | SCHRKCX9 | PPRNVW + EXIT |

---

## Error Handling Strategy

### Fail-Fast Validation
- Validations execute in sequence
- First validation failure triggers immediate rejection
- Subsequent validations are skipped
- Minimizes database operations for invalid records

**Validation Sequence**:
1. Member existence
2. Section & language determination
3. Payment description retrieval
4. Duplicate detection
5. IBAN validation
6. BBF record creation
7. Circular check country validation
8. Bank account discrepancy check (informational)

### Rejection List Strategy
- All validation failures written to list 500004 (or regional variant)
- Bilingual error messages (Dutch/French)
- Complete payment record included for analysis
- Lists routed to appropriate destination based on TRBFN-TYPE-COMPTA
- Enables operational staff to review and correct errors

### System Error Strategy
- Database and external program errors trigger PPRNVW
- Error messages written to batch log (BTMMSG)
- Program terminates (EXIT PROGRAM or FIN-BTM)
- Batch job may continue with next record (framework-dependent)
- Requires manual intervention to resolve

---

## Error Recovery Procedures

### For Validation Errors (List 500004)

1. **Review Rejection List**
   - Run report to extract list 500004 records
   - Sort by error type (BBF-N54-DIAG)
   - Prioritize by mutuality and amount

2. **Analyze Error Root Cause**
   - Language code errors: Update member administrative data
   - Description errors: Verify payment codes are valid
   - Duplicate errors: Check if intentional or data entry error
   - IBAN errors: Validate IBAN format and re-enter
   - Circular check errors: Change to SEPA or verify address

3. **Correct Input Data**
   - Update source data file
   - Re-create input records with corrections
   - Verify corrections before resubmission

4. **Resubmit Payments**
   - Run batch job with corrected input
   - Verify successful processing
   - Check payment lists (500001) for corrected payments

### For System Errors (Database/External Program)

1. **Review Batch Logs**
   - Extract BTMMSG error messages
   - Identify STAT1 or SCHRK-STATUS error codes
   - Determine affected component (SCH-LID, ADD-BBF, SEBNKUK9, etc.)

2. **Diagnose Issue**
   - Check database connectivity
   - Verify table availability and locks
   - Check user privileges
   - Review external program availability
   - Check system resources (disk space, memory)

3. **Resolve Root Cause**
   - Restart database if necessary
   - Clear table locks
   - Grant missing privileges
   - Ensure external programs are in library path
   - Free up system resources

4. **Restart Batch Job**
   - Verify environment is healthy
   - Restart from last checkpoint (if supported)
   - Or restart full batch job
   - Monitor for successful completion

### For Discrepancy Reports (List 500006)

1. **Review Discrepancy List**
   - Extract list 500006 records
   - Sort by mutuality and member

2. **Verify Account Changes**
   - Contact member to confirm new bank account
   - Cross-reference with change request documents
   - Check for data entry errors

3. **Update Member Data**
   - Update member's known IBAN in database
   - Document account change in member file
   - Log verification date and contact method

4. **Monitor for Patterns**
   - Identify frequent account changes
   - Flag suspicious activity
   - Report trends to management

---

## Testing Strategy for Error Handling

### Unit Testing - Validation Errors

1. **Language Code Error**
   - Test with ADM-TAAL = 0, WS-LIDVZ-AP-TAAL = 0, WS-LIDVZ-OP-TAAL = 0
   - Verify BBF-N54-DIAG = "TAALCODE ONBEKEND/CODE LANGUE INCONNU"
   - Verify CREER-REMOTE-500004 called
   - Verify FIN-BTM terminates processing

2. **Payment Description Error**
   - Test with TRBFN-CODE-LIBEL >= 90, description not in database
   - Verify BBF-N54-DIAG = "ONBEK. OMSCHR./LIBELLE INCONNU"
   - Verify CREER-REMOTE-500004 called

3. **Duplicate Payment Error**
   - Insert BBF record with matching amount and constant
   - Test with same TRBFN-MONTANT and TRBFN-CONSTANTE
   - Verify BBF-N54-DIAG = "DUBBELE BETALING/DOUBLE PAIEMENT"
   - Verify no new BBF record created

4. **Invalid IBAN Error**
   - Test with invalid IBAN format (bad checksum, wrong length)
   - Verify SEBNKUK9 returns WS-SEBNK-STAT-OUT > 2
   - Verify BBF-N54-DIAG = "IBAN FOUTIEF/IBAN ERRONE"

5. **Circular Check Country Error**
   - Test with TRBFN-BETWYZ = "C" and ADM-LND = "F  " (France)
   - Verify BBF-N54-DIAG = "CC - PAYS/LAND NOT = B"

### Integration Testing - System Errors

1. **Database Unavailable**
   - Simulate database connection failure
   - Verify SCH-LID returns STAT1 error code
   - Verify BTMMSG contains "ERREUR SCHLDDBD STAT1 = ..."
   - Verify PPRNVW called and program terminates

2. **External Program Failure**
   - Simulate SEBNKUK9 unavailable
   - Verify batch job ABENDs or error message generated
   - Test recovery after program availability restored

3. **Constraint Violation**
   - Attempt to insert duplicate BBF record (if unique constraint exists)
   - Verify ADD-BBF returns STAT1 error code
   - Verify BTMMSG contains "ERREUR ADD BBF STAT1 = ..."

### System Testing - Error Recovery

1. **Rejection List Processing**
   - Run batch with mix of valid and invalid records
   - Verify list 500004 contains all rejection records
   - Verify list 500001 contains only valid payments
   - Verify rejected payments not in BBF database

2. **Error Correction Workflow**
   - Extract rejection list
   - Correct error root causes
   - Resubmit corrected records
   - Verify successful processing second time

3. **Discrepancy Reporting**
   - Test with TRBFN-COMPTE-MEMBRE = 0 and different IBAN
   - Verify list 500006 generated
   - Verify payment still processed successfully
   - Verify both IBANs appear in discrepancy record

---

## Monitoring and Alerting

### Key Error Metrics

1. **Rejection Rate**
   - Formula: (Count of list 500004 records) / (Total input records) * 100%
   - Target: < 5%
   - Alert Threshold: > 10%

2. **Duplicate Rate**
   - Formula: (Count of "DUBBELE BETALING" errors) / (Total input records) * 100%
   - Target: < 1%
   - Alert Threshold: > 3%

3. **IBAN Error Rate**
   - Formula: (Count of "IBAN FOUTIEF" errors) / (Total input records) * 100%
   - Target: < 2%
   - Alert Threshold: > 5%

4. **System Error Rate**
   - Formula: (Count of PPRNVW calls) / (Total input records) * 100%
   - Target: 0%
   - Alert Threshold: > 0.1%

5. **Discrepancy Rate**
   - Formula: (Count of list 500006 records) / (Total input records) * 100%
   - Target: < 10%
   - Alert Threshold: > 20% (may indicate data quality issue)

### Error Trending

- Track error rates by error type over time
- Identify patterns by mutuality (TRBFN-DEST)
- Monitor seasonal variations
- Report trends to management monthly

### Operational Dashboards

**Daily Error Summary**:
- Total records processed
- Total rejections by error type
- Total discrepancies
- System errors (if any)
- Batch completion status

**Weekly Error Analysis**:
- Error rate trends
- Top error root causes
- Mutuality-specific error rates
- Corrective actions taken

---

## Related Documentation

- **Main Processing Flow**: [FF_MYFIN_001](FF_MYFIN_main_processing.md)
- **Business Use Cases**: 
  - [UC_MYFIN_001](../../business/use-cases/UC_MYFIN_001_process_manual_payment.md)
  - [UC_MYFIN_002](../../business/use-cases/UC_MYFIN_002_validate_payment_data.md)
- **Functional Requirements**:
  - [FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md) - Input Validation
  - [FUREQ_MYFIN_002](../requirements/FUREQ_MYFIN_002_duplicate_detection.md) - Duplicate Detection
  - [FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md) - Bank Account Validation
- **Data Structures**: 
  - [BFN54GZR - Rejection List](../integration/DS_BFN54GZR.md)
  - [BFN56CXR - Discrepancy Report](../integration/DS_BFN56CXR.md)
