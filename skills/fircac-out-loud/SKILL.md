---
name: ficrac-out-loud
description: "Makes the AI verbalize its FIRCAC reasoning process step-by-step as it works through problems. Use when you want transparent, auditable problem-solving. Triggers: 'think out loud', 'ficrac out loud', 'show your thinking', 'walk me through', 'explain your reasoning'."
---

# FIRCAC Out Loud

Verbalize every FIRCAC step as you work. No silent reasoning. The user sees your complete thought process.

## When to Use

- Complex debugging sessions
- Architecture decisions with tradeoffs
- When user wants to understand your approach
- When you're stuck and need to externalize reasoning
- Teaching/mentoring contexts

## How It Works

### Step 1: Announce FIRCAC Start
```
Starting FIRCAC analysis...
```

### Step 2: Verbalize Each Step

**FACTS:**
"Let me gather the facts. I'm seeing [observable evidence]. The error message is [X]. The input was [Y]."

**ISSUE:**
"The issue is: [one-sentence problem statement]."

**CASE:**
"This happens when [conditions]. It doesn't happen when [other conditions]. Affected scope: [what's impacted]."

**RULES:**
"The rules say: [requirements, specs, code contracts]. The type expects [X]. The spec requires [Y]."

**ANALYSIS:**
"Here's why: [root cause chain]. Because [A], then [B], which causes [C]."

**CONSEQUENCES:**
"If I fix this: [what improves]. If I don't: [what breaks]. Side effects: [risks]."

### Step 3: Announce Decision
"FIRCAC complete. Proceeding with [approach] because [reasoning]."

## Example Output

```
Starting FIRCAC analysis...

FACTS: User clicks "Submit", API returns 500. Console shows: TypeError: Cannot read property 'id' of undefined. Input: form with email field.

ISSUE: The user object is undefined when accessed in the submit handler.

CASE: Happens only when user is logged out AND form has >3 fields. Works when logged in. Affects all browsers.

RULES: Auth middleware should attach user to req before handler runs. Type says User is required (not optional).

ANALYSIS: Auth middleware skips attachment when no session cookie exists. Submit handler doesn't handle anonymous case. The code assumes user always exists.

CONSEQUENCES: If fixed: anonymous submissions will work. If not fixed: users can't submit without account. Side effects: need to decide if anonymous is allowed.

FIRCAC complete. Proceeding with adding optional user handling in submit handler.
```

## Rules

1. **Always verbalize** — no silent FIRCAC
2. **One step at a time** — don't skip ahead
3. **Use concrete details** — not vague statements
4. **Announce completion** — summarize decision
