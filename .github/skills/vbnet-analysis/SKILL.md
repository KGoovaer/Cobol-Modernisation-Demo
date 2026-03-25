---
name: vbnet-analysis
description: FRUTAS/Seizoensarbeiders VB.NET WinForms documentation patterns for flow discovery, business rules extraction, and architecture mapping.
license: MIT
---

# VB.NET Analysis Skill (FRUTAS)

This skill provides repository-specific guidance for documenting the Seizoensarbeiders (FRUTAS) application.

Use this skill when documentation work targets:
- `Seizoensarbeiders.sln`
- VB.NET WinForms forms under `Seizoensarbeiders/frm*.vb`
- Data access classes under `SARB_DA/cls*DA.vb`
- Data entities under `SARB_DATA/cls*.vb`
- Webservice routing classes `Seizoensarbeiders/clsWebservices*.vb`

## Goal

Produce documentation that reflects actual FRUTAS behavior, including:
- UI-driven CRUD flows (MDI parent and child forms)
- Oracle data access and SQL business rules
- Webservice integration by environment (DEV/PP/PROD)
- Security and access preconditions (Windows auth + AD groups)

## File Patterns

Search with these patterns first:

```text
Seizoensarbeiders/**/*.vb
SARB_DA/**/*.vb
SARB_DATA/**/*.vb
Seizoensarbeiders/App.config
Seizoensarbeiders/Connected Services/**/*
```

High-value classes/files:
- `Seizoensarbeiders/frmMDI.vb`
- `SARB_DA/clsDatabase.vb`
- `SARB_DA/clsLog.vb`
- `Seizoensarbeiders/clsWebservices.vb`
- `Seizoensarbeiders/clsWebservices_DEV.vb`
- `Seizoensarbeiders/clsWebservices_PP.vb`
- `Seizoensarbeiders/clsWebservices_PROD.vb`

## FRUTAS Architecture Map

- `Seizoensarbeiders`: WinForms UI and service orchestration
- `SARB_DA`: static data access classes (`Shared` methods)
- `SARB_DATA`: entity/view models; many inherit `ListViewItem`
- `SeizoenarbeidersSetup`: deployment project

## Entry Point Detection (VB.NET WinForms)

When discovering flows, prioritize these triggers:
- Form lifecycle handlers: `Load`, `Shown`, `FormClosing`
- Control events: `Click`, `SelectedIndexChanged`, `TextChanged`
- MDI coordination and custom events raised from child forms
- CRUD button handlers that call DA `Insert/Update/DeleteByPrimaryKey`

Document every flow as:
1. UI action
2. Validation checks
3. DA calls and SQL predicates
4. Side effects (logging, events, refresh)
5. Success and failure outcomes

## Data Access Analysis Rules

For each flow, inspect DA methods deeply:
- Capture full SQL intent: `WHERE`, joins, sort/order, and sequence usage
- Identify optimistic locking checks (`ROWVERSION`)
- Record parameter mapping (`OleDbParameter`) and null/default behavior
- Confirm use of `clsDatabase` helper methods instead of direct connections

Business rule extraction checklist from DA:
- Filter conditions that gate records
- Date validity conditions
- Identifier constraints and uniqueness assumptions
- Soft/hard delete behavior
- Required audit fields and mutation metadata

## Entity/Model Analysis Rules

In `SARB_DATA` entities, extract:
- Identity key fields (for traceability and UI tags)
- Audit fields (`*_DATUM_AANMAAK`, `*_USER_AANMAAK`, `*_ROWVERSION`)
- Side effects in property setters (`SubItems(n).Text` sync)
- Domain terms from class/property names (worker, employer, tewerkstelling, etc.)

## Webservice Documentation Rules

Document integration behavior through:
- `clsWebservices.vb` factory selection by `Frutas_Omgeving`
- Environment-specific implementations (`DEV`, `PP`, `PROD`)
- Service purpose:
  - `INTADM`: administrative person/address/nationality data
  - `INWET`: legal/social-security eligibility data
  - `INTVBD`: employer/company identification data
- WCF behavior attachment (`clsPasswordDigestBehavior`)

Always include:
- Inputs passed to webservice calls
- Mapping from response fields to UI/domain fields
- Error handling path and logging behavior

## Security and Access Preconditions

Documentation must explicitly include:
- Windows domain dependency (`MCM\\<personeelnummer>`)
- AD role gates (`RechtAD_USE`, `RechtAD_ADMIN`, `RechtAD_ICT`)
- Startup/authorization exit conditions if access checks fail

## Documentation Output Expectations

When used by documentation agents, create artifacts that include:
- `docs/discovered-flows.md`: UI-to-DA-to-integration flow maps
- `docs/discovered-components.md`: project/component matrix
- `docs/discovered-domain-concepts.md`: entities, key concepts, business terms
- Business docs that avoid implementation jargon where possible
- Technical docs with concrete file references and SQL-backed rules

## Quality Checks

Before finalizing documentation, verify:
- Each major form has at least one documented end-to-end flow
- Each documented flow references exact DA methods and SQL source
- Cross-project links are explicit (`Seizoensarbeiders` -> `SARB_DA` -> `SARB_DATA`)
- Environment-dependent behavior is called out where relevant
- Concurrency and rowversion behavior is documented for updates
