---
name: devops-patterns
description: "Senior DevOps patterns reference. Covers CI/CD, containers, infrastructure as code, monitoring, deployment, security, and cloud architecture. Use when setting up pipelines, containerizing apps, designing infrastructure, or troubleshooting production."
---

# DevOps Patterns Reference

Patterns for building reliable, observable, secure infrastructure. Not theory — actionable patterns with when-to-use.

---

## CI/CD

### Pattern: Trunk-Based Development

**When:** Fast-moving teams, frequent releases.

```
main ← short-lived feature branches (merge daily)
       ↓
  CI runs on every push
       ↓
  Deploy to staging
       ↓
  Merge to main = deploy to production
```

**Rules:**
- Feature branches: live < 1 day. Long-lived branches = merge hell.
- Feature flags for incomplete features. Ship behind a flag, enable when ready.
- Every push to main triggers deployment. No manual steps.
- If CI breaks, it's P0. Fix immediately. Nobody pushes until green.

### Pattern: Pipeline as Code

**When:** Always. No manual pipeline configuration.

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test
      - run: npm run build
      - run: ./deploy.sh
```

**Rules:**
- Pipeline lives in the repo. Version controlled, reviewable, reproducible.
- Same pipeline for all environments. Different variables, same steps.
- Cache dependencies. Don't reinstall on every run.
- Fail fast: lint → test → build → deploy. Don't build if tests fail.

### Pattern: Deployment Strategies

| Strategy | Risk | Downtime | Speed | Use when |
|----------|------|----------|-------|----------|
| Recreate | High | Yes | Slow | Dev/staging only |
| Rolling | Medium | None | Medium | Default for most apps |
| Blue-Green | Low | None | Fast | Critical services |
| Canary | Low | None | Fast | High-traffic, risk-averse |
| Feature Flag | Lowest | None | Instant | Client-side features |

**Rules:**
- Rolling: replace instances one by one. Health check before proceeding.
- Blue-Green: two identical environments. Switch traffic atomically.
- Canary: deploy to 1% → 5% → 25% → 100%. Monitor at each step.
- Feature flag: deploy code dormant, enable remotely. Instant rollback = disable flag.

### Pattern: Rollback

**When:** Deployment fails or post-deploy issues detected.

**Rules:**
- Rollback is ALWAYS the first option. Fix-forward is dangerous.
- Automated rollback: health check fails → automatic rollback within 5 min.
- Database migrations: never rollback schema. Use expand/contract pattern.
- Rollback speed: < 1 minute. If it takes longer, your deployment is wrong.

---

## Containers

### Pattern: Single Process per Container

**When:** Always. One container = one process.

```
✅ nginx container → serves static files
✅ api container → runs Node.js app
✅ worker container → processes jobs

❌ nginx + api + worker in one container
```

**Rules:**
- One process per container. No supervisord, no "let me just add one more thing."
- Init process: use `tini` or `--init` flag for proper signal handling.
- PID 1: process must handle SIGTERM gracefully. Don't ignore shutdown.

### Pattern: Multi-Stage Build

**When:** Keeping production images small.

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/index.js"]
```

**Rules:**
- Build stage: install all deps, compile, build.
- Production stage: copy only compiled output + production deps.
- Never build in production image. Pre-build, copy artifacts.
- Final image: < 200MB. If bigger, you're doing it wrong.

### Pattern: Layer Optimization

**When:** Always. Faster builds = faster deploys.

```dockerfile
# Order: least changing to most changing
COPY package*.json .    # Changes rarely
RUN npm ci              # Cached if package.json unchanged
COPY . .                # Changes often
```

**Rules:**
- Order layers: deps first, code last. Cache invalidates top-down.
- .dockerignore: exclude node_modules, .git, tests, docs.
- Combine RUN commands: `RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*`
- No `apt-get upgrade` in images. Use updated base images instead.

### Pattern: Health Checks in Containers

