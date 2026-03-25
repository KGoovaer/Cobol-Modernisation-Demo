# MYFIN Documentation Plan

**Module**: MYFIN  
**Description**: Batch program for manual GIRBET payment processing  
**Language**: COBOL  
**Status**: Planning Phase  
**Created**: 2026-01-28

## Executive Summary

MYFIN is a COBOL batch program that processes manual payment records for the GIRBET system. It validates member data, bank account information, handles IBAN/SEPA compliance, and generates payment lists for Belfius and KBC banks.

### Key Characteristics
- **Complexity**: Medium-High
- **Estimated Documentation Effort**: 10-17 hours
- **Total Batches**: 12 (across 4 phases)
- **Lines of Code**: ~1,394 lines
- **Copybooks**: 7 files

## Documentation Phases & Batches

### Phase 1: Discovery (Batches 1.1-1.3) - Est. 2-3 hours

#### Batch 1.1 - Code Structure Analysis
**Duration**: 30-45 minutes  
**Agent**: `@discovery.agent`  
**Command**:
```bash
@discovery.agent analyze-structure MYFIN --language cobol
```

**Objectives**:
- Identify all program sections and paragraphs
- Map COPY statements and dependencies
- Catalog database operations (MUTF08, UAREA)
- Document entry points (GIRBETPP)
- List all PERFORM statements and flow control
- Identify error handling sections

**Output**: `docs/discovery/MYFIN/discovered-components.md`

---

#### Batch 1.2 - Data Structure Discovery
**Duration**: 45-60 minutes  
**Agent**: `@discovery.agent`  
**Command**:
```bash
@discovery.agent extract-data-structures MYFIN --language cobol
```

**Objectives**:
- Analyze TRBFNCXP (input record structure)
- Analyze BFN51GZR (list 500001 structure)
- Analyze BFN54GZR (list 500004 structure)
- Analyze BBFPRGZP, INFPRGZP, SEPAAUKU copybooks
- Map field-level data types and constraints
- Document REDEFINES and complex structures
- Identify IBAN/SEPA data fields

**Output**: `docs/discovery/MYFIN/discovered-domain-concepts.md`

---

#### Batch 1.3 - Flow & Integration Analysis
**Duration**: 45-90 minutes  
**Agent**: `@discovery.agent`  
**Command**:
```bash
@discovery.agent trace-flows MYFIN --language cobol
```

**Objectives**:
- Trace main processing flow (TRAITEMENT-BTM)
- Map member lookup flow (SCH-LID, SCH-LID08)
- Document bank account validation flow
- Identify payment list creation logic
- Map error handling and rejection paths (500004 remotes)
- Document database read/write operations
- Catalog conditional logic (language selection, payment types)

**Output**: `docs/discovery/MYFIN/discovered-flows.md`

---

### Phase 2: Business Documentation (Batches 2.1-2.3) - Est. 3-4 hours

#### Batch 2.1 - Use Case Development
**Duration**: 60-90 minutes  
**Agent**: `@business.agent`  
**Command**:
```bash
@business.agent derive-use-cases MYFIN --from-discovery
```

**Objectives**:
- **UC_MYFIN_001**: Process Manual Payment Request
  - Actor: GIRBET Batch System
  - Preconditions: Valid input record
  - Main flow: Validate → Process → Generate output
  
- **UC_MYFIN_002**: Validate Payment Data
  - Actor: System
  - Business rules: Member validation, IBAN validation, language detection
  
- **UC_MYFIN_003**: Generate Payment Lists
  - Actor: System
  - Outputs: Lists 500001 (details), 500004 (errors)

**Outputs**:
- `docs/business/use-cases/UC_MYFIN_001_process_manual_payment.md`
- `docs/business/use-cases/UC_MYFIN_002_validate_payment_data.md`
- `docs/business/use-cases/UC_MYFIN_003_generate_payment_lists.md`

---

#### Batch 2.2 - Business Process Diagrams
**Duration**: 45-60 minutes  
**Agent**: `@business.agent`  
**Command**:
```bash
@business.agent create-process-diagrams MYFIN
```

**Objectives**:
- Create high-level GIRBET payment process flow
- Map decision points (language selection, payment type routing)
- Document business outcomes (successful payment vs. rejection)
- Show integration with Belfius/KBC banks
- Illustrate multi-language handling (FR/NL/DE/Bilingue)

**Output**: `docs/business/processes/BP_MYFIN_manual_payment_processing.md`

---

