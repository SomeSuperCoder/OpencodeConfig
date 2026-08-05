---
name: api-patterns
description: API design patterns, REST, GraphQL, gRPC, versioning. Use when designing APIs, implementing endpoints, or fixing API issues.
---

# API Design Patterns

## When To Use This

- Designing new endpoints or schemas
- Choosing REST vs GraphQL vs gRPC for a service
- Versioning, pagination, error formats, auth on APIs
- Fixing N+1, auth, or contract issues

## Choosing the Protocol — Decision Table

| Need | REST | GraphQL | gRPC |
|------|------|---------|------|
| Public web API, browsers, third parties | **Best** | Good | Poor (HTTP/2, complex) |
| Many clients need different field subsets | OK (over/under-fetch) | **Best** | Fixed messages |
| Internal microservice-to-microservice, typed, fast | OK | OK | **Best** |
| Real-time streaming | SSE/WebSocket | Subscriptions | **Streaming built-in** |
| Team simplicity, tooling ubiquity | **Best** | Good | Steeper learning curve |
| Schema evolution / backward compat | Version endpoints | Schema versioning | Proto3 field rules |

## REST Patterns

### Resource Naming — nouns, plural, hierarchical

```
# Good — nouns, plural, nested for sub-resources
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PUT    /api/v1/users/:id          # full replace
PATCH  /api/v1/users/:id          # partial update
DELETE /api/v1/users/:id
GET    /api/v1/users/:id/posts
GET    /api/v1/users/:id/posts/:postId

# Bad — verbs, actions, singular
GET  /api/v1/getUser
POST /api/v1/createUser
POST /api/v1/updateUserStatus    # prefer PATCH /users/:id/status
GET  /api/v1/userPosts?user_id=1 # use nested path
```

- Nouns, plural collections, lowercase, `kebab-case` for multi-word (`/order-items`).
- Verbs only for true actions that aren't CRUD: `/payments/:id/refund`, `/emails/:id/send`.
- RPC-style verbs (`/getUser`, `/save`) are the most common REST anti-pattern — model them as resources.

### Query Parameters — filter, paginate, sort, project

```
GET /api/v1/users?status=active&role=admin     # filtering (equality + operators)
GET /api/v1/users?page=2&limit=20              # offset pagination
GET /api/v1/users?sort=-created_at,name        # '-' = descending
GET /api/v1/users?fields=id,name,email         # sparse fields
GET /api/v1/users?q=john                       # search
GET /api/v1/users?created_at.gt=2024-01-01     # range operators (.gt/.gte/.lt/.lte)
```

### Pagination — cursor for large/volatile data

| Style | When | Shape |
|-------|------|-------|
| Page/limit | Small, static datasets, admin UIs | `?page=2&limit=20`, `meta.total/hasMore` |
| **Cursor** | Large/volatile data (offset shifts as rows change) | `?limit=20&cursor=eyJpZCI6Ij...` opaque cursor |

Cursor response:

```json
{ "data": [...],
  "meta": { "nextCursor": "eyJpZCI6IjUwIn0=", "hasMore": true } }
```

Rules: cursor is opaque to clients; never skip/recompute pages server-side; always bound `limit`.

### Response Envelope & Status Codes

```
// Success (single)
{ "data": { "id": "1", "name": "Alice" } }
// Success (list) — always include pagination meta
{ "data": [...], "meta": { "total": 100, "page": 2, "limit": 20, "hasMore": true } }
// Error — consistent shape everywhere
{ "error": { "code": "VALIDATION_ERROR", "message": "Invalid input",
             "details": [{ "field": "email", "message": "Invalid email format" }] } }
```

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Read success |
| 201 | Created | POST success (+ `Location` header) |
| 204 | No Content | DELETE / successful mutation with no body |
| 400 | Bad Request | Malformed request / validation |
| 401 | Unauthorized | Missing/invalid credentials |
| 403 | Forbidden | Authenticated but not permitted |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate / state conflict |
| 422 | Unprocessable Entity | Semantically invalid (field-level errors) |
| 429 | Too Many Requests | Rate limited (+ `Retry-After`) |
| 500 | Internal Server Error | Unexpected server failure |

Pitfalls: returning 200 with an error body; returning 401 for a permission problem (should be 403); using 400 for everything; leaking `500` with stack traces.

### Error Code Conventions

