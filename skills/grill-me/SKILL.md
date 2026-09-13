---
name: grill-me
description: "Smart clarification protocol. Scout FIRST, ask only what you can't figure out. Balance: investigate before interrogating."
---

# Grill-Me Protocol

Scout before you ask. Investigate before you interrogate. Only ask what you CAN'T figure out from context.

## The Anti-Pattern

The old way: user sends a request → Supervisor fires 5 questions → user is annoyed → wastes time.

The right way: user sends a request → Supervisor gathers context (scout/memory/file lookups) → asks ONLY what's genuinely unknown → moves fast.

## The Rule

**Before you ask a single question, you must have:**
1. Searched AgentMemory for prior context
2. Read the relevant files if accessible
3. Checked if the request is self-contained

**If you can answer it yourself → DON'T ASK. Investigate.**

## When to Grill vs When to Scout vs When to Just Do

| Situation | Action |
|-----------|--------|
| Clear, specific request ("rename X to Y") | **JUST DO IT.** No grill. No scout. Plan + execute. |
| Request with enough context to act | **SCOUT** for code/file context → plan → execute. 0 questions. |
| Ambiguous but scroungable | **SCOUT FIRST** → read files → find context → then ask 1-2 targeted questions only on what's still unknown. |
| Truly ambiguous (no code/files/memories can help) | **GRILL** — 2-3 targeted questions max. Then act. |
| Bug with symptoms described | **SCOUT FIRST** (find the code) → ask only if repro is missing. |
| New feature, clear scope | **SCOUT** for existing patterns → plan → execute. 0 questions. |
| User already gave follow-up details | **STOP ASKING.** They clarified. Execute. |

## The Balance

**Investigation before interrogation. Questions after research, not instead of it.**

```
REQUEST COMES IN
  ↓
① CAN I figure this out myself? (memory, files, context)
   YES → DO IT. No questions.
   NO  ↓
② CAN A SCOUT figure this out?
   YES → SPAWN SCOUT → get context → ask 1-2 targeted questions on gaps.
   NO  ↓
③ NOW ASK. 2-3 questions max. Specific. Answerable in one sentence.
   ↓
④ CONFIRM → PLAN → EXECUTE.
```

## Question Rules

1. **2-3 questions max.** Not 5. Not 4. Three is generous. Two is ideal.
2. **Each question must have a default answer.** Format: "Should we use X or Y? (default: X)" — if they don't answer, you go with the default.
3. **No open-ended questions.** Not "what do you think?" — that's a trap. Give options.
4. **No redundant questions.** If the answer is in the code, the files, or memory — don't ask.
5. **After 1 round of questions, STOP and act.** Perfect clarity is the enemy of shipped work. Take your best guess and move.
6. **If the user answers vaguely, accept it and move on.** Don't probe a second time.

## The Format

```
RESTATE (1 sentence): "You want X. Here's what I found: [context from scout/memory]."
QUESTION (1-3 max): "Two things I need to decide: [question with default]?"
CONFIRM: "If no objections, I'll go with [X]."
```

**Then WAIT for the response. Then ACT.**

## Anti-Rot Rules

- Don't grill for the sake of grilling. Grilling is a tool, not a ritual.
- If you find yourself typing question #4, STOP. You've asked enough.
- If the user says "just do it" at ANY point — that means STOP ASKING. Execute immediately.
- A question you could answer by reading a file = a wasted question.
- A question the user already answered = a wasted question.
- A question without a default = an open-ended trap. Don't do it.
