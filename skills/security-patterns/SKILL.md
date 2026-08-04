---
name: security-patterns
description: "Security best practices, OWASP Top 10, threat modeling, secure coding patterns. Use when implementing auth, handling sensitive data, reviewing code for vulnerabilities, or doing security audits."
---

# Security Patterns

Load this skill when implementing security features or reviewing code for vulnerabilities.

## OWASP Top 10 Quick Reference
1. **Injection** — Use parameterized queries, never concat SQL
2. **Broken Auth** — MFA, secure session handling, rate limiting
3. **Sensitive Data** — Encrypt at rest/transit, no logging secrets
4. **XXE** — Disable external entity parsing
5. **Broken Access Control** — Check permissions server-side, not client
6. **Security Misconfiguration** — No default creds, minimal error messages
7. **XSS** — Sanitize output, use CSP headers
8. **Insecure Deserialization** — Validate before deserializing
9. **Vulnerable Components** — Regular `pnpm audit`, update deps
10. **Insufficient Logging** — Log security events, alert on anomalies

## Secure Coding Checklist
- [ ] Input validation on ALL external data
- [ ] Parameterized queries (no SQL concat)
- [ ] Output sanitization (prevent XSS)
- [ ] Secrets in env vars, never code/git
- [ ] HTTPS everywhere
- [ ] Rate limiting on auth endpoints
- [ ] Least privilege permissions
- [ ] No sensitive data in URLs/logs

## Auth Patterns
| Pattern | Use When |
|---------|----------|
| JWT | Stateless APIs, microservices |
| Sessions | Traditional web apps |
| OAuth2 | Third-party login |
| API Keys | Service-to-service |

## Integration
- **AgentMemory:** Save security findings, vulnerability patterns
