---
name: caching-patterns
description: Caching strategies, CDN, Redis, invalidation patterns. Use when implementing caching, improving performance, or fixing stale data.
---

# Caching Patterns

## When To Use This

- Choosing a caching strategy for read or write paths
- Setting TTLs, invalidation, or stale-data handling
- Implementing CDN, browser, or Redis caching
- Debugging stale reads or cache stampedes

## Choosing a Strategy

### The Five Cache Patterns

| Pattern | Write path | Read path | Consistency | Best for |
|---------|-----------|-----------|-------------|----------|
| **Cache-aside** | App writes DB, then deletes/populates cache | App reads cache, fills on miss | Eventual (del on write) | Default for most reads |
| **Read-through** | Same as cache-aside | Cache lib fetches from store on miss | Eventual | Standardized read API, libs like Cache-Aside wrappers |
| **Write-through** | App writes cache **and** DB together | Any | Strong on writes, cache always current | Write-heavy, always-hot data |
| **Write-behind (write-back)** | App writes cache, queues DB write async | Any | Weakest, risk of data loss | High-write-throughput, non-critical writes |
| **Cache-aside + invalidation events** | App publishes invalidation on write | Any | Eventual, targeted | Multi-service / distributed |

### Pattern Selection — Decision Table

| Situation | Use |
|-----------|-----|
| Generic read-heavy workload | Cache-aside |
| Reads must be fast, writes are rare and low-stakes | Cache-aside |
| Data must never serve stale after a write | Write-through |
| Extreme write throughput, losing a few writes is acceptable | Write-behind |
| Multiple services read the same data | Cache-aside + invalidation events/tags |
| In-process/nearby data, needs zero network | Local LRU (lru-cache), not Redis |

## Cache-Aside (Lazy Loading) — the default

```typescript
async function getUser(id: string): Promise<User> {
  // 1. Check cache
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  // 2. Miss → fetch from DB
  const user = await db.users.findById(id);
  if (user) {
    // 3. Populate cache
    await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
  }
  return user;
}
```