#### Batch 2.3 - Business Overview & Actors
**Duration**: 30-45 minutes  
**Agent**: `@business.agent`  
**Command**:
```bash
@business.agent document-overview MYFIN
```

**Objectives**:
- Write system overview explaining GIRBET payment context
- Define actors (Batch Processor, Member Database, Banks)
- Document business events and triggers
- Explain mutuality federations (109-169)
- Describe payment types (circular cheques, transfers)
- Document language regions and handling

**Outputs**:
- `docs/business/overview/MYFIN-overview.md`
- `docs/business/actors/actors-catalog.md`
- `docs/business/index.md`

---

### Phase 3: Functional Documentation (Batches 3.1-3.4) - Est. 4-7 hours

#### Batch 3.1 - Functional Requirements Derivation
**Duration**: 90-120 minutes  
**Agent**: `@functional.agent`  
**Command**:
```bash
@functional.agent derive-requirements MYFIN --from-business
```

**Objectives**:
Derive detailed functional requirements from code:

- **FUREQ_001**: Input Record Validation
  - Validate TRBFN-PPR-RNR (member number)
  - Validate payment amount
  - Validate bank account number
  - Validate payment code (TRBFN-CODE-LIBEL)
  
- **FUREQ_002**: Member Data Lookup
  - Search MUTF08 database
  - Retrieve member address
  - Determine language preference (ADM-TAAL)
  - Handle missing members
  
- **FUREQ_003**: Bank Account Validation
  - IBAN format validation
  - BIC code lookup
  - Country code validation for circular cheques
  - Handle account discrepancies (REMOTE 500006)
  
- **FUREQ_004**: Payment List Generation
  - Create 500001 records (valid payments)
  - Create 500004 records (rejections)
  - Format output according to bank requirements
  
- **FUREQ_005**: Error Handling
  - Member not found → 500004
  - Invalid IBAN → 500004
  - Unknown language code → 500004
  - Duplicate payment detection

**Outputs**:
- `docs/functional/requirements/FUREQ_MYFIN_001_input_validation.md`
- `docs/functional/requirements/FUREQ_MYFIN_002_member_lookup.md`
- `docs/functional/requirements/FUREQ_MYFIN_003_bank_account_validation.md`
- `docs/functional/requirements/FUREQ_MYFIN_004_payment_list_generation.md`
- `docs/functional/requirements/FUREQ_MYFIN_005_error_handling.md`

---

#### Batch 3.2 - Data Structure Documentation
**Duration**: 60-90 minutes  
**Agent**: `@functional.agent`  
**Command**:
```bash
@functional.agent document-data-structures MYFIN
```

**Objectives**:
- Document TRBFNCXP input layout with field specifications
- Document BFN51GZR output layout (list 500001)
- Document BFN54GZR output layout (list 500004)
- Document BBF module structure
- Map SEPA/IBAN structures (SEPAAUKU)
- Specify validation rules per field
- Document data transformations (input → BBF → output)

**Output**: `docs/functional/integration/data-structures.md`

---

#### Batch 3.3 - Technical Flow Diagrams
**Duration**: 60-90 minutes  
**Agent**: `@functional.agent`  
**Command**:
```bash
@functional.agent create-flow-diagrams MYFIN
```

**Objectives**:
- Create detailed sequence diagram for main processing flow
- Create error flow diagram showing all rejection paths
- Document paragraph call hierarchy
- Show database interaction sequences
- Illustrate language selection logic
- Map payment type routing (circular cheque vs. transfer)

**Outputs**:
- `docs/functional/flows/FF_MYFIN_main_processing.md`
- `docs/functional/flows/FF_MYFIN_error_handling.md`

---

#### Batch 3.4 - Integration Specifications
**Duration**: 45-60 minutes  
**Agent**: `@functional.agent`  
**Command**:
```bash
@functional.agent document-integrations MYFIN
```

**Objectives**:
- Document input interface (TRBFNCXP record format)
- Document output interfaces (lists 500001, 500004)
- Specify database integration (MUTF08, UAREA)
- Document SEPA validation integration
- Specify error codes and diagnostics
- Document bank routing logic (Belfius/KBC)

**Outputs**:
- `docs/functional/integration/INT_input_records.md`
- `docs/functional/integration/INT_output_lists.md`

---

### Phase 4: Coordination & Completion (Batches 4.1-4.2) - Est. 1-2 hours

