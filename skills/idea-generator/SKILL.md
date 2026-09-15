---
name: idea-generator
description: "Creative brainstorming protocol for out-of-the-box thinking. Generates wild, unconventional, and surprising ideas. Use when the user needs alternatives, creative solutions, or when conventional approaches are failing. Triggers: 'brainstorm', 'ideas', 'creative', 'what else', 'think different', 'out of the box'."
---

# Idea Generator Protocol

Break the frame. The obvious answer is usually wrong. Generate ideas that surprise.

## When to Use

- User asks "what else can we do?"
- Conventional approaches aren't working
- Need alternatives before committing to a direction
- User feels stuck or boxed in
- Before a council decision — generate options first
- When the user wants to explore, not decide

## The Protocol

### Step 1: Define the Box

What are we thinking inside of? State the obvious constraints.

> "We're building a notification system. The box: email, push, SMS, existing APIs, current team size."

### Step 2: List the Assumptions

What are we assuming to be true without questioning?

> "We assume users want notifications. We assume real-time is better. We assume we need to build it ourselves."

### Step 3: Break the Assumptions

For each assumption, ask: "What if this were NOT true?"

| Assumption | What if false? | Idea |
|-----------|---------------|------|
| Users want notifications | Users want to check on their own schedule | Pull-based dashboard instead of push |
| Real-time is better | Delayed is actually better | Digest mode — batch notifications hourly |
| We need to build it | There's a service that does this | Zapier, n8n, Make integration |

### Step 4: Lateral Moves

Apply creative thinking frameworks:

**Reversal:** What's the opposite of the obvious solution? Do that instead.

> "Instead of sending notifications TO users, let users pull notifications FROM us."

**Combination:** What if we combined this with something unrelated?

> "What if notifications were gamified? Earn points for engaging with alerts."

**Extreme:** What's the most absurd version of this?

> "What if we had a notification concierge — a human who calls you when something matters?"

**Elimination:** What if we removed the core feature entirely?

> "What if we had zero notifications and just made the product so good users never need reminding?"

**Scale:** What if this were 10x bigger or 10x smaller?

> "What if we only sent ONE notification per day — the single most important thing?"

**Analogy:** How would a completely different industry solve this?

> "How does the postal service handle this? Physical mail for high-priority. Email for low-priority."

### Step 5: Wild Cards

Generate 3 ideas that are deliberately weird. Not practical — weird. Force yourself to think differently.

> 1. "Notification as a service — other companies pay us to notify their users"
> 2. "AI reads notifications and only wakes you up if it's truly urgent"
> 3. "Users subscribe to NOT receive notifications — pay for silence"

### Step 6: Filter (Only After Generating)

Now filter the ideas:

| Idea | Feasible? | Valuable? | Novel? | Keep? |
|------|----------|----------|--------|-------|
| Pull dashboard | ✅ | ✅ | ⚠️ Common | Maybe |
| Digest mode | ✅ | ✅ | ✅ | Yes |
| Human concierge | ❌ Too expensive | ✅ | ✅ | No (too costly) |
| Zero notifications | ✅ | ⚠️ Risky | ✅ | Maybe (bold) |
| Gamified alerts | ⚠️ Complex | ⚠️ Maybe | ✅ | Maybe |
| Notification as service | ✅ | ✅ | ✅ | Yes |
| Pay for silence | ❌ | ⚠️ | ✅ | No (too weird) |

## Output

```
THE BOX: [what we're thinking inside of]
ASSUMPTIONS: [what we take for granted]
BROKEN ASSUMPTIONS: [ideas from breaking each]
LATERAL MOVES: [reversal, combination, extreme, elimination, scale, analogy]
WILD CARDS: [3 deliberately weird ideas]
FILTERED: [top 3-5 ideas with feasibility check]
```

## Rules

1. **Generate BEFORE judging.** Don't self-censor during Step 4-5. Bad ideas are fuel for good ones.
2. **Quantity over quality.** 10 ideas > 3 perfect ones. You can filter later.
3. **Weird is good.** The wildest idea often contains a kernel of the best solution.
4. **Never start with "that's stupid."** Start with "what if..."
5. **The obvious answer is usually wrong.** If it were obvious, someone would've done it already.
6. **Steal from other domains.** The best ideas come from unrelated fields.
7. **The user picks, not you.** Generate options, don't decide.
