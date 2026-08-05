---
name: refactoring-patterns
description: Code smells, refactoring techniques, extraction patterns. Use when refactoring code, improving readability, or reducing complexity.
---

# Refactoring Patterns

## When To Use This

- Improving structure without changing behavior
- Eliminating code smells (long methods, duplication, feature envy)
- Making a change safe before touching tested code
- Reviewing a diff for refactorability

## Refactoring Fundamentals

### The Golden Rule: behavior preservation

> Refactoring is a change that improves structure while **keeping observable behavior identical**.

- Refactor and feature-work are separate activities. Don't fix a bug while refactoring — one change, one intent. (A refactor + bugfix mixed together makes the bug impossible to bisect.)
- **Run the tests before you start** — a green baseline is your safety net. If there's no coverage on the code you're refactoring, write characterization tests first.
- Small steps, green at each step. If you can't keep the suite green after a step, the step was too big.
- The IDE is your friend: Extract Method, Extract Variable, Rename, Inline are mechanical and reliable — use them over hand-editing.

### The Refactoring Loop

1. Identify the smell
2. Pick the smallest refactoring that removes it
3. Apply one step → run tests
4. If green, next step. If red, **revert** the step (you can, because steps are small)
5. Stop when the code reads clearly

### When NOT to refactor

| Situation | Do |
|-----------|-----|
| Untested third-party/legacy code you must ship a fix for | Write characterization tests first |
| Deployed hotfix under pressure | Ship the fix; refactor separately |
| Code with no tests and no time to add them | Get coverage before touching |
| Cosmetic churn with no structure gain | Leave it — churn costs review + merge risk |

## Code Smells

### The Common Smells — Symptoms & Fixes

| Smell | Symptom | Primary fix |
|-------|---------|-------------|
| **Long method** (>30 lines, 3+ levels of nesting) | Hard to read, one job mixed with many | Extract Function; Extract Conditional |
| **Large class** (>300 lines, 5+ responsibilities) | Many `// ---` comment sections | Extract Class; Split Module |
| **Duplicated code** (3+ places) | Same logic copy-pasted | Extract Function; Pull Up (template method) |
| **Long parameter list** (>3) | Callers hard to read, easy to swap args | Introduce Parameter Object / options object |
| **Feature envy** | Method uses another object's data more than its own | Move Method / Move Field |
| **Primitive obsession** | `string`/`number` used for domain concepts (email, money, IDs) | Replace Primitive with Value Object |
| **Switch/if chains on type** | `if (obj.type === 'a') ... else if (obj.type === 'b')` | Replace Conditional with Polymorphism / Strategy |
| **Data clumps** | `firstName, lastName, email` passed together everywhere | Extract Class / Parameter Object |
| **Dead code** | Never-called branches, unused params | Delete it; use Parameter Object if interface contract needs it |
| **Shotgun surgery** | One change touches 10 files | Move related behavior into one module |
| **Inappropriate intimacy** | Classes reach into each other's internals | Move Method; Hide Delegate |
| **Message chains** | `a.b().c().d()` deep traversal | Hide Delegate |
| **Refused bequest** | Subclass ignores inherited members | Replace Inheritance with Delegation |

### Long Method

```typescript
// Before — 40+ lines mixing validation, calculation, persistence, notification
function processOrder(order: Order) {
  // validate, compute tax, save, email ... all inline
}

// After — each named step is one responsibility, one test target
function processOrder(order: Order) {
  const validated = validateOrder(order);
  const priced = calculatePricing(validated);
  const saved = saveOrder(priced);
  return sendConfirmation(saved);
}
```

**Signal:** if you can't summarize a method in one sentence, it does too much. Extract until it's summarizable.

### Large Class → Extract Class

```typescript
// Before
class Person {
  name: string;
  officeAreaCode: string;
  officeNumber: string;
  getTelephoneNumber() { return `(${this.officeAreaCode}) ${this.officeNumber}`; }
}

// After
class TelephoneNumber {
  constructor(private areaCode: string, private number: string) {}
  toString() { return `(${this.areaCode}) ${this.number}`; }
}
class Person {
  name: string;
  telephoneNumber: TelephoneNumber;
  getTelephoneNumber() { return this.telephoneNumber.toString(); }
}
```

### Duplication — the DRY trigger (rule of three)

```typescript
// 2 places: tolerate (may not be the same concept yet)
// 3 places: extract
const totalA = itemsA.reduce((s, i) => s + i.price, 0);
const totalB = itemsB.reduce((s, i) => s + i.price, 0);

// Extracted — single source of truth for the formula
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

### Long Parameter List → Parameter Object

```typescript
// Before — 7 positional args, order errors are silent bugs
function createUser(name, email, phone, address, city, state, zip) {}

// After — one object, defaults possible, callers self-document
interface CreateUserParams { name: string; email: string; phone?: string; address?: Address; }
function createUser(params: CreateUserParams) {}
```

### Feature Envy → Move Method

```typescript
// Before — Order computes display logic from customer's fields
class Order { formatForDisplay() { return `${this.customer.name}: $${this.total}`; } }

// After — the class that owns the data formats it
class OrderFormatter { format(order: Order) { return `${order.customer.name}: $${order.total}`; } }
```

Envy is a hint about data ownership: **behavior should live next to the data it reads most.** Move it, don't just accept the smell.

### Primitive Obsession → Value Object

```typescript
// Before — email is an untyped string; invalid emails slip through everywhere
function createUser(name: string, email: string) {}