- `code` is machine-readable and stable (`EMAIL_TAKEN`); `message` is human-readable and mutable.
- Clients should switch on `code`/HTTP status, never on message text.

## GraphQL Patterns

### Schema Design Rules

```graphql
type Query {
  user(id: ID!): User
  users(filter: UserFilter, after: String, first: Int): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
}

type User { id: ID!, name: String!, email: String!, posts(after: String, first: Int): PostConnection! }

input CreateUserInput { name: String!, email: String! }

# Mutations return a payload with errors, not a raw union of scalars
type CreateUserPayload { user: User, errors: [UserError!] }
```

Rules:
- Mutations: single input object; return a payload type (`{ user, errors }`), not a bare scalar/object — lets you return field errors alongside data.
- Errors: per-field `errors` array for validation; top-level `errors` for unexpected failures.
- Pagination: connection pattern (`edges`/`node`/`cursor`/`pageInfo`) for lists — never return bare arrays for unbounded lists.
- Naming: PascalCase types, camelCase fields, verbs as mutation names.

### The N+1 Problem — DataLoader

```typescript
// Without loader: one DB query PER author (N+1)
Post: { author: async (post) => db.users.findById(post.authorId) }

// With DataLoader: batched into ONE query per tick, deduped per request
import DataLoader from 'dataloader';
const userLoader = new DataLoader(async (ids: string[]) => {
  const users = await db.users.findByIds(ids);
  return ids.map((id) => users.find((u) => u.id === id));  // keep request order
});

Post: { author: (post) => userLoader.load(post.authorId) }
```

**Key rule: a DataLoader instance must be per-request**, not module-global — otherwise it caches across users/requests (data leak) and batches across queries.

Detect N+1: turn on GraphQL query logging / `log` middleware that shows N identical queries; or use `graphql-shield`/query cost limiting for abuse.

### Depth & Query Cost Control

- Limit query depth (default 4–6) and breadth; reject huge `first:` values.
- Complex queries over data not in your schema = the classic GraphQL abuse vector.
- Use query-cost estimation + directives for heavy resolvers.

## gRPC Patterns

### Proto Definition

```protobuf
syntax = "proto3";

service UserService {
  rpc GetUser (GetUserRequest) returns (User);
  rpc ListUsers (ListUsersRequest) returns (stream User);       // server streaming
  rpc CreateUser (CreateUserRequest) returns (CreateUserResponse);
  rpc Chat (stream ChatMessage) returns (stream ChatMessage);   // bidirectional
}

message User { string id = 1; string name = 2; string email = 3; }
message GetUserRequest { string id = 1; }
```

### gRPC-Specific Rules

- **Field numbers never change** once shipped; keep unused numbers reserved (`reserved 5, 6;`).
- Proto3: `int32/string` are scalar-safe but missing values are indistinguishable — use `optional`/`google.protobuf.StringValue` when you need presence.
- **gRPC status codes** replace HTTP: `NOT_FOUND`, `INVALID_ARGUMENT`, `PERMISSION_DENIED`, `UNAUTHENTICATED`, `RESOURCE_EXHAUSTED` (rate limit), `INTERNAL`, `DEADLINE_EXCEEDED`. Map HTTP ↔ gRPC consistently in gateways.
- Always set **deadlines** on client calls — gRPC has no built-in timeout; a hung call is forever.
- Streaming: server-stream for large lists, bidi-stream for chat/logs; beware of unbounded buffering on the client.

### Stream patterns

```typescript
// Server streaming — yield as you read
server.addMethod('ListUsers', async function* (call) {
  for (const user of await db.users.find()) yield user;
});
// Bidirectional
server.addMethod('Chat', async function* (call) {
  for await (const msg of call) yield { response: `Echo: ${msg.text}` };
});
```

## API Versioning

### Strategies — Decision Table

| Strategy | Mechanism | Pros | Cons |
|----------|-----------|------|------|
| **URL** (`/api/v1/...`) | Path segment | Visible, cacheable, simple; most common | Ugly; changes for one resource version all |
| Header (`Accept: application/vnd.myapp.v2+json`) | Content negotiation | Clean URLs, media-type semantics | Invisible to proxies/debugging; server must parse |
| Query (`?version=2`) | Query param | Trivial to try | Pollutes cache keys/analytics; easy to forget |
| Breaking-change-only (no explicit versioning) | Compatible additive changes only | Zero overhead | Requires strict additive discipline; painful migrations |

### Recommendation

