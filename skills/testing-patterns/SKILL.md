---
name: testing-patterns
description: Testing strategies, mocking, fixtures, test coverage. Use when writing tests, improving test coverage, or fixing flaky tests.
---

# Testing Patterns

## Mocking Patterns

### Jest/Vitest Mocks

```typescript
// Mock entire module
vi.mock('./database', () => ({
  query: vi.fn(),
  connect: vi.fn(),
}));

// Mock specific method
const mockQuery = vi.spyOn(database, 'query');
mockQuery.mockResolvedValue([{ id: 1 }]);

// Mock implementation
mockQuery.mockImplementation((sql: string) => {
  if (sql.includes('users')) return Promise.resolve(users);
  return Promise.resolve([]);
});

// Clear mocks between tests
afterEach(() => {
  vi.clearAllMocks();
});
```

### Mock Factories

```typescript
// factories/user.ts
export const createUser = (overrides?: Partial<User>): User => ({
  id: crypto.randomUUID(),
  email: `test-${Date.now()}@example.com`,
  name: 'Test User',
  createdAt: new Date(),
  ...overrides,
});

// Usage in tests
const user = createUser({ name: 'Alice' });
```

## Test Database Strategies

### In-Memory Database

```typescript
let db: Database;

beforeAll(async () => {
  db = await Database.create(':memory:');
  await db.migrate();
});

afterEach(async () => {
  await db.truncateAll(); // Clean between tests
});

afterAll(async () => {
  await db.close();
});
```

### Transaction Rollback

```typescript
beforeEach(async () => {
  await db.beginTransaction();
});

afterEach(async () => {
  await db.rollback(); // No pollution between tests
});
```

### Test Containers

```typescript
// docker-compose.test.yml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: test_db
    ports:
      - "5433:5432"
```

## Coverage Targets

| Metric | Minimum | Target |
|--------|---------|--------|
| Statements | 80% | 90% |
| Branches | 75% | 85% |
| Functions | 80% | 90% |
| Lines | 80% | 90% |

**Coverage configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      thresholds: {
        statements: 80,
        branches: 75,
        functions: 80,
        lines: 80,
      },
    },
  },
});
```

## Flaky Test Fixes

### Common Causes

1. **Time-dependent tests** — Use fake timers
2. **Order-dependent tests** — Isolate tests, use fresh data
3. **Network calls** — Mock HTTP requests
4. **Shared state** — Clean up between tests
5. **Race conditions** — Await properly, use deterministic waits

### Solutions

```typescript
// Use fake timers
vi.useFakeTimers();
vi.setSystemTime(new Date('2024-01-01'));

// Wait for async operations
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument();
});

// Mock network requests
vi.mock('axios');
axios.get.mockResolvedValue({ data: mockData });
```

## Test Organization

### File Structure

```
src/
├── components/
│   └── Button/
│       ├── Button.tsx
│       ├── Button.test.tsx
│       └── Button.stories.tsx
├── services/
│   └── api.ts
│   └── api.test.ts
└── utils/
    └── helpers.ts
    └── helpers.test.ts
```

### Test Categories

```typescript
// Unit tests - isolated, fast
describe('formatDate', () => {
  it('formats ISO string to readable date', () => {
    expect(formatDate('2024-01-15')).toBe('January 15, 2024');
  });
});

// Integration tests - multiple components
describe('UserRegistration', () => {
  it('creates user and sends welcome email', async () => {
    // Test full flow
  });
});

// E2E tests - full application
test('user can sign up and access dashboard', async ({ page }) => {
  await page.goto('/signup');
  // Full user journey
});
```

### Test Patterns

```typescript
// Arrange-Act-Assert
it('calculates total price with tax', () => {
  // Arrange
  const items = [{ price: 10 }, { price: 20 }];
  const taxRate = 0.1;

  // Act
  const total = calculateTotal(items, taxRate);

  // Assert
  expect(total).toBe(33);
});

// Given-When-Then
describe('Shopping Cart', () => {
  it('given empty cart, when adding item, then total updates', () => {
    // Given
    const cart = new ShoppingCart();

    // When
    cart.addItem({ price: 10 });

    // Then
    expect(cart.total).toBe(10);
  });
});
```
