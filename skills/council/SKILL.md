---
name: council
description: "Convene a council of Advisors and Critiques. Each brings their own opinion on the same decision. Multiple viewpoints, synthesized by the Supervisor. Use for complex decisions that need diverse expert opinions."
---

# Council Protocol

Convene multiple Advisors and Critiques. Each gets the same decision. Each gives their own opinion. You synthesize. You decide.

## When to Convene

| Situation | Council? |
|-----------|----------|
| Complex decision with competing tradeoffs | YES |
| Architecture choice, build vs buy, direction change | YES |
| Risk assessment before a big move | YES |
| One perspective isn't enough | YES |
| Simple implementation detail | NO |
| Clear precedent exists | NO |
| Urgent and reversible | NO |

## The Protocol

### Step 1: Define the Decision

ONE sentence. What are we choosing?

> "Should we rewrite the auth module or patch it?"

### Step 2: Spawn the Council (2-4 members)

Spawn 2-4 Advisors and/or Critiques. Each gets the same decision but forms their OWN opinion.

```
task(subagent_type="team/core/advisor", background=true, prompt="
  You are Council Member 1 — an Advisor.
  DECISION: [the decision]
  CONTEXT: [relevant facts — what the codebase looks like, constraints, goals]
  FORM YOUR OWN OPINION. Analyze tradeoffs. Recommend.
  DELIVER: Your recommendation + reasoning. 5 sentences max.
")

task(subagent_type="team/core/advisor", background=true, prompt="
  You are Council Member 2 — an Advisor.
  DECISION: [the decision]
  CONTEXT: [same facts]
  FORM YOUR OWN OPINION. Think independently. Don't assume the other member is right.
  DELIVER: Your recommendation + reasoning. 5 sentences max.
")

task(subagent_type="team/core/critique", background=true, prompt="
  You are Council Member 3 — a Critique.
  DECISION: [the decision]
  CONTEXT: [same facts]
  ATTACK THIS DECISION. Find the risks, the hidden costs, the failure modes.
  DELIVER: Your critique + risks. 5 sentences max.
")

task(subagent_type="team/core/critique", background=true, prompt="
  You are Council Member 4 — a Critique.
  DECISION: [the decision]
  CONTEXT: [same facts]
  ATTACK THIS DECISION from a different angle. What are they missing?
  DELIVER: Your critique + risks. 5 sentences max.
")
```

### Step 3: Collect Opinions

Read each handoff. Each gives:
- **Recommendation or critique** — what they think
- **Reasoning** — why
- **Risks or concerns** — what could go wrong

### Step 4: Synthesize and Decide

You weigh the opinions. You decide.

**Synthesis:**
1. List each opinion
2. Where they AGREE → strong signal
3. Where they DISAGREE → this is where the real decision lives
4. Weigh by: what matters MOST for this task?
5. Make the call. State WHY.

**Example:**
```
COUNCIL SYNTHESIS:
- Advisor 1: Rewrite — patching adds debt, rewrite is cleaner long-term.
- Advisor 2: Patch — rewrite is 3x the effort, patch fixes the immediate issue.
- Critique 1: Rewrite risk — we might break things that work. Patch is safer.
- Critique 2: Patch risk — the auth module has 47 patches already. Next patch might not fit.

AGREEMENT: All agree the auth module is in bad shape.
TENSION: Rewrite (long-term) vs Patch (short-term safety).

DECISION: Rewrite. Critique 2's point about 47 patches is the tiebreaker — we're at the limit of patching.
```

### Step 5: Act

Proceed with the chosen path. Note the decision if high-stakes.

## Council Rules

1. **2-4 members.** Advisors and/or Critiques. Mix and match.
2. **Same decision, same context, different opinions.** Each member thinks independently.
3. **Parallel spawns.** All members start at once.
4. **5 sentences max per member.** Concise opinions, not essays.
5. **You decide.** The council advises. You are the tiebreaker.
6. **Unanimous → move fast.** No need to over-analyze agreement.
7. **Split → weigh by what matters most for THIS task.**
8. **Don't convene for reversible decisions.** Decide fast, fix later.
