---
name: handoff-output
description: "The mandatory output protocol for every specialist agent: write your handoff.json to data/handoffs/<agent_id>/<name>.json, then report only the path in your opencode HANDOFF section. Structured, predictable, nushell-queryable. Use at the END of every microtask, before reporting to the Team Lead."
---

# Handoff JSON Output Protocol

Every specialist agent ends a microtask by writing ONE structured JSON file. This file IS the work report. The opencode HANDOFF section that follows is only a path confirmation.

## When to Use

- At the END of every microtask, before reporting to the Team Lead
- After your VERIFY step, once you have your verdict + evidence

## The Contract — WRITE THE FILE, THEN REPORT THE PATH

```
data/handoffs/<agent_id>/<name>.json
```

- `<agent_id>` = your agent id (e.g. `team/quality/test-engineer`)
- `<name>` = short slug of the microtask (e.g. `tests.json`, `scout.json`, `review.json`)

**The opencode HANDOFF section in your report is MINIMAL — it is a crash-proof confirmation only:**

```markdown
## HANDOFF
**Verdict:** 🟢 GREEN
**Handoff JSON:** data/handoffs/team/quality/test-engineer/tests.json
```

That's it. The path proves the JSON was written and the agent didn't crash. The substance lives in the JSON — do NOT restate it in markdown.

## The Schema — EXACTLY THIS

Write the file with `to json` if possible, or as raw JSON. The schema:

```json
{
  "headers": {
    "timestamp": "ISO-8601 UTC string",
    "agent_id": "your-agent-id",
    "session_start": "ISO-8601 UTC string",
    "session_end": "ISO-8601 UTC string",
    "vector": "the vector from data/ops_board.json"
  },
  "data": {
    "shared": {
      "key_facts": ["facts the next agent needs"],
      "call_chains": ["import A -> B -> C"],
      "blast_radius": ["files you modified / affected"],
      "research_sources": ["links", "file paths"]
    },
    "for_teamlead": "ONE concise paragraph: verdict + evidence + what's next. The Team Lead reads ONLY this field.",
    "for_successor": "the next agent id + what to read + what to do — names the next owner"
  }
}
```

## Field Rules

| Field | What to put in it | Length |
|-------|-------------------|--------|
| `headers.timestamp` | `date -u +"%Y-%m-%dT%H:%M:%SZ"` | — |
| `headers.agent_id` | your agent id | — |
| `headers.vector` | copy from `data/ops_board.json` | — |
| `data.shared.key_facts` | every hard fact the next agent cannot infer | dense bullets |
| `data.shared.call_chains` | symbol flow: `X -> Y -> Z` | per chain |
| `data.shared.blast_radius` | files touched + affected tests | paths |
| `data.shared.research_sources` | links / docs / spec refs | URLs |
| `data.for_teamlead` | VERDICT + evidence + decision-ready summary | 1 paragraph, max 6 lines |
| `data.for_successor` | next owner + the exact JSON to read + the next microtask | 1 paragraph |

## How the Team Lead Consumes It

The Team Lead NEVER re-reads your full report. It runs:

```bash
nu -c "open data/handoffs/team/quality/test-engineer/tests.json | from json | .data.for_teamlead"
```

And for the next agent's spawn, it links the file and tells the worker to extract fields:

```bash
nu -c "open data/handoffs/team/core/scout/scout.json | from json | .data.shared.key_facts"
```

## Nushell Write Pattern (recommended)

When you can build your result as a nushell record, write it directly:

```bash
nu -c "{ headers: { timestamp: (date now | date to-utc | format date "%Y-%m-%dT%H:%M:%SZ"), agent_id: 'team/quality/test-engineer' }, data: { shared: { key_facts: ['a', 'b'], call_chains: [], blast_radius: ['x.ts'], research_sources: [] }, for_teamlead: 'verdict...', for_successor: 'next...' } } | to json | save data/handoffs/team/quality/test-engineer/tests.json -f"
```

## Verification — DID YOU COMPLY?

Before ending the session, confirm:

1. ✅ File exists at `data/handoffs/<agent_id>/<name>.json`
2. ✅ File is non-empty and valid JSON (`nu -c "open <path> | from json | get data.for_teamlead"`)
3. ✅ `headers.vector` matches `data/ops_board.json`
4. ✅ `for_teamlead` contains verdict + evidence
5. ✅ `for_successor` names the next owner
6. ✅ Your opencode HANDOFF section is ONLY: verdict + handoff JSON path

**The rule: a missing or empty handoff JSON = a FAILED microtask. The Team Lead will re-spawn you.**
