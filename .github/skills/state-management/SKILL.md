---
name: state-management
description: Automatic state file management for documentation agents. Always use this skill to update progress tracking.
license: MIT
---

# State Management Skill

This skill provides automatic state file management for the autonomous documentation pipeline. All agents use this skill to coordinate batch-oriented, zero-intervention documentation flows.

## When to Use This Skill

**ALWAYS** — every documentation agent must use this skill to:
- Read the current pipeline state and determine what to do
- Track batch progress through the pipeline
- Record completed artifacts
- Trigger automatic handoff to the next agent

## State File Location

```
docs/[MODULE_NAME]-state.json
```

## State File Schema

```json
{
  "module": "string",
  "language": "cobol|java|dotnet|python|javascript|vbnet|mixed",
  "created": "ISO8601 timestamp",
  "lastUpdated": "ISO8601 timestamp",

  "pipeline": {
    "mode": "autonomous",
    "maxRemediationCycles": 2,
    "status": "running|complete|failed",
    "agentSequence": ["discovery", "business", "technical", "coordination", "verification"]
  },

  "batches": [
    {
      "id": "batch-1",
      "name": "Human-readable batch name",
      "scope": ["list of files, forms, classes, or patterns in this batch"],
      "status": "pending|in-progress|complete|remediation|failed",
      "currentPhase": "discovery|business|technical|coordination|verification|complete",
      "remediationCycle": 0,
      "phases": {
        "discovery": {
          "status": "pending|in-progress|complete|remediation-needed",
          "completedAt": null,
          "artifacts": [],
          "discovered": { "flows": 0, "components": 0, "domainConcepts": 0 }
        },
        "business": {
          "status": "pending|in-progress|complete|remediation-needed",
          "completedAt": null,
          "artifacts": [],
          "created": { "useCases": 0, "businessRequirements": 0, "businessProcesses": 0 }
        },
        "technical": {
          "status": "pending|in-progress|complete|remediation-needed",
          "completedAt": null,
          "artifacts": [],
          "created": { "functionalRequirements": 0, "nonFunctionalRequirements": 0, "technicalFlows": 0 }
        },
        "coordination": {
          "status": "pending|in-progress|complete|remediation-needed",
          "completedAt": null,
          "artifacts": [],
          "validated": { "indexes": false, "traceability": false, "domainCatalog": false }
        },
        "verification": {
          "status": "pending|in-progress|complete|remediation-needed",
          "completedAt": null,
          "artifacts": [],
          "gaps": { "critical": 0, "high": 0, "medium": 0, "low": 0 },
          "remediationTargets": []
        }
      }
    }
  ],

  "currentBatch": "batch-1",

  "planning": {
    "status": "complete",
    "completedAt": "ISO8601 timestamp",
    "artifacts": ["docs/documentation-plan.md"]
  },

  "progress": {
    "totalBatches": 0,
    "completedBatches": 0,
    "currentBatchIndex": 0,
    "percentage": 0
  },

  "metadata": {
    "repository": "string",
    "paths": {
      "source": "string",
      "docs": "string"
    }
  }
}
```

## Batch Lifecycle

Each batch flows through the full agent pipeline before the next batch starts:

```
┌─────────────┐   ┌──────────┐   ┌───────────┐   ┌─────────────┐   ┌──────────────┐
│  Discovery   │──▶│ Business │──▶│ Technical │──▶│ Coordinator │──▶│ Verification │
│  (batch N)   │   │(batch N) │   │ (batch N) │   │  (batch N)  │   │  (batch N)   │
└─────────────┘   └──────────┘   └───────────┘   └─────────────┘   └──────┬───────┘
                                                                          │
                                                          ┌───────────────┤
                                                          │               │
                                                     PASS ▼          FAIL ▼
                                                  ┌──────────┐   ┌──────────────┐
                                                  │ Next batch│   │ Remediation  │
                                                  │ or DONE   │   │ (loop back)  │
                                                  └──────────┘   └──────────────┘
```

## Agent Integration Pattern

### At Start of Agent Work (ALL agents)

```markdown
1. Read `docs/[MODULE_NAME]-state.json`
2. Read `currentBatch` to know which batch to process
3. Find the batch object in `batches[]` by ID
4. Verify the previous phase for this batch is "complete"
5. Set this phase to "in-progress" for the current batch
6. Save state file
```

### During Agent Work

```markdown
1. Work ONLY on files/scope listed in `batch.scope`
2. Update counters as items are discovered/created
3. Add artifacts to the batch phase's artifacts array
4. Save state file periodically
```

### At End of Agent Work — MANDATORY HANDOFF

All agents declare `handoffs` in their YAML frontmatter. These create clickable buttons in the VS Code chat UI that invoke the next agent with a pre-filled prompt.

```markdown
1. Set this phase to "complete" for the current batch
2. Set batch.currentPhase to the next phase name
3. Save state file
4. Confirm completion in your response message
5. The handoff button defined in your frontmatter will appear automatically
6. With `send: true`, clicking the button immediately invokes the next agent
```

### Handoff Frontmatter Pattern

Each agent declares its handoff(s) in YAML frontmatter:

```yaml
handoffs:
  - label: "📋 Next Step Label"
    agent: Target Agent Name
    prompt: "Continue autonomous pipeline. Read the state file in docs/ to determine the current batch and proceed."
    send: true
```

Fields:
- `label` (required): Button text with emoji, shown in chat UI
- `agent` (required): Target agent name (matches the `name` field of the target `.agent.md`)
- `prompt` (required): Pre-filled prompt sent to the target agent
- `send` (required): `true` for auto-submit on click (no editing needed)

### Handoff Chain

