---
name: liveops-observability
description: "LiveOps and observability patterns. Covers SLIs/SLOs/SLAs, distributed tracing, log aggregation, live debugging, incident response, runbooks, on-call practices, and production forensics. Use when debugging production issues, designing monitoring, or responding to incidents."
---

# LiveOps & Observability Reference

You can't fix what you can't see. These patterns make production visible, debuggable, and manageable.

---

## SLIs, SLOs, SLAs

### Pattern: Define What Matters

| Term | What | Example |
|------|------|---------|
| **SLI** (Indicator) | Measurable metric of service behavior | Request latency p99, error rate |
| **Objective** (SLO) | Target for SLI | p99 latency < 200ms, error rate < 0.1% |
| **Agreement** (SLA) | Contract with consequences | 99.9% uptime, credits if breached |

**Rules:**
- SLIs are USER-FACING. Not "CPU usage" — "requests served successfully."
- Pick 2-3 SLIs max per service. Not 20. Focus on what users feel.
- SLO = target. Not "we hope" — "we commit to."
- Error budget: 100% - SLO = how much failure is acceptable. Spend it wisely.

### Pattern: Error Budget

**When:** Balancing reliability vs velocity.

```
SLO: 99.9% uptime = 0.1% error budget = 43 minutes downtime/month
```

**Rules:**
- Budget remaining → ship fast, take risks.
- Budget exhausted → stop shipping, fix reliability first.
- Track burn rate: how fast are you spending the budget?
- Burn rate > 2x → alert. You'll exhaust budget in < 15 days.

---

## The Three Pillars — Deep Dive

### Pattern: Structured Logs

**When:** Every log line should answer: who, what, when, where, outcome.

```json
{
  "ts": "2025-01-15T10:30:00.123Z",
  "level": "error",
  "service": "payment",
  "traceId": "abc-123",
  "userId": "u_789",
  "action": "charge",
  "amount": 49.99,
  "currency": "USD",
  "result": "failed",
  "error": "card_declined",
  "duration_ms": 342
}
```

**Rules:**
- Every log line has: timestamp, level, service, traceId. Non-negotiable.
- Log the DECISION, not the object. "User rejected: insufficient_permissions" not "User: {...}".
- Levels: ERROR (human action needed), WARN (degraded), INFO (normal), DEBUG (dev only).
- NEVER log: passwords, tokens, PII, credit cards, health data.
- Correlation: traceId links logs across services for one request.

### Pattern: Metrics

**When:** Measuring service health over time.

**Four Golden Signals (Google SRE):**

| Signal | What | Why |
|--------|------|-----|
| **Latency** | Time to serve a request | Slow = bad experience |
| **Traffic** | Requests per second | Capacity planning |
| **Errors** | Error rate (% of requests) | Broken = bad |
| **Saturation** | How full is the resource | Near capacity = trouble |

**Rules:**
- Measure at the BOUNDARY, not inside. Latency of the full request, not just DB query.
- Percentiles, not averages. p50 (median), p95, p99. Average hides outliers.
- Counters vs gauges: counters only go up (requests total), gauges go up and down (connections).
- Labels: `service`, `endpoint`, `status_code`, `method`. Not `host` (dynamic).

### Pattern: Distributed Tracing

**When:** Following a request across multiple services.

```
API Gateway → auth-service → order-service → payment-service → notification-service
   [trace-123]
```

**Rules:**
- One traceId per request. Generated at the edge, propagated everywhere.
- Span = one unit of work (DB call, API call, computation).
- Context propagation: pass traceId via headers (`traceparent`, `X-Trace-Id`).
- Sample: 100% for errors, 1-10% for success. Don't trace everything (cost).
- Exports: send to Jaeger, Tempo, X-Ray for analysis.

---

## Live Debugging

### Pattern: Production Debugging Checklist

**When:** Production is broken, users are affected.

