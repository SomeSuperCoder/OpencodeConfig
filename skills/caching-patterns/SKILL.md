---
name: caching-patterns
description: Caching strategies, CDN, Redis, invalidation patterns. Use when implementing caching, improving performance, or fixing stale data.
---

# Caching Patterns

## Cache Strategies

### Cache-Aside (Lazy Loading)

```typescript
async function getUser(id: string): Promise<User> {
  // Check cache first
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  // Cache miss — fetch from database
  const user = await db.users.findById(id);
  if (user) {
    await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
  }
  return user;
}
```

### Write-Through

```typescript
async function updateUser(id: string, data: Partial<User>) {
  // Write to database
  const user = await db.users.update(id, data);

  // Update cache simultaneously
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user));

  return user;
}
```

### Write-Behind (Write-Back)

```typescript
async function updateUser(id: string, data: Partial<User>) {
  // Update cache immediately
  const user = { ...await redis.get(`user:${id}`), ...data };
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user));

  // Queue database write (async)
  writeQueue.push({ id, data, timestamp: Date.now() });

  return user;
}
```

### Read-Through

```typescript
async function getUser(id: string): Promise<User> {
  return cache.getOrSet(`user:${id}`, async () => {
    return db.users.findById(id);
  }, { ttl: 3600 });
}
```

## TTL Strategies

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| User session | 30 min | Security, inactivity timeout |
| User profile | 1 hour | Changes infrequently |
| Product catalog | 24 hours | Rarely changes |
| Configuration | 5 min | Needs to be fresh |
| API response | 1-5 min | Balance freshness vs load |
| Static assets | 1 year | Immutable with versioning |

```typescript
// TTL with jitter to prevent thundering herd
const ttlWithJitter = (baseTtl: number): number => {
  const jitter = Math.random() * baseTtl * 0.1;
  return Math.floor(baseTtl + jitter);
};
```

## Cache Invalidation

### Time-Based

```typescript
// Simple TTL
await redis.setex(key, 3600, value);

// Sliding expiration
async function accessCache(key: string) {
  const value = await redis.get(key);
  if (value) {
    await redis.expire(key, 3600); // Reset TTL on access
  }
  return value;
}
```

### Event-Based

```typescript
// Invalidate on write
async function updateUser(id: string, data: Partial<User>) {
  const user = await db.users.update(id, data);

  // Invalidate related caches
  await redis.del(`user:${id}`);
  await redis.del(`user:${id}:profile`);
  await redis.del('users:list');

  // Publish invalidation event
  await pubsub.publish('cache:invalidate', { pattern: `user:${id}*` });
}
```

### Tag-Based

```typescript
// Tag cache entries
async function cacheWithTags(key: string, value: any, tags: string[]) {
  await redis.setex(key, 3600, JSON.stringify({ value, tags }));

  // Index by tags
  for (const tag of tags) {
    await redis.sadd(`tag:${tag}`, key);
  }
}

// Invalidate by tag
async function invalidateTag(tag: string) {
  const keys = await redis.smembers(`tag:${tag}`);
  if (keys.length) {
    await redis.del(...keys);
    await redis.del(`tag:${tag}`);
  }
}
```

## CDN Patterns

### Cache Headers

```typescript
// Static assets (immutable)
app.use(express.static('public', {
  maxAge: '1y',
  immutable: true,
}));

// API responses
app.get('/api/products', (req, res) => {
  res.set({
    'Cache-Control': 'public, max-age=300, stale-while-revalidate=60',
    'ETag': generateETag(data),
  });
  res.json(data);
});
```

### Purging Strategies

```
# CloudFlare purge
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/{zone}/purge_cache" \
  -H "Authorization: Bearer {token}" \
  -d '{"files": ["https://example.com/api/products"]}'
```

## Redis Patterns

### Cache Stampede Prevention

```typescript
async function getWithLock(key: string, fetcher: () => Promise<any>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Try to acquire lock
  const lock = await redis.set(`lock:${key}`, '1', 'NX', 'EX', 10);
  if (!lock) {
    // Another process is fetching — wait and retry
    await sleep(100);
    return getWithLock(key, fetcher);
  }

  try {
    const value = await fetcher();
    await redis.setex(key, 3600, JSON.stringify(value));
    return value;
  } finally {
    await redis.del(`lock:${key}`);
  }
}
```

### Batch Operations

```typescript
// Pipeline multiple operations
const pipeline = redis.pipeline();
keys.forEach(key => pipeline.get(key));
const results = await pipeline.exec();

// MGET for multiple keys
const values = await redis.mget('user:1', 'user:2', 'user:3');
```

## Browser Caching

### Service Worker Cache

```typescript
// sw.js
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
```

### localStorage with Expiry

```typescript
function setWithExpiry(key: string, value: any, ttlMs: number) {
  const item = {
    value,
    expiry: Date.now() + ttlMs,
  };
  localStorage.setItem(key, JSON.stringify(item));
}

function getWithExpiry(key: string): any {
  const item = localStorage.getItem(key);
  if (!item) return null;

  const { value, expiry } = JSON.parse(item);
  if (Date.now() > expiry) {
    localStorage.removeItem(key);
    return null;
  }
  return value;
}
```
