---
name: backend-patterns
description: "Senior backend architectural patterns reference. Covers events, logging, microservices, fault tolerance, websockets, repository pattern, and more. Use when implementing backend features, designing services, or reviewing architecture. Load when building, not when planning."
---

# Backend Patterns Reference

Patterns for building robust, observable, maintainable backends. Not theory — actionable patterns with when-to-use.

---

## Event-Driven Architecture

### Pattern: Event Emitter / Event Bus

**When:** Decoupling services, async workflows, audit trails.

```
Service A → emits(event) → Event Bus → Service B handles
                                    → Service C handles
```

**Rules:**
- Events are facts, not commands. `OrderPlaced` not `PlaceOrder`.
- Events carry data, not references. Include what the handler needs.
- Handlers must be idempotent. Same event twice = same result.
- Dead letter queue for failed events. Never lose an event.

### Pattern: Outbox Pattern

**When:** Reliable event publishing without distributed transactions.

1. Write business data + event to SAME database transaction
2. Separate process reads outbox, publishes to event bus
3. Mark as published

**Rules:**
- Outbox is a table, not a queue. Durable, queryable.
- Polling interval: 100-500ms. Not faster (waste), not slower (latency).
- Cleanup: archive events older than 7 days.

---

## Logging

### Pattern: Structured Logging

**When:** Always. Every log line should be parseable.

```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "level": "error",
  "service": "auth",
  "traceId": "abc-123",
  "message": "Token refresh failed",
  "userId": "u_123",
  "error": "token_expired"
}
```

**Rules:**
- Log at the BOUNDARY, not inside loops. Entry/exit of requests.
- ERROR = needs human attention. WARN = degraded but working. INFO = normal flow. DEBUG = development only.
- Never log secrets, passwords, tokens, PII. Ever.
- Include traceId in every log. Correlate across services.
- Log the DECISION, not the data. "User rejected: insufficient_permissions" not "User data: {...}"

### Pattern: Request-Scoped Context

**When:** Tracing requests across services.

```
Request comes in → generate traceId → attach to context → pass to all downstream calls
```

**Rules:**
- traceId generated at the edge (API gateway, first service).
- Propagate via headers: `X-Trace-Id`, `X-Request-Id`.
- Context is a value object, not a singleton. One per request.

---

## Microservices

### Pattern: Service Boundary by Business Capability

**When:** Splitting a monolith or designing new services.

| Business Capability | Service |
|---------------------|---------|
| User management | UserService |
| Payments | PaymentService |
| Notifications | NotificationService |
| Orders | OrderService |

**Rules:**
- One service = one business capability. Not one database table.
- Services own their data. No shared databases.
- Communicate via events (async) or APIs (sync). Not both for the same flow.
- API versioning: `/v1/`, `/v2/`. Never break existing consumers.

### Pattern: API Gateway

**When:** Single entry point for external clients.

```
Client → API Gateway → UserService
                    → PaymentService
                    → OrderService
```

**Rules:**
- Gateway handles: auth, rate limiting, request routing, response aggregation.
- Gateway does NOT contain business logic. Routing only.
- Internal services communicate directly, not through gateway.

### Pattern: Saga (Choreography)

**When:** Distributed transactions across services.

```
OrderService: OrderCreated → PaymentService
PaymentService: PaymentProcessed → InventoryService
InventoryService: InventoryReserved → OrderService
```

**Rules:**
- Each service emits an event, next service picks up. No coordinator.
- Compensating events for rollback: `PaymentRefunded`, `OrderCancelled`.
- Timeout: if no response in 30s, trigger compensating event.
- Saga is a pattern, not a framework. Events + handlers = saga.

---

## Fault Tolerance

### Pattern: Circuit Breaker

**When:** Calling external services that might fail.

States: CLOSED → (failures exceed threshold) → OPEN → (timeout) → HALF-OPEN → (success) → CLOSED

**Rules:**
- Threshold: 5 failures in 60s → OPEN.
- Open duration: 30s. Then try HALF-OPEN.
- Half-open: 1 test request. Success → CLOSED. Failure → OPEN.
- Log state transitions. They're important.

### Pattern: Retry with Backoff

**When:** Transient failures (network, timeout).

```
Attempt 1 → fail → wait 1s
Attempt 2 → fail → wait 2s
Attempt 3 → fail → wait 4s
Attempt 4 → fail → give up, propagate error
```

**Rules:**
- Max 3 retries. More = cascading failure.
- Exponential backoff: 1s, 2s, 4s. Not linear.
- Jitter: add ±200ms random to prevent thundering herd.
- Only retry on TRANSIENT errors (503, timeout, connection reset). Not 400, 401, 404.

### Pattern: Bulkhead

**When:** Isolating failures to prevent cascade.

