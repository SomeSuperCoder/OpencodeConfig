---
name: domain-knowledge
description: "Domain-specific patterns and best practices for authentication, payments, real-time, search, caching, ML/AI, and crypto. Use when implementing domain-specific features."
---

# Domain Knowledge

Load this skill when implementing domain-specific features.

## Authentication
| Pattern | Use When |
|---------|----------|
| JWT | Stateless APIs, microservices |
| Sessions | Traditional web apps |
| OAuth2 | Third-party login, SSO |
| API Keys | Service-to-service |
| MFA | High-security applications |

**JWT Best Practices:**
- Short expiry (15min access, 7d refresh)
- Rotate refresh tokens
- Store in httpOnly cookies, not localStorage
- Validate signature AND claims

## Payments
| Provider | Use When |
|----------|----------|
| Stripe | Most use cases |
| PayPal | Consumer-facing |
| Square | In-person + online |

**Stripe Patterns:**
- Use Payment Intents for SCA compliance
- Webhook for async events
- Idempotency keys for retries
- Test mode first, live mode separate

## Real-time
| Pattern | Use When |
|---------|----------|
| WebSockets | Bidirectional, low latency |
| SSE | Server-to-client streaming |
| Polling | Simple, acceptable latency |
| Pub/Sub | Many subscribers |

## Search
| Tool | Use When |
|------|----------|
| PostgreSQL FTS | Simple text search |
| Elasticsearch | Complex queries, analytics |
| Algolia | Managed, instant search |
| Meilisearch | Self-hosted alternative |

## Caching
| Layer | Tool | TTL |
|-------|------|-----|
| Browser | Service Worker | Varies |
| CDN | Cloudflare | 5-60min |
| App | Redis | 1-60min |
| Database | Query cache | Varies |

## Integration
- **AgentMemory:** Save domain patterns, provider quirks
