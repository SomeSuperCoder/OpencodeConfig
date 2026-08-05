---
name: testing-patterns
description: Testing strategies, mocking, fixtures, test coverage. Use when writing tests, improving test coverage, or fixing flaky tests.
---

# Testing Patterns

## When To Use This

- Writing unit, component, integration, or E2E tests
- Deciding what to mock, and how
- Setting up fixtures, factories, or test data builders
- Debugging flaky or order-dependent tests
- Setting coverage thresholds and knowing when they lie

## Testing Strategy

### The Test Pyramid

| Layer | Speed | Cost | Scope | Count |
|-------|-------|------|-------|-------|
| Unit | ms | low | One function/class, no I/O | Many (70%) |
| Integration | s | medium | Modules + real DB/HTTP/FS | Some (20%) |
| E2E | min | high | Full user flow, real browser/stack | Few (10%) |

Rules:
- **Unit tests must not touch the network, disk, DB, clock, or another component.** If one does, it's an integration test — move it.
- **E2E tests exist to catch cross-module wiring, not to test business logic.** Test logic at the unit layer.
- **One assertion style, one purpose per test.** Name the behavior, not the method.

### Unit vs Component vs E2E — Decision Table

| What you're validating | Layer | Example |
|------------------------|-------|---------|
| Pure logic, calculations, formatters | Unit | `calculateTotal(items)` |
| One component in isolation | Component | `<Button>` renders + fires `onClick` |
| A module talks to its DB/API correctly | Integration | `UserRepository.find()` vs Postgres |
| User journey end-to-end | E2E | signup → dashboard |

### Test File Organization

```
src/
├── components/Button/Button.tsx        # code
├── components/Button/Button.test.tsx   # colocated unit test
├── services/api.test.ts                # integration (real/mocked HTTP)
├── __tests__/e2e/checkout.spec.ts      # Playwright, separate runner
└── test/
    ├── fixtures/                       # static JSON files
    ├── factories/                      # programmatic data builders
    └── helpers/                        # render, setup, seed utilities
```

- Unit/component tests colocate with source. E2E lives separately (different deps, runner, timing).
- One `describe` block per behavior group; use `it.each` for data tables instead of copy-paste.

### Test Structure (AAA / GWT)

```
it('charges 10% tax on the subtotal', () => {
  // Arrange — build input + mocks
  const items = [{ price: 10 }, { price: 20 }];
  // Act — exercise exactly one thing
  const total = calculateTotal(items, 0.1);
  // Assert — one behavior, one expectation cluster
  expect(total).toBe(33);
});
```

## Mocking (Jest / Vitest)

### Choose the Right Mocking Level

| Need | Tool | Use when |
|------|------|----------|
| Stub a whole module | `vi.mock('module')` | Module has heavy side effects (DB, network, timers) |
| Replace one method | `vi.spyOn(obj, 'method')` | Real object exists, one call needs faking |
| Fake time | `vi.useFakeTimers()` | Code uses `setTimeout`, `Date`, `setInterval` |
| Fake fetch | `vi.stubGlobal('fetch', ...)` or MSW | Network boundary |
| Replace HTTP server | MSW (msw) | Integration tests want a real HTTP round-trip |
| Verify call contract | `expect(fn).toHaveBeenCalledWith(...)` | Asserting arguments/ordering |

### Mock APIs

```typescript
// Whole-module mock (hoisted)
vi.mock('./database', () => ({ query: vi.fn(), connect: vi.fn() }));
// Then import { database } and set return values.

// Partial mock — keep real exports, replace one
vi.mock('./database', async (importOriginal) => {
  const actual = await importOriginal();
  return { ...actual, query: vi.fn() };
});

// Spy on existing method
const spy = vi.spyOn(database, 'query');
spy.mockResolvedValue([{ id: 1 }]);

// Implementation, not value
spy.mockImplementation((sql) =>
  sql.includes('users') ? Promise.resolve(users) : Promise.resolve([])
);
```

**Mock hoisting gotcha:** `vi.mock` is hoisted above imports, so variables referenced inside the factory must be `vi.hoisted()` or prefixed `mock`:

```typescript
const { mockDb } = vi.hoisted(() => ({ mockDb: { query: vi.fn() } }));
vi.mock('./db', () => ({ db: mockDb }));
```

