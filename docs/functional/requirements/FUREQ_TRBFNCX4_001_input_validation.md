# Functional Requirement: Input Payment Record Validation

**ID**: FUREQ_MYFIN_001  
**Status**: Draft  
**Priority**: Critical  
**Last Updated**: 2026-01-28

## Traceability

### Business Requirements
- **BUREQ_MYFIN_001**: Member Validation
- **BUREQ_MYFIN_006**: Comprehensive Validation
- **BUREQ_MYFIN_008**: Validation Sequence

### Use Cases
- **UC_MYFIN_001**: Process Manual GIRBET Payment
- **UC_MYFIN_002**: Validate Payment Data

## Requirement Statement

The system must validate all payment input records (TRBFNCXP) for structural integrity, member existence, language code validity, and payment description code validity before processing, rejecting invalid records with bilingual diagnostic messages.

## Detailed Description

### Functional Behavior

Input validation occurs immediately upon receiving a payment record through the GIRBETPP entry point. The batch program performs sequential validation checks, terminating at the first failure and generating a rejection record on list 500004 (or regional variant).

### Input Specification

| Parameter | Type | Required | Format/Constraints | Example |
|-----------|------|----------|-------------------|---------|
| TRBFN-PPR-RNR | Binary S9(08) | Yes | Valid national registry number | 12345678 |
| TRBFN-RNR | X(13) | Yes | Alphanumeric national registry number | "00010156789-10" |
| TRBFN-DEST | 9(03) | Yes | Valid mutuality code (101-169) | 109, 116, 127 |
| TRBFN-CONSTANTE | 9(10) | Yes | Payment constant identifier | 1234567890 |
| TRBFN-NO-SUITE | 9(04) | Yes | Sequence number | 0001 |
| TRBFN-MONTANT | S9(08) | Yes | Payment amount (cents) | 12500 (= €125.00) |
| TRBFN-CODE-LIBEL | 9(02) | Yes | Valid payment description code | 01-99 |
| TRBFN-IBAN | X(34) | Yes (SEPA) | IBAN format if TRBFN-BETWYZ blank | "BE68539007547034" |
| TRBFN-REKNR | 9(12) | No | Legacy bank account (pre-SEPA) | 539007547034 |
| TRBFN-BETWYZ | X(01) | No | Payment method: blank/space='SEPA', 'C'='Circular check' | 'C' or ' ' |
| TRBFN-TYPE-COMPTA | 9(01) | Yes | Accounting type: 1=General, 3-6=Regional | 1, 3, 4, 5, 6 |
| TRBFN-COMPTE-MEMBRE | 9(01) | No | Known member account flag: 0=different, 1=same | 0 or 1 |

### Processing Logic

