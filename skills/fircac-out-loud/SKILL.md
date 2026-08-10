---
name: fircac-out-loud
description: "Makes the AI verbalize its FIRCAC reasoning process step-by-step as it works through problems. Use when you want transparent, auditable problem-solving. Also contains the ABC verification method (Assume Nothing, Believe Nobody, Confirm Everything) and the SOLID design protocol (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion), both verbalized. Triggers: 'think out loud', 'ficrac out loud', 'solid out loud', 'show your thinking', 'walk me through', 'explain your reasoning', 'reason the design'."
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

---

# ABC Verification Method

**ABC = Assume Nothing, Believe Nobody, Confirm Everything. A verification method that forces you to prove claims with evidence.**

## When to Use

- Before trusting any information
- Code review — verifying the reviewer's claims
- Testing claims — "it works" is a claim until proven
- Before accepting another agent's handoff verdict
- Before committing to a decision based on asserted facts

## The Method

### A — Assume Nothing
- Every claim starts as unverified, including your own assumptions.
- Don't assume code works because it looks right. Don't assume a verdict is correct because it's confident.
- List your assumptions explicitly — then challenge each one.

### B — Believe Nobody
- Treat claims from any source as hypotheses: docs, comments, other agents, even your own memory.
- Confidence is not evidence. A confident claim is still a claim.
- "The test passed" is not proof — the test output is proof.

### C — Confirm Everything
- Verify each claim with evidence: run the test, read the output, check the diff, execute the code.
- Ask: what would make this claim false? Then try to falsify it.
- Only accept a claim once you've independently confirmed it.

## Output

```
Starting ABC verification...
CLAIM: [the claim being verified]
ASSUMPTIONS: [what I'm assuming to be true]
EVIDENCE: [what I actually ran/read/observed]
VERDICT: CONFIRMED / DISPROVEN / UNVERIFIED
```

## Rules

1. **Always verbalize** — no silent ABC
2. **Evidence over authority** — who said it matters less than what proves it
3. **Confirm independently** — don't accept a claim on the strength of its source
4. **State the falsification test** — what would disprove this? Then run it.
5. **UNVERIFIED is a valid verdict** — better than a wrong CONFIRMED.

---

# SOLID Design Protocol

**SOLID = Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion. A design-quality protocol you verbalize over every design, module boundary, and implementation — the SOLID equivalent of FIRCAC. No silent design. Every principle argued out loud before it ships.**

## When to Use

- Designing a module, class, function, or service
- Defining interfaces, module boundaries, or dependency wiring
- Before reviewing any design or implementation
- When a design "looks fine" — SOLID is the structured way to prove it
- Whenever the 🏛️ SYSTEM DESIGN PRINCIPLES (modularity + dependency injection) are in play

## The Protocol

### S — Single Responsibility

**Goal:** Name the ONE reason this module/class/function changes.

**Questions:**
- What actor requests changes to this code?
- How many different reasons exist to modify it?
- Can I name its responsibility in one sentence?

**Verdict:** PASS — one clear reason to change. **SPLIT** — two or more actors pull it in different directions.

### O — Open/Closed

**Goal:** Show how the code is extended WITHOUT editing it.

**Questions:**
- Where is the extension point — an interface, a strategy, a plugin slot, a strategy?
- Can I add a new behavior by adding new code rather than changing existing code?
- Are there switch/if-chains that will grow every time a new variant appears?

**Verdict:** PASS — new behavior lands through an extension point. **NEEDS EXTENSION POINT** — editing existing code is the only way to change behavior.

### L — Liskov Substitution

**Goal:** Prove any implementation can be swapped at the interface without breaking callers.

**Questions:**
- Which concrete implementations sit behind this interface?
- If I swap implementation X for Y, does every caller still behave correctly?
- Are contracts honored — preconditions not strengthened, postconditions not weakened, invariants preserved?
- Does a subclass throw where the base contract promises success?

**Verdict:** PASS — contracts hold across all implementations. **CONTRACT BROKEN** — a swap changes behavior for existing callers.

### I — Interface Segregation

**Goal:** Show each client depends only on the interface members it actually uses.

**Questions:**
- Which clients consume this interface?
- Does any client depend on methods it never calls?
- Should the fat interface be split into narrow, role-specific interfaces?

**Verdict:** PASS — each client sees only what it uses. **FAT INTERFACE** — clients are forced to depend on unused surface.

### D — Dependency Inversion

**Goal:** Name the abstraction the module depends on and where that dependency is injected.

**Questions:**
- Does high-level policy depend on low-level detail, or on an abstraction of it?
- Where is the dependency constructed — injected at a composition root, or `new`-ed inside the consumer?
- Can I hand this module a fake/stub/mock at its boundary without touching its code?
- Are there service locators or global singletons hiding dependencies?

**Verdict:** PASS — depends on an abstraction, injected at the composition root. **INSTANTIATES OWN DEPS** — the module constructs its own concrete dependencies (violates the 🏛️ ARCHITECTURE LAW).

## Output — VERBALIZE IT

```
Starting SOLID review...
S: [module] exists for one reason — [reason]. Verdict: PASS / SPLIT.
O: Extended by [extension point]; no edit needed for new behavior. Verdict: PASS / NEEDS EXTENSION POINT.
L: Swappable implementations: [list]. Contracts held. Verdict: PASS / CONTRACT BROKEN.
I: Interfaces [X] serve [clients]; no client depends on unused members. Verdict: PASS / FAT INTERFACE.
D: Depends on [abstraction], injected at [composition root]. Verdict: PASS / INSTANTIATES OWN DEPS.
SOLID complete. [summary sentence]
```

## Rules

1. **Always verbalize** — a silent SOLID is a skipped SOLID
2. **One principle at a time** — never blend two into one vague sentence
3. **Say the concrete name** — "this class" not "the thing"; "the HttpClient interface" not "it"
4. **A principle you cannot answer is a RED flag** — fix the design before proceeding
5. **D is the architect's law** — for any module boundary or dependency wiring, Dependency Inversion and the composition root are non-negotiable
