---
name: anti-drift
description: "Self-audit protocol. The Supervisor loads this periodically to verify it hasn't drifted from the original task. Quick sanity check: Am I still solving the right problem? Have I added unnecessary complexity? Is the user's actual need still being addressed?"
---

# Anti-Drift Protocol

You are solving a problem. This protocol checks if you're still solving the RIGHT problem.

## When to Load This

- After spawning 3+ agents in a row without checking in
- Before making a decision that changes scope
- When the task feels like it's growing
- When you notice yourself adding "just one more thing"
- Periodically during long tasks — every few spawns

## The Check (60 seconds, not 60 minutes)

### 1. The Original Request

**What did the user ACTUALLY ask for?** Quote it. Not what you inferred. Not what you're now working on. The original words.

> "The user asked: [exact words]"

### 2. What Are You Doing Now?

**What is the CURRENT plan/task/agent working on?** Describe it in one sentence.

> "Right now I'm: [current activity]"

### 3. The Drift Test

| Question | If YES | If NO |
|----------|--------|-------|
| Is what I'm doing a direct step toward the original request? | ✅ CONTINUE | 🛑 STOP — you've drifted |
| Would the user recognize this as part of their ask? | ✅ CONTINUE | 🛑 STOP — you've added scope |
| Did I add something "while we're here"? | 🛑 STOP — that's scope creep | ✅ CONTINUE |
| Am I solving a problem the user didn't mention? | 🛑 STOP — that's YOUR concern, not theirs | ✅ CONTINUE |
| Is the current plan still the simplest path? | ✅ CONTINUE | ⚠️ SIMPLIFY — you've over-engineered |

### 4. If Drifted

**STOP. Re-align:**
1. State what drifted: "I started doing [X] when the user asked for [Y]."
2. Kill any in-flight agents working on the drifted task.
3. Return to the original request.
4. If the drifted work is genuinely useful, note it in `for_supervisor` on the next handoff — but DO NOT pursue it now.

### 5. If On Track

**Continue. But note one thing:**
- What's the next concrete deliverable?
- How many more spawns until it's done?
- Am I over-complicating the next step?

## Anti-Drift Heuristics

| Signal | What It Means |
|--------|---------------|
| "Let me also..." | You're adding scope. Stop. |
| "While we're at it..." | You're adding scope. Stop. |
| "This should probably also..." | You're adding scope. Stop. |
| "I noticed a bug in..." | That's not the task. Note it, don't fix it. |
| "Let me check one more thing..." | You're spiraling. Stop. Ship what you have. |
| 5+ agents spawned | Check in. Are you still on the original task? |
| Task feels "almost done" for 3+ spawns | You're gold-plating. Ship it. |

## The Rule

**Drift is silent.** It doesn't announce itself. You don't notice you've drifted until you've burned 20 spawns on something the user didn't ask for. Load this skill BEFORE that happens, not after.