### Mock Lifecycle — Three Distinct Operations

```typescript
beforeEach(() => {
  vi.resetAllMocks();   // clear calls AND remove implementations/return values
});
// NOT interchangeable:
// vi.clearAllMocks() — only clears call history, keeps implementations (use for spies you configure in beforeEach)
// vi.restoreAllMocks() — returns spies to original impl (only works on vi.spyOn)
```

- **Use `clear`** when you set up implementations in `beforeEach`.
- **Use `reset`** when mocks are configured per-test.
- **Use `restore`** only for spies on real objects, in `afterEach`.

### Fake Timers — Deterministic Time

```typescript
vi.useFakeTimers();
vi.setSystemTime(new Date('2024-01-01T00:00:00Z'));

// Advance time, firing timers in order
await vi.advanceTimersByTimeAsync(5_000);
// Or run all pending timers
await vi.runAllTimersAsync();

afterEach(() => vi.useRealTimers());
```

- Always use `Async` variants when code awaits between timer ticks — otherwise promises hang.
- Never mix real and fake timers for `Date` — pin it with `setSystemTime`.

### What (NOT) To Mock — the $20 question

| Situation | Do |
|-----------|----|
| Third-party lib with real side effects | Mock the module |
| Your own pure functions | Don't mock — use real ones |
| DB/API adapter you wrote | Mock at the boundary, test adapter separately against the real thing (integration) |
| React hooks / component internals | Don't mock — assert on rendered output |
| Fetch | Mock the network, not your client wrapper |

Anti-patterns:
- **Mocking your own implementation** — you then re-implement the function in the mock and test nothing.
- **Mocking everything** ("`vi.mock('./utils')` in every file") — kills the test's value and creates fragility.
- **Asserting implementation details** (calling private methods, checking internal state) — refactor-proof tests assert on behavior/output.

## Fixtures, Factories & Test Data Builders

### Static Fixtures — immutable reference data

```json
// test/fixtures/product.json  — read once, never mutate
{ "id": "p-1", "name": "Widget", "price": 9.99 }
```

Use for: blobs that never change (API responses, config, import files). **Never share a mutable fixture object across tests** — deep-clone or `structuredClone` it per test.

### Factory Function — defaults + overrides

```typescript
// test/factories/user.ts
export const createUser = (overrides: Partial<User> = {}): User => ({
  id: crypto.randomUUID(),
  email: `user-${crypto.randomUUID()}@example.com`,   // unique every call
  name: 'Test User',
  role: 'member',
  createdAt: new Date('2024-01-01'),
  ...overrides,
});
```

Rules:
- **Every call returns fresh, unique data** — no shared references, unique emails/ids.
- Overrides spread last — order matters, always `...overrides` at the end.
- Factory never throws for missing fields; defaults make any object valid.

### Test Data Builder — fluent, intent-revealing

```typescript
class UserBuilder {
  private user: User = { id: 'u-1', email: 'a@b.co', name: 'A', role: 'member' };
  admin() { this.user.role = 'admin'; return this; }
  withEmail(e: string) { this.user.email = e; return this; }
  build() { return { ...this.user }; }   // defensive copy
}
```

Choose factory vs builder:
- Factory: most cases, small object, few permutations.
- Builder: 5+ variations, explicit intent matters (`userBuilder.admin().build()`), or objects with required invariants.

### Setting Up Relationships (the common trap)

```typescript
// Wrong — shared mutable object across tests
const order = createOrder({ user: createUser() });

// Right — build in test, no cross-test aliasing
it('links order to user', () => {
  const user = createUser();
  const order = createOrder({ userId: user.id, user });
  expect(order.user.id).toBe(user.id);
});
```

## Test Isolation

### Four Isolation Axes — every test must reset all four

1. **Module state** — mocks cleared (`resetAllMocks` in `beforeEach`)
2. **Database** — fresh per test
3. **Filesystem / env** — temp dirs, `vi.stubEnv('NODE_ENV', 'test')`, never write to real paths
4. **Global singletons** — `fetch`, timers, `Date`, React cache, singletons

### Database Strategies — Decision Table

