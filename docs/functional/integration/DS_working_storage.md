# Data Structure: Working Storage Structures

**ID**: DS_WORKING_STORAGE  
**Type**: Program Working Storage  
**Purpose**: Internal working variables, control flags, and temporary storage for MYFIN payment processing  
**Source**: [cbl/MYFIN.cbl](../../../cbl/MYFIN.cbl#L94-L160) (WORKING-STORAGE SECTION)  
**Last Updated**: 2026-01-29

## Overview

The working storage section of MYFIN contains critical control variables, language tables, validation flags, and temporary storage areas used throughout payment processing. These structures support member validation, bilingual processing, bank account handling, IBAN validation, and payment description construction.

## Working Storage Structures

### TEST-MUTUALITE - Mutuality Language Classification

**Purpose**: Classify mutuality codes by language/region for bilingual processing  
**Location**: [cbl/MYFIN.cbl#L94-L104](../../../cbl/MYFIN.cbl#L94-L104)

```cobol
01  TEST-MUTUALITE PIC 9(3).
    88 MUT-FR        VALUE 109, 116, 127, 128, 129, 130, 132,
                           133, 134, 135, 136, 167, 168.           
    88 MUT-NL        VALUE 101, 102, 104, 105, 108, 110, 111,
                           112, 113, 114, 115, 117, 118, 119,
                           120, 121, 122, 126, 131, 169.                    
    88 MUT-BILINGUE  VALUE 106, 107, 150, 166.          
    88 MUT-VERVIERS  VALUE 137.
```

**Field Specifications**:

| Field | Type | Purpose | Values |
|-------|------|---------|--------|
| TEST-MUTUALITE | 9(3) | Mutuality code storage | 101-169 |
| MUT-FR | 88-level | French-speaking mutualities | 109, 116, 127-136, 167, 168 |
| MUT-NL | 88-level | Dutch-speaking mutualities | 101, 102, 104, 105, 108, 110-122, 126, 131, 169 |
| MUT-BILINGUE | 88-level | Bilingual mutualities (FR/NL) | 106, 107, 150, 166 |
| MUT-VERVIERS | 88-level | Verviers mutuality (FR/DE) | 137 |

**Usage**:
```cobol
MOVE TRBFN-DEST TO TEST-MUTUALITE

IF MUT-FR
    MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
END-IF

IF MUT-BILINGUE
    IF ADM-TAAL = 1
        MOVE LIBP-LIBELLE-NL TO SAV-LIBELLE
    ELSE
        MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
    END-IF
END-IF
```

**Modifications**:
- **CDU001** (2019-07-01): Added mutualities 167, 168 (MUT-FR), 169 (MUT-NL), 150, 166 (MUT-BILINGUE) for 6th State Reform

**Code Reference**: [cbl/MYFIN.cbl#L239-L271](../../../cbl/MYFIN.cbl#L239-L271) (usage in parameter retrieval)

---

### TABLE-LIB-AU - Language-Specific Period Connector

**Purpose**: Provide bilingual period connectors for date range descriptions  
**Location**: [cbl/MYFIN.cbl#L106-L111](../../../cbl/MYFIN.cbl#L106-L111)

```cobol
01  TABLE-LIB-AU.
    05 FILLER        PIC X(5) VALUE " TOT ".
    05 FILLER        PIC X(5) VALUE " AU  ".
    05 FILLER        PIC X(5) VALUE " BIS ".
01  TABLE-LIB-AU-RED REDEFINES TABLE-LIB-AU.
    05 LIB-AU   PIC X(5) OCCURS 3.
```

**Field Specifications**:

| Index | Language | Value | Meaning |
|-------|----------|-------|---------|
| 1 | Dutch | " TOT " | "to" (period connector) |
| 2 | French | " AU  " | "to" (au = à) |
| 3 | German | " BIS " | "to" |

**Usage**:
```cobol
* Build period description: "01/01/2026 TOT 31/01/2026"
MOVE date-from TO description-field
STRING LIB-AU(ADM-TAAL) DELIMITED BY SIZE
       date-to DELIMITED BY SIZE
       INTO description-field
END-STRING
```

**Purpose**: Used for payment codes 50 and 60 to build date-range descriptions in the member's language

---

### SAV-LIB1 and SAV-LIB2 - Description Date Storage

**Purpose**: Parse and store date components from payment descriptions  
**Location**: [cbl/MYFIN.cbl#L115-L127](../../../cbl/MYFIN.cbl#L115-L127)

```cobol
01  SAV-LIB1.
    05  SAV-DATE1-DMY.
        10  SAV-DATE1-DD    PIC 99.
        10  SAV-DATE1-MM    PIC 99.
        10  SAV-DATE1-YY    PIC 99.
    05  FILLER              PIC X(8).

01  SAV-LIB2.
    05  SAV-DATE2-DMY.
        10  SAV-DATE2-DD    PIC 99.
        10  SAV-DATE2-MM    PIC 99.
        10  SAV-DATE2-YY    PIC 99.
    05  FILLER              PIC X(8).
```

**Field Specifications**:

| Field | Type | Length | Purpose |
|-------|------|--------|---------|
| SAV-LIB1 | Group | 14 bytes | First description line with embedded date |
| SAV-DATE1-DD | 99 | 2 bytes | Day (01-31) |
| SAV-DATE1-MM | 99 | 2 bytes | Month (01-12) |
| SAV-DATE1-YY | 99 | 2 bytes | Year (last 2 digits) |
| SAV-LIB2 | Group | 14 bytes | Second description line with embedded date |
| SAV-DATE2-DD | 99 | 2 bytes | Day (01-31) |
| SAV-DATE2-MM | 99 | 2 bytes | Month (01-12) |
| SAV-DATE2-YY | 99 | 2 bytes | Year (last 2 digits) |

**Usage**:
- Extract dates from SAV-LIBELLE for codes 50 (period) and 60 (single date)
- Format: DDMMYY embedded in first 6 characters of description
- Used to build dynamic payment descriptions with actual dates

**Example**:
```cobol
* For code 50 (period payment):
* SAV-LIBELLE = "010126...rest of text..."
MOVE SAV-LIBELLE TO SAV-LIB1
* SAV-DATE1-DD = 01, SAV-DATE1-MM = 01, SAV-DATE1-YY = 26
* Build: "Payment for period 01/01/26 TO 31/01/26"
```

---

### COMMENT and COMMENT1 - Bank Communication Field

**Purpose**: Build SEPA communication/description for account statement  
**Location**: [cbl/MYFIN.cbl#L132-L143](../../../cbl/MYFIN.cbl#L132-L143)

```cobol
01  COMMENT                     PIC  X(106) VALUE SPACE.
01  COMMENT1 REDEFINES COMMENT.
    05  BANK-VELD1              PIC  X(53).
    05  REF-VELD1               PIC  X(07).
    05  KONSTANTE-VELD1         PIC  9(10).
    05  VOLGNR-VELD1            PIC  9(03).
    05  FILLER                  PIC  X.
    05  OMSCH1-VELD1            PIC  X(14).
    05  FILLER                  PIC  X.
    05  OMSCH2-VELD1            PIC  X(14).
    05  FILLER                  PIC  X(03).
```

**Field Specifications**:

| Field | Type | Length | Position | Purpose |
|-------|------|--------|----------|---------|
| COMMENT | X(106) | 106 bytes | 1-106 | Base communication field |
| BANK-VELD1 | X(53) | 53 bytes | 1-53 | Main bank description text |
| REF-VELD1 | X(07) | 7 bytes | 54-60 | Reference identifier |
| KONSTANTE-VELD1 | 9(10) | 10 bytes | 61-70 | Payment constant (from TRBFN-CONSTANTE) |
| VOLGNR-VELD1 | 9(03) | 3 bytes | 71-73 | Sequence number (from TRBFN-NO-SUITE) |
| FILLER | X(01) | 1 byte | 74 | Separator |
| OMSCH1-VELD1 | X(14) | 14 bytes | 75-88 | Description line 1 |
| FILLER | X(01) | 1 byte | 89 | Separator |
| OMSCH2-VELD1 | X(14) | 14 bytes | 90-103 | Description line 2 |
| FILLER | X(03) | 3 bytes | 104-106 | Reserved |

**Usage**:
```cobol
MOVE SAV-LIBELLE TO BANK-VELD1
MOVE TRBFN-CONSTANTE TO KONSTANTE-VELD1
MOVE TRBFN-NO-SUITE TO VOLGNR-VELD1
MOVE description-part1 TO OMSCH1-VELD1
MOVE description-part2 TO OMSCH2-VELD1
* COMMENT now contains full structured bank statement description
```

**Destination**: Copied to SEPAAUKU COMMENTAAR field (KOM-GEZO-BANK redefine)

---

### WS-RIJKSNUMMER - National Registry Number Storage

**Purpose**: Alphanumeric storage of member national registry number  
**Location**: [cbl/MYFIN.cbl#L144](../../../cbl/MYFIN.cbl#L144)

```cobol
279363 01  WS-RIJKSNUMMER            PIC  X(13).
```

**Field Specifications**:

| Field | Type | Length | Format | Purpose |
|-------|------|--------|--------|---------|
| WS-RIJKSNUMMER | X(13) | 13 bytes | XX.XX.XX-XXX.XX | Human-readable registry number |

**Usage**:
```cobol
PERFORM ZOEK-RIJKSNUMMER
* Converts binary RNRBIN to alphanumeric WS-RIJKSNUMMER
* Format: YY.MM.DD-XXX.CC (birth date, sequence, checksum)
```

**Modification**: Added in incident #279363 to display registry number instead of M-number

**Code Reference**: [cbl/MYFIN.cbl#L213](../../../cbl/MYFIN.cbl#L213) (ZOEK-RIJKSNUMMER paragraph)

---

### SAV-WELKEBANK - Bank Selection Flag

**Purpose**: Store which bank to use for payment (main or alternative)  
**Location**: [cbl/MYFIN.cbl#L145](../../../cbl/MYFIN.cbl#L145)

```cobol
01  SAV-WELKEBANK   PIC 9.
```

**Field Specifications**:

| Field | Type | Values | Meaning |
|-------|------|--------|---------|
| SAV-WELKEBANK | 9(1) | 0 | Main bank (HOOFDBANK) |
|  |  | 1 | Alternative bank (ALTERNATIEVEBANK) |
|  |  | 2 | Second alternative (KVS002 removed) |

**Usage**:
```cobol
MOVE "0" TO WS-SEBNK-WELKEBANK
IF WS-SEBNK-WELKEBANK = "0"
    MOVE 1 TO SAV-WELKEBANK
END-IF
* SAV-WELKEBANK used in SEPAAUKU record creation
```

**Context**: R140562 - Dual bank support (Belfius and KBC)  
**Modification**: KVS002 (JIRA-4311) - Simplified from 3 banks to 1 bank (Belfius only)

**Code Reference**: [cbl/MYFIN.cbl#L339-L368](../../../cbl/MYFIN.cbl#L339-L368) (VOIR-BANQUE-DEBIT)

---

### SAV-IBAN and WS-IBAN - IBAN Storage

**Purpose**: Store and validate IBAN bank account numbers  
**Location**: [cbl/MYFIN.cbl#L146-L147](../../../cbl/MYFIN.cbl#L146-L147)

```cobol
IBAN10 01  SAV-IBAN        PIC X(34).
IBAN10 01  WS-IBAN         PIC X(34).
```

**Field Specifications**:

| Field | Type | Length | Format | Purpose |
|-------|------|--------|--------|---------|
| SAV-IBAN | X(34) | 34 bytes | ISO 13616 IBAN | Saved IBAN from UAREA lookup |
| WS-IBAN | X(34) | 34 bytes | ISO 13616 IBAN | Working IBAN for validation |

**Usage**:
```cobol
MOVE TRBFN-IBAN TO WS-SEBNK-IBAN-IN
PERFORM WELKE-BANK
* SEBNK validation returns IBAN and BIC
MOVE WS-SEBNK-IBAN-OUT TO SAV-IBAN
```

**Validation**: IBAN10 project - SEPA compliance, ISO 13616 validation

**Code Reference**: [cbl/MYFIN.cbl#L331-L347](../../../cbl/MYFIN.cbl#L331-L347) (IBAN validation in VOIR-BANQUE-DEBIT)

---

### SAV-RNRBIN - Binary Registry Number

**Purpose**: Temporary storage for binary national registry number  
**Location**: [cbl/MYFIN.cbl#L148](../../../cbl/MYFIN.cbl#L148)

```cobol
01  SAV-RNRBIN      PIC S9(8) COMP.
```

**Field Specifications**:

| Field | Type | Length | Purpose |
|-------|------|--------|---------|
| SAV-RNRBIN | S9(8) COMP | 4 bytes binary | Save/restore RNRBIN during parameter lookup |

**Usage**:
```cobol
MOVE RNRBIN TO SAV-RNRBIN
ADD 6000000 TRBFN-DEST GIVING RNRBIN  * Adjust for parameter lookup
PERFORM SCH-LID08
MOVE SAV-RNRBIN TO RNRBIN              * Restore original value
```

**Context**: Parameter table lookup uses adjusted registry number (base + 6000000 + mutuality code)

**Code Reference**: [cbl/MYFIN.cbl#L225-L229](../../../cbl/MYFIN.cbl#L225-L229) (parameter lookup logic)

---

### SW-TROP-JEUNE - Age Validation Flag

**Purpose**: Flag indicating member is too young for payment type  
**Location**: [cbl/MYFIN.cbl#L149](../../../cbl/MYFIN.cbl#L149)

```cobol
01  SW-TROP-JEUNE   PIC 9.
```

**Field Specifications**:

| Field | Type | Values | Meaning |
|-------|------|--------|---------|
| SW-TROP-JEUNE | 9(1) | 0 | Age validation passed |
|  |  | 1 | Member too young |

**Usage**: Historical field, may be related to age-specific payment validation (not extensively used in current code)

---

### SAV-LIBELLE - Payment Description Text

**Purpose**: Store payment description retrieved from parameter table  
**Location**: [cbl/MYFIN.cbl#L150](../../../cbl/MYFIN.cbl#L150)

```cobol
01  SAV-LIBELLE     PIC X(53).
```

**Field Specifications**:

| Field | Type | Length | Purpose |
|-------|------|--------|---------|
| SAV-LIBELLE | X(53) | 53 bytes | Payment description in member's language |

**Usage**:
```cobol
IF MUT-FR
    MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
END-IF
IF MUT-NL
    MOVE LIBP-LIBELLE-NL TO SAV-LIBELLE
END-IF
* SAV-LIBELLE used in BANK-VELD1 (COMMENT1)
```

**Context**: Retrieved from LIBPNC parameter table (codes 90-99) or TBLIBCXW table (codes 1-89)

**Code Reference**: [cbl/MYFIN.cbl#L247-L269](../../../cbl/MYFIN.cbl#L247-L269) (language-specific description selection)

---

### SAV-TYPE-COMPTE - Account Type

**Purpose**: Store account type code from parameter table  
**Location**: [cbl/MYFIN.cbl#L151](../../../cbl/MYFIN.cbl#L151)

```cobol
01  SAV-TYPE-COMPTE PIC X(4).
```

**Field Specifications**:

| Field | Type | Length | Purpose |
|-------|------|--------|---------|
| SAV-TYPE-COMPTE | X(4) | 4 bytes | Account type classification |

**Usage**:
```cobol
MOVE LIBP-TYPE-COMPTE TO SAV-TYPE-COMPTE
* Or from table:
MOVE TBLIB-TYPE(TRBFN-CODE-LIBEL) TO SAV-TYPE-COMPTE
```

**Context**: Used for account categorization in financial processing

**Code Reference**: [cbl/MYFIN.cbl#L244](../../../cbl/MYFIN.cbl#L244), [cbl/MYFIN.cbl#L273](../../../cbl/MYFIN.cbl#L273)

---

### I - Loop Counter

**Purpose**: Generic loop counter variable  
**Location**: [cbl/MYFIN.cbl#L152](../../../cbl/MYFIN.cbl#L152)

```cobol
01  I               PIC 9(2).
```

**Field Specifications**:

| Field | Type | Range | Purpose |
|-------|------|-------|---------|
| I | 9(2) | 00-99 | General iteration counter |

**Usage**: Standard loop counter for various iterations in program logic

---

### SECTION-TROUVEE - Found Section Code

**Purpose**: Store mutuality code of found insurance section  
**Location**: [cbl/MYFIN.cbl#L153](../../../cbl/MYFIN.cbl#L153)

```cobol
01  SECTION-TROUVEE PIC 999.
```

**Field Specifications**:

| Field | Type | Length | Purpose |
|-------|------|--------|---------|
| SECTION-TROUVEE | 9(3) | 3 bytes | Mutuality code of active insurance section |

**Usage**:
```cobol
PERFORM RECHERCHE-SECTION
* SECTION-TROUVEE populated with mutuality code from active section
* Used for validation and routing
```

**Context**: Set by RECHERCHE-SECTION paragraph after scanning insurance records (LIDVZ)

**Code Reference**: [cbl/MYFIN.cbl#L196](../../../cbl/MYFIN.cbl#L196) (RECHERCHE-SECTION paragraph call)

---

### SW-TROUVE - Section Found Switch

**Purpose**: Indicate whether active insurance section was found  
**Location**: [cbl/MYFIN.cbl#L154](../../../cbl/MYFIN.cbl#L154)

```cobol
01  SW-TROUVE       PIC XXX.
```

**Field Specifications**:

| Field | Type | Values | Meaning |
|-------|------|--------|---------|
| SW-TROUVE | X(3) | "OK" | Section found |
|  |  | other | Section not found |

**Usage**:
```cobol
PERFORM RECHERCHE-SECTION
IF SW-TROUVE NOT = "OK"
    * Reject payment - no active section
END-IF
```

**Context**: Set by RECHERCHE-SECTION after scanning LIDVZ records

---

### WS-BIC - Bank Identifier Code

**Purpose**: Store BIC (Swift code) from IBAN validation  
**Location**: [cbl/MYFIN.cbl#L155](../../../cbl/MYFIN.cbl#L155)

```cobol
01  WS-BIC          PIC X(11).
```

**Field Specifications**:

| Field | Type | Length | Format | Purpose |
|-------|------|--------|--------|---------|
| WS-BIC | X(11) | 11 bytes | Swift BIC format | Bank Identifier Code for SEPA |

**Usage**:
```cobol
MOVE SPACES TO WS-BIC
PERFORM WELKE-BANK
IF WS-SEBNK-STAT-OUT = 0
    MOVE WS-SEBNK-BIC-OUT TO WS-BIC
END-IF
```

**Context**: IBAN10 project - retrieved from SEBNK validation service

**Code Reference**: [cbl/MYFIN.cbl#L331-L343](../../../cbl/MYFIN.cbl#L331-L343) (VOIR-BANQUE-DEBIT)

---

### WS-LIDVZ-OP-TAAL and WS-LIDVZ-AP-TAAL - Insurance Section Language

**Purpose**: Store language codes from open/closed insurance sections  
**Location**: [cbl/MYFIN.cbl#L156-L157](../../../cbl/MYFIN.cbl#L156-L157)

```cobol
JGO004 01  WS-LIDVZ-OP-TAAL     PIC  9(01).
JGO004 01  WS-LIDVZ-AP-TAAL     PIC  9(01).
```

**Field Specifications**:

| Field | Type | Values | Purpose |
|-------|------|--------|---------|
| WS-LIDVZ-OP-TAAL | 9(1) | 0-3 | Language from open package (OP) insurance section |
| WS-LIDVZ-AP-TAAL | 9(1) | 0-3 | Language from closed package (AP) insurance section |

**Values**:
- 0: No language/not set
- 1: French
- 2: Dutch
- 3: German

**Usage**:
```cobol
MOVE 0 TO WS-LIDVZ-OP-TAAL
MOVE 0 TO WS-LIDVZ-AP-TAAL
PERFORM RECHERCHE-SECTION  * Populates these fields

IF ADM-TAAL = 0
    IF WS-LIDVZ-AP-TAAL NOT = 0
        MOVE WS-LIDVZ-AP-TAAL TO ADM-TAAL
    ELSE IF WS-LIDVZ-OP-TAAL NOT = 0
        MOVE WS-LIDVZ-OP-TAAL TO ADM-TAAL
    END-IF
END-IF
```

**Context**: JGO004 modification - handle cases where ADM-TAAL = 0 by using insurance section language

**Code Reference**: [cbl/MYFIN.cbl#L186-L206](../../../cbl/MYFIN.cbl#L186-L206) (language fallback logic)

---

### WS-CREATION-CODE-43 - CSV Creation Control

**Purpose**: Control flag for CSV output creation (JIRA-4224)  
**Location**: [cbl/MYFIN.cbl#L161-L163](../../../cbl/MYFIN.cbl#L161-L163)

```cobol
KVS001 01  WS-CREATION-CODE-43          PIC 9(01).
KVS001     88 SW-NO-CREA-CODE-43        VALUE 0.         
KVS001     88 SW-CREA-CODE-43           VALUE 1.
```

**Field Specifications**:

| Field | Type | Values | Meaning |
|-------|------|--------|---------|
| WS-CREATION-CODE-43 | 9(1) | 0 | Do not create CSV output |
|  |  | 1 | Create CSV output |
| SW-NO-CREA-CODE-43 | 88-level | VALUE 0 | Condition: no CSV creation |
| SW-CREA-CODE-43 | 88-level | VALUE 1 | Condition: create CSV |

**Usage**:
```cobol
IF SW-CREA-CODE-43
    * Write detail lines to CSV instead of Papyrus format
END-IF
```

**Context**: KVS001 (JIRA-4224) - Shift from Papyrus to CSV output for list 500001 details

**Modification**: Added 2023-05-02 for CSV output migration

---

## Related Copybooks (Included in Working Storage)

The following copybooks are included in WORKING-STORAGE SECTION:

| Copybook | Purpose |
|----------|---------|
| ABX00XSW | ABXBS2 - System control blocks |
| WRNRSXDW | National registry number utilities |
| WDATEXDW | Date utilities |
| LIDVZASW | Insurance section (LIDVZ) access |
| VBONDASW | Federation data access |
| TBLIBCXW | Payment description table (codes 1-89) |
| SEPAAUKU | SEPA user record output (see DS_SEPAAUKU) |
| BFN51GZR | List 500001 output (successful payments) |
| BFN54GZR | List 500004 output (rejections) |
| BFN56CXR | List 500006 output (discrepancies) |
| LIBPNCXW | Payment description parameter records (codes 90-99) |
| SEPAKCXW | SEPA key control |
| SEBNKUKW | SEBNK bank validation utility |
| CGACVXSW | CGA/ARC Y2000 compliance |

**Note**: BFN52GZU (list 500002) was removed per R140562 (dual bank modification)

---

## Usage Patterns

### Member Validation Flow
```cobol
MOVE ZEROES TO STAT1
MOVE TRBFN-PPR-RNR TO RNRBIN
PERFORM SCH-LID
IF STAT1 NOT = ZEROES
    PERFORM PPRNVW  * Member not found - reject
END-IF
```

### Language Selection Flow
```cobol
MOVE 0 TO WS-LIDVZ-OP-TAAL
MOVE 0 TO WS-LIDVZ-AP-TAAL
PERFORM RECHERCHE-SECTION
MOVE 1 TO GETTP
PERFORM GET-ADM

IF ADM-TAAL = 0
    * Fallback to insurance section language
    IF WS-LIDVZ-AP-TAAL NOT = 0
        MOVE WS-LIDVZ-AP-TAAL TO ADM-TAAL
    ELSE IF WS-LIDVZ-OP-TAAL NOT = 0
        MOVE WS-LIDVZ-OP-TAAL TO ADM-TAAL
    ELSE
        * Reject: language code unknown
        MOVE "TAALCODE ONBEKEND/CODE LANGUE INCONNU" TO BBF-N54-DIAG
        PERFORM CREER-REMOTE-500004
        PERFORM FIN-BTM
    END-IF
END-IF
```

### Description Selection Flow
```cobol
MOVE TRBFN-DEST TO TEST-MUTUALITE

IF TRBFN-CODE-LIBEL NOT < 90
    * Lookup in parameter table (LIBPNC)
    PERFORM GET-PAR
    IF MUT-FR
        MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
    ELSE IF MUT-NL
        MOVE LIBP-LIBELLE-NL TO SAV-LIBELLE
    ELSE IF MUT-BILINGUE
        IF ADM-TAAL = 1
            MOVE LIBP-LIBELLE-NL TO SAV-LIBELLE
        ELSE
            MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
        END-IF
    END-IF
ELSE
    * Use hardcoded table (TBLIBCXW)
    MOVE TBLIB-LIBELLE(TRBFN-CODE-LIBEL, ADM-TAAL) TO SAV-LIBELLE
    MOVE TBLIB-TYPE(TRBFN-CODE-LIBEL) TO SAV-TYPE-COMPTE
END-IF
```

### IBAN Validation and BIC Retrieval Flow
```cobol
MOVE SPACES TO WS-BIC
MOVE TRBFN-IBAN TO WS-SEBNK-IBAN-IN
MOVE TRBFN-BETWYZ TO WS-SEBNK-BETWYZ-IN
PERFORM WELKE-BANK

MOVE "0" TO WS-SEBNK-WELKEBANK
IF (WS-SEBNK-WELKEBANK = 0 AND WS-SEBNK-STAT-OUT = 0 OR 1 OR 2)
    MOVE WS-SEBNK-BIC-OUT TO WS-BIC
ELSE
    MOVE "IBAN FOUTIEF/IBAN ERRONE" TO BBF-N54-DIAG
    PERFORM CREER-REMOTE-500004
END-IF
```

### Bank Selection by Payment Code
```cobol
EVALUATE TRBFN-CODE-LIBEL
WHEN 90 THRU 99
WHEN 1 THRU 49
WHEN 52 THRU 57
WHEN 71, 73, 74, 76, 78
    IF WS-SEBNK-WELKEBANK = "0"
        MOVE 1 TO SAV-WELKEBANK
    END-IF
WHEN 50, 51, 60, 80
    MOVE 1 TO SAV-WELKEBANK
WHEN OTHER
    MOVE 1 TO SAV-WELKEBANK
END-EVALUATE
```

---

## Performance Considerations

- **Binary Fields**: RNRBIN, SAV-RNRBIN use COMP for efficient arithmetic
- **88-Levels**: Provide readable, efficient condition checking
- **Tables**: TABLE-LIB-AU uses OCCURS for indexed access
- **Redefines**: COMMENT/COMMENT1 provide flexible structure without storage overhead

---

## Security Considerations

- **PII Storage**: WS-RIJKSNUMMER, SAV-IBAN contain sensitive personal data
- **Minimal Retention**: Working storage cleared at program termination
- **No Logging**: Sensitive fields should not be logged/displayed

---

## Related Documentation

- **Input Structure**: [DS_TRBFNCXP](DS_TRBFNCXP.md)
- **Output Structures**: [DS_BBFPRGZP](DS_BBFPRGZP.md), [DS_SEPAAUKU](DS_SEPAAUKU.md)
- **Functional Requirements**:
  - [FUREQ_MYFIN_001](../requirements/FUREQ_MYFIN_001_input_validation.md): Input validation (uses TEST-MUTUALITE, SW-TROUVE)
  - [FUREQ_MYFIN_003](../requirements/FUREQ_MYFIN_003_bank_account_validation.md): Bank validation (uses SAV-IBAN, WS-BIC)

---

## Modification History

| Date | Modifier | Reference | Change |
|------|----------|-----------|--------|
| 1998-05-10 | CGA/ARC | Y2000+ | Y2000 compliance (CGACVXSW copybook) |
| - | VVE | - | Original working storage structures |
| - | JGO004 | ADM-TAAL=0 | Added WS-LIDVZ-OP-TAAL, WS-LIDVZ-AP-TAAL |
| - | 279363 | Incident | Added WS-RIJKSNUMMER for display |
| 2010-2011 | IBAN10 | SEPA | Added SAV-IBAN, WS-IBAN, WS-BIC |
| 2019-07-01 | CDU001 | 6th State Reform | Updated TEST-MUTUALITE (mutualities 150, 166, 167, 168, 169) |
| 2023-05-02 | KVS001 | JIRA-4224 | Added WS-CREATION-CODE-43 for CSV output |
| 2023-06-16 | KVS002 | JIRA-4311 | Modified SAV-WELKEBANK logic (single bank) |

---

## Notes

- Working storage variables are program-scoped, initialized at program start
- Binary fields (COMP) used for performance in numeric operations
- 88-level conditions provide self-documenting code and efficient testing
- Language handling critical for bilingual mutualities (106, 107, 150, 166)
- IBAN10 project significantly expanded working storage for SEPA compliance
- JGO004 modification ensures language code always populated (fallback logic)
- KVS001/KVS002 modifications reflect recent modernization (CSV output, single bank)
