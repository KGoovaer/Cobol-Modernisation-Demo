# Data Structure: INFPRGZP - Inforek Payment Input Record

**ID**: DS_INFPRGZP  
**Type**: Input Record (Reference Only)  
**Source**: BTM input record structure  
**Used By**: INFPRCX4 program (not MYFIN)  
**Record Code**: Not specified  
**Record Name**: INFPRGZP  
**Last Updated**: 2026-01-29

## Overview

INFPRGZP is an input record structure for batch payment processing in the Inforek system. **This copybook is referenced in the MYFIN workspace but is NOT directly used by the MYFIN program.** The structure is documented here for completeness and to understand the broader payment processing ecosystem.

This record contains detailed payment information including healthcare provider data, benefits information, and IBAN/SEPA fields for modern payment processing.

## Important Note

**⚠️ MYFIN Usage**: This copybook is present in the workspace but is NOT copied or used in the MYFIN program. The primary input structure for MYFIN is [TRBFNCXP](DS_TRBFNCXP.md).

**Purpose in Workspace**: Likely included for reference, shared library purposes, or historical reasons. The related program would be **INFPRCX4**, not MYFIN.

## Record Specification

**Copybook**: [copy/infprgzp.cpy](../../../copy/infprgzp.cpy)  
**Purpose**: Input record for BTM program INFPRCX4  
**Record Type**: Fixed-length sequential  
**Encoding**: EBCDIC (mainframe)

## Historical Context

### MIS001 Modification (2010-11-22)
- **Date**: November 22, 2010
- **Purpose**: SEPA adaptations (IBAN support)
- **Impact**: Added IN-REKNUM-IBAN field (34 bytes)
- **Marker**: Fields marked with 'MIS001'

### JGO Modification (2018-10-15)
- **Date**: October 15, 2018
- **Purpose**: 6th State Reform
- **Impact**: Added regional accounting fields
- **Reference**: R224154
- **Marker**: Fields marked with 'JGO'

### 224154 Modification
- **Purpose**: Regional accounting tags
- **Impact**: Added IN-TAGREG-OP and IN-TAGREG-LEG fields

## Field-Level Documentation

### Record Header (Control Fields)

#### IN-LENGTH
```cobol
05 IN-LENGTH    PIC S9(04) COMP.
```
- **Purpose**: Record length indicator
- **Type**: Binary signed integer (2 bytes)
- **Usage**: Defines total record length

#### IN-CODE
```cobol
05 IN-CODE      PIC S9(04) COMP.
```
- **Purpose**: Record type code
- **Type**: Binary signed integer (2 bytes)
- **Usage**: Identifies record type for routing

#### IN-NUMBER
```cobol
05 IN-NUMBER    PIC 9(08).
```
- **Purpose**: Record sequence number
- **Type**: Numeric (8 digits)
- **Range**: 00000000-99999999

### PPR Identification Fields

#### IN-PPR-NAME
```cobol
05 IN-PPR-NAME  PIC X(06).
```
- **Purpose**: Pre-processing record name
- **Type**: Alphanumeric (6 characters)

#### IN-PPR-FED
```cobol
05 IN-PPR-FED   PIC 9(03).
```
- **Purpose**: Federation (mutuality) code
- **Type**: Numeric (3 digits)
- **Range**: 101-169 (valid mutuality codes)

#### IN-PPR-RNR
```cobol
05 IN-PPR-RNR   PIC S9(08) COMP.
```
- **Purpose**: National registry number (binary)
- **Type**: Binary signed integer (4 bytes)
- **Usage**: Member identification key

### BBF Data Group (IN-DATA-BBF)

#### IN-VBOND
```cobol
10 IN-VBOND     PIC 9(02).
```
- **Purpose**: Mutuality bond/association number
- **Type**: Numeric (2 digits)
- **Usage**: Identifies specific mutuality within federation

#### IN-KONST (Constant Group)
```cobol
10 IN-KONST.
   15 IN-AFDEL      PIC 9(03).
   15 IN-KASSIER    PIC 9(03).
   15 IN-DATZIT-DM  PIC 9(04).
```

**IN-AFDEL** (Department):
- **Purpose**: Department or section code
- **Type**: Numeric (3 digits)

**IN-KASSIER** (Cashier):
- **Purpose**: Cashier or counter identifier
- **Type**: Numeric (3 digits)

