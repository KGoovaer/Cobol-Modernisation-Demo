# Copilot Workspace Instructions — COBOL Modernisation Demo

## Project Purpose

This workspace combines a **COBOL modernisation toolkit** with an in-progress **target application implementation**. It is used both for analysing/documenting legacy mainframe programs and for building migration outputs (Java backend + Angular frontend).

## Repository Structure

```
MYFIN/
  cbl/          COBOL source programs (.cbl)
  copy/         Copybooks (.cpy) — shared data structures

.github/
  agents/       Custom Copilot agent definitions (.agent.md)
  skills/       Language-specific analysis skills (SKILL.md per domain)

docs/           Generated documentation output (created by the pipeline)
  [MODULE]-state.json      Pipeline state tracker
  discovery/               Flow, component & domain-concept artifacts
  business/                Use cases, business processes
  technical/               Functional & technical specs

migration/
  backend/      Java Spring Boot backend (Maven)
  frontend/     Angular frontend
  contracts/    API contracts
  checklists/   Delivery and validation checklists
```

## Working Modes

- **Documentation mode (legacy analysis):** use the autonomous multi-agent documentation pipeline and state tracking.
- **Application mode (migration build):** implement and validate changes in `migration/backend` and `migration/frontend` directly, while keeping traceability with `migration/spec.md`, `migration/plan.md`, and `migration/tasks.md`.

## Autonomous Documentation Pipeline

The primary workflow is a **self-driving multi-agent pipeline** triggered by the user once and then running to completion without further input. Never ask the user questions between pipeline stages — resolve ambiguity with conservative defaults and proceed.

### Agent Sequence

| Step | Agent | Responsibility |
|------|-------|----------------|
| 1 | **Planning Agent** | Detect language, divide codebase into batches, create state file, hand off |
| 2 | **Discovery Agent** | Analyse source code; extract flows, components, domain concepts |
| 3 | **Business Documenter Agent** | Produce use cases (UC_*) and business processes (BP_*) |
| 4 | **Technical Documenter Agent** | Produce functional & technical requirements (FR_*, NFR_*) |
| 5 | **Documentation Coordinator Agent** | Build indexes, traceability matrices, domain catalogue |
| 6 | **Verification Agent** | Cross-check docs vs. source; flag gaps; trigger remediation cycles if needed |

### How to Start

Invoke the **Planning Agent** and provide the module name (e.g. `MYFIN`). It will auto-detect the language, create `docs/[MODULE]-state.json`, divide the codebase into batches of 5–15 items, and hand off automatically.

### State File

All agents read and write `docs/[MODULE_NAME]-state.json`. This is the single source of truth for batch progress, phase transitions, and artifact tracking. Always consult the state file before doing any work.

## Skills

Load the relevant SKILL.md before analysing code. Do **not** embed language-specific parsing patterns directly in agent prompts.

| Language | Skill file |
|----------|-----------|
| COBOL | [`.github/skills/cobol-analysis/SKILL.md`](.github/skills/cobol-analysis/SKILL.md) |
| Java | [`.github/skills/java-analysis/SKILL.md`](.github/skills/java-analysis/SKILL.md) |
| TypeScript / JS | [`.github/skills/typescript-analysis/SKILL.md`](.github/skills/typescript-analysis/SKILL.md) |
| VB.NET WinForms | [`.github/skills/vbnet-analysis/SKILL.md`](.github/skills/vbnet-analysis/SKILL.md) |
| State tracking | [`.github/skills/state-management/SKILL.md`](.github/skills/state-management/SKILL.md) ← always load this |

When working under `migration/backend`, prioritize Java analysis practices and build validation.
When working under `migration/frontend`, prioritize TypeScript/Angular analysis practices and UI/API contract consistency.

## Migration Application Conventions

- Keep backend changes scoped to `migration/backend/src/main` unless the task explicitly requires build/config updates.
- Keep frontend changes scoped to `migration/frontend/src` unless the task explicitly requires Angular workspace/config updates.
- Treat `migration/contracts/*.md` as the API source of truth for endpoint payloads and naming.
- Keep generated/runtime artifacts out of source control (`migration/backend/target`, `migration/backend/logs`, `migration/frontend/node_modules`, `migration/frontend/dist`, `migration/frontend/test-results`).
- Preserve separation of concerns: business logic in backend services, UI state/interaction in frontend components/services.

## COBOL Conventions (MYFIN Module)

- **Source language**: Belgian mainframe COBOL — comments are bilingual (French & Dutch).
- **Change history** is embedded in source as tagged lines: `MTU`, `CDU001`, `KVS001`, `MSA001`, `JGO004`, `IBAN10`, `Y2000+` etc. Treat these as audit markers, not code.
- **Copybooks** are referenced via `COPY <name>.` statements. Common ones:
  - `BFN51GZR`, `BFN54GZR` — product/output document definitions
  - `SEPAAUKU` — SEPA/IBAN structures
  - `TRBFNCXK`, `TRBFNCXP` — program-specific working storage
- **Commented-out lines** begin with `*` in column 7, or carry tags like `140562*` (incident number prefix).
- Conditional compilation markers (`88`-level entries) may contain superseded values left in place with `*` comment — read both the active and commented values to understand business history.

## Documentation Output Conventions

- All docs go under `docs/`. Do not scatter output elsewhere.
- Use `[MODULE]` as the prefix (e.g. `MYFIN`) in state filenames and artifact directories.
- Include Mermaid diagrams in every use-case and business-process document.
- ID schemes: `UC_<BATCH>_NNN`, `BP_<BATCH>_NNN`, `FR_<BATCH>_NNN`, `NFR_<BATCH>_NNN`, `BUREQ_<BATCH>_NNN`.
- Remediation is capped at **2 cycles** per batch (`maxRemediationCycles: 2`).

## Key Principles for AI Agents

- **Skills first**: load state-management + the language skill before any analysis.
- **Batch scope**: work only on files listed in the current batch's `scope` field.
- **No user interaction**: the pipeline is autonomous — never pause for confirmation.
- **Link, don't embed**: reference existing docs and source files rather than duplicating content inline.
- **Conservative defaults**: when source intent is unclear, document what is observed and flag uncertainty rather than inventing intent.

For migration app work, apply the same conservative principle: implement only what is required by the task, prefer small safe diffs, and validate with module-appropriate build/test commands.
