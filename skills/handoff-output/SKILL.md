---
name: handoff-output
description: "The mandatory output protocol for every subagent: write your handoff.json to harness/handoffs/<agent_id>/<name>.json, then report only the path in your opencode HANDOFF section. Structured, predictable. Use at the END of every microtask, before reporting to the Supervisor."
---

# Handoff JSON Output Protocol

Every subagent ends a microtask by writing ONE structured JSON file. This file IS the work report. The opencode HANDOFF section that follows is only a path confirmation.

## When to Use

- At the END of every microtask, before reporting to the Supervisor
- After your VERIFY step, once you have your verdict + evidence

## The Contract — WRITE THE FILE, THEN REPORT THE PATH

```
harness/handoffs/<agent_id>/<name>.json
```

- `<agent_id>` = your agent id (e.g. `tester`, `scout`, `senior-dev`)
- `<name>` = short slug of the microtask (e.g. `tests.json`, `scout.json`, `review.json`)

**The opencode HANDOFF section in your report is MINIMAL — it is a crash-proof confirmation only:**

```markdown
## HANDOFF
**Verdict:** 🟢 GREEN
**Handoff JSON:** harness/handoffs/tester/tests.json
```

That's it. The path proves the JSON was written and the agent didn't crash. The substance lives in the JSON — do NOT restate it in markdown.

## The Schema — EXACTLY THIS

Write the file using the `write` tool. The schema:

```json
{
  "headers": {
    "timestamp": "ISO-8601 UTC string",
    "agent_id": "your-agent-id",
    "session_start": "ISO-8601 UTC string",
    "session_end": "ISO-8601 UTC string",
    "vector": "the vector from harness/ops_board.json"
  },
  "data": {
    "shared": {
      "key_facts": ["facts the next agent needs"],
      "call_chains": ["import A -> B -> C"],
      "blast_radius": ["files you modified / affected"],
      "research_sources": ["links", "file paths"]
    },
    "for_supervisor": "ONE concise paragraph: verdict + evidence + what's next. The Supervisor reads ONLY this field.",
    "for_successor": "the next agent id + what to read + what to do — names the next owner"
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

## How the Supervisor Reads It

The Supervisor uses the `read` tool to read `harness/handoffs/<agent_id>/<name>.json` and extracts `.data.for_supervisor`.

For the next agent's spawn, it links the file:
```
Read: harness/handoffs/scout/context.json → .data.shared.key_facts
```

## Verification — DID YOU COMPLY?

Before ending the session, confirm:

1. ✅ File exists at `harness/handoffs/<agent_id>/<name>.json`
2. ✅ File is non-empty and valid JSON
3. ✅ `headers.vector` matches `harness/ops_board.json`
4. ✅ `for_supervisor` contains verdict + evidence
5. ✅ `for_successor` names the next owner
6. ✅ Your opencode HANDOFF section is ONLY: verdict + handoff JSON path

**The rule: a missing or empty handoff JSON = a FAILED microtask. The Supervisor will re-spawn you.**