```
PaymentService → PaymentPool (max 10 concurrent)
              → separate pool
NotificationService → NotificationPool (max 20 concurrent)
```

**Rules:**
- Separate connection pools per dependency.
- One slow service doesn't consume all connections.
- Pool size: based on expected load, not arbitrary.

### Pattern: Graceful Degradation

**When:** Partial failure is better than total failure.

**Rules:**
- Fallback responses: cached data, default values, reduced functionality.
- Feature flags for disabling non-critical features under load.
- User sees "temporarily unavailable" not a crash.

---

## WebSockets

### Pattern: WebSocket with Heartbeat

**When:** Real-time features (chat, live updates, notifications).

```
Client ←→ WebSocket Server
         ↕ heartbeat every 30s
```

**Rules:**
- Heartbeat: ping/pong every 30s. Detect dead connections.
- Reconnect with backoff on client side. 1s, 2s, 4s, max 30s.
- Auth on connect: verify token, attach userId.
- Broadcast: send to all connected clients, filter by subscription.
- Message format: `{ "type": "event_name", "payload": {...}, "timestamp": "..." }`

### Pattern: Room/Channel Model

**When:** Scoped real-time updates.

```
User joins "order:123" room → receives only order 123 updates
User joins "dashboard" room → receives all dashboard updates
```

**Rules:**
- Rooms are logical, not physical. One server can handle all rooms.
- Join/leave is explicit. Subscribe, don't broadcast everything.
- Room state: who's connected, last activity, message history.

---

## Repository Pattern

### Pattern: Data Access Repository

**When:** Abstracting database access from business logic.

```typescript
interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
}
```

**Rules:**
- Interface defines WHAT data access is needed. Implementation defines HOW.
- Business logic depends on interface, not concrete class.
- One repository per aggregate root. Not per table.
- Repositories return domain objects, not database rows.
- No business logic in repositories. Data access only.

### Pattern: Unit of Work

**When:** Multiple database operations in one transaction.

```
Begin transaction
  → repo.save(entity)
  → repo.delete(otherEntity)
  → repo.update(anotherEntity)
Commit (all succeed) or Rollback (any fails)
```

**Rules:**
- Unit of Work tracks changes, commits at the end.
- One Unit of Work per request/operation.
- If any operation fails, rollback everything.

---

## Rate Limiting

### Pattern: Token Bucket

**When:** API rate limiting, preventing abuse.

```
Bucket fills at 10 tokens/second (capacity: 100)
Each request consumes 1 token
Empty bucket → 429 Too Many Requests
```

**Rules:**
- Per-user or per-IP limits. Not global.
- Headers: `X-RateLimit-Remaining`, `X-RateLimit-Reset`.
- 429 response with retry-after header.
- Separate limits for different endpoints (auth: 5/min, search: 100/min).

---

## Caching

### Pattern: Cache-Aside

**When:** Read-heavy workloads.

```
Request → Check cache → Hit? Return data
                     → Miss? Query DB → Store in cache → Return data
```

**Rules:**
- Cache TTL: based on data freshness requirements. Not infinite.
- Invalidation: cache-aside + TTL. Not event-driven (too complex).
- Cache key: deterministic. `user:{id}` not `user_data`.
- Cache is a performance optimization, not a data source. DB is source of truth.

### Pattern: Write-Through

**When:** Data must be cached immediately.

```
Write → Write to DB + Write to Cache (same time)
```

**Rules:**
- Consistent: cache always has latest data.
- Slower writes (two operations).
- Use for data that's read immediately after write.

---

## Health Checks

### Pattern: Liveness + Readiness

**When:** Container orchestration (K8s, ECS).

```
GET /health/live → 200 (process is alive)
GET /health/ready → 200 (can serve requests) or 503 (starting up, DB down, etc.)
```

**Rules:**
- Liveness: can the process run? Check: process alive, not deadlocked.
- Readiness: can it serve traffic? Check: DB connected, cache available, config loaded.
- Readiness failure → stop sending traffic. Don't restart.
- Liveness failure → restart the container.

---

## Anti-Patterns

| Anti-Pattern | Why it's bad | Do this instead |
|-------------|-------------|-----------------|
| Shared database between services | Tight coupling | API + events |
| Synchronous chain of 5+ services | Latency, cascading failure | Async events |
| Logging everything at DEBUG | Noise, performance hit | Log decisions, not data |
| No circuit breaker on external calls | Cascading failure | Circuit breaker + retry |
| God repository with 50 methods | SRP violation | One per aggregate |
| Global rate limit | One user hogs all traffic | Per-user limits |
| Cache without TTL | Stale data forever | TTL + invalidation |
| No health checks | Can't detect failures | Liveness + readiness |
| Retry on 400/401/404 | Pointless retries | Retry only on 503/timeout |
| Events as commands | Tight coupling | Events are facts |
