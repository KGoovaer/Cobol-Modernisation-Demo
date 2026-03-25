# Functional Requirement: Payment List Generation

**ID**: FUREQ_MYFIN_004  
**Status**: Draft  
**Priority**: High  
**Last Updated**: 2026-01-28

## Traceability

### Business Requirements
- **BUREQ_MYFIN_009**: Payment Detail List Generation
- **BUREQ_MYFIN_010**: Rejection List Generation
- **BUREQ_MYFIN_011**: Bank Account Discrepancy List
- **BUREQ_MYFIN_012**: Regional Accounting List Separation
- **BUREQ_MYFIN_013**: CSV Export for Modern Integration

### Use Cases
- **UC_MYFIN_001**: Process Manual GIRBET Payment
- **UC_MYFIN_003**: Generate Payment Lists

## Requirement Statement

The system must generate three types of output lists (payment details, rejections, and bank account discrepancies) with proper regional accounting separation, CSV export support, and complete payment information for audit, reconciliation, and review purposes.

## Detailed Description

### Functional Behavior

After successful payment processing, the system generates multiple output lists for different purposes:
1. **Payment Detail List (500001)**: Successfully validated payments with complete payment information
2. **Rejection List (500004)**: Failed validations with bilingual diagnostic messages
3. **Bank Account Discrepancy List (500006)**: Payments using different accounts than member's known account
4. **CSV Export (5DET01)**: Modern CSV format for standard payments (JIRA-4224)

All lists support regional accounting variants with separate list numbers and destination codes for Flemish, Walloon, Brussels, and German-speaking regions.

### Input Specification

| Parameter | Type | Required | Format/Constraints | Example |
|-----------|------|----------|-------------------|---------|
| TRBFN-TYPE-COMPTA | 9(01) | Yes | 1=General, 3=Flemish, 4=Walloon, 5=Brussels, 6=German | 1, 3-6 |
| TRBFN-DEST | 9(03) | Yes | Destination mutuality code | 109, 141, 153 |
| TRBFN-CONSTANTE | 9(10) | Yes | Payment constant identifier | 1234567890 |
| TRBFN-NO-SUITE | 9(04) | Yes | Sequence number | 0001 |
| BBF-N54-DIAG | X(32) | Yes (rejection) | Bilingual error message | "LIDNR ONBEKEND/AFFILIE INCONNU" |

### Processing Logic

#### 1. Payment Detail List Generation (CREER-REMOTE-500001)

**List Selection Logic:**
```cobol
EVALUATE TRBFN-TYPE-COMPTA
    WHEN 03 MOVE "500071" TO BBF-N51-NAME  * Flemish region
            MOVE 43       TO BBF-N51-CODE
            MOVE 151      TO BBF-N51-DESTINATION
    WHEN 04 MOVE "500091" TO BBF-N51-NAME  * Walloon region
            MOVE 151      TO BBF-N51-DESTINATION
            MOVE 43       TO BBF-N51-CODE
    WHEN 05 MOVE "500061" TO BBF-N51-NAME  * Brussels region
            MOVE 43       TO BBF-N51-CODE
            MOVE 151      TO BBF-N51-DESTINATION
    WHEN 06 MOVE "500081" TO BBF-N51-NAME  * German-speaking region
            MOVE 151      TO BBF-N51-DESTINATION
            MOVE 43       TO BBF-N51-CODE
    WHEN OTHER MOVE 40       TO BBF-N51-CODE  * General accounting
            IF TRBFN-DEST = 141
               MOVE 116           TO BBF-N51-DESTINATION
               MOVE "541001"      TO BBF-N51-NAME
            ELSE
               MOVE TRBFN-DEST    TO BBF-N51-DESTINATION
               MOVE "500001"      TO BBF-N51-NAME
            END-IF
END-EVALUATE
```