**When:** Every production container.

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:3000/health/live || exit 1
```

**Rules:**
- Interval: 30s. Not too frequent (waste), not too slow (delay detection).
- Timeout: 3s. If health check takes longer, something's wrong.
- Retries: 3. Don't restart on first failure.
- Use /health/live for liveness, /health/ready for readiness.

---

## Infrastructure as Code

### Pattern: Immutable Infrastructure

**When:** Always. Never modify running infrastructure.

```
Change → Build new image → Deploy new instance → Destroy old instance
```

**Rules:**
- Never SSH into production. If you need to, your monitoring is broken.
- Changes = new deployment. Not "let me just tweak this config file."
- Servers are cattle, not pets. Replace, don't repair.

### Pattern: Terraform/Pulumi State Management

**When:** Managing cloud infrastructure.

**Rules:**
- State file: store in remote backend (S3, GCS, Terraform Cloud). Never local.
- State locking: use DynamoDB/GCS locking. Prevents concurrent applies.
- Workspace per environment: dev, staging, production. Not branches.
- Import existing resources: `terraform import` before modifying.
- Plan before apply: always review `terraform plan` output.

### Pattern: Drift Detection

**When:** Detecting manual changes to infrastructure.

**Rules:**
- Scheduled plan: run `terraform plan` daily, alert on differences.
- No manual changes allowed. If detected, revert or add to code.
- Tag everything: `env`, `team`, `purpose`, `cost-center`. Tags = organization.

---

## Monitoring & Observability

### Pattern: Three Pillars

| Pillar | What | Tools |
|--------|------|-------|
| **Logs** | What happened | ELK, Loki, CloudWatch |
| **Metrics** | How much/how fast | Prometheus, Grafana, Datadog |
| **Traces** | Where time was spent | Jaeger, Tempo, X-Ray |

**Rules:**
- All three. Not just logs. Not just metrics. All three.
- Correlate: traceId connects logs → metrics → traces for one request.
- Alert on symptoms, not causes. Alert on "error rate > 5%", not "pod restarted."

### Pattern: Alerting

**When:** Something needs human attention.

**Rules:**
- Alert on USER-FACING symptoms: error rate, latency, availability.
- Don't alert on: CPU usage (auto-scale handles this), pod restarts (expected).
- Severity levels: P1 (page, immediate), P2 (slack, within hour), P3 (email, next day).
- Alert fatigue: if you get 100 alerts/day, you ignore all of them. Fix noisy alerts.
- Runbook: every alert links to a runbook. What to check, how to fix.

### Pattern: Dashboards

**When:** At a glance health status.

```
Row 1: RED metrics (Rate, Errors, Duration) — one per service
Row 2: Resource usage (CPU, Memory, Disk)
Row 3: Business metrics (signups, orders, revenue)
Row 4: Infrastructure (pods, deployments, scaling events)
```

**Rules:**
- RED metrics first. If everything else is down, these tell the story.
- Time range: default to last 1h, zoomable to 24h/7d/30d.
- Annotations: mark deployments, incidents, config changes on timeline.
- Mobile-friendly: on-call needs to check from phone at 3am.

---

## Kubernetes

### Pattern: Deployment Best Practices

**When:** Running workloads on K8s.

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      containers:
      - name: api
        resources:
          requests: { cpu: 100m, memory: 128Mi }
          limits: { cpu: 500m, memory: 512Mi }
        livenessProbe: { httpGet: { path: /health/live, port: 3000 } }
        readinessProbe: { httpGet: { path: /health/ready, port: 3000 } }
```

**Rules:**
- Replicas: minimum 3 for production. One is zero redundancy.
- Rolling update: maxSurge=1, maxUnavailable=0. Zero downtime.
- Resource requests: based on actual usage, not worst-case.
- Resource limits: based on realistic peak. Kill if exceeded.
- Probes: liveness and readiness on every pod.

### Pattern: Autoscaling

**When:** Variable traffic.

**Rules:**
- HPA (Horizontal Pod Autoscaler): scale on CPU/memory. Target 70% CPU.
- Cluster Autoscaler: add/remove nodes based on pending pods.
- Scale down slowly (10 min cooldown). Scale up fast (30s).
- Don't scale on request count alone. Use custom metrics (queue depth, latency).

### Pattern: Secrets Management

**When:** Storing sensitive configuration.