- Use **URL versioning** for public APIs — visible, cache-friendly, tooling-friendly.
- Version only what breaks: `GET /api/v1/users` can stay while `POST /api/v2/users` differs — don't fork the whole namespace.
- Keep old versions alive with a documented deprecation window; log usage so you can cut them off.
- Make additive changes without a version bump (new optional fields, new endpoints). Version bump = breaking change only.
- Return a `Deprecation` header (`Sunset`) on old versions to nudge migration.

## Authentication on APIs

### Mechanism Selection

| Mechanism | Use for | Pros | Cons |
|-----------|---------|------|------|
| **JWT Bearer** | First-party apps, SPAs | Stateless, standard | Revocation is hard; size grows; validation key juggling |
| **OAuth2 / OIDC** | Third-party access, scopes, multi-app | Standard, scoped, revocable | Setup complexity; token introspection |
| **API keys** | Server-to-server, public dev keys | Simple | Weak identity; no user context; rotate often |
| **mTLS** | Sensitive server-to-server | Strong transport auth | Ops-heavy |
| Session cookie | Traditional web apps | Revocable, httpOnly | CSRF concerns, mobile-unfriendly |

### JWT Best Practices

```typescript
// Verify signature + exp + issuer + audience — in that order
const decoded = jwt.verify(token, process.env.JWT_SECRET, {
  issuer: 'my-api',
  audience: 'my-app',
});
```

- Short-lived access tokens (5–15 min) + refresh tokens; **never** long-lived bearer tokens.
- Include only claims you need; never put PII/emails that leak into logs.
- `nbf`/`exp`/`iss`/`aud` must all be validated — `jwt.verify` isn't enough if you don't pass options.
- **Revocation:** JWTs can't be revoked before `exp` — for critical actions (password change, logout-all) keep a denylist or bump a token version claim.
- Use asymmetric signing (RS256) in multi-service setups; keep private keys in a secret store, rotate regularly.

### Authorization (RBAC) vs Authentication

```typescript
// authentication: WHO are you? (401)
// authorization: MAY you do this? (403)
function authorize(...roles: string[]) {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) return res.status(403).json({ error: 'Forbidden' });
    next();
  };
}
```

- Enforce authorization **server-side on every request** — client-side hiding is cosmetic, not security.
- Consider object-level (not just role-level) checks: a user can edit *their own* resource even when role matches.
- Rate limit auth endpoints aggressively (login, token refresh, password reset).

### Rate Limiting

```typescript
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  headers: true,                    // X-RateLimit-*
  standardHeaders: 'draft-7',
});
// Per-endpoint stricter limits
const authLimiter = rateLimit({ windowMs: 60 * 60 * 1000, max: 5, skipSuccessfulRequests: true });
```

Return `Retry-After` on 429; apply distributed rate limiting (Redis) when behind multiple instances; vary by identity (user/API key), not just IP.

## Common Pitfalls / Anti-Patterns

| Pitfall | Why it hurts | Fix |
|---------|-------------|-----|
| Verb/singular endpoints | Inconsistent, un-RESTful | Nouns, plural collections |
| 200 for errors | Clients can't branch on status | Correct status codes |
| No pagination meta | Clients guess at pages | Always include meta/hasMore or cursor |
| GraphQL module-global DataLoader | Cross-request data leak | Per-request loader instance |
| gRPC field number reuse | Undefined wire behavior | `reserved` obsolete numbers |
| Versioning everything always | Maintenance burden, churn | Version only breaking changes |
| No `exp`/`aud` validation on JWT | Token forgery/confusion | Validate all claims with options |
| Auth only in gateway, not service | Bypass via internal routing | Enforce at every boundary |
| Stack traces in 500 responses | Info leak | Sanitize; log server-side with requestId |

## Best Practices Checklist

- [ ] REST: nouns/plural, correct status codes, consistent error envelope
- [ ] Pagination (cursor for volatile data) with meta
- [ ] GraphQL: payload mutations, connection pagination, per-request DataLoaders, query cost/depth limits
- [ ] gRPC: reserved field numbers, deadlines, mapped status codes
- [ ] Versioning via URL; break-additively, never
- [ ] Auth: short-lived tokens, all claims validated, server-side authorization
- [ ] Rate limiting on sensitive endpoints with `Retry-After`
- [ ] Consistent machine-readable error codes
- [ ] Documented deprecation/sunset for old versions
