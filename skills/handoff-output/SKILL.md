---
name: handoff-output
description: "The mandatory output protocol for every subagent: write your handoff.json to harness/handoffs/<agent_id>/<name>.json, then report only the path in your opencode HANDOFF section. Structured, predictable. Use at the END of every microtask, before reporting to the Supervisor."
---
# Handoff JSON Output Protocol

Write ONE structured JSON file at end of microtask, then report path only.

**File:** `harness/handoffs/<agent_id>/<name>.json` — `<agent_id>` = your id, `<name>` = slug.

**HANDOFF section** (path-only, no JSON restatement):
```
## HANDOFF
**Verdict:** 🟢 GREEN
**Handoff JSON:** harness/handoffs/tester/tests.json
```

## Schema — EXACTLY THIS

```json
{
  "headers": { "timestamp": "ISO-8601 UTC", "agent_id": "your-agent-id", "session_start": "ISO-8601 UTC", "session_end": "ISO-8601 UTC", "vector": "from harness/ops_board.json" },
  "data": {
    "shared": { "key_facts": ["facts next agent needs"], "call_chains": ["A -> B -> C"], "blast_radius": ["files affected"], "research_sources": ["links"] },
    "for_supervisor": "ONE paragraph: verdict + evidence + what's next.",
    "for_successor": "next agent id + what to read + what to do"
  }
}
```

## Field Rules

| Field | What to put in it | Length |
|-------|-------------------|--------|
| `headers.timestamp` | Current UTC time in ISO-8601 | — |
| `headers.agent_id` | your agent id | — |
| `headers.vector` | copy from `harness/ops_board.json` | — |
| `data.shared.key_facts` | every hard fact the next agent cannot infer | dense bullets |
| `data.shared.call_chains` | symbol flow: `X -> Y -> Z` | per chain |
| `data.shared.blast_radius` | files touched + affected tests | paths |
| `data.shared.research_sources` | links / docs / spec refs | URLs |
| `data.for_supervisor` | VERDICT + evidence + decision-ready summary | 1 paragraph, max 6 lines |
| `data.for_successor` | next owner + the exact JSON to read + the next microtask | 1 paragraph |

## Verification

- ✅ File exists, non-empty, valid JSON
- ✅ `headers.vector` matches `harness/ops_board.json`
- ✅ `for_supervisor` has verdict + evidence
- ✅ `for_successor` names next owner
- ✅ HANDOFF section is only: verdict + path

**Missing/empty handoff JSON = FAILED microtask. Supervisor re-spawns you.**
