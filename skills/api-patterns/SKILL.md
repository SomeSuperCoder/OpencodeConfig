---
name: api-patterns
description: API design patterns, REST, GraphQL, gRPC, versioning. Use when designing APIs, implementing endpoints, or fixing API issues.
---

# API Design Patterns

## REST Patterns

### Resource Naming

```
# Good — nouns, plural
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PUT    /api/v1/users/:id
DELETE /api/v1/users/:id

# Nested resources
GET    /api/v1/users/:id/posts
GET    /api/v1/users/:id/posts/:postId

# Bad — verbs, singular
GET    /api/v1/getUser
POST   /api/v1/createUser
```

### Query Parameters

```
# Filtering
GET /api/v1/users?status=active&role=admin

# Pagination
GET /api/v1/users?page=2&limit=20

# Sorting
GET /api/v1/users?sort=-created_at,name

# Field selection
GET /api/v1/users?fields=id,name,email

# Search
GET /api/v1/users?q=john
```

### Response Format

```typescript
// Success response
{
  "data": { "id": "1", "name": "Alice" },
  "meta": { "timestamp": "2024-01-15T10:00:00Z" }
}

// List response
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 2,
    "limit": 20,
    "hasMore": true
  }
}

// Error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

### Status Codes

| Code | Usage |
|------|-------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (delete) |
| 400 | Bad Request (validation) |
| 401 | Unauthorized (no auth) |
| 403 | Forbidden (no permission) |
| 404 | Not Found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable Entity |
| 429 | Rate Limited |
| 500 | Internal Server Error |

## GraphQL Patterns

### Schema Design

```graphql
type Query {
  user(id: ID!): User
  users(filter: UserFilter, pagination: PaginationInput): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
}

type User {
  id: ID!
  name: String!
  email: String!
  posts(first: Int, after: String): PostConnection!
}

input CreateUserInput {
  name: String!
  email: String!
}

type CreateUserPayload {
  user: User
  errors: [UserError!]
}
```

### Solving N+1 Problem

```typescript
// DataLoader pattern
import DataLoader from 'dataloader';

const userLoader = new DataLoader(async (ids: string[]) => {
  const users = await db.users.findByIds(ids);
  return ids.map(id => users.find(u => u.id === id));
});

// In resolver
const resolvers = {
  Post: {
    author: (post) => userLoader.load(post.authorId),
  },
};
```

### Pagination

```graphql
# Relay-style cursor pagination
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

## gRPC Patterns

### Proto Definition

```protobuf
syntax = "proto3";

service UserService {
  rpc GetUser (GetUserRequest) returns (User);
  rpc ListUsers (ListUsersRequest) returns (stream User);
  rpc CreateUser (CreateUserRequest) returns (CreateUserResponse);
}

message User {
  string id = 1;
  string name = 2;
  string email = 3;
}

message GetUserRequest {
  string id = 1;
}
```

### Streaming Patterns

```typescript
// Server streaming
server.addMethod('ListUsers', async function* (call) {
  const users = await db.users.find();
  for (const user of users) {
    yield user;
  }
});

// Bidirectional streaming
server.addMethod('Chat', async function* (call) {
  for await (const message of call) {
    yield { response: `Echo: ${message.text}` };
  }
});
```

## API Versioning

### URL Versioning

```typescript
// /api/v1/users
// /api/v2/users

app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);
```

### Header Versioning

```typescript
// Request: Accept: application/vnd.myapp.v2+json
app.use('/api', (req, res, next) => {
  const version = req.headers.accept?.match(/v(\d+)/)?.[1] || '1';
  req.apiVersion = parseInt(version);
  next();
});
```

### Query Parameter Versioning

```
GET /api/users?version=2
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests',
  headers: true,
});

// Per-endpoint limits
const strictLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // 5 attempts
  skipSuccessfulRequests: true,
});
```

## Authentication Patterns

### JWT Bearer Token

```typescript
// Middleware
function authenticate(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}

// Role-based access
function authorize(...roles: string[]) {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}
```

### API Key Authentication

```typescript
function authenticateApiKey(req, res, next) {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey) return res.status(401).json({ error: 'No API key' });

  const validKey = await db.apiKeys.findOne({ key: apiKey });
  if (!validKey) return res.status(401).json({ error: 'Invalid API key' });

  req.user = validKey.user;
  next();
}
```

## Error Handling

```typescript
// Global error handler
app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  logger.error({
    error: message,
    stack: err.stack,
    requestId: req.id,
  });

  res.status(statusCode).json({
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production' ? 'Something went wrong' : message,
      requestId: req.id,
    },
  });
});

// Async error wrapper
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

app.get('/api/users', asyncHandler(async (req, res) => {
  const users = await db.users.find();
  res.json({ data: users });
}));
```
