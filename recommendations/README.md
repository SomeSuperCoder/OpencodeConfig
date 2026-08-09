# 📋 Recommendations Directory

**Purpose:** Persistent storage for improvement suggestions from QA, security reviews, code reviews, and other verification agents.

**When to save here:**
- QA gives "Pass with recommendations"
- Security reviewer gives "Pass with notes"
- Code reviewer suggests improvements
- Test Engineer identifies flaky tests or coverage gaps
- Any agent gives a non-blocking improvement suggestion

## 📁 File Structure

```
recommendations/
├── README.md                    ← this file
├── security/                    ← security-related recommendations
│   └── YYYY-MM-DD-topic.md
├── performance/                 ← performance recommendations
│   └── YYYY-MM-DD-topic.md
├── quality/                     ← code quality recommendations
│   └── YYYY-MM-DD-topic.md
├── testing/                     ← test improvements
│   └── YYYY-MM-DD-topic.md
├── accessibility/               ← a11y recommendations
│   └── YYYY-MM-DD-topic.md
├── architecture/                ← architectural improvements
│   └── YYYY-MM-DD-topic.md
└── general/                     ← other recommendations
    └── YYYY-MM-DD-topic.md
```

## 📝 File Format

Each recommendation file follows this template:

```markdown
# [Topic]

**Date:** YYYY-MM-DD
**Source:** [Agent that generated this] (e.g., QA Engineer, Security Engineer)
**Priority:** low | medium | high
**Status:** pending | in_progress | dismissed   (completed → REMOVED from the directory)
**Effort:** quick (<1hr) | medium (1-4hr) | large (>4hr)

## Recommendation

[Clear description of what should be improved]

## Rationale

[Why this improvement matters — business value, risk reduction, technical debt]

## Evidence

[Links to code, test results, or specific findings that support this recommendation]

## Implementation Notes

[Optional: suggested approach, files to modify, patterns to follow]
```

## 🔄 Protocol

### Saving Recommendations
When an agent gives a non-blocking suggestion:
1. Create the file in the appropriate subdirectory
2. Use format: `YYYY-MM-DD-topic.md` (e.g., `2026-08-07-rate-limiting.md`)
3. Set Status to `pending`
4. Reference the source agent and their findings

### Implementing Recommendations
When the user says **"Implement all recommendations"** (or "Implement all prior recommendations"), the Tech Lead owns execution end-to-end via the RECOMMENDATION IMPLEMENTATION PROTOCOL:

```
① SCAN      — list every `pending` recommendation across the directory, by domain. Only `pending` items are candidates.
② ALREADY-IMPLEMENTED CHECK — verify each candidate against the CURRENT codebase (CodeGraph). Change already present? → REMOVE the file, no spawn. Record "already present."
③ CONTRADICTION SCAN — read every candidate against every other AND against current code/spec. A conflicting pair canNOT both be implemented: flag to the Director or dismiss the losing one with a note. Resolve BEFORE any spawn.
④ GROUP BY DOMAIN — bundle non-conflicting candidates.
⑤ SPAWN — one specialist per domain/item. Verification proportional to tier.
⑥ VERIFY — each implementation verified by its tier.
⑦ REMOVE ON COMPLETION — implemented + verified = DELETE the file (optional: archive to `archive/`). Done means gone from the active pool.
⑧ REPORT — to the Director: implemented/removed, dismissed + why, already-present + removed, contradictions found.
```

**The Rule:** the `pending` pool is the source of truth for what still needs doing. A completed recommendation has no file. Never re-implement what already exists.

### Dismissing Recommendations
If a recommendation is rejected:
1. Set Status to `dismissed`
2. Add a note explaining why
3. Keep the file for historical reference

## 🎯 Why This Exists

**The Problem:** Agents give improvement suggestions that get lost in chat history. No persistence. No tracking. Technical debt accumulates.

**The Solution:** Persistent directory. Clear format. User controls when to implement. Nothing gets lost.

**The Philosophy:** "Pass with recommendations" shouldn't mean "recommendations forgotten." Capture them. Track them. Implement when ready.