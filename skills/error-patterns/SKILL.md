---
name: error-patterns
description: Error handling patterns, Result types, error boundaries, recovery strategies. Use when implementing error handling, improving reliability, or debugging error flows.
---

# Error Handling Patterns

## When To Use This

- Deciding between exceptions and Result types
- Categorizing errors and giving them stable codes
- Implementing retries, backoff, and circuit breakers
- Building error boundaries and graceful degradation
- Making errors observable (context, request IDs, correlation)

## Result Types vs Exceptions

### The Core Decision

| Criterion | Exceptions | Result types |
|-----------|-----------|--------------|
| Expected, recoverable failures (validation, not-found, conflict) | Awkward — must try/catch everywhere | **Prefer Result** |
| Unexpected failures (bug, I/O, invariants) | **Prefer exceptions** | Verbose if overused |
| Control flow you must handle | Hidden in stack traces | **Explicit in type** — cannot be ignored |
| Performance-sensitive hot path | Throwing is expensive | Cheaper (no stack capture) |
| Legacy/standard API | Match the ecosystem | Introduce at boundaries |

**Rule of thumb:** use Result types at *domain boundaries* where the caller must handle failure (repo calls, API parsing, validation). Use exceptions for programmer errors and anything you can't recover from. Don't throw for control flow; don't return Results for truly unexpected bugs.

### TypeScript Result Type

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

const Ok = <T>(value: T): Result<T, never> => ({ ok: true, value });
const Err = <E>(error: E): Result<never, E> => ({ ok: false, error });

function divide(a: number, b: number): Result<number, string> {
  return b === 0 ? Err('Division by zero') : Ok(a / b);
}

const result = divide(10, 2);
if (result.ok) {
  // TS narrows: result.value is number
} else {
  // TS narrows: result.error is string
}
```

### Chaining with neverthrow

```typescript
import { ok, err, Result } from 'neverthrow';

function parseJSON(input: string): Result<object, Error> {
  try { return ok(JSON.parse(input)); }
  catch (e) { return err(new Error(`Parse error: ${(e as Error).message}`)); }
}

const result = parseJSON('{"a": 1}')
  .map((o) => ({ ...o, b: 2 }))          // transform ok value
  .andThen((o) => validate(o))            // chain a fallible step
  .mapErr((e) => new Error(`Failed: ${e.message}`)); // transform error
```

Never `.unwrap()`/`.match()` on a Result you haven't handled — the whole point is forcing the branch.

## Error Categories

### Categorize Every Error — stable machine-readable codes

```typescript
enum ErrorCategory {
  VALIDATION = 'VALIDATION',         // 400 — caller sent bad input
  AUTHENTICATION = 'AUTHENTICATION', // 401 — missing/invalid credentials
  AUTHORIZATION = 'AUTHORIZATION',   // 403 — not permitted
  NOT_FOUND = 'NOT_FOUND',           // 404
  CONFLICT = 'CONFLICT',             // 409 — duplicate/state conflict
  RATE_LIMIT = 'RATE_LIMIT',         // 429
  EXTERNAL = 'EXTERNAL',             // upstream service failure
  INTERNAL = 'INTERNAL',             // our bug / unexpected
  TIMEOUT = 'TIMEOUT',               // deadline exceeded
  CANCELLED = 'CANCELLED',           // caller gave up
}

