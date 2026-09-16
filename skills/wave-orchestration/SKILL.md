---
name: wave-orchestration
description: "Dynamic wave planning for the Supervisor. Groups microtasks into adaptive waves based on dependencies, complexity, and what comes back from agents. Not rigid phases — organic, evolving structure."
---

# Wave Orchestration

Waves are groups of related microtasks that run together. You decide the wave structure dynamically based on the task, not a fixed template.

## The Core Idea

```
TASK COMES IN
  ↓
① DECOMPOSE — What are the microtasks? What depends on what?
② WAVE 1 — The microtasks that can start NOW (no dependencies)
③ COLLECT — Read handoffs from Wave 1
④ WAVE 2 — What's unblocked by Wave 1's results
⑤ COLLECT — Read handoffs from Wave 2
⑥ REPEAT — Until the task is done
```

**Waves are not phases.** They're live. They adapt. If Wave 1 reveals something unexpected, Wave 2 changes. You don't stick to the original plan when reality disagrees.

## How to Decompose

For each microtask, ask:
1. **What does this need?** (inputs, context, prerequisites)
2. **What does this produce?** (output, handoff, deliverable)
3. **Can this run alongside other microtasks?** (parallel) or **must it wait?** (sequential)

## Wave Patterns

### Pattern 1: Simple Task (1 wave)

```
Wave 1: [Senior Dev] — implement the thing → handoff → DONE
```

One agent. One wave. Ship it.

### Pattern 2: Context → Implement (2 waves)

```
Wave 1: [Scout] — gather context → handoff
Wave 2: [Senior Dev] — implement with context → handoff → DONE
```

Scout first, then build. Classic.

### Pattern 3: Parallel Build (2 waves)

```
Wave 1: [Senior Dev A] — build module X
         [Senior Dev B] — build module Y (parallel)
Wave 2: [Tester] — test both → handoff → DONE
```

Independent work runs together. Testing waits for both.

### Pattern 4: Design → Build → Verify (3 waves)

```
Wave 1: [Advisor] — recommend approach
         [Scout] — gather codebase context (parallel)
Wave 2: [Senior Dev] — implement based on advice + context
Wave 3: [Tester] — test
         [Critique] — review (parallel) → DONE
```

Design wave, build wave, verification wave.

### Pattern 5: Complex Multi-Component (adaptive)

```
Wave 1: [Scout] — gather context for ALL components
Wave 2: [Senior Dev A] — component 1
         [Senior Dev B] — component 2 (parallel)
         [Advisor] — architecture advice (parallel)
Wave 3: [Senior Dev A] — integration work (needs both components)
         [Tester] — test component 1 (parallel, can start early)
Wave 4: [Tester] — test integration
         [Critique] — review full system → DONE
```

Waves 2 and 3 overlap. Testing starts before build finishes. Adaptive.

## Wave Decision Rules

| Situation | What to do |
|-----------|------------|
| Microtask has no dependencies | Put it in the EARLIEST wave |
| Microtask depends on another's output | Put it in the NEXT wave after the dependency |
| Two microtasks are independent | Run them in the SAME wave (parallel) |
| A microtask reveals new work | Add it to the CURRENT or NEXT wave — don't restart |
| Wave 1 fails | Diagnose, fix, re-run. Don't skip to Wave 2. |
| Task is simpler than expected | Collapse waves. Fewer waves = faster. |
| Task is more complex than expected | Split a wave. More granular = safer. |

## Dynamic Adaptation

**The handoff changes the plan.** When you collect a handoff:
1. Read `for_supervisor` — what was the verdict?
2. Read `for_successor` — who should come next?
3. Adjust Wave N+1 based on what you learned.

If a handoff says "found a blocker" → add a microtask to the next wave to address it.
If a handoff says "component X is more complex" → split the next wave.
If a handoff says "nothing to do here" → collapse the next wave.

**Never blindly follow the original plan when reality disagrees.**

## Wave Naming Convention

Name waves by purpose, not number:
- `gather-context` — scouts, research
- `design` — advisors, architects, critique
- `implement` — senior devs
- `verify` — testers, critique
- `ship` — final review, handoff

This makes it clear what each wave DOES, not just when it runs.

## Recursive Verification (RLM-Inspired)

After EVERY wave, verify before proceeding. Don't just hope it worked.

### The Verification Loop

```
WAVE COMPLETES
  ↓
① READ handoffs — what did the agents actually produce?
② VERIFY — does output match expected output? (what we asked for, not "is it good")
③ IF MATCH → proceed to next wave
④ IF MISMATCH → diagnose:
   a. Was the decomposition wrong? → re-decompose
   b. Was the prompt bad? → re-write prompt, re-spawn
   c. Was the scope wrong? → adjust scope
⑤ FIX root cause → re-spawn failed wave → re-verify
```

### What to Check

| Check | What to look for | If missing |
|-------|-----------------|------------|
| Completeness | All expected deliverables present | Re-spawn with tighter scope |
| Correctness | Output matches what was asked | Re-spawn with better prompt |
| Quality | Meets minimum bar (not perfect, not broken) | Re-spawn or fix forward |
| Dependencies | All prerequisites satisfied | Block next wave, resolve first |

### The Rule

**Never proceed on hope.** "It probably worked" is not verification. Read the handoff. Check the output. Confirm. Then proceed.

## Anti-Patterns

| Anti-Pattern | Why it's bad |
|-------------|-------------|
| Spawning the whole task in one wave | Agents block each other, no parallelism |
| Waiting for one agent before spawning the next | Serial when parallel is possible |
| Re-spawning failed agents in the same wave | Diagnose first, then re-spawn in a new wave |
| Collapsing verification into the build wave | Testing needs clean code first |
| Planning 5 waves ahead | You don't know what Wave 1 will reveal |

## The Rule

**Waves are living structure, not a Gantt chart.** Plan the first wave in detail. Hold the rest loosely. Adapt as handoffs come in. The best wave plan is the one that survives contact with reality.
