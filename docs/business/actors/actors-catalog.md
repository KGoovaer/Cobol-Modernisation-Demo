# Actors and Roles Catalog - MYFIN

**System**: Manual GIRBET Payment Processing  
**Last Updated**: 2026-01-28

## Overview

This document catalogs all actors (human and system) that interact with or are involved in the MYFIN manual payment processing system. Each actor is described with their responsibilities, interactions with use cases, and business context.

---

## Human Actors

### Mutuality Administrator
- **Type**: Human
- **Organization**: Local mutual insurance organization (mutuality)
- **Responsibilities**:
  - Review payment detail lists (500001 and variants)
  - Investigate rejected payments on error lists (500004 and variants)
  - Correct invalid payment data and resubmit
  - Monitor bank account discrepancies (500006 and variants)
  - Verify payment processing completeness
  - Coordinate with finance department on payment issues
- **Use Cases Involved**:
  - UC_MYFIN_003 (consumer of generated lists)
  - Indirectly involved in UC_MYFIN_002 (interprets validation failures)
- **Business Context**: Front-line operational staff responsible for ensuring members receive correct payments. They rely on the system's comprehensive reporting to identify and resolve payment issues quickly.
- **Volume**: 50-100 administrators across all Belgian mutualities
- **Key Decisions**: Whether to resubmit rejected payments, how to correct payment data errors

### Finance Department Staff
- **Type**: Human
- **Organization**: Mutuality finance department or federation finance
- **Responsibilities**:
  - Reconcile payment lists against bank confirmations
  - Track total payment amounts by accounting type
  - Monitor payment volumes and trends
  - Ensure regional accounting separation compliance
  - Verify CSV export data (5DET01) for modern systems
  - Approve batch processing results
  - Budget tracking and financial reporting
- **Use Cases Involved**:
  - UC_MYFIN_003 (consumer of payment detail lists)
  - UC_MYFIN_001 (relies on accurate payment creation)
- **Business Context**: Responsible for financial accuracy and compliance. Need aggregated views of payments for reconciliation and reporting to management and regulators.
- **Volume**: 20-40 staff across federations
- **Key Decisions**: Approval of batch results, escalation of significant discrepancies

### Audit Team Member
- **Type**: Human
- **Organization**: Internal audit or external auditors
- **Responsibilities**:
  - Verify payment processing accuracy and completeness
  - Trace payments from input to bank transmission
  - Validate business rule compliance
  - Review rejection patterns for control effectiveness
  - Assess SEPA compliance
  - Verify regional accounting separation
  - Sample test payment accuracy
- **Use Cases Involved**:
  - All use cases (reviews controls and outputs)
  - Particularly UC_MYFIN_002 (validation controls)
- **Business Context**: Ensure organizational controls prevent financial errors and regulatory violations. Review payment system annually or upon significant changes.
- **Volume**: 5-10 auditors periodically
- **Key Decisions**: Audit findings and recommendations, control effectiveness assessments

### Bank Operations Staff
- **Type**: Human
- **Organization**: Belfius or KBC bank
- **Responsibilities**:
  - Receive SEPA payment instructions (SEPAAUKU records)
  - Process payment files through banking systems
  - Compare payment instructions against mutuality lists
  - Resolve discrepancies between files and lists
  - Report payment transmission issues
  - Confirm payment execution
- **Use Cases Involved**:
  - UC_MYFIN_001 (receives payment instructions)
  - UC_MYFIN_003 (uses payment detail lists for reconciliation)
- **Business Context**: Execute payment instructions on behalf of mutualities. Need clear, accurate payment data to prevent processing delays or errors.
- **Volume**: 10-20 staff at Belfius/KBC
- **Key Decisions**: Accept/reject payment batches, escalate technical issues

### Member (Payment Recipient)
- **Type**: Human
- **Organization**: Belgian mutual insurance member
- **Responsibilities**:
  - Provide correct bank account information (IBAN)
  - Maintain updated member profile
  - Receive payments into bank account
  - Report payment discrepancies or delays
