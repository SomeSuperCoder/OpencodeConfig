---
name: fircac-out-loud
description: "Makes the AI verbalize its FIRCAC reasoning process step-by-step as it works through problems. Use when you want transparent, auditable problem-solving. Also contains the ABC verification method (Assume Nothing, Believe Nobody, Confirm Everything) and the SOLID design protocol (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion), both verbalized. Triggers: 'think out loud', 'ficrac out loud', 'solid out loud', 'show your thinking', 'walk me through', 'explain your reasoning', 'reason the design'."
---

# FIRCAC Protocol

A structured reasoning framework for designing, implementing, debugging, and reviewing software. Verbalize every step — no silent reasoning.

## The Protocol

### F — Facts
**Goal:** Collect objective information before making any decisions.
**Questions:** What is the project trying to accomplish? Requirements? What code exists? Technologies used? Constraints? Confirmed assumptions? Observed errors? Unknown information?
**Output:** A concise list of verified facts only. No opinions, guesses, or proposed solutions.

### I — Issue
**Goal:** Identify the real engineering problem. Avoid treating symptoms as the problem.
**Questions:** What is preventing success? What decision must be made? What bug needs explanation? Which architectural question is unresolved? What ambiguity exists in the requirements?
**Output:** State the issue as a single clear question.

### R — Rules
**Goal:** Determine the governing constraints (specs, docs, conventions, architecture, security, performance, style guides, best practices).
**Questions:** What official documentation applies? Which invariants must never be violated? What interfaces must remain compatible? What constraints are imposed by the architecture?
**Output:** A numbered list of applicable rules.

### C — Cases
**Goal:** Study existing examples before inventing a solution (codebase patterns, prior fixes, design patterns, ADRs, RFCs, community practices).
**Questions:** Has this problem already been solved? How does the project solve similar problems? Which patterns have proven successful? What mistakes have occurred previously?
**Output:** Summarize relevant precedents and explain why they are relevant.

### A — Application
**Goal:** Reason from facts using rules and precedents. Connect: Facts → Rules → Cases → Proposed Solution.
**Questions:** Which rules apply? Which cases are most similar? What solution best satisfies the requirements? Trade-offs? Edge cases? What could break? Which alternatives were rejected and why?
**Output:** A complete justification for the chosen implementation.

### C — Consequences
**Goal:** Evaluate expected outcomes before implementation.
**Consider:** correctness (does this solve the issue?), compatibility (will existing behavior change?), performance (CPU, memory, network, disk), security (new attack surface? secrets exposed? authorization preserved?), maintainability (easy to understand? extensible? reduces tech debt?), testing (what tests should pass?), risks (regressions, migration, rollback strategy).
**Output:** A prediction of the implementation's consequences and verification plan.

---

# ABC Verification Method

**ABC = Assume Nothing, Believe Nobody, Confirm Everything.** A verification method that forces you to prove claims with evidence.
**When to use:** before trusting any information, code review, testing claims, before accepting another agent's handoff verdict, before committing to a decision based on asserted facts.

## The Method

- **A — Assume Nothing:** Every claim starts as unverified, including your own. Don't assume code works because it looks right. List assumptions explicitly — then challenge each one.
- **B — Believe Nobody:** Treat claims from any source as hypotheses (docs, comments, agents, your own memory). Confidence is not evidence. "The test passed" is not proof — the output is proof.
- **C — Confirm Everything:** Verify each claim with evidence (run the test, read the output, check the diff). Ask: what would make this claim false? Then try to falsify it. Only accept a claim once independently confirmed.

## Output

```
CLAIM: [claim] | ASSUMPTIONS: [assumptions] | EVIDENCE: [what I observed] | VERDICT: CONFIRMED / DISPROVEN / UNVERIFIED
```

## Rules

1. **Always verbalize** — no silent ABC
2. **Evidence over authority** — who said it matters less than what proves it
3. **Confirm independently** — don't accept a claim on the strength of its source
4. **State the falsification test** — what would disprove this? Then run it
5. **UNVERIFIED is a valid verdict** — better than a wrong CONFIRMED

---

# SOLID Design Protocol

**SOLID = Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.** A design-quality protocol verbalized over every design, module boundary, and implementation.
**When to use:** designing a module/class/function/service, defining interfaces or module boundaries, before reviewing any design or implementation.

## The Protocol

### S — Single Responsibility
**Goal:** Name the ONE reason this module/class/function changes.
**Questions:** What actor requests changes? How many different reasons exist to modify it? Can I name its responsibility in one sentence?
**Verdict:** PASS — one clear reason. **SPLIT** — two or more actors pull in different directions.

### O — Open/Closed
**Goal:** Show how the code is extended WITHOUT editing it.
**Questions:** Where is the extension point (interface, strategy, plugin)? Can new behavior be added without changing existing code? Are there switch/if-chains that grow with every new variant?
**Verdict:** PASS — new behavior lands through an extension point. **NEEDS EXTENSION POINT** — editing existing code is the only way.

### L — Liskov Substitution
**Goal:** Prove any implementation can be swapped at the interface without breaking callers.
**Questions:** Which concrete implementations sit behind this interface? If I swap X for Y, do callers still behave correctly? Are contracts honored (preconditions not strengthened, postconditions not weakened, invariants preserved)? Does a subclass throw where the base contract promises success?
**Verdict:** PASS — contracts hold across all implementations. **CONTRACT BROKEN** — a swap changes behavior for existing callers.

### I — Interface Segregation
**Goal:** Show each client depends only on the interface members it actually uses.
**Questions:** Which clients consume this interface? Does any client depend on methods it never calls? Should the fat interface be split into narrow, role-specific interfaces?
**Verdict:** PASS — each client sees only what it uses. **FAT INTERFACE** — clients depend on unused surface.

### D — Dependency Inversion
**Goal:** Name the abstraction the module depends on and where that dependency is injected.
**Questions:** Does high-level policy depend on low-level detail, or on an abstraction? Where is the dependency constructed (injected at composition root, or `new`-ed inside the consumer)? Can I hand this module a fake/stub/mock at its boundary without touching its code? Are there service locators or global singletons hiding dependencies?
**Verdict:** PASS — depends on abstraction, injected at composition root. **INSTANTIATES OWN DEPS** — module constructs its own concrete dependencies.

## Output

```
S: [module] → [reason]. PASS / SPLIT.
O: [extension point]. PASS / NEEDS EXTENSION POINT.
L: [list]. PASS / CONTRACT BROKEN.
I: [clients]. PASS / FAT INTERFACE.
D: [abstraction] at [root]. PASS / INSTANTIATES OWN DEPS.
```

## Rules

1. **Always verbalize** — a silent SOLID is a skipped SOLID
2. **One principle at a time** — never blend two into one vague sentence
3. **Say the concrete name** — "this class" not "the thing"
4. **A principle you cannot answer is a RED flag** — fix the design before proceeding
5. **D is the architect's law** — Dependency Inversion and the composition root are non-negotiable