```
1. WHAT is failing?
   - Error messages, status codes, affected endpoints

2. WHEN did it start?
   - Check deployment timeline, config changes, dependency updates

3. WHERE is the failure?
   - Which service? Which endpoint? Which pod/instance?

4. WHO is affected?
   - All users? Specific region? Specific feature?

5. HOW BAD is it?
   - Total failure? Partial? Degraded? One endpoint?

6. ROOT CAUSE or SYMPTOM?
   - Is this the source, or is a dependency failing?
```

**Rules:**
- Start with symptoms, not assumptions. Don't guess — observe.
- Check recent changes first: deploy, config, dependency, traffic spike.
- Reproduce: can you trigger it in staging? In production (safe endpoint)?
- Blast radius: limit the damage. Feature flag off? Rollback? Scale up?

### Pattern: Feature Flag Triage

**When:** Something broke after a feature flag change.

**Rules:**
- Disable the flag first. Instant rollback. No deploy needed.
- If fix is fast (< 30 min): fix forward, re-enable.
- If fix is slow: rollback code, investigate offline.
- Post-mortem: why didn't staging catch this?

### Pattern: Log-Driven Debugging

**When:** Need to understand what happened.

```
1. Find the traceId from user report or error monitoring
2. Search logs: traceId:"abc-123"
3. Follow the request through all services
4. Find where it diverged from expected behavior
```

**Rules:**
- Always start with traceId. It's the thread that connects everything.
- If no traceId → your logging is broken. Fix that first.
- Time-box: 5 min to find the trace. If not found, escalate.
- Don't grep raw logs. Use structured log queries (Loki, CloudWatch Insights, Datadog).

---

## Incident Response

### Pattern: Incident Severity Levels

| Level | Impact | Response | Example |
|-------|--------|----------|---------|
| **SEV1** | Users cannot use the product | Page immediately, all hands | Complete outage, data loss |
| **SEV2** | Major feature broken, workaround exists | Page on-call, fix within 1h | Payment processing down |
| **SEV3** | Minor feature broken, no user impact | Slack alert, fix within 24h | Admin dashboard bug |
| **SEV4** | Cosmetic, low priority | Ticket, fix next sprint | UI glitch, typo |

**Rules:**
- SEV1/SEV2: incident commander assigned within 5 min.
- SEV3/SEV4: no page, handle during business hours.
- Severity based on USER IMPACT, not technical complexity.

### Pattern: Incident Commander

**When:** SEV1 or SEV2.

**Rules:**
- One person. Not a committee. Not a Slack thread with 20 people.
- Commander decides: who does what, when to escalate, when to communicate.
- Commander does NOT debug. They coordinate.
- Delegation: "You investigate service A, you check logs, you update status page."
- Handoff: if commander goes offline, designate successor before starting.

### Pattern: Status Page Communication

**When:** Users are affected.

**Rules:**
- Update within 15 min of declaring incident.
- Template:
  ```
  [Investigating] We're aware of issues with [service]. Investigating now.
  [Identified] Root cause identified: [brief description]. Working on fix.
  [Monitoring] Fix deployed. Monitoring for stability.
  [Resolved] Service fully restored. Post-mortem to follow.
  ```
- Be honest: "We don't know yet" is better than silence.
- Never blame users or third parties publicly.

### Pattern: War Room

**When:** SEV1, multiple people involved.

**Rules:**
- Dedicated channel: `#incident-YYYY-MM-DD-short-description`
- Commander speaks in channel. Others post findings.
- No side conversations. Everything in the channel.
- Time-stamp everything: "[10:32] Found the issue: DB connection pool exhausted"
- Record decisions: "[10:35] DECIDED: Rollback to v2.3.1"

---

## Runbooks

### Pattern: Alert → Runbook → Action

**When:** Every alert should link to a runbook.