#### Batch 4.1 - Documentation Structure & Indexes
**Duration**: 30-45 minutes  
**Agent**: `@coordination.agent`  
**Command**:
```bash
@coordination.agent build-indexes MYFIN
```

**Objectives**:
- Create main documentation index (docs/index.md)
- Build traceability matrix (Use Cases → Requirements → Code)
- Create requirement mapping document
- Generate glossary of terms
- Build navigation structure
- Create quick reference guide

**Outputs**:
- `docs/index.md`
- `docs/traceability/requirements-map.md`

---

#### Batch 4.2 - Validation & Completeness Check
**Duration**: 30-45 minutes  
**Agent**: `@coordination.agent`  
**Command**:
```bash
@coordination.agent validate-completeness MYFIN
```

**Objectives**:
- Verify all planned artifacts exist
- Check all requirements have traceability to code
- Validate cross-references are valid
- Ensure all copybooks are documented
- Verify diagram accuracy
- Generate completion report

**Output**: `docs/planning/MYFIN-completion-report.md`

---

## Source Files Inventory

### Main Program
- `cbl/MYFIN.cbl` (1,394 lines)

### Input/Output Copybooks
- `copy/trbfncxp.cpy` - Input record structure
- `copy/bfn51gzr.cpy` - Output list 500001 (payment details)
- `copy/bfn54gzr.cpy` - Output list 500004 (rejections)

### Supporting Copybooks
- `copy/bbfprgzp.cpy` - BBF module structure
- `copy/infprgzp.cpy` - Information structure
- `copy/sepaauku.cpy` - SEPA/IBAN utilities
- `copy/trbfncxk.cpy` - Additional structures

### External Dependencies
- MUTF08 database (member master data)
- UAREA database (user area)
- LIDVZASW, VBONDASW, TBLIBCXW (working storage copies)

---

## Special Considerations

### Historical Modifications
The code contains extensive modification history:
- **IBAN10**: SEPA/IBAN compliance modifications
- **JGO004**: Language code handling (ADM-TAAL = 0)
- **279363**: National registry number handling
- **CDU001**: 6th State Reform (mutuality codes)
- **KVS001**: JIRA-4224 - CSV format instead of Papyrus
- **KVS002**: JIRA-4311 - PAIFIN-Belfius adaptation
- **MSA001**: JIRA-4837 - Corrections
- **MSA002**: JIRA-???? - Bulk processing

### Multi-Language Complexity
- French federations: 109, 116, 127-136, 167-168
- Dutch federations: 101-102, 104-105, 108, 110-122, 126, 131, 169
- Bilingual federations: 106-107, 150, 166
- Verviers (German): 137

### Payment Processing
- Dual bank routing: Belfius and KBC (R140562)
- Circular cheque restrictions (Belgian addresses only)
- Bank account discrepancy handling (REMOTE 500006)

---

## Progress Tracking

Current progress will be maintained in `docs/planning/MYFIN-state.json`:
- **Overall Progress**: 0%
- **Current Phase**: Discovery
- **Current Batch**: 1.1
- **Next Action**: Run discovery.agent to analyze code structure

---

## Getting Started

### Step 1: Initialize Discovery Phase
```bash
@discovery.agent analyze-structure MYFIN --language cobol
```

### Step 2: Update State After Batch Completion
```bash
@planning.agent complete-batch 1.1 --module MYFIN
```

### Step 3: Check Status
```bash
@planning.agent status MYFIN
```

### Step 4: Resume Work
```bash
@planning.agent resume MYFIN
```

---

## Expected Deliverables

By completion of all 12 batches, the following documentation will exist:

### Discovery Phase (3 documents)
- Component analysis
- Domain concepts
- Flow analysis

### Business Phase (7 documents)
- 3 Use case specifications
- 1 Process diagram
- 1 System overview
- 1 Actor catalog
- 1 Business index

### Functional Phase (10 documents)
- 5 Functional requirements
- 2 Flow diagrams
- 2 Integration specifications
- 1 Data structure reference

### Coordination Phase (3 documents)
- Main index
- Traceability matrix
- Completion report

**Total**: 23 documentation artifacts

---

## Contact & Support

For questions about this documentation plan, refer to:
- Planning agent: `.github/agents/planning.agent`
- Discovery agent: `.github/agents/discovery.agent`
- Business agent: `.github/agents/business.agent`
- Functional agent: `.github/agents/functional.agent`
- Coordination agent: `.github/agents/coordination.agent`

---

**Document Version**: 1.0  
**Last Updated**: 2026-01-28  
**Status**: Ready to Execute