- **Use Cases Involved**:
  - UC_MYFIN_001 (ultimate beneficiary of processed payments)
  - UC_MYFIN_002 (their data is validated)
- **Business Context**: The end beneficiary of the payment system. They rely on the system to deliver correct payments to their bank accounts without error.
- **Volume**: Hundreds of thousands of members potentially
- **Key Decisions**: Choice of bank account, notification of account changes

### IT Operations Staff
- **Type**: Human
- **Organization**: IT operations team
- **Responsibilities**:
  - Schedule and monitor batch job execution
  - Investigate batch processing failures
  - Manage database connections and availability
  - Resolve technical errors (file access, system unavailability)
  - Perform system maintenance and updates
  - Monitor batch processing performance
  - Escalate business logic issues to support teams
- **Use Cases Involved**:
  - All use cases (ensures system availability and performance)
- **Business Context**: Ensure the batch processing system runs reliably and on schedule. They keep the technical infrastructure operational but do not make business decisions about payments.
- **Volume**: 5-10 operations staff
- **Key Decisions**: When to restart failed batches, escalation of technical issues

### Data Entry Clerk
- **Type**: Human
- **Organization**: Mutuality or federation data entry department
- **Responsibilities**:
  - Create manual payment input records (TRBFNCXP)
  - Enter member national registry numbers
  - Input payment amounts and descriptions
  - Select payment description codes
  - Enter or verify IBAN information
  - Create payment batches for processing
- **Use Cases Involved**:
  - Upstream of all use cases (creates input that triggers processing)
- **Business Context**: Responsible for accurate data entry of manual payment requests. Their accuracy directly impacts validation success rates.
- **Volume**: 30-50 data entry staff
- **Key Decisions**: Selection of payment codes, verification of member data

---

## System Actors

### MYFIN Batch Processing System
- **Type**: System (Batch Program)
- **Technology**: COBOL batch program
- **Responsibilities**:
  - Read manual payment input files (TRBFNCXP records)
  - Coordinate execution of all three use cases
  - Manage database connections (MUTF08, BBF, UAREA)
  - Control batch processing workflow
  - Generate processing statistics
  - Handle errors and exceptions
  - Write output lists and files
- **Use Cases**: Primary actor for UC_MYFIN_001, UC_MYFIN_002, UC_MYFIN_003
- **Business Context**: The core payment processing engine that automates payment validation, creation, and reporting. Runs as scheduled batch job, typically daily or multiple times per day.

### Member Database (MUTF08)
- **Type**: System (Database)
- **Technology**: DB2 database
- **Responsibilities**:
  - Store and provide member administrative data
  - Maintain insurance section information (OT, OP, AT, AP)
  - Provide member language preferences
  - Store national registry numbers
  - Maintain parameter libraries (payment descriptions)
  - Track member demographic information
- **Use Cases Involved**:
  - UC_MYFIN_002 (validates member existence and retrieves data)
  - UC_MYFIN_001 (provides member context for payments)
- **Business Context**: Central repository of member information. Must be available and accurate for payment processing to succeed. Data quality here directly impacts validation success.

### Payment Module Database (BBF)
- **Type**: System (Database)
- **Technology**: DB2 database or file system
- **Responsibilities**:
  - Store historical payment records
  - Enable duplicate payment detection
  - Track payment constants and amounts
  - Provide payment history for members
  - Support payment reporting and analytics
- **Use Cases Involved**:
  - UC_MYFIN_002 (checks for duplicate payments)
  - UC_MYFIN_001 (creates new payment records)
- **Business Context**: Payment database of record. Prevents duplicate payments by maintaining complete payment history. Critical for financial controls.