```markdown
# Alert: High Error Rate (>5%)

## Symptoms
- Error rate > 5% for 5 minutes
- Users reporting failures on checkout

## Investigation
1. Check Grafana dashboard: service → errors panel
2. Find the failing endpoint: `kubectl logs -l service=api --tail=100 | grep ERROR`
3. Check recent deployments: `kubectl rollout history deployment/api`

## Common Causes
- Recent deploy introduced bug → rollback
- Database connection pool exhausted → restart pods
- Dependency down → check dependency health

## Resolution
- If deploy-related: rollback immediately
- If resource-related: scale up, investigate later
- If dependency: enable circuit breaker, notify dependency team

## Escalation
- If not resolved in 15 min → page platform team
- If data loss suspected → page database team immediately
```

**Rules:**
- Every alert has a runbook. No orphaned alerts.
- Runbook is step-by-step. Not "investigate" — "run this command."
- Updated after every incident. If runbook didn't help, fix it.
- Tested: new on-call should be able to follow runbook without prior knowledge.

---

## On-Call

### Pattern: Healthy On-Call

**When:** Someone is always available for production issues.

**Rules:**
- Rotation: 1 week. Not longer (burnout), not shorter (context loss).
- Handoff: 30-min overlap. Previous on-call briefs new on-call.
- Compensation: on-call pay for hours outside business days. Not free.
- Post-on-call: day off after a SEV1 night. Not "back to normal tomorrow."
- Escalation: on-call is first responder, not last resort. Escalate early.

### Pattern: Pager Hygiene

**When:** Reducing alert fatigue.

**Rules:**
- Every alert must be actionable. "CPU > 80%" → what do I do?
- Page only for: user-facing impact, data loss risk, security breach.
- Slack/email for: degraded but not broken, informational, trends.
- Review alerts monthly. If nobody acted on it, kill it.
- False positive rate < 5%. If higher, fix the alert, not the on-call.

---

## Production Forensics

### Pattern: Post-Incident Review (Blameless)

**When:** After every SEV1/SEV2.

**Rules:**
- Blameless: focus on systems, not people. "Why did the system allow this?" not "Who broke it?"
- Timeline: reconstruct what happened, when, in what order.
- Root cause: not "human error" — what system design allowed this to happen?
- Action items: specific, assigned, deadline. Not "improve monitoring" — "add alert for X by Friday."
- Publish: share with the team. Transparency builds trust.

### Pattern: Log Retention

**When:** Defining how long to keep logs.

| Log Type | Retention | Why |
|----------|-----------|-----|
| Application logs | 30 days | Debug recent issues |
| Audit logs | 1 year | Compliance, forensics |
| Access logs | 90 days | Security analysis |
| Debug/trace logs | 7 days | Development debugging |
| Error logs | 90 days | Trend analysis |

**Rules:**
- Compliance-driven: GDPR, SOC2, HIPAA may require longer retention.
- Cost-driven: logs are expensive. Archive old logs to cold storage.
- Query-driven: if you never query it, don't keep it hot.

### Pattern: Profiling in Production

**When:** Performance issues that can't be reproduced in staging.

**Rules:**
- Continuous profiling: always-on, low overhead (pprof, Datadog Profiler).
- Not in hot paths: profiling adds 1-3% overhead. Don't profile the profiler.
- Flame graphs: visualize where CPU time is spent.
- Memory profiling: find leaks before OOM kills the pod.

---

## Anti-Patterns

| Anti-Pattern | Why it's bad | Do this instead |
|-------------|-------------|-----------------|
| Logging everything at DEBUG | Noise, cost, slow | Log decisions, not data |
| Alerting on CPU/memory | Auto-scales, not actionable | Alert on user-facing symptoms |
| No runbooks for alerts | On-call guesses, wastes time | Every alert → linked runbook |
| Average latency | Hides p99 outliers | Percentiles (p50, p95, p99) |
| Blameless post-mortems in name only | Team doesn't trust the process | Truly blameless, focus on systems |
| No traceId correlation | Can't follow requests across services | Propagate traceId everywhere |
| Keeping all logs forever | Cost explosion | Tiered retention by log type |
| On-call without compensation | Burnout, turnover | Pay for on-call hours |
| Debugging without checking recent deploys | Wastes hours | Check deploy timeline first |
| Updating status page after incident | Users lose trust | Update during incident, honestly |
