---
name: compliance-patterns
description: GDPR, HIPAA, SOC2 compliance patterns. Use when implementing privacy, security compliance, or data protection.
---

# Compliance Patterns

## GDPR (General Data Protection Regulation)

### Consent Management

```typescript
interface Consent {
  userId: string;
  purpose: string;
  granted: boolean;
  timestamp: Date;
  ipAddress: string;
  version: string;
}

class ConsentManager {
  async recordConsent(consent: Omit<Consent, 'timestamp'>): Promise<void> {
    await db.consents.create({
      ...consent,
      timestamp: new Date(),
      version: CURRENT_CONSENT_VERSION,
    });
  }

  async hasConsent(userId: string, purpose: string): Promise<boolean> {
    const consent = await db.consents.findOne({
      userId,
      purpose,
      granted: true,
    });
    return !!consent;
  }

  async revokeConsent(userId: string, purpose: string): Promise<void> {
    await db.consents.updateMany(
      { userId, purpose },
      { granted: false, revokedAt: new Date() }
    );
  }
}
```

### Right to Erasure (Right to be Forgotten)

```typescript
class DataErasureService {
  async eraseUserData(userId: string): Promise<ErasureResult> {
    const result: ErasureResult = {
      userId,
      deletedAt: new Date(),
      deletedFrom: [],
    };

    // Delete from all tables
    const tables = ['users', 'profiles', 'orders', 'logs'];
    
    for (const table of tables) {
      const count = await db(table).where({ userId }).del();
      if (count > 0) {
        result.deletedFrom.push({ table, recordsDeleted: count });
      }
    }

    // Anonymize in analytics
    await db.analytics
      .where({ userId })
      .update({ userId: 'ANONYMIZED', email: null });

    // Log erasure for audit
    await this.logErasure(result);

    return result;
  }

  async logErasure(result: ErasureResult): Promise<void> {
    await db.auditLogs.create({
      action: 'DATA_ERASURE',
      userId: result.userId,
      details: result,
      timestamp: new Date(),
    });
  }
}
```

### Data Portability

```typescript
class DataPortabilityService {
  async exportUserData(userId: string): Promise<UserDataExport> {
    const user = await db.users.findById(userId);
    const orders = await db.orders.findByUserId(userId);
    const consents = await db.consents.findByUserId(userId);

    return {
      exportDate: new Date(),
      format: 'JSON',
      data: {
        personalInformation: {
          name: user.name,
          email: user.email,
          phone: user.phone,
        },
        orders: orders.map(o => ({
          id: o.id,
          date: o.createdAt,
          total: o.total,
          items: o.items,
        })),
        consents: consents.map(c => ({
          purpose: c.purpose,
          granted: c.granted,
          timestamp: c.timestamp,
        })),
      },
    };
  }

  async importUserData(userId: string, data: UserDataExport): Promise<void> {
    // Validate data structure
    this.validateImportData(data);

    // Import with transaction
    await db.transaction(async (trx) => {
      await trx('users').where({ id: userId }).update({
        name: data.data.personalInformation.name,
        phone: data.data.personalInformation.phone,
      });

      // Import orders if needed
      for (const order of data.data.orders) {
        await trx('orders').insert({
          userId,
          ...order,
        });
      }
    });
  }
}
```

## HIPAA (Health Insurance Portability and Accountability Act)

### PHI (Protected Health Information) Handling

```typescript
// Encryption at rest
class PHIEncryption {
  private algorithm = 'aes-256-gcm';
  
  async encrypt(plaintext: string): Promise<EncryptedData> {
    const iv = crypto.randomBytes(16);
    const key = await this.getKey();
    
    const cipher = crypto.createCipheriv(this.algorithm, key, iv);
    const encrypted = Buffer.concat([
      cipher.update(plaintext, 'utf8'),
      cipher.final(),
    ]);
    
    return {
      data: encrypted.toString('base64'),
      iv: iv.toString('base64'),
      tag: cipher.getAuthTag().toString('base64'),
    };
  }

  async decrypt(encrypted: EncryptedData): Promise<string> {
    const key = await this.getKey();
    const iv = Buffer.from(encrypted.iv, 'base64');
    const tag = Buffer.from(encrypted.tag, 'base64');
    const data = Buffer.from(encrypted.data, 'base64');
    
    const decipher = crypto.createDecipheriv(this.algorithm, key, iv);
    decipher.setAuthTag(tag);
    
    return Buffer.concat([
      decipher.update(data),
      decipher.final(),
    ]).toString('utf8');
  }
}

// Database field-level encryption
interface EncryptedPatientRecord {
  id: string;
  name: string; // Encrypted
  ssn: string; // Encrypted
  diagnosis: string; // Encrypted
  createdAt: Date;
}
```