### Bank Payment System (Belfius/KBC)
- **Type**: System (External Banking System)
- **Technology**: SEPA payment processing system
- **Responsibilities**:
  - Receive SEPA payment instructions (SEPAAUKU records)
  - Validate IBAN and BIC codes
  - Execute electronic fund transfers
  - Confirm payment execution
  - Report payment failures or rejections
  - Maintain payment audit trails
- **Use Cases Involved**:
  - UC_MYFIN_001 (receives payment instructions)
- **Business Context**: The actual executor of payments to member bank accounts. Relies on MYFIN to provide valid, SEPA-compliant payment instructions. Currently Belfius handles all payments per KVS002 modification.

### IBAN Validation Service (SEBNKUK9)
- **Type**: System (Validation Service)
- **Technology**: COBOL program or service
- **Responsibilities**:
  - Validate IBAN format and checksums
  - Extract BIC codes from IBANs
  - Determine bank from IBAN
  - Return validation status codes (0, 1, 2 for valid)
  - Provide payment method compatibility information
- **Use Cases Involved**:
  - UC_MYFIN_002 (validates all IBANs)
- **Business Context**: External validation service that ensures SEPA compliance. Critical dependency - if unavailable, no payments can be validated. Prevents invalid IBANs from reaching banks.

### Remote Printing System
- **Type**: System (Report Distribution)
- **Technology**: Legacy printing system
- **Responsibilities**:
  - Receive list records (500001, 500004, 500006 and variants)
  - Format lists for printing or distribution
  - Distribute lists to appropriate mutualities
  - Archive list outputs
  - Manage list variants by federation
- **Use Cases Involved**:
  - UC_MYFIN_003 (receives all generated lists)
- **Business Context**: Distribution system that ensures payment lists reach the right mutuality administrators. Handles multiple list formats and regional variants.

### CSV Export System
- **Type**: System (Modern Integration)
- **Technology**: CSV file processing
- **Responsibilities**:
  - Receive CSV export records (5DET01)
  - Create CSV formatted files
  - Enable integration with modern systems
  - Support data warehouse loading
  - Provide alternative format to legacy lists
- **Use Cases Involved**:
  - UC_MYFIN_003 (receives CSV export for standard payments)
- **Business Context**: Modern integration point added per JIRA-4224. Allows newer systems to consume payment data without parsing legacy list formats.

### UAREA Database
- **Type**: System (Database)
- **Technology**: DB2 database or file system
- **Responsibilities**:
  - Store user application records (SEPAAUKU)
  - Maintain bank payment instruction records
  - Provide persistence for payment instructions
  - Enable retrieval of payment data
- **Use Cases Involved**:
  - UC_MYFIN_001 (stores SEPAAUKU records)
- **Business Context**: Staging area for bank payment instructions before transmission. Acts as buffer between payment creation and bank submission.

### Manual Payment Input System
- **Type**: System (Data Entry Application)
- **Technology**: Unknown (possibly TRBFNCXB program or web application)
- **Responsibilities**:
  - Provide data entry interface for payment clerks
  - Validate basic input data (formats, ranges)
  - Generate TRBFNCXP payment records
  - Create payment input batches
  - Track payment request status
- **Use Cases Involved**:
  - Upstream system that creates input for all use cases
- **Business Context**: Front-end system where manual payments originate. Quality of data entered here determines validation success rate in MYFIN.

### Date Conversion Service (CGACVXD9)
- **Type**: System (Utility Service)
- **Technology**: COBOL program
- **Responsibilities**:
  - Convert date formats between systems
  - Handle century dates (CCYYMMDD)
  - Provide date validation
  - Support date arithmetic
- **Use Cases Involved**:
  - UC_MYFIN_001 (date format conversions)
- **Business Context**: Utility service that handles date complexity. Ensures date consistency across different system formats.

### Member Account Search Service (SCHRKCX9)
- **Type**: System (Search Service)
- **Technology**: COBOL program using SEPAKCXD copybook
- **Responsibilities**:
  - Search for member bank account numbers
  - Retrieve known member IBANs
  - Support account discrepancy detection
  - Provide account history