**IN-DATZIT-DM** (Date):
- **Purpose**: Sitting date in MMDD format
- **Type**: Numeric (4 digits)
- **Format**: MMDD (month-day)

#### IN-BETWYZ
```cobol
10 IN-BETWYZ    PIC X(01).
```
- **Purpose**: Payment method indicator
- **Type**: Alphanumeric (1 character)
- **Valid Values**:
  - Space: SEPA transfer
  - 'C': Circular cheque
- **Usage**: Determines payment processing type

#### IN-RNR
```cobol
10 IN-RNR       PIC X(13).
```
- **Purpose**: National registry number (alphanumeric)
- **Type**: Alphanumeric (13 characters)
- **Format**: "YY.MM.DD-NNN.CC" or similar

#### IN-BETKOD
```cobol
10 IN-BETKOD    PIC 9(02).
```
- **Purpose**: Payment reason/type code
- **Type**: Numeric (2 digits)
- **Usage**: Classifies payment reason

#### IN-REKNUM / IN-REKNR
```cobol
10 IN-REKNUM                PIC 9(12).
10 IN-REKNR REDEFINES IN-REKNUM.
   15 IN-REKNR-PART1        PIC 9(03).
   15 IN-REKNR-PART2        PIC 9(07).
   15 IN-REKNR-PART3        PIC 9(02).
```
- **Purpose**: Bank account number (legacy format)
- **Type**: Numeric (12 digits)
- **Format**: BBB-NNNNNNN-CC
  - PART1: Bank code (3 digits)
  - PART2: Account number (7 digits)
  - PART3: Check digits (2 digits)

#### IN-VOLGNR-M30
```cobol
10 IN-VOLGNR-M30    PIC 9(03).
```
- **Purpose**: Sequence number M30
- **Type**: Numeric (3 digits)
- **Range**: 001-999

#### IN-INFOREK
```cobol
10 IN-INFOREK       PIC 9(01).
```
- **Purpose**: Inforek indicator flag
- **Type**: Numeric (1 digit)
- **Usage**: Indicates if additional information follows

#### IN-AANT-INF
```cobol
10 IN-AANT-INF      PIC 9(02).
```
- **Purpose**: Number of information records
- **Type**: Numeric (2 digits)
- **Range**: 00-14 (max OCCURS 14)
- **Usage**: Count of information entries in table

#### IN-BEDRAG-EUR / IN-BEDRAG-RMG-EUR
```cobol
10 IN-BEDRAG-EUR            PIC 9(08).
10 IN-BEDRAG-RMG-EUR REDEFINES IN-BEDRAG-EUR  PIC 9(11) COMP.
```
- **Purpose**: Payment amount in Euro cents
- **Type**: Numeric (8 digits) or Binary (11 digits)
- **Currency**: EUR
- **Example**: 12500 = €125.00

#### IN-BEDRAG-DV / IN-BEDRAG-RMG-DV
```cobol
10 IN-BEDRAG-DV             PIC X(01).
10 IN-BEDRAG-RMG-DV REDEFINES IN-BEDRAG-DV  PIC X(01).
```
- **Purpose**: Amount currency indicator
- **Type**: Alphanumeric (1 character)

#### IN-REKNUM-IBAN (MIS001)
```cobol
10 IN-REKNUM-IBAN   PIC X(34).
```
- **Purpose**: International Bank Account Number
- **Type**: Alphanumeric (34 characters)
- **Format**: ISO 13616 IBAN
- **Added**: MIS001 modification (2010-11-22)
- **Usage**: SEPA payment processing
- **Example**: "BE68539007547034"

### Information Table (IN-TABLE-INF)

The record includes a table of up to 14 information entries:

```cobol
10 IN-TABLE-INF.
   15 IN-DATA-INF OCCURS 14.
```

#### IN-VOL-INF
```cobol
20 IN-VOL-INF   PIC 9(02).
```
- **Purpose**: Information sequence number
- **Type**: Numeric (2 digits)
- **Range**: 01-14

#### IN-PREST / IN-PREST-R (MIS001)
```cobol
20 IN-PREST             PIC 9(12).
20 IN-PREST-R REDEFINES IN-PREST.
   25 IN-FILLER-1       PIC 9(01).
   25 IN-VERSTR-1       PIC 9(01).
   25 IN-VERSTR-2       PIC 9(01).
   25 IN-FILLER-2       PIC 9(06).
   25 IN-SPEC           PIC 9(03).
```
- **Purpose**: Healthcare provider/service information
- **Type**: Numeric (12 digits) with redefined structure
- **Components** (MIS001):
  - FILLER-1: Reserved (1 digit)
  - VERSTR-1: Provider code 1 (1 digit)
  - VERSTR-2: Provider code 2 (1 digit)
  - FILLER-2: Reserved (6 digits)
  - SPEC: Specialty code (3 digits)

