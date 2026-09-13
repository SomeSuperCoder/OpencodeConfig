---
name: council
description: "Convene a council of specialists for complex decisions. Multiple perspectives in parallel, synthesized by the Supervisor. Use when one advisor isn't enough — when the decision touches multiple domains or needs diverse viewpoints."
---

# Council Protocol

When a decision is too complex for one advisor, convene a council. Multiple specialists give their perspective in parallel. You synthesize. You decide.

## When to Convene

| Situation | Council? |
|-----------|----------|
| Decision touches multiple domains (security + performance + UX) | YES |
| Architecture decision with competing tradeoffs | YES |
| "Should we build or buy?" | YES |
| Risk assessment before a big change | YES |
| One advisor already gave advice, but you need more viewpoints | YES |
| Simple implementation detail | NO — just decide |
| Decision with clear precedent in the codebase | NO — follow the pattern |
| Urgent and reversible | NO — decide fast, fix later |

## The Protocol

### Step 1: Define the Decision

State the decision in ONE sentence. What are we choosing between?

> "Should we use WebSocket or polling for real-time updates?"

### Step 2: Pick the Council (2-4 members max)

Choose specialists whose domain touches the decision. Each member brings ONE perspective.

| Domain | Who | What they advise on |
|--------|-----|---------------------|
| Code quality | Critique | Maintainability, simplicity, technical debt |
| Implementation | Senior Dev | Build cost, complexity, existing patterns |
| Testing | Tester | Testability, regression risk, coverage |
| Research | Scout | Prior art, community practices, existing solutions |
| Architecture | Advisor | Long-term implications, reversibility, tradeoffs |

**Pick 2-4.** Not 1 (defeats the purpose). Not 5+ (too many voices).

### Step 3: Spawn in Parallel

Spawn all council members at once. Each gets:
- The decision (same question)
- Their domain lens (what to focus on)
- What to deliver (recommendation + reasoning)

```
task(subagent_type="team/core/critique", background=true, prompt="
  COUNCIL MEMBER: You are the quality voice.
  DECISION: [the decision]
  YOUR LENS: What does this mean for code quality and maintainability?
  DELIVER: One recommendation + reasoning. 3 sentences max.
")

task(subagent_type="team/core/senior-developer", background=true, prompt="
  COUNCIL MEMBER: You are the implementation voice.
  DECISION: [the decision]
  YOUR LENS: What does this mean for build cost and complexity?
  DELIVER: One recommendation + reasoning. 3 sentences max.
")

task(subagent_type="team/core/scout", background=true, prompt="
  COUNCIL MEMBER: You are the research voice.
  DECISION: [the decision]
  YOUR LENS: What do existing codebases and community practices say?
  DELIVER: One recommendation + reasoning. 3 sentences max.
")
```

### Step 4: Collect Perspectives

Read each handoff. Each gives:
- **Recommendation** — what they'd choose
- **Reasoning** — why from their domain lens
- **Risk** — what they're worried about

### Step 5: Synthesize and Decide

You are the tiebreaker. You weigh the perspectives. You decide.

**Synthesis framework:**
1. List each recommendation
2. Note where they AGREE (strong signal — probably right)
3. Note where they DISAGREE (tension — this is where the real decision lives)
4. Weigh by: what matters MOST for this specific task?
5. Make the call. State WHY.

**Example output:**
```
COUNCIL SYNTHESIS:
- Critique: WebSocket — simpler long-term, but more upfront work.
- Senior Dev: Polling — faster to build, patterns exist in codebase.
- Scout: WebSocket — community consensus for real-time, polling is legacy.

AGREEMENT: Both Critique and Scout favor WebSocket for long-term quality.
TENSION: Senior Dev wants faster build, but the codebase already has WebSocket infra (Scout found this).

DECISION: WebSocket. The infra exists, long-term quality wins, and the build cost is lower than Senior Dev estimated because of existing patterns.
```

### Step 6: Act on the Decision

Proceed with the chosen path. If the decision is high-stakes, note it in memory for future reference.

## Council Rules

1. **2-4 members.** More voices ≠ better decision.
2. **Parallel spawns.** All members start at the same time.
3. **3 sentences max per member.** Concise advice, not essays.
4. **You decide.** The council advises. You are the tiebreaker.
5. **If the council is unanimous, move fast.** No need to over-analyze agreement.
6. **If the council is split, weigh by what matters most for THIS task.** Not every task values the same things.
7. **Don't convene a council for reversible decisions.** Decide fast, fix later.

## Anti-Patterns

| Anti-Pattern | Why it's bad |
|-------------|-------------|
| Convening a council for a one-liner | Overhead > value |
| Asking the same question to 5 specialists | Too many voices, no clarity |
| Letting one loud voice dominate | You weigh, not them |
| Ignoring disagreement in the council | Disagreement is signal — explore it |
| Convening a council because you're uncertain | Uncertainty means scout first, council second |
