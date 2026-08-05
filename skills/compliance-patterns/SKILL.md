---
name: compliance-patterns
description: GDPR, HIPAA, SOC2 compliance patterns. Use when implementing privacy, security compliance, or data protection.
---

# Compliance Patterns

## When To Use This

- Designing systems that handle personal data (PII) or health data (PHI)
- Implementing GDPR rights (consent, erasure, portability)
- Applying HIPAA controls (encryption, audit, access)
- Building toward SOC2 (access control, monitoring, retention)
- Choosing what data to collect, store, and for how long

> **Scope note:** these are engineering patterns, not legal advice. Always confirm exact requirements with legal/compliance on your jurisdiction, contracts, and data volume. When in doubt, the strictest applicable rule wins.

## Framework Comparison — Who Requires What

| Control | GDPR | HIPAA | SOC2 |
|---------|------|-------|------|
| Consent / lawful basis | **Core** | Consent for marketing; treatment doesn't need it | Not required |
| Data subject rights (access, erasure, portability) | **Core** (Art. 15–20) | Right of access/inspection | Not required |
| Encryption at rest & in transit | Required where appropriate | **Required for PHI** | Required (CC6.x) |
| Access control / least privilege | Required | Required (minimum necessary) | Required (CC6) |
| Audit logging of access | Records of processing | **Required** for PHI access | Required (CC7) |
| Data retention limits | Required | 6 years typical (varies) | Contract-defined |
| Breach notification | 72h (Art. 33) | 60 days (varies) | Contract-defined |
| Vendor/subprocessor management | Required (DPA) | Required (BAAs) | Required (CC9) |

## GDPR Patterns

### The Six Principles → Engineering Translation

| Principle | Engineering practice |
|-----------|----------------------|
| Lawfulness, fairness, transparency | Privacy notice per purpose; consent records |
| Purpose limitation | Bind every collection to a purpose (see PurposeLimiter) |
| Data minimization | Collect only fields needed for the purpose |
| Accuracy | Allow correction; record rectification requests |
| Storage limitation | Retention policies + deletion jobs |
| Integrity & confidentiality | Encryption at rest/in transit, access control |

### Consent Management

```typescript
interface Consent {
  userId: string;
  purpose: string;           // e.g. 'marketing', 'analytics', 'personalization'
  granted: boolean;
  timestamp: Date;
  ipAddress: string;
  version: string;           // version of the consent text agreed to
}

class ConsentManager {
  async recordConsent(c: Omit<Consent, 'timestamp'>): Promise<void> {
    await db.consents.create({ ...c, timestamp: new Date(), version: CURRENT_VERSION });
  }
  async hasConsent(userId: string, purpose: string): Promise<boolean> {
    const c = await db.consents.findOne({ userId, purpose, granted: true });
    return !!c;
  }
  async revokeConsent(userId: string, purpose: string): Promise<void> {
    // revoke is a NEW record (append-only) — never overwrite history
    await db.consents.create({ userId, purpose, granted: false, timestamp: new Date(), version: CURRENT_VERSION });
  }
}
```

Rules:
- **Consent = documented, verifiable event** — record *when, what version, from which IP*. If you can't prove consent, you don't have it.
- Consent must be **as easy to withdraw as to give**; one-click revocation.
- Consent is **purpose-scoped and versioned** — a text change requires re-consent.
- Never pre-ticked boxes; no bundled "accept everything" without granular purposes.
- **Children** require verifiable parental consent (age varies by jurisdiction) — gate accordingly.

### Right to Erasure (Art. 17)

```typescript
class DataErasureService {
  async eraseUserData(userId: string): Promise<ErasureResult> {
    const result = { userId, deletedAt: new Date(), deletedFrom: [] as { table: string; recordsDeleted: number }[] };
    for (const table of ['users', 'profiles', 'orders', 'consents']) {
      const count = await db(table).where({ userId }).del();
      if (count > 0) result.deletedFrom.push({ table, recordsDeleted: count });
    }
    // Anonymize where deletion would break the system (analytics aggregates)
    await db.analytics.where({ userId }).update({ userId: 'ANONYMIZED', email: null });
    // The erasure itself becomes an audit record
    await db.auditLogs.create({ action: 'DATA_ERASURE', userId, details: result, timestamp: new Date() });
    return result;
  }
}
```