**Rules:**
- Never in code, never in env vars committed to git.
- Kubernetes Secrets: base64-encoded (not encrypted). Use with external secrets operator.
- External secrets: AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager.
- Rotate secrets regularly. Automated rotation > manual.
- Least privilege: each service gets only the secrets it needs.

---

## Networking

### Pattern: Ingress Controller

**When:** Exposing services to the internet.

```
Internet → Load Balancer → Ingress Controller → Service → Pod
```

**Rules:**
- Single entry point: Ingress controller handles routing.
- TLS termination: at Ingress level. Cert-manager for automatic certificates.
- Rate limiting: at Ingress, not application level.
- Path-based routing: `/api` → API service, `/` → frontend service.

### Pattern: Service Mesh (When Needed)

**When:** Complex microservices with mTLS, observability, traffic management.

**Rules:**
- Start without service mesh. Add only when you need: mTLS, fine-grained traffic control, distributed tracing.
- Istio/Linkerd adds complexity. Don't add complexity you don't need.
- Use case: canary deployments, traffic splitting, mutual TLS between services.

---

## Security

### Pattern: Defense in Depth

**When:** Every layer.

```
Layer 1: Network (firewall, WAF)
Layer 2: Transport (TLS)
Layer 3: Application (auth, input validation)
Layer 4: Data (encryption at rest)
Layer 5: Monitoring (audit logs, alerts)
```

**Rules:**
- No single point of failure in security. If one layer fails, others catch it.
- Principle of least privilege everywhere. Default deny, explicit allow.
- Audit logging: who did what, when, from where. Immutable logs.

### Pattern: Supply Chain Security

**When:** Every dependency.

**Rules:**
- Lock files: package-lock.json, yarn.lock, go.sum. Commit and use them.
- Pin versions: `node:20.11-alpine` not `node:latest`.
- Audit: `npm audit`, `pip audit`, `trivy` for container scanning.
- SBOM: generate Software Bill of Materials. Know what's in your build.
- Signing: sign container images with cosign. Verify before deploy.

### Pattern: Secrets Scanning

**When:** Every commit, every PR.

**Rules:**
- Pre-commit hook: scan for secrets before commit.
- CI pipeline: scan for secrets on every PR.
- If leaked: rotate IMMEDIATELY. Don't "clean it up later."
- Tools: gitleaks, trufflehog, git-secrets.

---

## Disaster Recovery

### Pattern: Backup Strategy

**When:** Every critical data store.

**Rules:**
- 3-2-1 rule: 3 copies, 2 different media, 1 offsite.
- Automated backups: daily full, hourly incremental.
- Test restores regularly. Backup you can't restore is not a backup.
- RPO (Recovery Point Objective): how much data can you lose? Define it.
- RTO (Recovery Time Objective): how fast must you recover? Define it.

### Pattern: Incident Response

**When:** Production is down.

```
1. Detect → Alert fires
2. Triage → Assess severity, assign responder
3. Mitigate → Restore service (rollback, scale, failover)
4. Communicate → Status page, stakeholder updates
5. Resolve → Fix root cause
6. Review → Post-incident, add prevention
```

**Rules:**
- Incident commander: one person makes decisions. Not a committee.
- Communication: status page updated every 15 min during incident.
- Post-incident: blameless. Focus on systems, not people.
- Action items: every incident produces prevention measures.

---

## Anti-Patterns

| Anti-Pattern | Why it's bad | Do this instead |
|-------------|-------------|-----------------|
| Manual deployments | Human error, slow, unrepeatable | CI/CD pipeline |
| Pet servers | Can't replace, can't scale | Immutable infrastructure, cattle |
| Root SSH to production | Unauditable, dangerous | CI/CD, no manual access |
| Alert on everything | Alert fatigue, real alerts ignored | Alert on user-facing symptoms |
| Logs without structure | Unsearchable, unparseable | Structured JSON logs |
| Secrets in code/env vars | Leaked in git, visible to all | External secrets manager |
| No health checks | Can't detect failures | Liveness + readiness probes |
| Big bang deploys | High risk, hard to rollback | Canary, feature flags |
| No rollback plan | Stuck when deploy fails | Automated rollback |
| Ignoring security until launch | Expensive to fix later | Defense in depth from day 1 |