### Audit Logs

```typescript
interface AuditLog {
  id: string;
  timestamp: Date;
  userId: string;
  action: string;
  resourceType: string;
  resourceId: string;
  ipAddress: string;
  userAgent: string;
  details: Record<string, any>;
  phiAccessed: boolean;
}

class AuditLogger {
  async logAccess(log: Omit<AuditLog, 'id' | 'timestamp'>): Promise<void> {
    await db.auditLogs.create({
      ...log,
      id: crypto.randomUUID(),
      timestamp: new Date(),
    });

    // Alert on suspicious activity
    if (this.isSuspicious(log)) {
      await this.alertSecurity(log);
    }
  }

  async getAuditTrail(
    resourceId: string,
    startDate: Date,
    endDate: Date
  ): Promise<AuditLog[]> {
    return db.auditLogs
      .where({ resourceId })
      .whereBetween('timestamp', [startDate, endDate])
      .orderBy('timestamp', 'desc');
  }

  private isSuspicious(log: Omit<AuditLog, 'id' | 'timestamp'>): boolean {
    // Large data access
    if (log.phiAccessed && log.action === 'EXPORT') return true;
    // After hours access
    const hour = new Date().getHours();
    if (hour < 6 || hour > 22) return true;
    return false;
  }
}
```

### Access Controls

```typescript
class HIPAAAccessControl {
  async checkAccess(
    userId: string,
    resourceId: string,
    action: string
  ): Promise<boolean> {
    const user = await db.users.findById(userId);
    
    // Role-based access
    const allowedRoles = this.getAllowedRoles(action);
    if (!allowedRoles.includes(user.role)) {
      await this.logAccessDenied(userId, resourceId, action);
      return false;
    }

    // Minimum necessary principle
    const hasMinimumAccess = await this.checkMinimumNecessary(
      userId,
      resourceId,
      action
    );
    
    if (!hasMinimumAccess) {
      await this.logAccessDenied(userId, resourceId, action);
      return false;
    }

    await this.logAccess(userId, resourceId, action);
    return true;
  }

  private getAllowedRoles(action: string): string[] {
    const roleMap: Record<string, string[]> = {
      'VIEW_PHI': ['doctor', 'nurse', 'admin'],
      'EDIT_PHI': ['doctor', 'nurse'],
      'EXPORT_PHI': ['admin'],
      'DELETE_PHI': ['admin'],
    };
    return roleMap[action] || [];
  }
}
```

## SOC2 (Service Organization Control 2)

### Access Controls

```typescript
class SOC2AccessControl {
  async provisionAccess(
    userId: string,
    permissions: string[]
  ): Promise<void> {
    // Principle of least privilege
    const currentPermissions = await this.getUserPermissions(userId);
    const newPermissions = this.calculateMinimalPermissions(
      currentPermissions,
      permissions
    );

    await db.userPermissions.create({
      userId,
      permissions: newPermissions,
      grantedAt: new Date(),
      grantedBy: getCurrentUserId(),
    });

    // Log access change
    await this.logAccessChange(userId, 'PROVISION', newPermissions);
  }

  async deprovisionAccess(userId: string): Promise<void> {
    // Immediate access revocation
    await db.userPermissions.deleteMany({ userId });
    
    // Revoke active sessions
    await db.sessions.deleteMany({ userId });
    
    // Log deprovisioning
    await this.logAccessChange(userId, 'DEPROVISION', []);
  }

  async reviewAccess(): Promise<AccessReviewResult> {
    const users = await db.users.findActive();
    const reviews: AccessReviewItem[] = [];

    for (const user of users) {
      const permissions = await this.getUserPermissions(user.id);
      const lastAccess = await this.getLastAccess(user.id);
      
      reviews.push({
        userId: user.id,
        permissions,
        lastAccess,
        recommendedAction: this.recommendAction(permissions, lastAccess),
      });
    }

    return {
      reviewedAt: new Date(),
      totalUsers: users.length,
      reviews,
      actionItems: reviews.filter(r => r.recommendedAction !== 'NONE'),
    };
  }
}
```