Rules:
- **Delete or anonymize; never partial-delete + leave email** — a pseudonymous token is still personal data if it can re-identify.
- **Erasure ≠ deletion of legal/financial records** you're required to keep (invoices, tax) — those are exempt; keep the minimum, note the legal basis.
- Scrub **backups and logs** on a schedule; a GDPR delete that survives in a 30-day backup is still a violation when read.
- Document exemptions applied (a "refusal" log for retained records).

### Right to Portability (Art. 20)

```typescript
class DataPortabilityService {
  async exportUserData(userId: string): Promise<UserDataExport> {
    return {
      exportDate: new Date(),
      format: 'json',            // machine-readable, common format
      data: {
        personalInformation: { name, email, phone },
        orders: [...],           // data the user PROVIDED, not derived analytics
        consents: [...],
      },
    };
  }
  // Import validates structure before writing, inside a transaction
  async importUserData(userId: string, data: UserDataExport): Promise<void> { /* validate → transact → write */ }
}
```

Rules: portable data = **user-provided + observed behavioral** data, in a structured, machine-readable format (JSON/CSV). Export must be available on request (typically within a month); provide a direct download endpoint, not email-only.

### Records of Processing (Art. 30)

Keep a living register: what data you process, purpose, categories, recipients, retention, transfer basis, security measures. The register itself is an engineering artifact — a config-driven table (`purpose → fields → retention → storage`), not a Word doc. See the retention table below.

## HIPAA Patterns

### PHI Handling Fundamentals

