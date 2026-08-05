---
name: ficrac-out-loud
description: "Makes the AI verbalize its FIRCAC reasoning process step-by-step as it works through problems. Use when you want transparent, auditable problem-solving. Triggers: 'think out loud', 'ficrac out loud', 'show your thinking', 'walk me through', 'explain your reasoning'."
---

# FIRCAC Protocol for Software Engineering

> A structured reasoning framework for designing, implementing, debugging, and reviewing software.

Verbalize every FIRCAC step as you work. No silent reasoning. The user sees your complete thought process.

## When to Use

- Complex debugging sessions
- Architecture decisions with tradeoffs
- When user wants to understand your approach
- When you're stuck and need to externalize reasoning
- Teaching/mentoring contexts

## The Protocol

### F — Facts

**Goal:** Collect objective information before making any decisions.

**Questions:**
- What is the project trying to accomplish?
- What are the requirements?
- What code already exists?
- What technologies are being used?
- What constraints exist?
- What assumptions are confirmed?
- What errors have actually been observed?
- What information is still unknown?

**Output:** A concise list of verified facts only. Do NOT include opinions, guesses, or proposed solutions.

### I — Issue

**Goal:** Identify the real engineering problem. Avoid treating symptoms as the problem.

**Questions:**
- What is preventing success?
- What decision must be made?
- What bug needs explanation?
- Which architectural question is unresolved?
- What ambiguity exists in the requirements?

**Output:** State the issue as a single clear question.

Examples:
> Why does authentication fail after token refresh?
> Which database schema best satisfies the scaling requirements?
> Why is memory usage increasing over time?

### R — Rules

**Goal:** Determine the governing constraints.

Rules include:
- language specifications
- framework documentation
- API contracts
- project conventions
- architecture principles
- security practices
- performance requirements
- style guides
- engineering best practices

**Questions:**
- What official documentation applies?
- Which invariants must never be violated?
- What interfaces must remain compatible?
- What constraints are imposed by the architecture?

**Output:** A numbered list of applicable rules.

### C — Cases

**Goal:** Study existing examples before inventing a solution.

Cases may include:
- existing codebase implementations
- similar modules
- previous bug fixes
- design patterns
- accepted architecture
- official examples
- community best practices
- RFCs
- prior decisions (ADRs)

**Questions:**
- Has this problem already been solved?
- How does the project solve similar problems?
- Which patterns have already proven successful?
- What mistakes have occurred previously?

**Output:** Summarize the relevant precedents and explain why they are relevant.

### A — Application

**Goal:** Reason from facts using the rules and precedents. This is the analysis phase.

**Questions:**
- Which rules apply?
- Which cases are most similar?
- What solution best satisfies the requirements?
- What trade-offs exist?
- What edge cases appear?
- What could break?
- Which alternatives were rejected and why?

The application should explicitly connect: Facts → Rules → Cases → Proposed Solution.

**Output:** A complete justification for the chosen implementation.

### C — Consequences

**Goal:** Evaluate the expected outcomes before implementation.

Consider:

**Correctness** — Does this solve the issue?

**Compatibility** — Will existing behavior change?

**Performance** — CPU, Memory, Network, Disk.

**Security** — New attack surface? Secrets exposed? Authorization preserved?

**Maintainability** — Is the solution easy to understand? Is it extensible? Does it reduce technical debt?

**Testing** — What tests should pass? Unit, integration, end-to-end, regression.

**Risks** — Possible regressions, migration requirements, rollback strategy.

**Output:** A prediction of the implementation's consequences and verification plan.

### Summary

```
Facts
    ↓
Issue
    ↓
Rules
    ↓
Cases
    ↓
Application
    ↓
Consequences
```

### Checklist

Before writing code, ensure you can answer:
- [ ] Do I understand all relevant facts?
- [ ] Have I identified the actual problem?
- [ ] Which official rules or specifications apply?
- [ ] Are there existing implementations or precedents?
- [ ] Have I justified the chosen solution?
- [ ] Have I considered performance, security, compatibility, and maintainability?
- [ ] Have I identified risks and defined how success will be verified?

### Guiding Principle

> Never jump from a problem directly to code.
> First understand the facts. Then define the issue. Then identify the governing rules. Then study precedent. Then justify the solution. Finally evaluate its consequences.
> Code should be the result of structured reasoning, not intuition.

## Example Output

```
Starting FIRCAC analysis...

FACTS: User clicks "Submit", API returns 500. Console shows: TypeError: Cannot read property 'id' of undefined. Input: form with email field. Verified: auth middleware runs before handler.

ISSUE: Why does the submit handler crash when the user object is undefined?

RULES: (1) Auth middleware must attach user before handlers run. (2) User is typed as required, not optional. (3) Project convention: guard all external input.

CASES: Login flow guards the anonymous case (checks req.user). A prior bug fix (#142) added the same guard to the profile endpoint.

APPLICATION: The submit handler follows the login-flow pattern: add the same guard. Rules 2 contradicts the current handler's assumption — the guard belongs in the handler, not the type. Edge case: anonymous submissions must be decided as allowed or rejected.

CONSEQUENCES: Correctness — crash fixed. Compatibility — login flow unchanged; only submit path gains a guard. Security — no new attack surface; anonymous path now explicit. Testing — add unit test for logged-out submit, e2e regression for form submit. Risk — if anonymous is disallowed, return 401 instead of crashing.

FIRCAC complete. Proceeding with adding the anonymous-user guard in the submit handler.
```

## Rules

1. **Always verbalize** — no silent FIRCAC
2. **One step at a time** — don't skip ahead: Facts → Issue → Rules → Cases → Application → Consequences
3. **Use concrete details** — not vague statements
4. **Never jump from problem to code** — reason through the full chain first
5. **Announce completion** — summarize decision