class AppError extends Error {
  constructor(
    message: string,
    public readonly category: ErrorCategory,
    public readonly statusCode: number = 500,
    public readonly code?: string,           // stable identifier, e.g. 'EMAIL_TAKEN'
    public readonly metadata?: Record<string, unknown>,
    public readonly cause?: unknown,          // chained root cause
  ) {
    super(message);
    this.name = 'AppError';
  }
}
```

**Rules:**
- `code` (e.g. `EMAIL_TAKEN`) is stable for clients; `message` is human-readable and may change; `category` drives retry and mapping logic.
- Always set `cause` — swallowing an error without chaining it destroys the root-cause trail.
- Map internal errors to categories at the boundary; never leak DB errors or stack traces to clients.

## Retry / Backoff

### When NOT to retry — decision table

| Error type | Retry? |
|------------|--------|
| 429 / rate limit | Yes — honor `Retry-After` header |
| 5xx, network, timeout | Yes — with backoff + jitter |
| 400/401/403/404/409/422 | **No** — permanent; retrying won't help |
| Cancellation | No — rethrow/stop |
| Idempotent writes | Yes, if request carries an idempotency key |

### Exponential Backoff with Jitter

```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  options: { maxRetries?: number; baseDelay?: number; maxDelay?: number; shouldRetry?: (e: Error) => boolean } = {},
): Promise<T> {
  const { maxRetries = 3, baseDelay = 1000, maxDelay = 10_000, shouldRetry } = options;

  for (let attempt = 0; ; attempt++) {
    try {
      return await fn();
    } catch (error) {
      const err = error as Error;
      if (attempt >= maxRetries || (shouldRetry && !shouldRetry(err))) throw error;
      // Full jitter — randomized in [0, cap], prevents synchronized retry storms
      const cap = Math.min(maxDelay, baseDelay * 2 ** attempt);
      const delay = Math.floor(Math.random() * cap);
      await sleep(delay);
    }
  }
}
```

**Jitter types:**
- Full jitter `random(0, cap)` — best for distributed systems (avoids thundering herd).
- Equal jitter `cap/2 + random(0, cap/2)` — keeps minimum delay, still randomizes.
- Plain exponential (no jitter) — fine single-client, dangerous at scale.

**Honor `Retry-After`** when present (429/503) — it's the server telling you the safe wait.

## Circuit Breaker

### Why and When

| State | Meaning | Action |
|-------|---------|--------|
| CLOSED | Healthy | Allow calls; count failures |
| OPEN | Failing fast | **Reject immediately** (fail fast, don't pile on a dying service) |
| HALF_OPEN | Probing after cooldown | Allow a small trial set; success → CLOSED, failure → OPEN |

```typescript
class CircuitBreaker {
  private failures = 0;
  private openedAt = 0;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';

  constructor(
    private readonly threshold = 5,        // failures before OPEN
    private readonly resetTimeoutMs = 30_000, // time in OPEN before probing
    private readonly probeRequests = 1,    // requests allowed in HALF_OPEN
  ) {}

  async call<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.openedAt > this.resetTimeoutMs) {
        this.state = 'HALF_OPEN';   // allow one probe through
      } else {
        throw new Error('Circuit breaker OPEN — failing fast');
      }
    }
    if (this.state === 'HALF_OPEN' && this.failures > 0) {
      throw new Error('Circuit breaker OPEN — probe failed');
    }
    try {
      const result = await fn();
      this.failures = 0;
      this.state = 'CLOSED';
      return result;
    } catch (error) {
      this.failures++;
      this.openedAt = Date.now();
      if (this.failures >= this.threshold) this.state = 'OPEN';
      throw error;
    }
  }
}
```

Guidelines:
- Thresholds tuned per dependency — generous for slow-but-healthy services, tight for critical paths.
- Combine breaker + fallback: on OPEN, return degraded response or cached data rather than throwing to the user.
- Use a library (resilience4j, opossum, Polly) rather than hand-rolling in production; the pattern above is for understanding.
- Track OPEN state duration and half-open probe results in metrics.

## Graceful Degradation

### Fallback Cascade

```typescript
async function getUserWithFallback(id: string): Promise<User> {
  try {
    return await db.users.findById(id);           // primary
  } catch {
    try {
      const cached = await redis.get(`user:${id}`); // fallback 1: cache
      if (cached) return JSON.parse(cached);
    } catch { /* cache also down */ }
    return { id, name: 'Unknown User', email: null, isFallback: true }; // fallback 2: degraded
  }
}
```

### Principles

| Principle | Meaning |
|-----------|---------|
| Reduce scope | Page renders, non-critical section shows placeholder |
| Provide defaults | Empty lists, sensible placeholders, cached last-known-good |
| Never fail the whole for the part | One broken widget ≠ blank page |
| Mark degraded data | Flag `isFallback`/`isStale` so consumers know |
| Time-box dependency calls | Timeouts on every external call — a hang is worse than a failure |

```typescript
const withTimeout = <T>(p: Promise<T>, ms: number): Promise<T> =>
  Promise.race([p, new Promise<never>((_, rej) => setTimeout(() => rej(new Error('timeout')), ms))]);