| Current Agent       | Handoff Button Label      | Target Agent              |
|---------------------|---------------------------|---------------------------|
| Planning Agent      | 🔍 Start Discovery        | Discovery Agent           |
| Discovery Agent     | 📋 Document Business      | Business Documenter Agent |
| Business Documenter | ⚙️ Document Technical     | Technical Documenter Agent|
| Technical Documenter| 🔗 Coordinate Docs        | Documentation Coordinator Agent |
| Doc Coordinator     | ✅ Verify Batch            | Verification Agent        |
| Verification (PASS) | 🔍 Next Batch → Discovery | Discovery Agent           |
| Verification (PASS, last batch) | — (pipeline complete) | none            |
| Verification (FAIL) | 🔧 Remediate → [target]   | varies by gap type        |

### Verification Remediation Handoff

When verification finds critical or high gaps, the Verification Agent has multiple handoff buttons declared in its frontmatter:

```yaml
handoffs:
  - label: "🔧 Remediate → Discovery"
    agent: Discovery Agent
    prompt: "Continue autonomous pipeline — REMEDIATION. Read the state file..."
    send: true
  - label: "🔧 Remediate → Business"
    agent: Business Documenter Agent
    ...
  - label: "🔧 Remediate → Technical"
    agent: Technical Documenter Agent
    ...
  - label: "🔧 Remediate → Coordinator"
    agent: Documentation Coordinator Agent
    ...
```

The Verification Agent's instructions tell it to:

```markdown
1. Set batch.status to "remediation"
2. Increment batch.remediationCycle
3. If remediationCycle > pipeline.maxRemediationCycles:
   - Log warning, set batch.status to "complete" with gaps noted
   - Move to next batch using "🔍 Next Batch → Discovery" handoff
4. Otherwise:
   - Set batch.phases.verification.remediationTargets to list of
     {phase, reason} objects describing what needs fixing
   - Set the target phase status back to "remediation-needed"
   - Instruct user to click the appropriate "🔧 Remediate → [target]" button
   - That agent processes ONLY the gaps, then re-hands-off forward
     through the pipeline until verification runs again
```

## Advancing to Next Batch

When verification passes (or max remediation reached):

```markdown
1. Set batch.status to "complete"
2. Increment progress.completedBatches
3. Update progress.percentage
4. If more batches remain:
   a. Set currentBatch to next batch ID
   b. Set progress.currentBatchIndex++
   c. Invoke Discovery Agent for the new batch
5. If all batches complete:
   a. Set pipeline.status to "complete"
   b. Stop — do NOT invoke any further agents
```

## Helper Operations

### Initialize State File (Planning Agent only)

```javascript
function initializeState(moduleName, language, batches) {
  return {
    module: moduleName,
    language: language,
    created: now(),
    lastUpdated: now(),
    pipeline: {
      mode: "autonomous",
      maxRemediationCycles: 2,
      status: "running",
      agentSequence: ["discovery", "business", "technical", "coordination", "verification"]
    },
    batches: batches.map(b => ({
      id: b.id,
      name: b.name,
      scope: b.scope,
      status: "pending",
      currentPhase: "discovery",
      remediationCycle: 0,
      phases: {
        discovery:    { status: "pending", completedAt: null, artifacts: [], discovered: { flows: 0, components: 0, domainConcepts: 0 } },
        business:     { status: "pending", completedAt: null, artifacts: [], created: { useCases: 0, businessRequirements: 0, businessProcesses: 0 } },
        technical:    { status: "pending", completedAt: null, artifacts: [], created: { functionalRequirements: 0, nonFunctionalRequirements: 0, technicalFlows: 0 } },
        coordination: { status: "pending", completedAt: null, artifacts: [], validated: { indexes: false, traceability: false, domainCatalog: false } },
        verification: { status: "pending", completedAt: null, artifacts: [], gaps: { critical: 0, high: 0, medium: 0, low: 0 }, remediationTargets: [] }
      }
    })),
    currentBatch: batches[0].id,
    planning: { status: "complete", completedAt: now(), artifacts: ["docs/documentation-plan.md"] },
    progress: { totalBatches: batches.length, completedBatches: 0, currentBatchIndex: 0, percentage: 0 },
    metadata: { repository: "", paths: { source: "", docs: "docs/" } }
  };
}
```

### Update Batch Phase Status

```javascript
function updateBatchPhase(state, batchId, phaseName, status) {
  const batch = state.batches.find(b => b.id === batchId);
  batch.phases[phaseName].status = status;
  if (status === "complete") {
    batch.phases[phaseName].completedAt = now();
  }
  state.lastUpdated = now();
  return state;
}
```

### Advance Batch to Next Phase

```javascript
function advanceBatch(state, batchId, nextPhase) {
  const batch = state.batches.find(b => b.id === batchId);
  batch.currentPhase = nextPhase;
  state.lastUpdated = now();
  return state;
}
```

## Error Handling

### State File Not Found
- Only the Planning Agent may create a new state file
- All other agents must STOP and report: "State file missing — run Planning Agent first"

### Phase Dependency Not Met
- Log: "Cannot start [phase] for batch [id] because [previous-phase] is not complete"
- Do NOT set to blocked — instead re-invoke the missing predecessor agent

### Max Remediation Reached
- Log warning with gap summary
- Mark batch complete with `remediationCycle` at max
- Continue to next batch

## Best Practices

1. **Always update state before handoff** — the next agent reads it immediately
2. **Work only on batch scope** — never touch files outside the current batch
3. **Keep batches small** — 5-15 items per batch to stay within context limits
4. **Pretty-print JSON** — human-readable state file for debugging
5. **Never ask the user** — the pipeline is fully autonomous; resolve ambiguity with conservative defaults