| Context | Strategy |
|---------|----------|
| SQLite, small, offline | In-memory `:memory:` + migrate once, truncate between tests |
| Postgres/MySQL, transactional logic | **Transaction rollback**: open transaction in `beforeEach`, rollback in `afterEach` (fastest, no data loss) |
| Full DB semantics, CI has Docker | Test containers (`testcontainers`) — real Postgres per suite |
| Local dev with real DB | Truncate all tables between tests, disable FK checks |

```typescript
let db: Database;

beforeAll(async () => {
  db = await Database.create(':memory:');
  await db.migrate();
});

afterEach(async () => {
  await db.truncateAll();   // wipe data, keep schema
});

afterAll(async () => {
  await db.close();
});
```

### Parallel vs Serial

- **Parallel** (default in Vitest/Jest) — each test file isolated; great speed.
- **Serial / `--runInBand`** — when tests share a resource they can't isolate (a single dev DB, a port, a global).
- Rules: never share ports or a single real DB between files that run parallel. Use per-file databases or a dedicated test DB.

## Coverage

### Meaningful Thresholds

| Metric | Minimum | Target |
|--------|---------|--------|
| Statements | 80% | 90% |
| Branches | 75% | 85% |
| Functions | 80% | 90% |
| Lines | 80% | 90% |

```typescript
// vitest.config.ts
test: {
  coverage: {
    provider: 'v8',
    reporter: ['text', 'html', 'lcov'],
    thresholds: { statements: 80, branches: 75, functions: 80, lines: 80 },
    exclude: ['src/main.ts', 'src/**/*.config.ts', 'dist/**'],
  },
}
```

**Coverage lies. High % ≠ good tests.** It's a floor, not a target:
- Line coverage says nothing about assertion quality — you can call code and assert nothing.
- **Branch coverage is the number that matters** — it exposes untested `if/else`, error paths, and edge cases.
- Enforce thresholds in CI, not just locally.
- Don't game it with `/* istanbul ignore */` or broad excludes.
- **Coverage is a trailing indicator**: first cover critical paths (money, auth, data integrity), then raise thresholds gradually.

### Coverage Targets by Risk

| Code area | Required |
|-----------|----------|
| Payment / billing logic | 100% branch |
| Auth & authorization | 100% branch |
| Error/retry paths | ≥90% branch |
| Plumbing (config, wiring) | leave uncovered — test the behavior above it |

## Flaky Test Fixes

### Diagnose by Cause

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Fails only when suite runs together | Order/shared-state dependency | Isolate; don't share fixtures/DB/globals |
| Fails only in CI | Timing/real network/env differences | Fake timers, mock network, stub env |
| Fails intermittently on same input | Race condition | Await properly, use deterministic waits |
| Passes alone, fails with parallelism | Port/DB/global collision | Per-file DB or serialize |
| Fails near midnight/time zones | `Date`/timezone leak | `setSystemTime`, `TZ=UTC` in CI |

### Deterministic Waiting (never `sleep(500)`)

```typescript
// Wait for a condition, not a duration
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument();
}, { timeout: 2_000, interval: 50 });

// Poll real async in integration tests
await vi.waitFor(async () => {
  expect(await db.users.count()).toBe(3);
});
```

### Race-Condition Prevention

```typescript
// Wrong: fire and forget
updateUser(1);   // test ends before update lands
expect(...).toThrow();

// Right: await the operation or a deterministic signal
await updateUser(1);
await vi.waitFor(() => expect(onSuccess).toHaveBeenCalled());
```

Anti-patterns:
- Fixed `setTimeout`/`sleep` waits — flaky on slow CI, slow on fast machines.
- Tests that depend on wall-clock time without fake timers.
- Mutating a fixture/file that another test reads.
- Relying on test execution order (`it` alphabetical/reg in files).

## Best Practices Checklist

- [ ] Test the behavior, not the implementation
- [ ] One logical behavior per test; name it as a sentence
- [ ] AAA (Arrange–Act–Assert) or Given–When–Then structure
- [ ] Every test isolates all four axes (mocks, DB, FS/env, globals)
- [ ] Use factories/builders, not shared mutable fixtures
- [ ] Mock at the boundary only; never mock your own logic
- [ ] Fake timers for anything time-based
- [ ] Deterministic waits via `waitFor`, never bare sleeps
- [ ] Branch coverage threshold enforced in CI
- [ ] E2E covers critical journeys only; logic lives in unit tests
- [ ] Test error paths as seriously as happy paths