**Record Population:**
- Length: 213 bytes
- Device: "L" (line printer) or "C" (console) if TRBFN-DEST = 153
- Switching: "*"
- Priority: SPACE
- Key: SPACES
- Member info: National registry number, name, first name
- Payment info: Constant, sequence number, description code, amount
- Bank info: IBAN, payment method (TRBFN-BETWYZ), bank code (SAV-WELKEBANK)
- Regional tags: BBF-N51-TAGREG-OP and BBF-N51-VERB based on TRBFN-TYPE-COMPTA
- Code: [cbl/MYFIN.cbl#L711-L826](../../../cbl/MYFIN.cbl#L711-L826)

**CSV Export (JIRA-4224):**
- Only for standard payments (non-regional)
- List name: "5DET01"
- Record code: 43
- Destination: 151
- Contains same data as traditional list
- Code: [cbl/MYFIN.cbl#L825-L831](../../../cbl/MYFIN.cbl#L825-L831)

#### 2. Rejection List Generation (CREER-REMOTE-500004)

**List Selection Logic:**
```cobol
EVALUATE TRBFN-TYPE-COMPTA
    WHEN 03 MOVE "500074" TO BBF-N54-NAME  * Flemish region rejections
            MOVE 43       TO BBF-N54-CODE
            MOVE 151      TO BBF-N54-DESTINATION
    WHEN 04 MOVE "500094" TO BBF-N54-NAME  * Walloon region rejections
            MOVE 151      TO BBF-N54-DESTINATION
            MOVE 43       TO BBF-N54-CODE
    WHEN 05 MOVE "500064" TO BBF-N54-NAME  * Brussels region rejections
            MOVE 43       TO BBF-N54-CODE
            MOVE 151      TO BBF-N54-DESTINATION
    WHEN 06 MOVE "500084" TO BBF-N54-NAME  * German region rejections
            MOVE 151      TO BBF-N54-DESTINATION
            MOVE 43       TO BBF-N54-CODE
    WHEN OTHER MOVE 40       TO BBF-N54-CODE  * General accounting rejections
            IF TRBFN-DEST = 141
               MOVE 116           TO BBF-N54-DESTINATION
               MOVE "541004"      TO BBF-N54-NAME
            ELSE
               MOVE TRBFN-DEST    TO BBF-N54-DESTINATION
               MOVE "500004"      TO BBF-N54-NAME
            END-IF
END-EVALUATE
```

**Record Population:**
- Length: 259 bytes
- Device: "L" (line printer) or "C" (console) if TRBFN-DEST = 153
- Diagnostic message: BBF-N54-DIAG (32 characters, bilingual format "NL TEXT/FR TEXT")
- Member info: National registry number, language code
- Payment info: Constant, sequence number, amount, description code
- Bank info: IBAN, payment method
- Regional tags: BBF-N54-TAGREG-OP and BBF-N54-VERB based on TRBFN-TYPE-COMPTA
- Code: [cbl/MYFIN.cbl#L901-L1002](../../../cbl/MYFIN.cbl#L901-L1002)

#### 3. Bank Account Discrepancy List Generation (CREER-REMOTE-500006)

**Trigger Condition:**
- TRBFN-COMPTE-MEMBRE = 0 (indicates provided account differs from known account)
- SAV-IBAN NOT = TRBFN-IBAN (confirmation that accounts differ)

**List Selection Logic:**
```cobol
EVALUATE TRBFN-TYPE-COMPTA
    WHEN 03 MOVE "500076" TO BBF-N56-NAME  * Flemish region discrepancies
            MOVE 43       TO BBF-N56-CODE
            MOVE 151      TO BBF-N56-DESTINATION
    WHEN 04 MOVE "500096" TO BBF-N56-NAME  * Walloon region discrepancies
            MOVE 151      TO BBF-N56-DESTINATION
            MOVE 43       TO BBF-N56-CODE
    WHEN 05 MOVE "500066" TO BBF-N56-NAME  * Brussels region discrepancies
            MOVE 43       TO BBF-N56-CODE
            MOVE 151      TO BBF-N56-DESTINATION
    WHEN 06 MOVE "500086" TO BBF-N56-NAME  * German region discrepancies
            MOVE 151      TO BBF-N56-DESTINATION
            MOVE 43       TO BBF-N56-CODE
    WHEN OTHER 
            IF TRBFN-DEST = 141
               MOVE "541006" TO BBF-N56-NAME  * Special mutuality
               MOVE 116      TO BBF-N56-DESTINATION
            ELSE
               MOVE "500006" TO BBF-N56-NAME  * General accounting
               MOVE TRBFN-DEST TO BBF-N56-DESTINATION
            END-IF
            MOVE 40 TO BBF-N56-CODE
END-EVALUATE
```

**Special Handling:**
- List 541006 is NOT generated per MIS01 modification (DOCSOL project)
- Code: [cbl/MYFIN.cbl#L1039-L1107](../../../cbl/MYFIN.cbl#L1039-L1107)

**Record Population:**
- Length: 258 bytes
- Shows both provided IBAN (TRBFN-IBAN) and known IBAN (SAV-IBAN)
- Member information for review
- Payment constant and sequence for traceability

### Output Specification

**Success Output:**
- List records written to appropriate output files
- Records formatted for remote printing system or CSV export
- Proper record code and destination set based on accounting type
- Regional tags correctly populated for 6th State Reform compliance

**List Output Summary:**

| Accounting Type | Payment Detail | Rejection List | Discrepancy List | CSV Export |
|----------------|----------------|----------------|------------------|------------|
| 1 (General) | 500001 (RC 40) | 500004 (RC 40) | 500006 (RC 40) | 5DET01 (RC 43) |
| 3 (Flemish) | 500071 (RC 43) | 500074 (RC 43) | 500076 (RC 43) | None |
| 4 (Walloon) | 500091 (RC 43) | 500094 (RC 43) | 500096 (RC 43) | None |
| 5 (Brussels) | 500061 (RC 43) | 500064 (RC 43) | 500066 (RC 43) | None |
| 6 (German) | 500081 (RC 43) | 500084 (RC 43) | 500086 (RC 43) | None |
| Special (141) | 541001 (RC 40) | 541004 (RC 40) | 541006* (RC 40) | None |

*List 541006 suppressed per MIS01 modification

## Technical Constraints

- **Performance**: List record creation must not significantly impact batch processing time
- **Record Size**: BFN51GZR=213 bytes, BFN54GZR=259 bytes, BFN56CXR=258 bytes
- **Destination**: All regional lists use destination 151, general uses mutuality code
- **Record Code**: Regional lists use code 43, general uses code 40

## Data Structures

### BFN51GZR (Payment Detail List Record)

```cobol
      * Payment Detail List Record (from BFN51GZR copybook)
       01  BFN51GZR.
           05  BBF-N51-LENGTH         PIC S9(04) COMP.  * 213 bytes
           05  BBF-N51-CODE           PIC S9(04) COMP.  * 40 or 43
           05  BBF-N51-DEVICE-OUT     PIC X(01).        * "L" or "C"
           05  BBF-N51-SWITCHING      PIC X(01).        * "*"
           05  BBF-N51-DESTINATION    PIC 9(03).        * Mutuality or 151
           05  BBF-N51-NAME           PIC X(06).        * "500001" etc.
           05  BBF-N51-PRIORITY       PIC X(01).        * SPACE
           05  BBF-N51-KEY            PIC X(10).        * SPACES
           05  BBF-N51-KONST          PIC 9(10).        * Payment constant
           05  BBF-N51-VOLGNR         PIC 9(04).        * Sequence number
           05  BBF-N51-RNR            PIC X(13).        * National registry
           05  BBF-N51-NAAM           PIC X(30).        * Last name
           05  BBF-N51-VOORN          PIC X(20).        * First name
           05  BBF-N51-LIBEL          PIC 9(02).        * Description code
           05  BBF-N51-BEDRAG         PIC S9(08).       * Amount in cents
           05  BBF-N51-DV             PIC X(01).        * Currency indicator
           05  BBF-N51-DN             PIC 9(01).        * Euro flag (0 or 2)
           05  BBF-N51-BANK           PIC 9(01).        * Bank code
           05  BBF-N51-IBAN           PIC X(34).        * IBAN
           05  BBF-N51-BETWY          PIC X(01).        * Payment method
           05  BBF-N51-TAGREG-OP      PIC 9(01).        * Regional tag
           05  BBF-N51-VERB           PIC 9(03).        * Federation code
           05  BBF-N51-AFK            PIC 9(01).        * Account type
           05  BBF-N51-TYPE-COMPTE    PIC X(04).        * Account type detail
```

### BFN54GZR (Rejection List Record)

```cobol
      * Rejection List Record (from BFN54GZR copybook)
       01  BFN54GZR.
           05  BBF-N54-LENGTH         PIC S9(04) COMP.  * 259 bytes
           05  BBF-N54-CODE           PIC S9(04) COMP.  * 40 or 43
           05  BBF-N54-DEVICE-OUT     PIC X(01).        * "L" or "C"
           05  BBF-N54-SWITCHING      PIC X(01).        * "*"
           05  BBF-N54-DESTINATION    PIC 9(03).        * Mutuality or 151
           05  BBF-N54-NAME           PIC X(06).        * "500004" etc.
           05  BBF-N54-PRIORITY       PIC X(01).        * SPACE
           05  BBF-N54-KEY            PIC X(10).        * SPACES
           05  BBF-N54-DIAG           PIC X(32).        * Bilingual diagnostic
           05  BBF-N54-KONST          PIC 9(10).        * Payment constant
           05  BBF-N54-VOLGNR         PIC 9(04).        * Sequence number
           05  BBF-N54-RNR            PIC X(13).        * National registry
           05  BBF-N54-BEDRAG         PIC S9(08).       * Amount in cents
           05  BBF-N54-BETKOD         PIC 9(02).        * Description code
           05  BBF-N54-IBAN           PIC X(34).        * IBAN
           05  BBF-N54-BETWYZ         PIC X(01).        * Payment method
           05  BBF-N54-TAGREG-OP      PIC 9(01).        * Regional tag
           05  BBF-N54-VERB           PIC 9(03).        * Federation code
           05  BBF-N54-VBOND          PIC 9(03).        * Mutuality code
           05  BBF-N54-TAAL           PIC 9(01).        * Language code
      
      * Diagnostic message format:
      * - "DUTCH TEXT/FRENCH TEXT" (32 characters max)
      * - Examples: "LIDNR ONBEKEND/AFFILIE INCONNU"
      *              "DUBBELE BETALING/DOUBLE PAIEMENT"
      *              "IBAN FOUTIEF/IBAN ERRONE"
```

### BFN56CXR (Discrepancy List Record)

```cobol
      * Bank Account Discrepancy List Record (from BFN56CXR copybook)
       01  BFN56CXR.
           05  BBF-N56-LENGTH         PIC S9(04) COMP.  * 258 bytes
           05  BBF-N56-CODE           PIC S9(04) COMP.  * 40 or 43
           05  BBF-N56-DEVICE-OUT     PIC X(01).        * "L" or "C"
           05  BBF-N56-SWITCHING      PIC X(01).        * "*"
           05  BBF-N56-DESTINATION    PIC 9(03).        * Mutuality or 151
           05  BBF-N56-NAME           PIC X(06).        * "500006" etc.
           05  BBF-N56-PRIORITY       PIC X(01).        * SPACE
           05  BBF-N56-KEY            PIC X(10).        * SPACES
           05  BBF-N56-IBAN-PROVIDED  PIC X(34).        * IBAN from input
           05  BBF-N56-IBAN-KNOWN     PIC X(34).        * IBAN from database
           05  BBF-N56-KONST          PIC 9(10).        * Payment constant
           05  BBF-N56-VOLGNR         PIC 9(04).        * Sequence number
           05  BBF-N56-RNR            PIC X(13).        * National registry
           05  BBF-N56-TAGREG-OP      PIC 9(01).        * Regional tag
           05  BBF-N56-VERB           PIC 9(03).        * Federation code
```

## Validation Rules

| Field | Rule | Error Code | Error Message |
|-------|------|------------|---------------|
| TRBFN-TYPE-COMPTA | Must be 1-6 | N/A | (Validated earlier) |
| BBF-N54-DIAG | Required for rejections, max 32 chars | N/A | (Set by calling routine) |
| List name | Must match accounting type | N/A | (Enforced by EVALUATE logic) |

## Error Handling

### Error Scenarios

1. **List Write Failure**
   - **Trigger**: COPY ADLOGDBD operation fails (file write error)
   - **Action**: Depends on system configuration (may log error or ABEND)
   - **Logging**: System logs record write failure
   - **Recovery**: Varies by configuration

2. **Invalid Accounting Type**
   - **Trigger**: TRBFN-TYPE-COMPTA NOT = 1-6
   - **Action**: Falls through to WHEN OTHER clause, uses general list
   - **Logging**: No specific error (handled as general accounting)
   - **Recovery**: Payment processes with standard list numbers

## Integration Points

### External Systems

**Remote Printing System:**
- **Type**: File output for remote printing
- **Purpose**: Format and print payment lists for distribution
- **Interface**: BFN51GZR, BFN54GZR, BFN56CXR copybook structures
- **Error Handling**: COPY ADLOGDBD writes records to output files
- **Lists Generated**: See output specification table above

**CSV Export System (JIRA-4224):**
- **Type**: CSV file output for modern integration
- **Purpose**: Provide payment data in CSV format for newer systems
- **Interface**: Same BFN51GZR structure, record code 43, destination 151
- **List Name**: "5DET01"
- **Scope**: Standard payments only (not regional)
- **Code**: [cbl/MYFIN.cbl#L825-L831](../../../cbl/MYFIN.cbl#L825-L831)

## Configuration

| Parameter | Source | Required | Default | Description |
|-----------|--------|----------|---------|-------------|
| TRBFN-TYPE-COMPTA | Input record | Yes | 1 | Determines list variant |
| TRBFN-DEST | Input record | Yes | N/A | Mutuality code for destination |
| SW-CREA-CODE-43 | Program flag | Yes | FALSE | Controls CSV export creation |

## Implementation Notes

### Code References

- **Payment Detail List**: 
  - Source: [cbl/MYFIN.cbl#L711-L826](../../../cbl/MYFIN.cbl#L711-L826) - CREER-REMOTE-500001 paragraph
  - CSV Export: [cbl/MYFIN.cbl#L825-L831](../../../cbl/MYFIN.cbl#L825-L831)
- **Rejection List**: 
  - Source: [cbl/MYFIN.cbl#L901-L1002](../../../cbl/MYFIN.cbl#L901-L1002) - CREER-REMOTE-500004 paragraph
- **Discrepancy List**: 
  - Source: [cbl/MYFIN.cbl#L1039-L1107](../../../cbl/MYFIN.cbl#L1039-L1107) - CREER-REMOTE-500006 paragraph
- **List 541006 Suppression**: 
  - Source: [cbl/MYFIN.cbl#L1103-L1105](../../../cbl/MYFIN.cbl#L1103-L1105) - MIS01 conditional logic

### Design Patterns Used

- **Regional Separation**: EVALUATE logic separates accounting types into distinct lists
- **Bilingual Formatting**: Error messages in "NL/FR" format for Belgian compliance
- **Conditional CSV Export**: CSV only for standard payments (SW-CREA-CODE-43 flag)
- **Template-Based Generation**: COPY ADLOGDBD for consistent record writing
- **Special Case Handling**: Mutuality 141 uses different list numbers (541xxx)

### Dependencies

- **Copybooks**: 
  - BFN51GZR.cpy: Payment detail list structure
  - BFN54GZR.cpy: Rejection list structure
  - BFN56CXR.cpy: Discrepancy list structure
  - ADLOGDBD: Database/file write operation template
- **Called Programs**: None (uses COPY statements for file writes)
- **System Services**: 
  - Remote printing system for list formatting and distribution

## Test Scenarios

### Positive Tests

1. **Standard payment list generation**
   - Input: TRBFN-TYPE-COMPTA = 1, successful payment
   - Expected: Records written to lists 500001 and 5DET01 (CSV)

2. **Regional payment - Flemish**
   - Input: TRBFN-TYPE-COMPTA = 3, successful payment
   - Expected: Record written to list 500071, record code 43, destination 151

3. **Regional payment - Walloon**
   - Input: TRBFN-TYPE-COMPTA = 4, successful payment
   - Expected: Record written to list 500091, record code 43, destination 151

4. **Rejection list - duplicate payment**
   - Input: Duplicate payment detected
   - Expected: Record written to list 500004 with diagnostic "DUBBELE BETALING/DOUBLE PAIEMENT"

5. **Bank account discrepancy**
   - Input: TRBFN-COMPTE-MEMBRE = 0, SAV-IBAN differs from TRBFN-IBAN
   - Expected: Record written to list 500006 with both IBANs shown

6. **Special mutuality 141**
   - Input: TRBFN-DEST = 141, TRBFN-TYPE-COMPTA = 1
   - Expected: Lists 541001 (detail), 541004 (rejection), destination 116

### Negative Tests

1. **List 541006 suppression**
   - Input: TRBFN-DEST = 141, discrepancy condition
   - Expected: List 541006 NOT generated per MIS01 modification

2. **Invalid accounting type**
   - Input: TRBFN-TYPE-COMPTA = 9 (invalid)
   - Expected: Falls to WHEN OTHER, uses general lists (500001, 500004)

3. **CSV export not for regional**
   - Input: TRBFN-TYPE-COMPTA = 3 (Flemish), successful payment
   - Expected: List 500071 generated, but NOT 5DET01 (CSV)

## Acceptance Criteria

- [x] Payment detail list (500001) generated for successful payments
- [x] Rejection list (500004) generated for validation failures with bilingual diagnostics
- [x] Bank account discrepancy list (500006) generated when TRBFN-COMPTE-MEMBRE = 0
- [x] Regional list variants correctly selected based on TRBFN-TYPE-COMPTA (3-6)
- [x] All regional lists use record code 43 and destination 151
- [x] CSV export (5DET01) generated for standard payments only
- [x] Special mutuality 141 uses list numbers 541001, 541004
- [x] List 541006 suppressed per MIS01 modification
- [x] Regional tags (BBF-N51-TAGREG-OP, etc.) correctly set for 6th State Reform
- [x] Federation codes correctly assigned based on accounting type

## Open Issues

- [ ] Confirm retention period for generated lists
- [ ] Document list distribution process (printing, archival, delivery)
- [ ] Clarify CSV export format specifications (delimiters, encoding)
- [ ] Confirm whether list 541006 suppression is permanent or temporary (MIS01)