### Monitoring & Alerting

```typescript
class SOC2Monitoring {
  async monitorSecurityEvents(): Promise<void> {
    // Failed login attempts
    const failedLogins = await db.auditLogs
      .where({ action: 'LOGIN_FAILED' })
      .where('timestamp', '>', new Date(Date.now() - 15 * 60 * 1000))
      .groupBy('userId')
      .having('COUNT(*)', '>=', 5);

    if (failedLogins.length > 0) {
      await this.alert('BRUTE_FORCE_ATTEMPT', failedLogins);
    }

    // Unusual data access patterns
    const unusualAccess = await this.detectAnomalousAccess();
    if (unusualAccess.length > 0) {
      await this.alert('UNUSUAL_ACCESS_PATTERN', unusualAccess);
    }
  }

  async generateComplianceReport(): Promise<ComplianceReport> {
    return {
      period: {
        start: this.getPeriodStart(),
        end: new Date(),
      },
      accessControls: await this.reviewAccess(),
      securityIncidents: await this.getSecurityIncidents(),
      auditLogIntegrity: await this.verifyAuditLogIntegrity(),
      dataEncryption: await this.verifyEncryptionStatus(),
      backupRecovery: await this.verifyBackupStatus(),
    };
  }
}
```

### Data Classification

```typescript
enum DataClassification {
  PUBLIC = 'PUBLIC',
  INTERNAL = 'INTERNAL',
  CONFIDENTIAL = 'CONFIDENTIAL',
  RESTRICTED = 'RESTRICTED', // PHI, PII
}

interface DataClassificationPolicy {
  classification: DataClassification;
  encryptionRequired: boolean;
  accessLogging: boolean;
  retentionDays: number;
  backupRequired: boolean;
}

const classificationPolicies: Record<DataClassification, DataClassificationPolicy> = {
  [DataClassification.PUBLIC]: {
    classification: DataClassification.PUBLIC,
    encryptionRequired: false,
    accessLogging: false,
    retentionDays: 365,
    backupRequired: false,
  },
  [DataClassification.RESTRICTED]: {
    classification: DataClassification.RESTRICTED,
    encryptionRequired: true,
    accessLogging: true,
    retentionDays: 2555, // 7 years for HIPAA
    backupRequired: true,
  },
};
```

## Privacy by Design

```typescript
// Data minimization
class DataMinimizer {
  minimize<T>(data: T, fields: (keyof T)[]): Pick<T, keyof T> {
    const minimized = {} as Pick<T, keyof T>;
    for (const field of fields) {
      if (data[field] !== undefined) {
        minimized[field] = data[field];
      }
    }
    return minimized;
  }
}

// Purpose limitation
class PurposeLimiter {
  async collectData(
    data: any,
    purpose: string,
    userId: string
  ): Promise<void> {
    // Verify purpose is valid
    if (!this.isValidPurpose(purpose)) {
      throw new Error(`Invalid purpose: ${purpose}`);
    }

    // Record purpose
    await db.dataCollection.create({
      userId,
      purpose,
      data: this.sanitize(data),
      collectedAt: new Date(),
    });
  }

  async useData(
    userId: string,
    requestedPurpose: string
  ): Promise<any> {
    // Verify data was collected for this purpose
    const records = await db.dataCollection.find({
      userId,
      purpose: requestedPurpose,
    });

    if (records.length === 0) {
      throw new Error(`No data collected for purpose: ${requestedPurpose}`);
    }

    return records;
  }
}
```