| Control | Requirement |
|---------|-------------|
| Identify PHI | Any health info + identifiers (name, SSN, DOB, medical record #, etc.) that can identify the patient |
| Encryption in transit | TLS 1.2+ everywhere PHI travels |
| Encryption at rest | AES-256 (or NIST-approved) for stored PHI |
| Minimum necessary | Access only the PHI needed for the task |
| Audit | Log every create/read/update/delete of PHI with who/when/what |
| BAAs | Business Associate Agreements with every vendor touching PHI |
| Breach | Notify per applicable law (e.g., 60 days in the US) |

### Field-Level Encryption at Rest

```typescript
class PHIEncryption {
  private algorithm = 'aes-256-gcm';

  async encrypt(plaintext: string): Promise<EncryptedData> {
    const iv = crypto.randomBytes(16);
    const key = await this.getKey();                       // from KMS, not source code
    const cipher = crypto.createCipheriv(this.algorithm, key, iv);
    const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
    return { data: encrypted.toString('base64'), iv: iv.toString('base64'), tag: cipher.getAuthTag().toString('base64') };
  }
}
```

- Encrypt sensitive columns (SSN, diagnosis, name) with **AEAD** (AES-GCM includes auth tag). Never ECB, never hardcoded IVs.
- **Keys live in a KMS / HSM with rotation**, never in source or env committed to git. Store the key *version* with the ciphertext so rotation stays decryptable.
- If you use a managed DB, prefer **transparent DB encryption + field-level for the most sensitive columns** — the trade-off is queryability vs security.

### Audit Logging of PHI Access

```typescript
interface AuditLog {
  id: string; timestamp: Date; userId: string;
  action: string;              // VIEW / EDIT / EXPORT / DELETE
  resourceType: string; resourceId: string;
  ipAddress: string; userAgent: string;
  phiAccessed: boolean;        // flags that this touched PHI
  details: Record<string, unknown>;
}

class AuditLogger {
  async logAccess(log: Omit<AuditLog, 'id' | 'timestamp'>): Promise<void> {
    await db.auditLogs.create({ ...log, id: crypto.randomUUID(), timestamp: new Date() });
    if (this.isSuspicious(log)) await this.alertSecurity(log);
  }
  private isSuspicious(log) {
    if (log.phiAccessed && log.action === 'EXPORT') return true;      // bulk export = red flag
    const h = new Date().getHours();
    if (h < 6 || h > 22 && log.phiAccessed) return true;              // off-hours access
    return false;
  }
}
```

Rules: audit logs are **append-only** (write once, no update/delete paths); log **failed attempts** too (denials are audit events); retain per policy (HIPAA commonly ≥ 6 years); alert on suspicious patterns, don't just store them.

### Access Control — Role + Minimum Necessary

```typescript
class HIPAAAccessControl {
  async checkAccess(userId: string, resourceId: string, action: string): Promise<boolean> {
    const user = await db.users.findById(userId);
    const allowedRoles = this.getAllowedRoles(action);        // role mapping
    if (!allowedRoles.includes(user.role)) { await this.logDenied(userId, resourceId, action); return false; }
    if (!(await this.checkMinimumNecessary(userId, resourceId, action))) {
      await this.logDenied(userId, resourceId, action); return false;
    }
    await this.logAccess({ userId, action, resourceType: 'PHI', resourceId, phiAccessed: true });
    return true;
  }
}
```

Rules: deny-by-default (empty allowed list = no access); **log every denial**; emergency access path must exist and be logged + reviewed; revoke immediately on termination (see SOC2 deprovisioning).

## SOC2 Patterns

### Trust Services Criteria → What to Build

| TSC area | Key controls to implement |
|----------|---------------------------|
| CC6 (Logical & physical access) | Provisioning, least privilege, review, offboarding |
| CC7 (System operations) | Monitoring, alerting, anomaly detection, incident response |
| CC8 (Change management) | Deploy pipelines, peer review, separation of duties |
| CC9 (Risk mitigation) | Vendor management, subprocessor inventory |
| A1/C1 (Availability & confidentiality) | Backups, redundancy, encryption |

### Access Control — Lifecycle

```typescript
class SOC2AccessControl {
  // Provision: least privilege, with approver trail
  async provisionAccess(userId: string, requested: string[]): Promise<void> {
    const current = await this.getUserPermissions(userId);
    const granted = this.intersectionMinimal(current, requested);   // no privilege creep
    await db.userPermissions.create({ userId, permissions: granted, grantedAt: new Date(), grantedBy: getCurrentUserId() });
    await this.logAccessChange(userId, 'PROVISION', granted);
  }

  // Deprovision: IMMEDIATE on termination — sessions too
  async deprovisionAccess(userId: string): Promise<void> {
    await db.userPermissions.deleteMany({ userId });
    await db.sessions.deleteMany({ userId });        // kill active sessions now
    await this.logAccessChange(userId, 'DEPROVISION', []);
  }

  // Review: recurring recertification (quarterly/annually)
  async reviewAccess(): Promise<AccessReviewResult> { /* flag unused/over-privileged */ }
}
```

Rules:
- **Least privilege** enforced at grant time; **recertification** is periodic, documented, and acted on.
- Deprovisioning is a hard, immediate, idempotent operation covering permissions **and sessions and API keys**.
- Every grant/deny/revoke is logged with who authorized it.

### Monitoring & Alerting

```typescript
class SOC2Monitoring {
  async monitorSecurityEvents(): Promise<void> {
    // Brute force: 5+ failed logins in 15 min
    const failures = await db.auditLogs
      .where({ action: 'LOGIN_FAILED' })
      .where('timestamp', '>', new Date(Date.now() - 15 * 60 * 1000))
      .groupBy('userId').having('COUNT(*)', '>=', 5);
    if (failures.length) await this.alert('BRUTE_FORCE_ATTEMPT', failures);

    // Anomalous bulk/export access
    const anomalies = await this.detectAnomalousAccess();
    if (anomalies.length) await this.alert('UNUSUAL_ACCESS_PATTERN', anomalies);
  }
}
```

What to monitor: failed logins, privilege escalations, bulk exports, off-hours access, new API keys, admin actions, and PHI access. **Integrity:** store logs in a way that can't be silently tampered with (WORM, external SIEM, hash-chaining) — auditors test log integrity.

### Data Classification → Policy-Driven Handling

```typescript
enum DataClassification { PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED }  // RESTRICTED = PHI, PII

interface ClassificationPolicy {
  classification: DataClassification;
  encryptionRequired: boolean;
  accessLogging: boolean;
  retentionDays: number;
  backupRequired: boolean;
}

const policies: Record<DataClassification, ClassificationPolicy> = {
  PUBLIC:      { classification: DataClassification.PUBLIC,      encryptionRequired: false, accessLogging: false, retentionDays: 365,  backupRequired: false },
  INTERNAL:    { classification: DataClassification.INTERNAL,    encryptionRequired: false, accessLogging: false, retentionDays: 730,  backupRequired: true  },
  CONFIDENTIAL:{ classification: DataClassification.CONFIDENTIAL,encryptionRequired: true,  accessLogging: true,  retentionDays: 1095, backupRequired: true  },
  RESTRICTED:  { classification: DataClassification.RESTRICTED,  encryptionRequired: true,  accessLogging: true,  retentionDays: 2555, backupRequired: true  }, // 7y HIPAA
};
```

Classify on ingest, tag everything with its class, and drive encryption/retention/backup policy from the tag — not from scattered per-table code.

## Privacy by Design (and Default)

### The Seven Principles → Practices

| Principle | Practice |
|-----------|----------|
| Proactive, not reactive | Privacy impact assessment (PIA) before building features |
| Privacy as default | Opt-in by default; least data by default; private settings |
| Embedded into design | Data minimization + purpose binding at the data layer |
| Full functionality (no trade-off) | Security controls don't block usability |
| End-to-end security | Encryption at rest/in transit, access control, audits |
| Visibility & transparency | Privacy notice reflects actual practice; consent is auditable |
| Respect for user privacy | Erasure/portability endpoints actually work |

### Data Minimization + Purpose Limitation

```typescript
class DataMinimizer {
  // Only keep fields the purpose requires
  minimize<T>(data: T, fields: (keyof T)[]): Pick<T, keyof T> {
    const out = {} as Pick<T, keyof T>;
    for (const f of fields) if (data[f] !== undefined) out[f] = data[f];
    return out;
  }
}

class PurposeLimiter {
  async collectData(data: any, purpose: string, userId: string): Promise<void> {
    if (!this.isValidPurpose(purpose)) throw new Error(`Invalid purpose: ${purpose}`);
    await db.dataCollection.create({ userId, purpose, data: this.sanitize(data), collectedAt: new Date() });
  }
  async useData(userId: string, requestedPurpose: string): Promise<any> {
    const records = await db.dataCollection.find({ userId, purpose: requestedPurpose });
    if (!records.length) throw new Error(`No data collected for purpose: ${requestedPurpose}`);
    return records;
  }
}
```

- Every data field maps to exactly one declared purpose; using data for a new purpose requires a **new** lawful basis/consent.
- Sanitize on **write** (strip XSS/scripts, trim, validate types), not on read.

## Data Retention

### Retention Decision Table (defaults — confirm with legal)

| Data | Reasonable default | Rationale |
|------|--------------------|-----------|
| Active accounts | While account active + grace | Needed for service |
| Deleted-account personal data | Delete promptly (or per policy) | GDPR erasure |
| Financial/legal records | 6–10 years (statute) | Legal obligation — exempt from erasure |
| Health records (HIPAA) | 6 years+ (state law varies) | Regulatory |
| Security/audit logs | 90 days–2 years | Incident investigation |
| Analytics (anonymized) | Indefinite if truly anonymous | Not personal data |
| Backup snapshots | Matches source retention | Otherwise erasure fails |

Implementation: store `retentionDays` per classification (table above), run a **scheduled deletion job**, and make it verifiable (logs of deletions). Retention limits are enforceable by the same scheduler that enforces erasure.

## Common Pitfalls / Anti-Patterns

| Pitfall | Why it hurts | Fix |
|---------|-------------|-----|
| Consent stored as a bool flag with no timestamp/version/IP | Unprovable consent | Append-only consent event records |
| Erasure that skips backups/logs/aggregates | Data survives deletion | Retention/erasure job covers all copies |
| Hardcoded encryption keys in source | Key leak = total PHI compromise | KMS + rotation + key version in ciphertext |
| Audit logs with update/delete paths | Tamperable evidence | Append-only, integrity-checked logs |
| Shared credentials / no per-user access | Unauditable, violates minimum necessary | Per-user identity on every PHI access |
| Deprovisioning that only removes a permission row | Ex-users keep live sessions/keys | Kill sessions + keys atomically |
| Collecting everything "just in case" | Maximization = GDPR violation | Minimize at ingest; map field→purpose |
| No retention limits | Data hoarding = storage limitation breach | Classification-driven retention jobs |
| Adding a vendor without BAA/DPA | Subprocessor liability | Vendor inventory + agreements before integration |
| Logging PII/PHI into generic logs | Data at rest outside control | Redact secrets/PII at the log boundary |

## Best Practices Checklist

- [ ] Every data field mapped to a declared purpose + lawful basis
- [ ] Consent recorded as auditable events (who, when, version, IP)
- [ ] Erasure + portability endpoints working, tested, and covering backups/logs
- [ ] PHI encrypted at rest (AEAD) and in transit (TLS), keys in KMS with rotation
- [ ] Append-only audit logs for all sensitive access, including denials
- [ ] Role-based + minimum-necessary access control; off-hours/bulk alerts
- [ ] Least-privilege provisioning; immediate full deprovisioning on termination
- [ ] Access reviews recertified on a documented schedule
- [ ] Data classified at ingest; encryption/retention/backup driven by class
- [ ] Retention + deletion jobs run on schedule with evidence
- [ ] Subprocessor inventory with BAA/DPA for every vendor
- [ ] Privacy impact assessment before building new personal-data features