```

## Error Boundaries

### React Error Boundary — class component (only place React allows catch)

```typescript
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback: React.ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };   // render fallback
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    logErrorToService(error, info);  // report; never rely on console
  }

  render() {
    return this.state.hasError ? this.props.fallback : this.props.children;
  }
}
```

- **Does NOT catch:** event handlers, async code, errors thrown in the boundary itself. Wrap those in try/catch or use error-boundary hooks.
- Place boundaries at meaningful segments (router, feature, widget), not just the root.
- Error boundaries prevent cascading UI crashes and send errors to the observability stack.

### Promise/Async Boundary

```typescript
function useAsync<T>(fn: () => Promise<T>, deps: unknown[]) {
  const [state, setState] = useState<{ status: 'idle'|'loading'|'error'|'success'; value?: T; error?: Error }>({ status: 'idle' });
  useEffect(() => {
    let cancelled = false;
    setState({ status: 'loading' });
    fn().then(
      (value) => !cancelled && setState({ status: 'success', value }),
      (error) => !cancelled && setState({ status: 'error', error }),
    );
    return () => { cancelled = true; };
  }, deps);
  return state;
}
```

## Error Context & Observability

### Enrich Errors — context is everything

```typescript
// Attach correlation/request context to every error as it propagates
function wrap(error: unknown, ctx: Record<string, unknown>): AppError {
  if (error instanceof AppError) { Object.assign(error.metadata ??= {}, ctx); return error; }
  return new AppError((error as Error).message, ErrorCategory.INTERNAL, 500, 'INTERNAL', ctx, error);
}
```

**What to attach:** `requestId`/`traceId`, `userId` (careful: PII), operation, service, component, attempt count, upstream status.

### Standard Error Response

```typescript
interface ErrorResponse {
  error: {
    code: string;             // stable, e.g. 'EMAIL_TAKEN'
    message: string;          // human-readable
    details?: Record<string, unknown> | Array<{ field: string; message: string }>; // validation specifics
    requestId: string;        // correlates client + server logs
    timestamp: string;
  };
}
```

- `requestId` generated per request, passed to all logs and downstream calls (for distributed tracing).
- In production, never expose stack traces or internal messages; map to safe messages.

### Logging Rules

| What | Do |
|------|----|
| Every handled error | Log with `requestId`, category, code, duration, attempts |
| Retried & succeeded | Log as warning with retry count |
| Exhausted retries / OPEN breaker | Log as error + alert |
| Error expected by business flow | Log at debug/info — not every 404 is an incident |
| Swallowed errors | Never — if you swallow, log why |

## Common Pitfalls / Anti-Patterns

| Anti-pattern | Why it hurts | Fix |
|--------------|-------------|-----|
| `catch {}` / `catch (e) {}` empty | Errors vanish; impossible to debug | Log + rethrow or handle explicitly |
| Throwing in every layer | Stack-full of wrappers, no info gained | Enrich once at boundaries |
| Retrying permanent errors | Wasted work, delayed failure | Never retry 4xx; category-driven `shouldRetry` |
| No timeout on external calls | Hang = worse than failure | Always time-box dependency calls |
| Swallowing error, returning null | Caller can't distinguish "no data" from "failed" | Result type with explicit error |
| Logging error then `throw new Error(msg)` | Loses stack + cause | Set `cause` and chain |
| `catch` on every line | Masks real failure boundaries | Catch where you can act (boundary/fallback) |
| Throwing `new Error('something failed')` | No category/code for retry mapping | Use categorized `AppError` |

## Best Practices Checklist

- [ ] Expected failures → Result types; unexpected → exceptions
- [ ] Errors carry stable `code`, `category`, `statusCode`, and `cause`
- [ ] Retry only retryable errors; exponential backoff with full jitter
- [ ] Honor `Retry-After`; never retry 4xx
- [ ] Circuit breaker on critical external dependencies; fallback on OPEN
- [ ] Every external call has a timeout
- [ ] UI never crashes wholesale — error boundaries + degradation
- [ ] Every error logged with `requestId` + context
- [ ] Client responses never leak stack traces or internals
- [ ] Swallowed errors are logged with reason
