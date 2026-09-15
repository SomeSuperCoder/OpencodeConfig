---
name: cybersec-patterns
description: "Cybersecurity patterns for developers and pentesters. Covers OWASP Top 10, authentication/authorization, input validation, secrets management, API security, and secure coding practices. Use when building, reviewing, or testing for security."
---

# Cybersecurity Patterns for Developers

Security is not a feature — it's a requirement. These patterns prevent the most common attacks.

---

## OWASP Top 10 (2021)

### A01: Broken Access Control

**What:** Users can access data/actions they shouldn't.

**Attack:** User A accesses User B's data by changing `/api/users/123/orders` to `/api/users/456/orders`.

**Prevention:**
- Server-side validation for EVERY request. Never trust client-side checks.
- Deny by default. Explicit allow for each role/permission.
- Use UUIDs, not sequential IDs (harder to guess, but NOT a security control).
- Ownership check: `if (order.userId !== currentUser.id) throw 403`.
- Admin functions: separate admin auth, not just role flag.

**Test:** Change IDs in requests. Access admin endpoints as regular user. Check IDOR.

### A02: Cryptographic Failures

**What:** Sensitive data exposed due to weak encryption.

**Attack:** Passwords stored in MD5, API keys in plaintext, TLS not enforced.

**Prevention:**
- Passwords: bcrypt/argon2 with salt. Never MD5, never SHA-256 alone.
- Data at rest: AES-256. Data in transit: TLS 1.3.
- No custom crypto. Use established libraries (libsodium, OpenSSL).
- Key management: never in code, never in env vars committed to git. Use secrets manager.
- Certificate pinning for mobile apps.

**Test:** Check hash algorithms in code. Verify TLS config. Check for hardcoded secrets.

### A03: Injection

**What:** Untrusted data sent to interpreters (SQL, NoSQL, OS, LDAP).

**Attack:** `' OR 1=1 --` in login field. `{"$gt":""}` in MongoDB query.

**Prevention:**
- SQL: parameterized queries / prepared statements. NEVER string concatenation.
- NoSQL: validate and sanitize input. Use schema validation (Mongoose, Zod).
- OS: never pass user input to `exec()`, `eval()`, `system()`.
- ORM: use query builders, not raw SQL.
- Input validation: whitelist allowed characters, reject everything else.

**Test:** SQLmap on endpoints. Input `'; --` in all fields. Check for raw query usage.

### A04: Insecure Design

**What:** Security not considered in architecture.

**Attack:** Password reset doesn't expire. No rate limiting on login. Trusting client-side auth.

**Prevention:**
- Threat modeling before building. Ask: "How could this be abused?"
- Secure design patterns: least privilege, defense in depth, fail secure.
- Rate limiting on auth endpoints: 5 attempts per minute.
- Password reset: time-limited tokens, single-use, expire in 15 min.
- Trust boundaries: identify where trust changes (client → server, service → service).

**Test:** Review auth flow end-to-end. Check rate limiting. Check password reset flow.

### A05: Security Misconfiguration

**What:** Defaults, unnecessary features, verbose errors.

**Attack:** Debug mode in production. Default admin credentials. Directory listing enabled.

**Prevention:**
- Disable debug mode in production. `NODE_ENV=production`.
- Remove default accounts, change default passwords.
- Disable directory listing. Remove unnecessary HTTP headers.
- Error messages: generic to user, detailed in logs. Never stack traces to client.
- CORS: specific origins, not `*`. Never allow all origins.

**Test:** Check HTTP headers. Try default credentials. Trigger errors and check response.

### A06: Vulnerable Components

**What:** Using libraries with known CVEs.

**Attack:** Using lodash 4.17.15 (has prototype pollution CVE).

**Prevention:**
- Lock files: commit and use them. `package-lock.json`, `yarn.lock`.
- Automated scanning: `npm audit`, `pip-audit`, `trivy` in CI.
- Update regularly: weekly dependency updates. Not "never."
- Replace unmaintained packages. If no updates in 2 years, find alternative.
- SBOM: know what's in your build.

**Test:** `npm audit`, `trivy image`, `pip-audit`. Check for outdated dependencies.