#### IN-AVR (IGO)
```cobol
20 IN-AVR       PIC 9(02).
```
- **Purpose**: AVR code (healthcare provider type)
- **Type**: Numeric (2 digits)
- **Marker**: IGO modification

#### IN-AANT-PREST
```cobol
20 IN-AANT-PREST    PIC 9(02).
```
- **Purpose**: Number of services/benefits
- **Type**: Numeric (2 digits)
- **Range**: 01-99

#### IN-LAST-DATE
```cobol
20 IN-LAST-DATE     PIC 9(06).
```
- **Purpose**: Last service date
- **Type**: Numeric (6 digits)
- **Format**: YYMMDD or DDMMYY

#### IN-HONOR
```cobol
20 IN-HONOR         PIC 9(06).
```
- **Purpose**: Honorarium/fee amount (likely in cents)
- **Type**: Numeric (6 digits)
- **Example**: 012500 = €125.00

#### IN-RIJKSNR
```cobol
20 IN-RIJKSNR       PIC X(13).
```
- **Purpose**: Provider's national registry number
- **Type**: Alphanumeric (13 characters)

#### IN-BEDRAG
```cobol
20 IN-BEDRAG        PIC 9(08).
```
- **Purpose**: Benefit amount for this entry
- **Type**: Numeric (8 digits)
- **Currency**: EUR cents

#### IN-OMSCHR3-AVR (MIS001)
```cobol
20 IN-OMSCHR3-AVR   PIC X(40).
```
- **Purpose**: Description/comment for AVR
- **Type**: Alphanumeric (40 characters)
- **Added**: MIS001 modification
- **Usage**: Additional descriptive text

#### IN-PRESTATIE (JGO)
```cobol
20 IN-PRESTATIE     PIC 9(06).
```
- **Purpose**: Service/benefit code
- **Type**: Numeric (6 digits)
- **Added**: JGO modification (6th State Reform)

### Regional Accounting Fields (224154)

#### IN-TAGREG-OP
```cobol
10 IN-TAGREG-OP     PIC 9(02).
```
- **Purpose**: Regional accounting tag (opening/operational)
- **Type**: Numeric (2 digits)
- **Added**: R224154 modification
- **Valid Values**:
  - 00: National/general
  - 01-99: Regional codes

#### IN-TAGREG-LEG
```cobol
10 IN-TAGREG-LEG    PIC 9(02).
```
- **Purpose**: Regional accounting tag (legislative)
- **Type**: Numeric (2 digits)
- **Added**: R224154 modification
- **Usage**: Complements IN-TAGREG-OP for regional tracking

## Comparison with TRBFNCXP

### Similarities

| Feature | TRBFNCXP | INFPRGZP |
|---------|----------|----------|
| Header fields | IN-LENGTH, IN-CODE, IN-NUMBER | Similar structure |
| PPR identification | TRBFN-PPR-* fields | IN-PPR-* fields |
| National registry | TRBFN-PPR-RNR, TRBFN-RNR | IN-PPR-RNR, IN-RNR |
| Payment amount | TRBFN-MONTANT | IN-BEDRAG-EUR |
| Bank account | TRBFN-REKNR | IN-REKNUM |
| IBAN support | TRBFN-IBAN | IN-REKNUM-IBAN |
| Payment method | TRBFN-BETWYZ | IN-BETWYZ |
| Regional tags | N/A (added later) | IN-TAGREG-OP/LEG |

### Differences

| Aspect | TRBFNCXP | INFPRGZP |
|--------|----------|----------|
| **Purpose** | Manual GIRBET payments | Inforek benefit payments |
| **Program** | MYFIN | INFPRCX4 |
| **Description** | Text fields (LIBELLE1/2) | Code-based (BETKOD) |
| **Constant** | 10-digit CONSTANTE | Composite (AFDEL+KASSIER+DATZIT) |
| **Detail data** | Simple payment info | Complex table (14 occurrences) |
| **Provider info** | Not included | Extensive (AVR, PREST, HONOR) |
| **Service details** | Not included | Multiple entries with dates, amounts |