**The invalidation rule of cache-aside:** after a successful write, **delete** the key (don't update it). Updating risks stale/divergent copies when two writers race; deleting forces a clean repopulate.

## Write-Through vs Write-Behind

```typescript
// Write-through — both must succeed (or cache becomes stale)
async function updateUser(id: string, data: Partial<User>) {
  const user = await db.users.update(id, data);
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
  return user;
}

// Write-behind — cache updated immediately, DB write queued
async function updateUser(id: string, data: Partial<User>) {
  const cached = await redis.get(`user:${id}`);          // merge with cache
  const user = { ...JSON.parse(cached ?? '{}'), ...data };
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
  writeQueue.push({ id, data, timestamp: Date.now() });  // async flush to DB
  return user;
}
```

- **Write-behind failure modes:** process crash loses queued writes; DB down drains queue. Add idempotent write keys, retry with backoff, and monitor queue depth.
- **Write-through failure:** if DB succeeds but cache write fails, log + invalidate so the next read repopulates.

## TTL Strategy

### TTL by Data Type

| Data type | TTL | Rationale |
|-----------|-----|-----------|
| User session | 15–30 min | Security; sliding expiry per access |
| User profile | 1 hour | Rarely changes |
| Product catalog | 24 h | Changes rarely, high read volume |
| Configuration | 5 min | Needs freshness; tolerate 5 min staleness |
| API response | 1–5 min | Balance freshness vs upstream load |
| Search result pages | 5–15 min | Expensive query, acceptable staleness |
| Immutable static assets | 1 year + `immutable` | Never change; versioned URLs |
| Counters (views, likes) | 1–10 min | Approximate values acceptable |

### Jitter & Thundering Herd

```typescript
// Jittered TTL spreads expirations so mass-expiry doesn't hit the DB at once
const ttlWithJitter = (base: number): number =>
  Math.floor(base + Math.random() * base * 0.1);

// Set short "soft" TTL + long "hard" TTL — background refresh at soft TTL
// read path: if now > softTTL, refresh in background, serve stale.
```

| Problem | Fix |
|---------|-----|
| All keys expire at once | Random jitter (±10–20% of TTL) |
| Cold cache + 10k requests on one key | Single-flight lock (below) |
| Stale data is fine but must refresh soon | `stale-while-revalidate` |
| Expensive query, hard to rebuild | Longer TTL + explicit invalidation |

## Invalidation

### Time-Based (TTL) vs Event-Based

| Strategy | Pros | Cons | Use when |
|----------|------|------|----------|
| TTL only | Simple, self-healing | Serves stale data until expiry | Staleness is acceptable |
| Delete on write | Correct, simple | Write amplification; every write touches cache | Cache-aside, standard |
| Tag-based | One op invalidates related keys | Requires tag index bookkeeping | Lists/aggregates (`users:list`, search) |
| Pub/sub event | Decoupled, cross-service | Requires message broker, eventual | Multiple services share caches |

```typescript
// Sliding expiration — reset TTL on every read (sessions)
async function accessCache(key: string) {
  const value = await redis.get(key);
  if (value) await redis.expire(key, 3600);
  return value;
}
```

```typescript
// Tag-based invalidation — invalidate every key that carries a tag
async function cacheWithTags(key: string, value: any, tags: string[]) {
  await redis.setex(key, 3600, JSON.stringify(value));
  for (const tag of tags) await redis.sadd(`tag:${tag}`, key);
}

async function invalidateTag(tag: string) {
  const keys = await redis.smembers(`tag:${tag}`);
  if (keys.length) await redis.del(...keys);
  await redis.del(`tag:${tag}`);
}
```

### The Classic Bug: stale list caches

Writing entity keys is easy; forgetting aggregate keys (`users:list`, `page:2`) is the #1 stale-data source. Always invalidate:
1. The entity key
2. Every list/aggregate key it appears in
3. Every tag that references it

## Stale Data Handling

| Technique | Behavior | Use when |
|-----------|----------|----------|
| `stale-while-revalidate` | Serve stale, refresh in background | Slight staleness OK, want fast reads |
| `stale-if-error` | Serve stale only if upstream errors | Availability > freshness |
| Background refresh at soft TTL | Refresh before expiry | Hot, expensive keys |
| Short TTL + tolerant reads | Re-read DB periodically | Stronger consistency needed |

```typescript
// HTTP example — combine them
res.set('Cache-Control', 'public, max-age=300, stale-while-revalidate=60, stale-if-error=86400');
```

## Cache Stampede Prevention (Single-Flight / Locking)

```typescript
async function getWithLock(key: string, fetcher: () => Promise<any>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const lock = await redis.set(`lock:${key}`, '1', 'NX', 'EX', 10);
  if (!lock) {
    // Another process is fetching — wait briefly, then re-read cache
    await sleep(50);
    const retried = await redis.get(key);
    if (retried) return JSON.parse(retried);
    return getWithLock(key, fetcher); // guard with max attempts
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

- **Single-flight in-process:** a `Map<key, Promise>` ensures one request per process refreshes; Redis lock (above) covers multiple processes.
- Always add a max-wait/attempt bound to avoid infinite recursion.

## CDN Caching

### Cache Headers That Matter

| Header | Meaning |
|--------|---------|
| `Cache-Control: public, max-age=300` | Shared caches OK; 5 min freshness |
| `Cache-Control: private` | Only browser may cache (auth'd responses) |
| `Cache-Control: no-store` | Never cache (PII, tokens) |
| `Cache-Control: immutable` | Never revalidate (hashed assets) |
| `Cache-Control: no-cache` | Store but always revalidate with origin |
| `ETag` / `Last-Modified` | Conditional GET revalidation |
| `Vary: Accept-Encoding` | Cache variants separately (never omit) |

```typescript
// Immutable static assets
app.use(express.static('public', { maxAge: '1y', immutable: true, etag: true }));

// Public API response
app.get('/api/products', (req, res) => {
  res.set('Cache-Control', 'public, max-age=300, stale-while-revalidate=60');
  res.set('ETag', generateETag(data));
  res.json(data);
});

// Auth'd/user-specific — must NOT be cached publicly
app.get('/api/me', (req, res) => {
  res.set('Cache-Control', 'private, no-store');
  res.json(req.user);
});
```

### CDN Purging

- Cache-bust by changing the URL (hash/version in filename) — never wait for TTL on new deploys.
- Purge selectively on release (changed assets only), or purge-all when URL scheme changes.
- Invalidate CDN **and** origin caches — a cached 404 can pin broken deploys.

## Redis Patterns

### Batch Operations — reduce round-trips

```typescript
// Pipeline: send many commands in one round-trip
const pipeline = redis.pipeline();
keys.forEach(k => pipeline.get(k));
const results = await pipeline.exec();

// MGET for a known key set
const values = await redis.mget('user:1', 'user:2', 'user:3');
```

### Data-Structure Choice — use the right type

| Need | Redis type |
|------|-----------|
| Expiring value | `SET key val EX n` / `SETEX` |
| Counters / limits | `INCR` + `EXPIRE` (rate limiting) |
| Tagging / sets | `SADD`/`SMEMBERS` (tag index) |
| Recent items | `LPUSH`/`LRANGE` (cap with `LTRIM`) |
| Sorted leaderboards | `ZADD`/`ZREVRANGE` |
| Distributed lock | `SET key 1 NX EX 10` |
| Recurring publish/subscribe invalidation | `PUBLISH`/`SUBSCRIBE` |

## Browser Caching

### Service Worker — stale-while-revalidate pattern

```typescript
// sw.js — serve cache, fetch update in background, update cache
self.addEventListener('fetch', (event) => {
  event.respondWith((async () => {
    const cached = await caches.match(event.request);
    const network = fetch(event.request).then((res) => {
      if (res.ok) caches.open('v1').then((c) => c.put(event.request, res.clone()));
      return res;
    }).catch(() => cached);
    return cached || network;
  })());
});
```

- **Never cache POST / non-GET, auth'd, or `no-store` responses** in service workers.
- Version the cache name (`caches.open('v2')`) and clean old versions on activate.

### localStorage/IndexedDB with Expiry

```typescript
function setWithExpiry(key: string, value: any, ttlMs: number) {
  localStorage.setItem(key, JSON.stringify({ value, expiry: Date.now() + ttlMs }));
}

function getWithExpiry(key: string): any {
  const item = localStorage.getItem(key);
  if (!item) return null;
  const { value, expiry } = JSON.parse(item);
  if (Date.now() > expiry) { localStorage.removeItem(key); return null; }
  return value;
}
```

- localStorage is synchronous and blocks the main thread — use for small payloads; IndexedDB for large data.
- Wrap JSON.parse/getItem in try/catch (quota, corrupted data, SSR where `localStorage` is undefined).

## Common Pitfalls / Anti-Patterns

| Pitfall | Why it hurts | Fix |
|---------|-------------|-----|
| No TTL anywhere | Memory fills; stale forever | Always set TTL; bounded caches |
| Updating cache on write instead of deleting | Race between writers → divergent copies | Delete, not update |
| Forgetting aggregate/list keys | Stale lists even though entity updated | Tag-based or systematic invalidation |
| Caching auth'd/user data publicly | Data leak | `Cache-Control: private`/`no-store` |
| No jitter | Stampede at expiry boundary | Add ±10–20% jitter |
| Missing single-flight | Thundering herd on cold cache | Lock + wait + retry |
| Service worker caching mutations | Corrupt/leaked data | Never cache non-GET/auth'd |
| Redis as primary store | Losing data on eviction/restart | Cache is a cache; DB is truth |
| Long TTL on mutable data | Users see old data | Shorter TTL + event invalidation |
| Same key across environments | Dev cache pollutes prod | Namespace keys (`prod:user:1`) |

## Best Practices Checklist

- [ ] Every cached value has a TTL (or bounded eviction)
- [ ] Invalidation deletes entity key AND all aggregate keys/tags
- [ ] Cache-aside is the default; write-through/behind only when the trade-off is justified
- [ ] Jitter on TTLs; single-flight on expensive keys
- [ ] `Cache-Control` correct per response type (public/private/no-store/immutable)
- [ ] Versioned asset URLs so deploys don't need purge
- [ ] Keys namespaced and versioned (`app:v2:user:1`)
- [ ] Cache is treated as disposable — DB remains source of truth
- [ ] Stampede, queue depth, and eviction metrics monitored