1. **Member Existence Validation**
   - Extract TRBFN-PPR-RNR (binary national registry number) from input record
   - Search member database (MUTF08) using RNRBIN = TRBFN-PPR-RNR
   - Execute paragraph: [SCH-LID](../../../cbl/MYFIN.cbl#L190) and [SCH-LID08](../../../cbl/MYFIN.cbl#L229)
   - Error response: If STAT1 NOT = ZEROES (member not found), reject with diagnostic "LIDNR ONBEKEND/AFFILIE INCONNU"

2. **Insurance Section Validation**
   - Search for active insurance section in member insurance records (LIDVZ)
   - Execute paragraph: [RECHERCHE-SECTION](../../../cbl/MYFIN.cbl#L196)
   - Check open holder data (OT), open PAC data (OP), closed holder data (AT), closed PAC data (AP)
   - Exclude product codes: 609, 659, 679, 689
   - Set SECTION-TROUVEE to member's mutuality code
   - Error response: If SW-TROUVE NOT = "OK", reject payment

3. **Language Code Validation**
   - Retrieve administrative data (ADM record) from database
   - Execute paragraph: [GET-ADM](../../../cbl/MYFIN.cbl#L198)
   - Check ADM-TAAL field for valid language code
   - If ADM-TAAL = 0, attempt to use language from insurance section (WS-LIDVZ-AP-TAAL or WS-LIDVZ-OP-TAAL)
   - Valid values: 1=French, 2=Dutch, 3=German
   - Determine based on mutuality code and member preference for bilingual mutualities (106, 107, 150, 166)
   - Error response: If language code remains 0 or invalid, reject with "TAALCODE ONBEK/CODE LING INCON"

4. **Payment Description Code Validation**
   - Retrieve parameter record using TRBFN-CODE-LIBEL
   - Execute paragraph: [GET-PAR](../../../cbl/MYFIN.cbl#L233)
   - Search through parameter records with matching code and language
   - Extract payment description text (SAV-LIBELLE) from parameter record
   - Valid codes: 1-99 (specific ranges: 1-49, 50-51, 52-57, 60, 70-99)
   - Special handling for date-based descriptions (codes 50, 60)
   - Error response: If parameter not found, reject with "CODE OMSCHR ONBEK/CODE LIBEL INCON"

### Output Specification

**Success Output:**
- All validation checks passed
- Payment processing continues to duplicate check and IBAN validation
- Member context established: SECTION-TROUVEE, ADM-TAAL, SAV-LIBELLE populated

**Error Output:**
- Rejection record written to list 500004 (or regional variants: 500074, 500094, 500064, 500084)
- Rejection record structure: BFN54GZR copybook
- Bilingual diagnostic message in BBF-N54-DIAG field (32 characters)
- Processing terminates via [FIN-BTM](../../../cbl/MYFIN.cbl#L311) paragraph

## Technical Constraints

- **Performance**: Member lookup must complete within 100ms per record
- **Database Access**: Uses COPY LIDVZASD for member data access, DB2 for BBF/PAR lookups
- **Validation Sequence**: Must follow strict order: member → section → language → description
- **Batch Window**: Part of nightly batch processing, must handle thousands of records efficiently

## Data Structures

### TRBFNCXP (Input Record)

```cobol
      * Payment request record from TRBFNCXB
       01 TRBFNCXP.
          05 TRBFN-LENGTH                 PIC S9(04)  COMP.  * 186/174 bytes
          05 TRBFN-CODE                   PIC S9(04) COMP.   * Record code: 42
          05 TRBFN-NUMBER                 PIC 9(08).         * Sequence number
          05 TRBFN-PPR-NAME               PIC X(06).         * "GIRBET"
          05 TRBFN-PPR-FED                PIC 9(03).         * Federation code
          05 TRBFN-PPR-RNR                PIC S9(08)  COMP.  * National registry (binary)
          05 TRBFN-DATA.
             10 TRBFN-DEST                 PIC 9(3).         * Destination mutuality
             10 TRBFN-CONSTANTE            PIC 9(10).        * Payment constant
             10 TRBFN-NO-SUITE             PIC 9(4).         * Sequence number
             10 TRBFN-RNR                  PIC X(13).        * National registry (alpha)
             10 TRBFN-MONTANT              PIC S9(8).        * Amount in cents
             10 TRBFN-CODE-LIBEL           PIC 9(2).         * Description code
             10 TRBFN-LIBELLE1             PIC X(14).        * Description text 1
             10 TRBFN-LIBELLE2             PIC X(14).        * Description text 2
             10 TRBFN-IBAN                 PIC X(34).        * IBAN bank account
             10 TRBFN-BETWYZ               PIC X(01).        * Payment method
             10 TRBFN-TYPE-COMPTA          PIC 9.            * Accounting type
      
      * Validation rules:
      * - TRBFN-PPR-RNR: Required, must exist in MUTF08
      * - TRBFN-CODE-LIBEL: Required, must exist in parameter table
      * - TRBFN-IBAN: Required if TRBFN-BETWYZ = spaces, SEPA format
      * - TRBFN-TYPE-COMPTA: 1=General, 3=Flemish, 4=Walloon, 5=Brussels, 6=German
```

### Working Storage Variables

```cobol
       01  SECTION-TROUVEE PIC 999.        * Found insurance section code
       01  SW-TROUVE       PIC XXX.        * "OK" if section found, "NOK" otherwise
       01  SAV-LIBELLE     PIC X(53).      * Payment description text
       01  I               PIC 9(2).       * Loop counter for section search
```

## Validation Rules

| Field | Rule | Error Code | Error Message |
|-------|------|------------|---------------|
| TRBFN-PPR-RNR | Must exist in MUTF08 | VAL_001 | "LIDNR ONBEKEND/AFFILIE INCONNU" |
| Insurance section | Active section required | VAL_002 | "GEEN GELDIGE VERZEKERING/PAS D'ASSURANCE VALIDE" |
| ADM-TAAL | Must be 1, 2, or 3 | VAL_003 | "TAALCODE ONBEK/CODE LING INCON" |
| TRBFN-CODE-LIBEL | Must exist in PAR table | VAL_004 | "CODE OMSCHR ONBEK/CODE LIBEL INCON" |
| TRBFN-DEST | Mutuality codes 101-169 | VAL_005 | "ONGELDIG MUTUALITEIT/MUTUALITE INVALIDE" |

## Error Handling

### Error Scenarios

1. **Member Not Found**
   - **Trigger**: STAT1 NOT = ZEROES after SCH-LID or SCH-LID08
   - **Action**: Set BBF-N54-DIAG = "LIDNR ONBEKEND/AFFILIE INCONNU"
   - **Logging**: Write to rejection list 500004
   - **Recovery**: PERFORM CREER-REMOTE-500004, PERFORM FIN-BTM (terminate processing)
   - **Code**: [cbl/MYFIN.cbl#L192-L194](../../../cbl/MYFIN.cbl#L192-L194)

2. **Language Code Unknown**
   - **Trigger**: ADM-TAAL = 0 and both WS-LIDVZ-OP-TAAL and WS-LIDVZ-AP-TAAL = 0
   - **Action**: Set BBF-N54-DIAG = "TAALCODE ONBEK/CODE LING INCON"
   - **Logging**: Write to rejection list 500004
   - **Recovery**: PERFORM CREER-REMOTE-500004, PERFORM FIN-BTM
   - **Code**: [cbl/MYFIN.cbl#L198-L210](../../../cbl/MYFIN.cbl#L198-L210)

3. **Payment Description Code Unknown**
   - **Trigger**: Parameter record not found for TRBFN-CODE-LIBEL and language combination
   - **Action**: Set BBF-N54-DIAG = "CODE OMSCHR ONBEK/CODE LIBEL INCON"
   - **Logging**: Write to rejection list 500004
   - **Recovery**: PERFORM CREER-REMOTE-500004, PERFORM FIN-BTM
   - **Code**: [cbl/MYFIN.cbl#L233-L278](../../../cbl/MYFIN.cbl#L233-L278)

4. **Insurance Section Not Found**
   - **Trigger**: SW-TROUVE = "NOK" after RECHERCHE-SECTION
   - **Action**: Set appropriate rejection diagnostic
   - **Logging**: Write to rejection list 500004
   - **Recovery**: Terminate payment processing

## Integration Points

### Database

**Files/Records:**
- MUTF08 (Member Database): READ operations
  - Source: [cbl/MYFIN.cbl#L190](../../../cbl/MYFIN.cbl#L190)
  - Purpose: Verify member existence via national registry number
  - Key: RNRBIN (binary national registry number)

- LIDVZ (Member Insurance Data): READ operations
  - Source: [cbl/MYFIN.cbl#L633-L706](../../../cbl/MYFIN.cbl#L633-L706)
  - Copybook: [copy/lidvzasd.cpy](../../../copy/lidvzasd.cpy) (via COPY LIDVZASD)
  - Purpose: Find active insurance section and language preference
  - Sections checked: OT (open holder), OP (open PAC), AT (closed holder), AP (closed PAC)

- PAR (Parameter Table): READ operations
  - Source: [cbl/MYFIN.cbl#L233-L238](../../../cbl/MYFIN.cbl#L233-L238)
  - Purpose: Retrieve payment description text by code and language
  - Key: TRBFN-CODE-LIBEL + ADM-TAAL

- ADM (Administrative Data): READ operations
  - Source: [cbl/MYFIN.cbl#L198](../../../cbl/MYFIN.cbl#L198)
  - Purpose: Retrieve member name, address, language preference
  - Fields: ADM-TAAL, ADM-NAAM, ADM-VOORN, ADM-STRAAT, etc.

### External Systems

**Rejection List Generation:**
- **Type**: File output (remote printing record)
- **Purpose**: Record validation failures for administrator review
- **Interface**: BFN54GZR copybook structure
- **Error Handling**: Record created with bilingual diagnostic message
- **List Variants**: 500004 (general), 500074 (Flemish), 500094 (Walloon), 500064 (Brussels), 500084 (German)

## Configuration

| Parameter | Source | Required | Default | Description |
|-----------|--------|----------|---------|-------------|
| RNRBIN | Input TRBFN-PPR-RNR | Yes | N/A | Binary national registry number for member lookup |
| GETTP | Program constant | Yes | 1 | Type of administrative data retrieval |
| STAT1 | Database status | Yes | 0 | Database operation status (0=success) |

## Implementation Notes

### Code References

- **Main Implementation**: 
  - Source: [cbl/MYFIN.cbl#L180-L295](../../../cbl/MYFIN.cbl#L180-L295)
  - Main section: TRAITEMENT-BTM SECTION
- **Member Validation**: 
  - Source: [cbl/MYFIN.cbl#L190](../../../cbl/MYFIN.cbl#L190) - PERFORM SCH-LID
  - Source: [cbl/MYFIN.cbl#L229](../../../cbl/MYFIN.cbl#L229) - PERFORM SCH-LID08
- **Section Search**: 
  - Source: [cbl/MYFIN.cbl#L633-L706](../../../cbl/MYFIN.cbl#L633-L706) - RECHERCHE-SECTION paragraph
- **Language Code Handling**: 
  - Source: [cbl/MYFIN.cbl#L198-L210](../../../cbl/MYFIN.cbl#L198-L210) - GET-ADM and language fallback logic
- **Description Lookup**: 
  - Source: [cbl/MYFIN.cbl#L233-L278](../../../cbl/MYFIN.cbl#L233-L278) - Parameter retrieval loop

### Design Patterns Used

- **Early Termination**: Validation stops at first failure to avoid unnecessary processing
- **Fail-Fast**: Each validation step checks result before proceeding to next step
- **Language Fallback**: Multiple attempts to determine language (ADM-TAAL, then LIDVZ section language)
- **Bilingual Messaging**: All error diagnostics provided in Dutch/French format ("NL TEXT/FR TEXT")

### Dependencies

- **Copybooks**: 
  - TRBFNCXP.cpy: Input record structure
  - BFN54GZR.cpy: Rejection list output structure
  - LIDVZASD: Member insurance data access
  - WRNRSXDW: National registry number handling
- **Called Programs**: None for input validation (uses inline processing)
- **System Services**: 
  - Database access for MUTF08, LIDVZ, PAR, ADM tables
  - COPY LIDVZASD for member data retrieval

## Test Scenarios

### Positive Tests

1. **Valid payment with all required fields**
   - Input: Complete TRBFNCXP record with valid member, language code, description code
   - Expected: All validation checks pass, processing continues to duplicate check

2. **Bilingual mutuality member**
   - Input: Member from mutuality 106, 107, 150, or 166 with language preference
   - Expected: Correct language selected, appropriate description retrieved

3. **Regional accounting payment**
   - Input: TRBFN-TYPE-COMPTA = 3, 4, 5, or 6 with valid member
   - Expected: Validation passes, regional federation codes set correctly

### Negative Tests

1. **Member not found**
   - Input: Invalid TRBFN-PPR-RNR not in MUTF08
   - Expected: STAT1 NOT = ZEROES, rejection with "LIDNR ONBEKEND/AFFILIE INCONNU"

2. **Language code unknown**
   - Input: Member with ADM-TAAL = 0 and no section language
   - Expected: Rejection with "TAALCODE ONBEK/CODE LING INCON"

3. **Invalid payment description code**
   - Input: TRBFN-CODE-LIBEL = 70 (withdrawn per MTU01 modification) or unknown code
   - Expected: Parameter not found, rejection with "CODE OMSCHR ONBEK/CODE LIBEL INCON"

4. **No active insurance section**
   - Input: Member with only product codes 609, 659, 679, 689 (excluded codes)
   - Expected: SW-TROUVE = "NOK", payment rejected

## Acceptance Criteria

- [x] Member existence verified via MUTF08 database lookup
- [x] Active insurance section found in LIDVZ (OT, OP, AT, or AP)
- [x] Language code determined (1=FR, 2=NL, 3=DE) with fallback logic
- [x] Payment description code validated against PAR parameter table
- [x] Bilingual error messages generated for all validation failures
- [x] Rejection records written to appropriate list (500004 or regional variant)
- [x] Processing terminates immediately upon first validation failure
- [x] Excluded product codes (609, 659, 679, 689) correctly filtered from section search

## Open Issues

- [ ] Clarify handling of mutuality code 141 special case (generates list 541001)
- [ ] Document complete list of valid TRBFN-CODE-LIBEL values and their descriptions
- [ ] Confirm performance targets for batch processing (current: ~100ms per member lookup)