### Key Distinction

**TRBFNCXP** focuses on **simple manual payments** with user-entered descriptions.  
**INFPRGZP** handles **complex healthcare benefit payments** with detailed provider and service information.

## Usage Context

### Intended Program: INFPRCX4

This copybook is designed for use in program **INFPRCX4** (not MYFIN), which likely processes:
- Healthcare provider benefits
- Multiple services per payment
- Detailed honorarium calculations
- SEPA-compliant payments with extensive metadata

### Why Present in MYFIN Workspace?

Possible reasons:
1. **Shared Library**: Common copybook library includes related structures
2. **Historical Reference**: Previous integration or migration considerations
3. **Code Reuse**: Some common field definitions may be referenced
4. **Documentation**: Maintained for understanding payment ecosystem
5. **Future Enhancement**: Potential future integration planned

## Data Relationships

### Related Data Structures

- **TRBFNCXP**: Primary input for MYFIN (manual GIRBET payments)
- **BBFPRGZP**: BBF payment processing structure
- **SEPAAUKU**: SEPA user output record (common output format)

### Processing Flow (Hypothetical for INFPRCX4)

1. **Record Input**: INFPRGZP received via program entry point
2. **Member Validation**: IN-PPR-RNR lookup in database
3. **Provider Validation**: IN-RIJKSNR verification
4. **Service Processing**: Iterate through IN-TABLE-INF (up to 14 entries)
5. **Payment Calculation**: Sum IN-BEDRAG values, validate against IN-BEDRAG-EUR
6. **IBAN Validation**: Check IN-REKNUM-IBAN format
7. **Output Generation**: Create payment records and lists

## Implementation Notes

### Code References

- **Copybook Definition**: [copy/infprgzp.cpy](../../../copy/infprgzp.cpy)
- **Not Used In**: MYFIN program (confirmed via grep search)
- **Likely Program**: INFPRCX4 (Inforek payment processing)

### Special Considerations

1. **Complex Table Structure**: 14 occurrences of detailed information
2. **Healthcare Focus**: Fields specific to provider payments (AVR, HONOR, PREST)
3. **SEPA Compliant**: MIS001 modifications for IBAN support
4. **Regional Accounting**: 6th State Reform fields for regional tracking
5. **Multi-Service**: Single payment can include multiple service entries

### Dependencies

- **Database**: Member database (MUTF08 or similar)
- **Validation**: SEPA/IBAN validation routines
- **Parameters**: Healthcare provider codes, specialty codes
- **Regional**: Regional accounting configuration

## Testing Scenarios

### Positive Tests (Hypothetical)

1. **Single Service Payment**
   - Input: INFPRGZP with 1 information entry
   - Expected: Payment processed, amount validated

2. **Multiple Services**
   - Input: INFPRGZP with 14 information entries
   - Expected: All services processed, totals calculated

3. **SEPA Payment**
   - Input: Valid IN-REKNUM-IBAN, IN-BETWYZ=space
   - Expected: SEPA transfer generated

### Negative Tests (Hypothetical)

1. **Invalid Provider**
   - Input: IN-RIJKSNR not in database
   - Expected: Rejection with provider validation error

2. **Amount Mismatch**
   - Input: Sum of IN-BEDRAG ≠ IN-BEDRAG-EUR
   - Expected: Validation error

3. **Invalid IBAN**
   - Input: Malformed IN-REKNUM-IBAN
   - Expected: IBAN validation failure

## Change History

| Date | Project/Incident | Description | Marker |
|------|------------------|-------------|--------|
| Unknown | Initial | Original Inforek payment record | - |
| 2010-11-22 | MIS001 | SEPA adaptations (IBAN) | MIS001 |
| 2018-10-15 | JGO/R224154 | 6th State Reform - regional tags | JGO, 224154 |

## Related Documentation

- **Primary Input Structure**: [DS_TRBFNCXP](DS_TRBFNCXP.md) - Actual MYFIN input
- **Discovery**: [Discovered Components](../../discovery/MYFIN/discovered-components.md)

## Conclusion

INFPRGZP is a reference data structure not actively used by MYFIN. It represents a more complex payment processing scenario focused on healthcare provider benefits with detailed service tracking. For MYFIN program documentation, refer to [TRBFNCXP](DS_TRBFNCXP.md) as the primary input structure.
