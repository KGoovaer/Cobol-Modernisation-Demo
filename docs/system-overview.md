# MYFIN System Overview

**System**: GIRBET Manual Payment Processing  
**Module**: MYFIN  
**Last Updated**: 2026-01-29  
**Version**: 1.0

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)
3. [Component Architecture](#component-architecture)
4. [Data Flow Architecture](#data-flow-architecture)
5. [Integration Architecture](#integration-architecture)
6. [Technology Stack](#technology-stack)
7. [Deployment Architecture](#deployment-architecture)
8. [Performance Characteristics](#performance-characteristics)
9. [Security Architecture](#security-architecture)
10. [Scalability & Reliability](#scalability--reliability)

---

## Executive Summary

MYFIN is a COBOL batch processing system that handles manual payment requests for Belgian mutual insurance members through the GIRBET interface. The system validates payment data, prevents duplicate payments, ensures SEPA/IBAN compliance, creates BBF payment module records and SEPA instructions, and generates comprehensive audit and reporting lists.

### Key Capabilities

- **Manual Payment Processing**: Processes individual payment requests with comprehensive validation
- **Multi-Language Support**: Handles French, Dutch, and German (Bilingue) throughout the system
- **SEPA Compliance**: Validates IBANs and generates SEPA-compliant payment instructions
- **Regional Accounting**: Supports Belgian 6th State Reform with 6 accounting types and regional routing
- **Duplicate Prevention**: Detects and prevents duplicate payments through reference tracking
- **Comprehensive Audit**: Generates multiple audit lists (500001, 500004, 500006 with regional variants)

### Business Value

- Ensures payment accuracy through multi-layer validation
- Prevents financial losses from duplicate payments
- Maintains SEPA banking compliance
- Supports Belgian multilingual legal requirements
- Enables regional accounting per Belgian federalization law
- Provides complete audit trail for financial oversight

---

## System Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "Input Layer"
        A[TRBFNCXP<br/>Input Files]
        B[INFPRGZP<br/>Alt Input Files]
    end
    
    subgraph "Processing Layer"
        C[MYFIN<br/>Batch Program]
        D[MUTF08<br/>Member DB]
        E[UAREA<br/>User DB]
    end
    
    subgraph "Business Logic"
        F[Input Validation]
        G[Member Validation]
        H[Duplicate Detection]
        I[IBAN Validation]
        J[Account Verification]
        K[Payment Creation]
    end
    
    subgraph "Output Layer"
        L[BBF Payment<br/>Module]
        M[SEPA Payment<br/>System]
        N[List Processing<br/>500001/04/06]
        O[CSV Export<br/>5DET01]
    end
    
    A --> C
    B --> C
    C --> F
    C --> D
    C --> E
    F --> G
    G --> H
    H --> I
    I --> J
    J --> K
    K --> L
    K --> M
    K --> N
    K --> O
    
    style C fill:#4CAF50,stroke:#333,stroke-width:3px,color:#fff
    style D fill:#2196F3,stroke:#333,stroke-width:2px,color:#fff
    style E fill:#2196F3,stroke:#333,stroke-width:2px,color:#fff
    style L fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
    style M fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
    style N fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
    style O fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
```

### Layered Architecture

```mermaid
graph LR
    subgraph "Presentation Layer"
        A[Input Files<br/>TRBFNCXP/INFPRGZP]
    end
    
    subgraph "Business Logic Layer"
        B[Validation Engine]
        C[Payment Processing]
        D[List Generation]
    end
    
    subgraph "Data Access Layer"
        E[MUTF08 Queries]
        F[UAREA Access]
        G[File I/O]
    end
    
    subgraph "Integration Layer"
        H[BBF Interface]
        I[SEPA Interface]
        J[CSV Export]
    end
    
    A --> B
    B --> E
    B --> F
    B --> C
    C --> G
    C --> D
    D --> H
    D --> I
    D --> J
    
    style B fill:#e3f2fd
    style C fill:#e3f2fd
    style D fill:#e3f2fd
```

---

## Component Architecture

### Core Components

```mermaid
graph TB
    subgraph "MYFIN Main Program"
        A[Main Control]
        B[Input Reader]
        C[Validation Engine]
        D[Database Access]
        E[Payment Creator]
        F[List Generator]
        G[Error Handler]
    end
    
    subgraph "Data Structures"
        H[TRBFNCXP<br/>Input Record]
        I[BBFPRGZP<br/>Payment Record]
        J[SEPAAUKU<br/>SEPA Record]
        K[BFN51GZR<br/>Detail List]
        L[BFN54GZR<br/>Error List]
        M[BFN56CXR<br/>Discrepancy List]
    end
    
    A --> B
    A --> C
    A --> E
    A --> F
    A --> G
    B --> H
    C --> D
    C --> G
    E --> I
    E --> J
    F --> K
    F --> L
    F --> M
    
    style A fill:#4CAF50,color:#fff
    style C fill:#2196F3,color:#fff
    style E fill:#FF9800,color:#fff
    style F fill:#9C27B0,color:#fff
```

### Component Responsibilities

| Component | Responsibility | Input | Output |
|-----------|---------------|-------|--------|
| **Main Control** | Orchestrate overall processing flow | - | - |
| **Input Reader** | Read and parse input records | TRBFNCXP/INFPRGZP files | Parsed input structures |
| **Validation Engine** | Validate all payment data | Input records | Validation results |
| **Database Access** | Query MUTF08 and UAREA | Member number, queries | Member data |
| **Payment Creator** | Create BBF and SEPA records | Validated data | BBFPRGZP, SEPAAUKU |
| **List Generator** | Generate audit/report lists | Payment data, errors | BFN51GZR, BFN54GZR, BFN56CXR |
| **Error Handler** | Handle errors and rejections | Error conditions | Error messages, rejection lists |

---

## Data Flow Architecture

### End-to-End Data Flow

```mermaid
flowchart TB
    Start([Start Batch]) --> Read[Read Input Record]
    Read --> Parse{Parse<br/>Format}
    
    Parse -->|TRBFNCXP| V1[Field Validation]
    Parse -->|INFPRGZP| V1
    
    V1 --> V2{Valid<br/>Format?}
    V2 -->|No| E1[Format Error]
    V2 -->|Yes| DB1[Query MUTF08<br/>Member Data]
    
    DB1 --> V3{Member<br/>Exists?}
    V3 -->|No| E2[Member Not Found]
    V3 -->|Yes| V4{Insurance<br/>Section Valid?}
    
    V4 -->|No| E3[Invalid Section]
    V4 -->|Yes| V5[Check Duplicate<br/>REF1+REF2]
    
    V5 --> V6{Is<br/>Duplicate?}
    V6 -->|Yes| E4[Duplicate Payment]
    V6 -->|No| V7[Validate IBAN<br/>ISO 13616]
    
    V7 --> V8{Valid<br/>IBAN?}
    V8 -->|No| E5[Invalid IBAN]
    V8 -->|Yes| V9[Compare Bank Account<br/>Input vs MUTF08]
    
    V9 --> V10{Account<br/>Match?}
    V10 -->|Differs| W1[Account Discrepancy<br/>Warning]
    V10 -->|Match| P1[Create Payment]
    W1 --> P1
    
    P1 --> P2[Create BBFPRGZP<br/>Payment Record]
    P2 --> P3[Create SEPAAUKU<br/>SEPA Instruction]
    P3 --> P4[Route by<br/>Accounting Type]
    
    P4 --> L1[Write to Detail List<br/>500001 + variants]
    W1 --> L2[Write to Discrepancy List<br/>500006 + variants]
    
    E1 --> L3[Write to Error List<br/>500004 + variants]
    E2 --> L3
    E3 --> L3
    E4 --> L3
    E5 --> L3
    
    L1 --> Next{More<br/>Records?}
    L2 --> Next
    L3 --> Next
    
    Next -->|Yes| Read
    Next -->|No| End([End Batch])
    
    style Start fill:#4CAF50,color:#fff
    style End fill:#4CAF50,color:#fff
    style P1 fill:#2196F3,color:#fff
    style P2 fill:#2196F3,color:#fff
    style P3 fill:#2196F3,color:#fff
    style E1 fill:#f44336,color:#fff
    style E2 fill:#f44336,color:#fff
    style E3 fill:#f44336,color:#fff
    style E4 fill:#f44336,color:#fff
    style E5 fill:#f44336,color:#fff
    style W1 fill:#FF9800,color:#fff
```

### Regional Accounting Routing

```mermaid
graph TB
    Input[Validated Payment] --> Route{Accounting<br/>Type}
    
    Route -->|Type 1| G1[General<br/>Standard Bank Code]
    Route -->|Type 2| G2[Alternative<br/>AL Bank Code]
    Route -->|Type 3| R1[Regional 1<br/>Federation 167<br/>Force Belfius]
    Route -->|Type 4| R2[Regional 2<br/>Federation 169<br/>Force Belfius]
    Route -->|Type 5| R3[Regional 3<br/>Federation 166<br/>Force Belfius]
    Route -->|Type 6| R4[Regional 4<br/>Federation 168<br/>Force Belfius]
    
    G1 --> L1[Lists 500001<br/>500004<br/>500006]
    G2 --> L1
    
    R1 --> L2[Lists 500071<br/>500074<br/>500076]
    R2 --> L3[Lists 500091<br/>500094<br/>500096]
    R3 --> L4[Lists 500061<br/>500064<br/>500066]
    R4 --> L5[Lists 500081<br/>500084<br/>500086]
    
    style Route fill:#4CAF50,color:#fff
    style G1 fill:#2196F3,color:#fff
    style G2 fill:#2196F3,color:#fff
    style R1 fill:#FF9800,color:#fff
    style R2 fill:#FF9800,color:#fff
    style R3 fill:#FF9800,color:#fff
    style R4 fill:#FF9800,color:#fff
```

### Data Transformation Flow

```mermaid
graph LR
    subgraph "Input Transformation"
        A[TRBFNCXP] -->|Parse| B[Input Structure]
        A1[INFPRGZP] -->|Parse| B
    end
    
    subgraph "Enrichment"
        B -->|Lookup| C[MUTF08 Data]
        C -->|Merge| D[Enriched Data]
    end
    
    subgraph "Validation"
        D -->|Validate| E[Validated Data]
    end
    
    subgraph "Output Transformation"
        E -->|Map| F[BBFPRGZP]
        E -->|Map| G[SEPAAUKU]
        E -->|Format| H[BFN51GZR]
        E -->|Format| I[BFN54GZR]
        E -->|Format| J[BFN56CXR]
    end
    
    style E fill:#4CAF50,color:#fff
```

---

## Integration Architecture

### External System Integration

```mermaid
graph TB
    subgraph "MYFIN System"
        A[MYFIN<br/>Main Program]
    end
    
    subgraph "Database Systems"
        B[(MUTF08<br/>Member Database)]
        C[(UAREA<br/>User Area Database)]
    end
    
    subgraph "Payment Systems"
        D[BBF Payment<br/>Module]
        E[SEPA Payment<br/>System]
    end
    
    subgraph "Reporting Systems"
        F[List Processing<br/>System]
        G[Modern Integration<br/>CSV Export]
    end
    
    subgraph "Upstream Systems"
        H[GIRBET<br/>Interface]
    end
    
    H -->|Input Files| A
    A -->|SQL Queries| B
    A -->|Data Access| C
    A -->|BBFPRGZP Records| D
    A -->|SEPAAUKU Records| E
    A -->|Print Lists| F
    A -->|CSV Files| G
    
    style A fill:#4CAF50,stroke:#333,stroke-width:3px,color:#fff
    style B fill:#2196F3,stroke:#333,stroke-width:2px,color:#fff
    style C fill:#2196F3,stroke:#333,stroke-width:2px,color:#fff
    style D fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
    style E fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
```

### Integration Points Detail

| Integration Point | Type | Protocol | Data Format | Frequency |
|------------------|------|----------|-------------|-----------|
| **GIRBET Interface** | Input | File Transfer | EBCDIC Fixed-width | Daily batch |
| **MUTF08 Database** | Query | DB2 SQL | Relational | Per payment |
| **UAREA Database** | Query | DB2 SQL | Relational | As needed |
| **BBF Payment Module** | Output | File/Queue | BBFPRGZP Copybook | Per payment |
| **SEPA Payment System** | Output | File/Queue | SEPAAUKU Copybook | Per payment |
| **List Processing** | Output | Print/File | Fixed-width Report | End of batch |
| **CSV Export (5DET01)** | Output | File | CSV | End of batch |

### Data Exchange Patterns

```mermaid
sequenceDiagram
    participant G as GIRBET Interface
    participant T as MYFIN
    participant M as MUTF08 DB
    participant B as BBF Module
    participant S as SEPA System
    participant L as List Processing
    
    G->>T: Input File (TRBFNCXP)
    loop For Each Payment
        T->>T: Parse Input Record
        T->>M: Query Member Data
        M-->>T: Member Details
        T->>T: Validate & Process
        alt Valid Payment
            T->>B: Write BBFPRGZP Record
            T->>S: Write SEPAAUKU Record
            T->>L: Accumulate Detail List
        else Invalid Payment
            T->>L: Accumulate Error List
        end
        alt Account Differs
            T->>L: Accumulate Discrepancy List
        end
    end
    T->>L: Finalize All Lists
    L-->>T: Lists Generated
```

---

## Technology Stack

### Core Technologies

```mermaid
graph TB
    subgraph "Application Layer"
        A[COBOL<br/>IBM Enterprise COBOL]
    end
    
    subgraph "Data Layer"
        B[DB2<br/>Database]
        C[VSAM<br/>File System]
    end
    
    subgraph "Runtime Environment"
        D[z/OS<br/>Mainframe OS]
        E[JCL<br/>Job Control]
    end
    
    subgraph "Standards & Protocols"
        F[SEPA<br/>ISO 20022]
        G[IBAN<br/>ISO 13616]
        H[EBCDIC<br/>Encoding]
    end
    
    A --> B
    A --> C
    A --> D
    E --> A
    A --> F
    A --> G
    A --> H
    
    style A fill:#4CAF50,color:#fff
    style B fill:#2196F3,color:#fff
    style D fill:#FF9800,color:#fff
```

### Technology Details

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Programming Language** | COBOL | IBM Enterprise COBOL | Main application logic |
| **Database** | DB2 | z/OS DB2 | Member data (MUTF08, UAREA) |
| **File System** | VSAM | z/OS | Sequential file processing |
| **Operating System** | z/OS | Mainframe | Batch execution environment |
| **Job Control** | JCL | z/OS | Batch job scheduling |
| **Encoding** | EBCDIC | Mainframe | Character encoding |
| **Banking Standard** | SEPA | ISO 20022 | Payment instructions |
| **Account Standard** | IBAN | ISO 13616 | Bank account validation |

### Copybook Dependencies

```mermaid
graph TB
    Main[MYFIN.cbl] --> C1[trbfncxp.cpy<br/>Input Structure]
    Main --> C2[infprgzp.cpy<br/>Alt Input]
    Main --> C3[bbfprgzp.cpy<br/>Payment Record]
    Main --> C4[sepaauku.cpy<br/>SEPA Record]
    Main --> C5[bfn51gzr.cpy<br/>Detail List]
    Main --> C6[bfn54gzr.cpy<br/>Error List]
    Main --> C7[trbfncxk.cpy<br/>Constants]
    
    style Main fill:#4CAF50,color:#fff
    style C1 fill:#2196F3,color:#fff
    style C2 fill:#2196F3,color:#fff
    style C3 fill:#FF9800,color:#fff
    style C4 fill:#FF9800,color:#fff
    style C5 fill:#9C27B0,color:#fff
    style C6 fill:#9C27B0,color:#fff
```

---

## Deployment Architecture

### Batch Processing Environment

```mermaid
graph TB
    subgraph "z/OS Mainframe"
        subgraph "Input Zone"
            A[GIRBET Input Files<br/>TRBFNCXP/INFPRGZP]
        end
        
        subgraph "Processing Zone"
            B[JCL Job Scheduler]
            C[MYFIN Program]
            D[DB2 Subsystem]
        end
        
        subgraph "Output Zone"
            E[BBF Payment Files<br/>BBFPRGZP]
            F[SEPA Files<br/>SEPAAUKU]
            G[Print Lists<br/>500001/04/06]
            H[CSV Export<br/>5DET01]
        end
    end
    
    A --> B
    B --> C
    C --> D
    C --> E
    C --> F
    C --> G
    C --> H
    
    style C fill:#4CAF50,stroke:#333,stroke-width:3px,color:#fff
    style D fill:#2196F3,stroke:#333,stroke-width:2px,color:#fff
```

### Execution Flow

```mermaid
sequenceDiagram
    participant S as Job Scheduler
    participant J as JCL Job
    participant P as MYFIN Program
    participant D as DB2
    participant F as Output Files
    
    S->>J: Schedule Daily Batch
    J->>J: Allocate Resources
    J->>P: Execute Program
    activate P
    P->>P: Initialize
    P->>D: Open Database Connections
    P->>P: Open Input Files
    loop Process Records
        P->>D: Query Member Data
        D-->>P: Return Data
        P->>P: Validate & Process
        P->>F: Write Output Records
    end
    P->>P: Generate Lists
    P->>F: Write Final Lists
    P->>D: Close Connections
    P->>P: Cleanup
    deactivate P
    P-->>J: Return Code
    J-->>S: Job Complete
```

---

## Performance Characteristics

### Processing Metrics

| Metric | Typical Value | Peak Value | Notes |
|--------|--------------|------------|-------|
| **Throughput** | 5,000-10,000 payments/hour | 20,000 payments/hour | Depends on DB performance |
| **Response Time** | 0.1-0.5 sec/payment | 1.0 sec/payment | Including DB lookup |
| **Batch Duration** | 30-60 minutes | 2-3 hours | For typical daily volume |
| **Database Queries** | 1 per payment | - | MUTF08 member lookup |
| **Memory Usage** | 10-20 MB | 50 MB | Working storage |
| **File I/O** | Sequential | - | Input and output files |

### Performance Optimization

```mermaid
graph LR
    subgraph "Optimization Strategies"
        A[Database Indexing<br/>MUTF08 Member Number]
        B[Sequential File Access<br/>No Random I/O]
        C[Minimal Memory<br/>Record-at-a-time]
        D[Batch Processing<br/>Off-peak Hours]
    end
    
    A --> E[Improved Performance]
    B --> E
    C --> E
    D --> E
    
    style E fill:#4CAF50,color:#fff
```

### Bottleneck Analysis

```mermaid
graph TB
    A[Performance Bottlenecks] --> B[DB2 MUTF08 Lookups]
    A --> C[IBAN Validation Algorithm]
    A --> D[List Formatting]
    
    B --> B1[Solution: Index Optimization]
    B --> B2[Solution: Connection Pooling]
    
    C --> C1[Solution: Optimized Algorithm]
    
    D --> D1[Solution: Buffered Writes]
    
    style A fill:#f44336,color:#fff
    style B1 fill:#4CAF50,color:#fff
    style B2 fill:#4CAF50,color:#fff
    style C1 fill:#4CAF50,color:#fff
    style D1 fill:#4CAF50,color:#fff
```

---

## Security Architecture

### Security Layers

```mermaid
graph TB
    subgraph "Access Control"
        A[User Authentication<br/>RACF/ACF2]
        B[File Access Control<br/>Dataset Permissions]
        C[Database Security<br/>DB2 Grants]
    end
    
    subgraph "Data Security"
        D[Data Encryption<br/>At Rest]
        E[Audit Logging<br/>All Operations]
        F[Data Masking<br/>Sensitive Fields]
    end
    
    subgraph "Network Security"
        G[Mainframe Firewall]
        H[Encrypted Channels<br/>DB2 Communication]
    end
    
    A --> E
    B --> E
    C --> E
    D --> E
    
    style A fill:#2196F3,color:#fff
    style D fill:#FF9800,color:#fff
    style E fill:#4CAF50,color:#fff
```

### Security Controls

| Control Type | Implementation | Purpose |
|-------------|----------------|---------|
| **Authentication** | RACF/ACF2 | User identity verification |
| **Authorization** | Dataset permissions | File access control |
| **Database Security** | DB2 grants | MUTF08/UAREA access control |
| **Audit Logging** | System logs | Track all operations |
| **Data Protection** | IBAN partial masking | Protect sensitive account data |
| **Segregation of Duties** | Role-based access | Prevent unauthorized changes |

### Sensitive Data Handling

```mermaid
graph LR
    A[Input Data] --> B{Classify Data}
    B -->|PII| C[Member Number<br/>National Registry]
    B -->|Financial| D[Bank Account<br/>IBAN]
    B -->|General| E[Payment Amount<br/>References]
    
    C --> F[Masked in Logs]
    D --> G[Encrypted Storage]
    E --> H[Normal Processing]
    
    style C fill:#f44336,color:#fff
    style D fill:#FF9800,color:#fff
    style E fill:#4CAF50,color:#fff
```

---

## Scalability & Reliability

### Scalability Characteristics

```mermaid
graph TB
    subgraph "Vertical Scaling"
        A[Increase CPU<br/>MIPS/MSU]
        B[Increase Memory<br/>Working Storage]
        C[Optimize DB Indexes<br/>MUTF08]
    end
    
    subgraph "Horizontal Scaling"
        D[Parallel Processing<br/>Split Input Files]
        E[Regional Partitioning<br/>6 Accounting Types]
    end
    
    A --> F[Handle Higher Volume]
    B --> F
    C --> F
    D --> F
    E --> F
    
    style F fill:#4CAF50,color:#fff
```

### Reliability Features

| Feature | Implementation | Benefit |
|---------|----------------|---------|
| **Error Handling** | Comprehensive validation | Prevent bad data propagation |
| **Checkpoint/Restart** | JCL checkpoints | Resume after failure |
| **Transaction Integrity** | Atomic DB operations | Data consistency |
| **Duplicate Detection** | Reference tracking | Prevent double payments |
| **Audit Trail** | Complete logging | Traceability |
| **Bilingual Errors** | FR/NL/DE messages | Clear error communication |

### Fault Tolerance

```mermaid
graph TB
    A[Batch Execution] --> B{Failure?}
    
    B -->|DB Error| C[Log Error<br/>Continue Next Record]
    B -->|Validation Error| D[Write to Error List<br/>Continue Processing]
    B -->|System Error| E[JCL Checkpoint<br/>Restart Capability]
    B -->|No Error| F[Normal Processing]
    
    C --> G[End of Batch<br/>Generate Reports]
    D --> G
    E --> A
    F --> G
    
    style B fill:#FF9800,color:#fff
    style G fill:#4CAF50,color:#fff
```

### Disaster Recovery

```mermaid
graph LR
    subgraph "Primary Site"
        A[Production System]
        B[Production DB2]
    end
    
    subgraph "DR Site"
        C[Standby System]
        D[Replicated DB2]
    end
    
    subgraph "Backup Strategy"
        E[Daily Backups]
        F[Transaction Logs]
    end
    
    A -.->|Replicate| C
    B -.->|Replicate| D
    A --> E
    B --> F
    
    style A fill:#4CAF50,color:#fff
    style C fill:#FF9800,color:#fff
```

---

## System Constraints & Limitations

### Current Limitations

| Limitation | Description | Impact | Mitigation |
|-----------|-------------|--------|------------|
| **Batch-Only Processing** | No real-time capability | Delayed processing | Schedule frequent batches |
| **Sequential Processing** | One record at a time | Limited throughput | Optimize algorithms |
| **Database Dependency** | Requires MUTF08 availability | Single point of failure | DB replication |
| **Mainframe Platform** | z/OS dependency | Platform lock-in | Document for migration |
| **Fixed Accounting Types** | 6 types hardcoded | Inflexible | Configuration externalization |

### Technical Debt

```mermaid
graph TB
    A[Technical Debt Areas] --> B[Hardcoded Values<br/>Accounting Types, Federations]
    A --> C[Monolithic Design<br/>Single Large Program]
    A --> D[Limited Error Recovery<br/>Record-level Only]
    A --> E[Manual List Distribution<br/>No Automation]
    
    B --> F[Refactoring Needed]
    C --> F
    D --> F
    E --> F
    
    style A fill:#FF9800,color:#fff
    style F fill:#f44336,color:#fff
```

---

## Modernization Opportunities

### Potential Improvements

```mermaid
graph TB
    subgraph "Architecture Modernization"
        A[Microservices<br/>Decomposition]
        B[API Layer<br/>REST/GraphQL]
        C[Event-Driven<br/>Real-time Processing]
    end
    
    subgraph "Technology Modernization"
        D[Cloud Migration<br/>Azure/AWS]
        E[Container Deployment<br/>Kubernetes]
        F[Modern DB<br/>PostgreSQL/SQL Server]
    end
    
    subgraph "Process Modernization"
        G[CI/CD Pipeline<br/>Automated Deployment]
        H[Monitoring<br/>Observability]
        I[Self-Service<br/>Portal]
    end
    
    style A fill:#4CAF50,color:#fff
    style D fill:#2196F3,color:#fff
    style G fill:#FF9800,color:#fff
```

### Migration Path

```mermaid
graph LR
    A[Current COBOL<br/>Mainframe] --> B[Phase 1:<br/>Extract Services]
    B --> C[Phase 2:<br/>API Wrapper]
    C --> D[Phase 3:<br/>Rewrite Core Logic]
    D --> E[Phase 4:<br/>Cloud Native]
    
    style A fill:#f44336,color:#fff
    style E fill:#4CAF50,color:#fff
```

---

## Related Documentation

- **[Main Documentation Index](index.md)** - Complete documentation overview
- **[Business Documentation](business/index.md)** - Use cases and business processes
- **[Functional Documentation](functional/index.md)** - Technical specifications
- **[Traceability Matrix](traceability/requirements-map.md)** - Requirements mapping
- **[Requirement Matrix (Coordination)](traceability/requirement-matrix.md)** - Consolidated BUREQ -> UC -> FUREQ mapping
- **[Flow-to-Component Map](traceability/flow-to-component-map.md)** - Technical flow/component traceability
- **[ID Registry](traceability/id-registry.md)** - Unique identifier registry across artifacts
- **[Domain Concepts Catalog](domain/domain-concepts-catalog.md)** - Consolidated domain concept definitions
- **[Data Structures](functional/integration/data-structures.md)** - Complete data catalog

---

## Appendix

### Glossary

| Term | Definition |
|------|------------|
| **BBF** | Belgian payment module system |
| **GIRBET** | Manual payment interface system |
| **IBAN** | International Bank Account Number (ISO 13616) |
| **MUTF08** | Member database containing insurance member data |
| **SEPA** | Single Euro Payments Area (ISO 20022) |
| **6th State Reform** | Belgian federal reform requiring regional accounting separation |
| **Bilingue** | Bilingual (French/Dutch) support throughout Belgium |

### Acronyms

| Acronym | Expansion |
|---------|-----------|
| **COBOL** | Common Business-Oriented Language |
| **DB2** | Database 2 (IBM relational database) |
| **EBCDIC** | Extended Binary Coded Decimal Interchange Code |
| **JCL** | Job Control Language |
| **VSAM** | Virtual Storage Access Method |
| **z/OS** | Zero downtime Operating System (IBM mainframe OS) |

---

*This system overview was created through comprehensive analysis of the MYFIN COBOL program, copybooks, and business requirements. Last updated: 2026-01-29.*
