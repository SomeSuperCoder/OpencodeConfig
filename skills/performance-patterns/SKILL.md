---
name: performance-patterns
description: "Performance optimization patterns, profiling, caching, lazy loading. Use when optimizing code, reducing bundle size, improving load times, or fixing performance issues."
---

# Performance Patterns

Load this skill when optimizing performance or fixing bottlenecks.

## Metrics Targets
| Metric | Target | Critical |
|--------|--------|----------|
| p95 latency | < 200ms | > 500ms |
| LCP | < 2.5s | > 4s |
| FID | < 100ms | > 300ms |
| Memory | Stable | Growing |

## Optimization Playbook
| Problem | Solution |
|---------|----------|
| Slow queries | Add indexes, optimize queries |
| Large bundle | Code split, tree shake, lazy load |
| Slow renders | Memoize, virtualize, debounce |
| High memory | Fix leaks, pool objects |
| Slow API | Cache, batch, parallelize |

## Caching Strategies
| Layer | Tool | TTL |
|-------|------|-----|
| Browser | Service Worker | Varies |
| CDN | Cloudflare/CloudFront | 5-60min |
| App | Redis/Memcached | 1-60min |
| Database | Query cache | Varies |

## Code Patterns
```typescript
// Memoize expensive computations
const memoize = <T>(fn: (...args: any[]) => T) => {
  const cache = new Map();
  return (...args: any[]) => {
    const key = JSON.stringify(args);
    if (!cache.has(key)) cache.set(key, fn(...args));
    return cache.get(key);
  };
};

// Debounce user input
const debounce = <T>(fn: (...args: any[]) => T, ms: number) => {
  let timer: NodeJS.Timeout;
  return (...args: any[]) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), ms);
  };
};
```

## Integration
- **MCPs:** Browser MCP for frontend profiling
- **AgentMemory:** Save performance findings, optimization patterns