### A07: Auth Failures

**What:** Broken authentication mechanisms.

**Attack:** Brute force login, session fixation, credential stuffing.

**Prevention:**
- Multi-factor authentication (MFA) for sensitive accounts.
- Session management: server-side sessions or short-lived JWTs (15 min).
- Password policy: min 12 chars, no max limit, check against breach databases.
- Account lockout: 5 failed attempts → lock for 15 min or CAPTCHA.
- Session invalidation: on logout, on password change, on suspicious activity.

**Test:** Brute force login (check lockout). Check session handling. Test MFA bypass.

### A08: Data Integrity Failures

**What:** Untrusted data not validated.

**Attack:** Deserializing malicious objects, unsigned updates, insecure CI/CD.

**Prevention:**
- Input validation: validate ALL input at API boundaries. Schema validation (Zod, Joi).
- Deserialization: never deserialize untrusted data. Use safe formats (JSON).
- Integrity checks: sign builds, verify signatures before deploy.
- CI/CD: secure pipeline, no plaintext secrets, signed commits.

**Test:** Send malformed data to APIs. Check input validation. Review CI/CD config.

### A09: Logging Failures

**What:** Insufficient logging for security events.

**Attack:** Attacker operates undetected because no audit trail.

**Prevention:**
- Log ALL auth events: login, logout, failed login, password change.
- Log ALL access control events: forbidden, unauthorized.
- Log ALL data modifications: create, update, delete.
- Tamper-proof logs: append-only, centralized, not in application directory.
- Alert on suspicious patterns: multiple failed logins, unusual access patterns.

**Test:** Check what's logged. Trigger security events, verify they're logged.

### A10: SSRF (Server-Side Request Forgery)

**What:** Server makes requests to user-specified URLs.

**Attack:** `?url=http://169.254.169.254/latest/meta-data/` → access cloud metadata.

