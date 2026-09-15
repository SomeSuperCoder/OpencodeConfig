---
name: anti-drift
description: "Mandatory anti-drift protocol. Run on EVERY user request before planning. Verifies alignment with what the user actually asked. Prevents scope creep, assumption drift, and over-engineering. Not optional — it's the first thing you do."
---

# Anti-Drift Protocol

Run this on EVERY user request. Not sometimes. Every time. It takes 30 seconds and prevents hours of wasted work.

## When to Run

**EVERY. SINGLE. REQUEST.**

Before you plan. Before you spawn. Before you do anything. Run this first.

## The Protocol

### Step 1: Capture the Request

Quote the user's exact words. Not your interpretation. The raw request.

> User said: "[exact words]"

### Step 2: Identify the Core Intent

What is the user ACTUALLY trying to achieve? One sentence. Not what they said — what they MEANT.

> Core intent: [one sentence]

### Step 3: Drift Detection Checklist

Check each item. If ANY answer is "yes" — you're drifting. Stop.

| # | Check | If YES → |
|---|-------|----------|
| 1 | Am I adding features the user didn't ask for? | 🛑 STOP. That's scope creep. |
| 2 | Am I solving a problem they didn't mention? | 🛑 STOP. That's YOUR concern, not theirs. |
| 3 | Am I redesigning something that works? | 🛑 STOP. That's gold-plating. |
| 4 | Am I preparing for edge cases they didn't describe? | ⚠️ CAUTION. Note it, don't build it yet. |
| 5 | Am I making this "more robust" than needed? | 🛑 STOP. Ship the minimum. |
| 6 | Am I adding "just in case" logic? | 🛑 STOP. YAGNI. |
| 7 | Am I touching files/modules outside the request? | 🛑 STOP. Stay in scope. |
| 8 | Am I building infrastructure for future tasks? | 🛑 STOP. That's not this task. |

### Step 4: Scope Boundary

Define what's IN and what's OUT. Be explicit.

```
IN SCOPE:
- [specific thing 1]
- [specific thing 2]

OUT OF SCOPE:
- [specific thing 3]
- [specific thing 4]
```

### Step 5: Success Criteria

How do we know it's done? One sentence.

> Done when: [specific, testable criterion]

### Step 6: Self-Audit

Answer these honestly:

| Question | Honest answer |
|----------|--------------|
| Would the user recognize my plan as their request? | ? |
| Am I doing something "while I'm at it"? | ? |
| Is this the simplest way to solve what they asked? | ? |
| Am I building for a future task instead of this one? | ? |

## The Output

```
ANTI-DRIFT CHECK:
REQUEST: "[exact user words]"
CORE INTENT: [what they actually want]
IN SCOPE: [list]
OUT OF SCOPE: [list]
DONE WHEN: [success criteria]
DRIFT RISK: LOW/MEDIUM/HIGH
```

## Rules

1. **This is not optional.** Run it every time. No exceptions.
2. **If drift detected → STOP immediately.** Don't justify it. Don't rationalize it. Stop.
3. **If the user said "just do it" → skip the planning, keep the drift check.** You can act fast AND stay aligned.
4. **If the user's request is vague → that's NOT an excuse to drift.** Ask for clarification (grill-me) instead of guessing wrong.
5. **The drift check is for YOU, not the user.** You don't need to show it unless asked. But you MUST do it.
