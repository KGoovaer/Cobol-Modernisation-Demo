# MYFIN Domain Concepts Catalog

**Module**: MYFIN  
**Catalog Type**: Coordination Consolidation  
**Last Updated**: 2026-03-25

## Purpose

This catalog consolidates domain concepts discovered across discovery, business, and functional documentation for the current module scope.

## Concepts

| Concept ID | Concept | Definition | Primary Sources |
|---|---|---|---|
| DC_MYFIN_001 | Manual GIRBET Payment | A manually initiated payment request processed through the GIRBET batch flow. | UC_MYFIN_001, FLOW_MYFIN_MAIN_001 |
| DC_MYFIN_002 | Member Validation | Verification that a member exists and has a processable insurance context. | BUREQ_MYFIN_001, FUREQ_MYFIN_001 |
| DC_MYFIN_003 | Payment Uniqueness | Rule preventing duplicate payments based on amount + constant matching logic. | BUREQ_MYFIN_002, FUREQ_MYFIN_002 |
| DC_MYFIN_004 | IBAN/SEPA Compliance | Validation of IBAN and related banking data for payment eligibility. | BUREQ_MYFIN_003, FUREQ_MYFIN_003 |
| DC_MYFIN_005 | Multi-language Messaging | Bilingual/multilingual behavior for labels and diagnostics (FR/NL/DE context). | BUREQ_MYFIN_004, BUREQ_MYFIN_007 |
| DC_MYFIN_006 | Regional Accounting Type | Belgian 6th State Reform routing using accounting types and federation overrides. | BUREQ_MYFIN_005, BUREQ_MYFIN_012 |
| DC_MYFIN_007 | Payment Detail List | Operational detail list output for successfully processed payments. | BUREQ_MYFIN_009, FUREQ_MYFIN_004 |
| DC_MYFIN_008 | Rejection List | Operational error/rejection list containing diagnostic reasons. | BUREQ_MYFIN_010, FF_MYFIN_002 |
| DC_MYFIN_009 | Discrepancy List | Non-blocking reporting output for bank account mismatches. | BUREQ_MYFIN_011, FUREQ_MYFIN_003 |
| DC_MYFIN_010 | Payment Record Creation | Transformation of validated input into BBF and SEPA output structures. | FUREQ_MYFIN_005, FF_MYFIN_001 |

## Related Artifacts

- docs/discovery/MYFIN/discovered-components.md
- docs/discovery/MYFIN/discovered-flows.md
- docs/business/use-cases/
- docs/functional/requirements/