- **Use Cases Involved**:
  - UC_MYFIN_001 (checks known account for discrepancy detection)
  - UC_MYFIN_003 (identifies account mismatches)
- **Business Context**: Enables comparison of payment IBAN against member's known account to detect potential data issues or account changes.

---

## Actor Interaction Matrix

| Actor | UC_MYFIN_001<br/>Process Payment | UC_MYFIN_002<br/>Validate Data | UC_MYFIN_003<br/>Generate Lists |
|-------|-------------------------------------|-----------------------------------|-----------------------------------|
| **MYFIN Batch System** | Primary Actor | Primary Actor | Primary Actor |
| **Member Database (MUTF08)** | Provides member data | Validates member existence | - |
| **Payment Database (BBF)** | Stores payment records | Checks duplicates | - |
| **IBAN Validation (SEBNKUK9)** | - | Validates IBANs | - |
| **Bank Payment System** | Receives instructions | - | - |
| **Remote Printing System** | - | - | Receives all lists |
| **CSV Export System** | - | - | Receives CSV records |
| **UAREA Database** | Stores SEPAAUKU | - | - |
| **Account Search (SCHRKCX9)** | Checks known account | - | Detects discrepancies |
| **Mutuality Administrator** | - | - | Reviews lists |
| **Finance Staff** | - | - | Reconciles lists |
| **Audit Team** | Verifies controls | Reviews validation | Checks completeness |
| **Bank Operations** | Receives payments | - | Uses for reconciliation |
| **Member** | Receives payment | Data subject | - |

## Actor Dependencies

### Critical Dependencies
These actors MUST be available for payment processing to succeed:

1. **Member Database (MUTF08)**: Without member data, no validation possible
2. **IBAN Validation Service (SEBNKUK9)**: Without IBAN validation, no payments can be approved
3. **Payment Database (BBF)**: Without duplicate check, financial risk increases
4. **MYFIN Batch System**: Core processing engine

### Important Dependencies
These actors should be available for full functionality:

1. **Remote Printing System**: Lists must be distributed for operational visibility
2. **Bank Payment System**: Payments must be transmitted for member benefit
3. **UAREA Database**: Payment instructions must be persisted

### Optional Dependencies
These actors enhance functionality but aren't strictly required:

1. **CSV Export System**: Legacy lists can substitute if unavailable
2. **Account Search Service**: Discrepancy detection can be skipped
3. **Date Conversion Service**: Basic date handling can work as fallback

## Security and Access

### System Access Controls

| Actor Type | Authentication | Authorization | Audit Logging |
|------------|----------------|---------------|---------------|
| MYFIN Batch System | Service account | Database read/write, program execution | All database operations logged |
| Member Database | Database credentials | Read-only access | All queries logged |
| Payment Database | Database credentials | Read/write access | All inserts/updates logged |
| IBAN Validation | Service call | Validation service access | Validation requests logged |
| Human Actors | User credentials | Role-based access to lists/reports | Access and actions logged |

### Data Privacy Considerations

- **Member Data**: Contains PII (national registry numbers, names, bank accounts)
- **Compliance**: GDPR, Belgian privacy law
- **Access Restrictions**: Only authorized personnel see member details
- **Audit Requirements**: All access to member data logged
- **Retention**: Payment records retained per legal requirements

---

## Related Documentation

- **[Business Process](../processes/BP_MYFIN_manual_payment_processing.md)**: How actors interact in the overall process
- **[Use Cases](../use-cases/)**: Detailed actor interactions per use case
- **[System Overview](../overview/MYFIN-overview.md)**: System context and integration points
- **[Business Index](../index.md)**: Navigation to all business documentation

---

**Document Version**: 1.0  
**Last Review**: 2026-01-28  
**Next Review**: Upon significant organizational or system changes