// After — the type guards itself at construction
class Email {
  constructor(private value: string) {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) throw new Error('Invalid email');
  }
  toString() { return this.value; }
}
function createUser(name: Name, email: Email) {}
```

Value objects are **immutable**; equality by value, not identity. Money, dates, currency, IDs, emails — all primitives with rules.

### Conditional Chains → Strategy / Polymorphism

```typescript
// Before — every new risk level means editing this class
class Parachute {
  calculateValue(risk: string) {
    if (risk === 'low') return this.basePrice * 1.1;
    if (risk === 'medium') return this.basePrice * 1.3;
    if (risk === 'high') return this.basePrice * 1.8;
  }
}

// After — open/closed: add a level by adding a class, not editing
interface ValuationStrategy { calculate(base: number): number; }
class LowRiskValuation implements ValuationStrategy { calculate(b: number) { return b * 1.1; } }
class Parachute {
  constructor(private strategy: ValuationStrategy) {}
  calculateValue() { return this.strategy.calculate(this.basePrice); }
}
```

**Don't over-apply:** replace-if-with-polymorphism only when branches select *behavior by type*, not when they're simple value differences.

## Safe Refactoring Techniques

### Extract Function — the workhorse

```typescript
// Before
function printOwing(invoice) {
  let outstanding = 0;
  console.log('*** Customer Owes ***');
  for (const o of invoice.orders) outstanding += o.amount;
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}

// After — each step named, independently testable
function printOwing(invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}
```

Extract criteria: a code block with a single purpose you can name; it produces a value or a clear side effect. **Extract until the original method reads like a table of contents.**

### Inline Function — the counter-move

```typescript
// Before — a name that hides more than it clarifies
function getRating(driver) { return moreThanFiveLateDeliveries(driver) ? 2 : 1; }
function moreThanFiveLateDeliveries(driver) { return driver.numberOfLateDeliveries > 5; }

// After — indirection removed
function getRating(driver) { return driver.numberOfLateDeliveries > 5 ? 2 : 1; }
```

Inline when: the function name adds nothing, it's called once, or its body is as clear as its name. (The inverse of Extract — both are first-class techniques.)

### Move Method / Move Field

```typescript
// Before — shipping math lives in Order but only uses destination + shippingRate
class Order {
  calculateShippingCost(destination: Address) {
    return destination.distance * this.shippingRate;
  }
}

// After — moved to the collaborator that owns the concern
class ShippingCalculator {
  calculateCost(order: Order, destination: Address) {
    return destination.distance * order.shippingRate;
  }
}
```

Move when: a method references another object's fields more than its own, or cohesion is split across classes.

### Replace Conditional with Guard Clauses (readability)

```typescript
// Before — nested else hides the "early exit" intent
function handle(req) {
  if (req.user) {
    if (req.user.isAdmin) {
      return doAdminThing(req);
    } else {
      return doMemberThing(req);
    }
  }
  throw new Error('No user');
}

// After — guard clause: the exceptional path exits first
function handle(req) {
  if (!req.user) throw new Error('No user');
  return req.user.isAdmin ? doAdminThing(req) : doMemberThing(req);
}
```

## Testing Around Refactors

### Characterization Tests (legacy / untested code)

Before touching untested code, capture current behavior — **including bugs** — as tests, then refactor:

```typescript
// Record ACTUAL current behavior, not intended behavior
it('sums items as it does today', () => {
  const result = legacyCalculateTotal([{ price: 10 }, { price: 5 }]);
  expect(result).toBe(15);      // what it does NOW
});
```

- These are throwaway safety nets: keep them until the refactor lands, then replace with tests for *intended* behavior.
- If behavior looks wrong, note it, but the characterization test pins it so your refactor doesn't silently change it.

### Refactor → Test Strategy

| Phase | What to run |
|-------|-------------|
| Before first edit | Full suite + characterize untested code |
| After each small step | Affected tests (fast loop) |
| After the refactor | Full suite |
| Behavior *intentionally* changed? | That's not a refactor — split it into its own change with its own tests |

### The Safest Refactor Workflow

1. Green baseline (add characterization tests if needed)
2. One small mechanical step per commit (IDE tool when possible)
3. Commit each green step separately — bisectable, reviewable history
4. Keep the diff readable: no formatting churn mixed with moves
5. Big refactor = many small commits, not one giant diff

## Common Pitfalls / Anti-Patterns

| Pitfall | Why it hurts | Fix |
|---------|-------------|-----|
| Refactor + bugfix together | Bug becomes un-bisectable | Separate changes, separate commits |
| Big-bang rewrites instead of incremental | Impossible to review or verify | Small steps, green after each |
| Extracting too eagerly | Indirection without benefit | Extract for a named single purpose only |
| Changing behavior "while I'm at it" | Silent behavior drift | Behavior preservation is the contract |
| No tests before touching legacy | Fear-driven edits that don't improve | Characterization tests first |
| Cosmetic-only churn (reformatting) | Noisy diffs, wasted review | Refactor structure, not style |
| Refactoring untested hot paths under deadline | Regressions ship to users | Cover it, or defer |
| Over-engineering with strategy/patterns | Complexity replaces simplicity | Apply patterns to actual smells only |

## Best Practices Checklist

- [ ] Tests green before starting; characterize untested code
- [ ] One behavior-preserving step at a time; green after each
- [ ] Use IDE refactoring tools for mechanical steps
- [ ] Extract to a name that adds meaning; inline when it doesn't
- [ ] Move behavior next to the data it reads (feature envy)
- [ ] Replace primitives with value objects for domain rules
- [ ] Separate refactor commits from feature/bugfix commits
- [ ] Final full-suite run + review of the diff like a reviewer
