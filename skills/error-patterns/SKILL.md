---
name: error-patterns
description: Error handling patterns, Result types, error boundaries, recovery strategies. Use when implementing error handling, improving reliability, or debugging error flows.
---

# Error Handling Patterns

## Result Types

### TypeScript Result Type

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function Ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function Err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Usage
function divide(a: number, b: number): Result<number, string> {
  if (b === 0) return Err('Division by zero');
  return Ok(a / b);
}

const result = divide(10, 2);
if (result.ok) {
  console.log(result.value); // TypeScript knows this is number
} else {
  console.error(result.error); // TypeScript knows this is string
}
```

### Neverthrow Library

```typescript
import { ok, err, Result } from 'neverthrow';

function parseJSON(input: string): Result<object, Error> {
  try {
    return ok(JSON.parse(input));
  } catch (e) {
    return err(new Error(`Parse error: ${e.message}`));
  }
}

// Chain operations
const result = parseJSON('{"a": 1}')
  .map(obj => ({ ...obj, b: 2 }))
  .mapErr(e => new Error(`Failed: ${e.message}`));
```

## Error Boundaries (React)

### Class Component Error Boundary

```typescript
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback: React.ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

// Usage
<ErrorBoundary fallback={<ErrorPage />}>
  <App />
</ErrorBoundary>
```

### Hook-Based Error Boundary

```typescript
function useErrorBoundary() {
  const [error, setError] = useState<Error | null>(null);

  if (error) throw error;

  const captureError = (error: Error) => {
    setError(error);
  };

  return { captureError };
}
```

## Error Categories

```typescript
enum ErrorCategory {
  VALIDATION = 'VALIDATION',
  AUTHENTICATION = 'AUTHENTICATION',
  AUTHORIZATION = 'AUTHORIZATION',
  NOT_FOUND = 'NOT_FOUND',
  CONFLICT = 'CONFLICT',
  RATE_LIMIT = 'RATE_LIMIT',
  EXTERNAL = 'EXTERNAL',
  INTERNAL = 'INTERNAL',
}

class AppError extends Error {
  constructor(
    message: string,
    public category: ErrorCategory,
    public statusCode: number = 500,
    public metadata?: Record<string, any>
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// Usage
throw new AppError(
  'User not found',
  ErrorCategory.NOT_FOUND,
  404,
  { userId: '123' }
);
```

## Retry Patterns

### Exponential Backoff

```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  options: { maxRetries?: number; baseDelay?: number } = {}
): Promise<T> {
  const { maxRetries = 3, baseDelay = 1000 } = options;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries) throw error;

      const delay = baseDelay * Math.pow(2, attempt);
      const jitter = Math.random() * delay * 0.1;
      await sleep(delay + jitter);
    }
  }

  throw new Error('Max retries exceeded');
}
```

### Retry with Conditional Logic

```typescript
async function withSmartRetry<T>(
  fn: () => Promise<T>,
  shouldRetry: (error: Error) => boolean
): Promise<T> {
  let lastError: Error;

  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      if (!shouldRetry(lastError)) throw lastError;
      await sleep(1000 * Math.pow(2, attempt));
    }
  }

  throw lastError!;
}
```

## Circuit Breaker

```typescript
class CircuitBreaker {
  private failures = 0;
  private lastFailureTime = 0;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';

  constructor(
    private threshold: number = 5,
    private resetTimeout: number = 30000
  ) {}

  async call<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime > this.resetTimeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit breaker is OPEN');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess() {
    this.failures = 0;
    this.state = 'CLOSED';
  }

  private onFailure() {
    this.failures++;
    this.lastFailureTime = Date.now();
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
    }
  }
}
```

## Graceful Degradation

```typescript
async function getUserWithFallback(id: string): Promise<User> {
  try {
    // Primary: database
    return await db.users.findById(id);
  } catch (dbError) {
    try {
      // Fallback: cache
      const cached = await redis.get(`user:${id}`);
      if (cached) return JSON.parse(cached);
    } catch (cacheError) {
      // Final fallback: default
    }

    return {
      id,
      name: 'Unknown User',
      email: null,
      isFallback: true,
    };
  }
}
```

## Error Response Patterns

```typescript
// API error response
interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
    timestamp: string;
    requestId: string;
  };
}

function createErrorResponse(
  error: AppError,
  requestId: string
): ErrorResponse {
  return {
    error: {
      code: error.category,
      message: error.message,
      details: error.metadata,
      timestamp: new Date().toISOString(),
      requestId,
    },
  };
}
```