**Prevention:**
- Whitelist allowed URLs/domains. Reject internal IPs (10.x, 172.16-31.x, 192.168.x, 169.254.x).
- Disable unused URL schemes (file://, gopher://).
- Network segmentation: app servers can't reach internal services directly.
- Use a proxy for outbound requests. Don't make requests from app server.

**Test:** Send internal URLs in parameters. Check if server makes the request.

---

## Authentication Patterns

### Pattern: JWT Authentication

**When:** Stateless auth for APIs.

```
Login → Server validates credentials → Issues JWT (15 min expiry)
Request → Client sends JWT in header → Server verifies → Grants access
```

**Rules:**
- Short expiry: 15 min for access tokens, 7 days for refresh tokens.
- Never store JWT in localStorage (XSS vulnerability). Use httpOnly cookies.
- Refresh token rotation: new refresh token on each use. Old one = stolen.
- Claims: minimal data. userId, roles, exp. Not full user object.
- Revocation: JWT can't be revoked. Use short expiry + refresh token rotation.

### Pattern: OAuth 2.0 / OIDC

**When:** Third-party login, API authorization.

**Rules:**
- Use Authorization Code flow with PKCE for web apps.
- Never use Implicit flow (deprecated, insecure).
- Validate state parameter to prevent CSRF.
- Check `iss`, `aud`, `exp`, `iat` claims on ID tokens.
- Scope: request minimal permissions. Don't ask for everything.

### Pattern: API Key Authentication

**When:** Machine-to-machine, not user auth.

**Rules:**
- API keys are for identification, not authentication. Use alongside auth.
- Rotate keys regularly. Support multiple active keys.
- Rate limit per API key. Different limits per plan/tier.
- Never expose in URLs. Use headers: `Authorization: Bearer <key>`.

---

## Input Validation

### Pattern: Whitelist Validation

**When:** Every input at every boundary.

**Rules:**
- Validate on the SERVER. Client-side validation is UX, not security.
- Schema validation: Zod, Joi, Yup. Define types, enforce them.
- Whitelist: define what's ALLOWED, reject everything else.
- Length limits: max 255 chars for names, max 10000 for text fields.
- Type checks: number fields reject strings. Boolean fields reject non-booleans.

### Pattern: Sanitization

**When:** Data that will be displayed or processed.

**Rules:**
- HTML: escape `<`, `>`, `"`, `'`, `&` before rendering.
- SQL: parameterized queries, not string concatenation.
- OS: never pass user input to shell commands.
- URL: validate scheme (https only), reject internal IPs.
- File upload: validate type (magic bytes, not extension), size limit, scan for malware.

---

## Secrets Management

### Pattern: Zero Secrets in Code

**When:** Always. No exceptions.

**Rules:**
- Never commit secrets to git. Use `.env` + `.gitignore`.
- Environment variables for runtime secrets. Not config files.
- Secrets manager for production: AWS Secrets Manager, HashiCorp Vault, Doppler.
- Rotate on compromise: if a secret leaks, rotate IMMEDIATELY.
- Audit: scan git history for leaked secrets (trufflehog, gitleaks).

### Pattern: Secret Rotation

**When:** Regularly, and on compromise.

**Rules:**
- Automated rotation: rotate secrets without downtime.
- Grace period: accept old + new secret during rotation window.
- Frequency: API keys quarterly, database passwords monthly, SSH keys annually.
- Breach: rotate everything that could have been exposed.

---

## API Security

### Pattern: Rate Limiting

**When:** Every public API endpoint.

**Rules:**
- Per-user or per-API-key limits. Not global.
- Different limits for different endpoints: auth (5/min), read (100/min), write (20/min).
- Headers: `X-RateLimit-Remaining`, `X-RateLimit-Reset`, `Retry-After`.
- 429 response with retry-after. Not 500.
- Sliding window or token bucket. Not fixed window (bursty).

### Pattern: CORS Configuration

**When:** Every API endpoint.

**Rules:**
- Specific origins: `https://app.example.com`. Not `*`.
- Credentials: `Access-Control-Allow-Credentials: true` only with specific origins.
- Methods: allow only needed methods. Not `*`.
- Headers: allow only needed headers. Not `*`.
- Preflight: cache for 1 hour. Don't preflight every request.

### Pattern: Content Security Policy (CSP)

**When:** Preventing XSS and injection.

```
Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-abc123'; style-src 'self' 'unsafe-inline'
```

**Rules:**
- `default-src 'self'`: only load resources from own origin.
- `script-src`: nonce-based or hash-based. Never `unsafe-eval`.
- Report violations: `report-uri` endpoint.
- Start strict, loosen as needed. Not the other way around.

---

## Secure Coding Checklist

### Before Every Commit

- [ ] No hardcoded secrets, API keys, passwords
- [ ] Input validation on all user-facing endpoints
- [ ] Parameterized queries for all database access
- [ ] Auth check on every protected endpoint
- [ ] Error messages don't leak internals
- [ ] No `eval()`, `exec()`, or dynamic code execution
- [ ] Dependencies updated (no known CVEs)
- [ ] Logging for security events

### Before Every Deploy

- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] Security headers configured (HSTS, CSP, X-Frame-Options)
- [ ] CORS configured (not `*`)
- [ ] Debug mode disabled
- [ ] Default credentials changed
- [ ] Secrets in secrets manager, not env vars
- [ ] Health checks configured
- [ ] Rate limiting enabled

---

## Anti-Patterns

| Anti-Pattern | Why it's bad | Do this instead |
|-------------|-------------|-----------------|
| Client-side only validation | Bypassed trivially | Server-side validation always |
| MD5/SHA for passwords | Cracked in seconds | bcrypt/argon2 with salt |
| `SELECT *` in queries | Returns unnecessary data | Select only needed columns |
| Trusting JWT claims without validation | Expired/forged tokens | Validate signature, exp, iss, aud |
| Security through obscurity | Obscurity fails, security holds | Defense in depth |
| "We're too small to be targeted" | Automated attacks don't care | Basic security for everyone |
| Security as last step | Expensive to fix, always rushed | Security from design phase |
| Logging sensitive data | Audit trail becomes breach | Log events, not data |
| Hardcoded API keys in code | Visible in git history | Environment variables + secrets manager |
| No CSP header | XSS attacks succeed | Strict CSP with nonces |
