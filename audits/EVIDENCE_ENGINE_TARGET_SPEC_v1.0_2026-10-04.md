# TEC Evidence Engine — Target Implementation Specification v1.0

**Stored:** 2026-10-04 (Session 56s) — the owner's document, kept here as written (§0–§27 below)
**Truth State:** [Future Vision] · **Governance State:** [Draft] — a target, deferred by decision
**Verification:** [Documentation Verified] — none of it exists in code (checked 2026-10-04, all 28 repos, every branch)

> **Read first.** This is a design to build *towards*, not a description of anything built.
> `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` holds the decision it sits under:
> **campaign funnel first, then a one-mission Round 3 MVP, and this Engine only when real data
> asks for it.** Its own Step 0 says the same: "Confirm research decision / campaign requirements."

## Adopting it on this platform — three adjustments (2026-10-04)

The spec is sound on its rules: Observed apart from Declared; a declaration alone never yields
VERIFIED; friction never turns into a Pioneer score; foreign lineage fails rather than being
filtered; Analytics reads snapshots only. Three things in it must change before any build.

1. **Where it lives.**
   - §2 proposes `apps/evidence-api` plus five new `packages/evidence-*`. In effect that is a
     **new service**, and Phase 0 forbids one (tec-core-backend CLAUDE.md: "Do NOT add new
     services during Phase 0").
   - Build it as an **`evidence` module inside `tec-identity-service`**, which already owns the
     campaign and the Pioneer runtime.
   - Its schema goes in that service's `schema.prisma`, applied by `scripts/migrate.cjs`
     (`db push`, bounded).
   - Shared contracts move to `@yasser172/tec-sdk` only when a second app needs them.
2. **Where its events start.**
   - `CampaignEvent` (tec-core-backend #366: VIEWED · QUALIFIED · STOP_REASON) already holds
     the funnel and the declared stop reasons, keyed owner · round · type.
   - A first Engine slice reads from it, and its `STOP_REASON` row is the first Declared
     evidence. It does not start from an empty store.
3. **When it starts — the trigger the spec does not set.**
   - Build it when the funnel produces a question that only Observed-vs-Declared evidence can
     answer.
   - Example: pioneers *say* (a) "too long" — did they actually spend long, or leave early?
   - Until then, Steps 1–14 stay unbuilt.

Identity on this platform is the verified token's Pi username (campaign `owner`) or `sub`.
Where §6–§9 say `piUserId`, read that. It is never a client field.

---
## 0. Important implementation status

This document is a complete target implementation blueprint. The reviewed KB did not contain the full Engine implementation. The Master Specification defines the architecture and contracts, but its SEALED/RUNTIME VERIFIED labels must not be interpreted as proof that the code exists. The implementation below is therefore a build specification and reference implementation skeleton, not a report of already-deployed code.


## 1. Final architecture


```text
Pioneer / Research Client
        |
        v
Assignment Engine
        |
        v
Test Session
        |
        v
Immutable TaskEvent Store
        |
        +--------------------+
        v                    v
Observed Evidence       Declared Evidence
        |                    |
        +---------+----------+
                  v
        Deterministic Reconciliation
                  |
                  v
           Derived Evidence
                  |
                  +----------------+
                  v                v
          Verification       Friction Detector
                  |                |
                  +-------+--------+
                          v
                ProductEvidenceRecord
                          |
                          v
             Immutable ProductEvidenceSnapshot
                          |
                          v
                      Analytics
                          |
                          v
                       TEC AI
```


## 2. Repository target


```text
apps/
  evidence-api/

packages/
  evidence-contracts/
  evidence-core/
  evidence-prisma/
  evidence-analytics/
  evidence-sdk/

prisma/
  schema.prisma

tests/
  integration/
  concurrency/
  replay/
  determinism/
  analytics/
```


## 3. Package boundaries

- @tec/evidence-contracts — DTOs, enums, domain interfaces. No Prisma dependency.
- @tec/evidence-core — assignment, lifecycle, ingestion, mapping, reconciliation, friction, aggregation, fingerprinting and replay.
- @tec/evidence-prisma — repositories and persistence adapters only.
- @tec/evidence-analytics — snapshot-only analytics.
- @tec/evidence-sdk — thin client wrapper for event/session/report submission.
- apps/evidence-api — NestJS transport/API boundary.

## 4. Canonical domain enums


```typescript
export enum SessionStatus {
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  ABORTED = 'ABORTED',
  EXPIRED = 'EXPIRED',
  FLAGGED = 'FLAGGED',
}

export enum TelemetryEventType {
  TASK_STARTED = 'TASK_STARTED',
  TASK_STEP_COMPLETED = 'TASK_STEP_COMPLETED',
  TASK_SUBMITTED = 'TASK_SUBMITTED',
  TASK_FAILED = 'TASK_FAILED',
  VIEW_RENDERED = 'VIEW_RENDERED',
  ACTION_EXECUTED = 'ACTION_EXECUTED',
  EVIDENCE_ATTACHED = 'EVIDENCE_ATTACHED',
}

export enum EvidenceSource {
  OBSERVED = 'OBSERVED',
  DECLARED = 'DECLARED',
  DERIVED = 'DERIVED',
}

export enum EvidenceStatus {
  VERIFIED = 'VERIFIED',
  PARTIAL = 'PARTIAL',
  INSUFFICIENT = 'INSUFFICIENT',
  CONTRADICTORY = 'CONTRADICTORY',
  UNKNOWN = 'UNKNOWN',
}

export enum VerificationResult {
  VERIFIED = 'VERIFIED',
  PARTIAL = 'PARTIAL',
  INSUFFICIENT_EVIDENCE = 'INSUFFICIENT_EVIDENCE',
  CONTRADICTORY = 'CONTRADICTORY',
}

export enum ConfidenceLevel {
  HIGH = 'HIGH',
  MEDIUM = 'MEDIUM',
  LOW = 'LOW',
  NONE = 'NONE',
}

export enum FrictionSignalType {
  EXCESSIVE_DURATION = 'EXCESSIVE_DURATION',
  RETRY_SPIKE = 'RETRY_SPIKE',
  BACKTRACKING = 'BACKTRACKING',
  FAILURE_RECOVERY = 'FAILURE_RECOVERY',
  REPEATED_ACTION = 'REPEATED_ACTION',
  ABANDONMENT = 'ABANDONMENT',
  DECLARED_FRICTION = 'DECLARED_FRICTION',
}

export enum FrictionSeverity {
  NONE = 'NONE',
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
}

export enum FrictionClassification {
  NORMAL = 'NORMAL',
  DECLARED_ONLY_FRICTION = 'DECLARED_ONLY_FRICTION',
  OBSERVED_FRICTION = 'OBSERVED_FRICTION',
  CONFIRMED_FRICTION = 'CONFIRMED_FRICTION',
  FRICTION_ANOMALY = 'FRICTION_ANOMALY',
}
```


## 5. Prisma schema


```prisma
enum SessionStatus {
  IN_PROGRESS
  COMPLETED
  ABORTED
  EXPIRED
  FLAGGED
}

enum TelemetryEventType {
  TASK_STARTED
  TASK_STEP_COMPLETED
  TASK_SUBMITTED
  TASK_FAILED
  VIEW_RENDERED
  ACTION_EXECUTED
  EVIDENCE_ATTACHED
}

enum EvidenceSource {
  OBSERVED
  DECLARED
  DERIVED
}

enum EvidenceStatus {
  VERIFIED
  PARTIAL
  INSUFFICIENT
  CONTRADICTORY
  UNKNOWN
}

enum VerificationResult {
  VERIFIED
  PARTIAL
  INSUFFICIENT_EVIDENCE
  CONTRADICTORY
}

enum ConfidenceLevel {
  HIGH
  MEDIUM
  LOW
  NONE
}

enum FrictionSignalType {
  EXCESSIVE_DURATION
  RETRY_SPIKE
  BACKTRACKING
  FAILURE_RECOVERY
  REPEATED_ACTION
  ABANDONMENT
  DECLARED_FRICTION
}

enum FrictionSeverity {
  NONE
  LOW
  MEDIUM
  HIGH
}

enum FrictionClassification {
  NORMAL
  DECLARED_ONLY_FRICTION
  OBSERVED_FRICTION
  CONFIRMED_FRICTION
  FRICTION_ANOMALY
}

model TaskDefinition {
  id              String   @id @default(uuid())
  taskCatalogId   String
  version         Int
  active          Boolean  @default(true)
  repeatable      Boolean  @default(false)
  targetCoverage  Int
  weight          Int
  requirements    Json
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  assignedTasks   AssignedTask[]
  @@unique([taskCatalogId, version])
  @@index([active])
}

model TestSession {
  id               String        @id @default(uuid())
  piUserId         String
  status            SessionStatus @default(IN_PROGRESS)
  deviceAppVersion String
  platform         String?
  nextEventSequence Int           @default(0)
  createdAt        DateTime       @default(now())
  updatedAt        DateTime       @updatedAt
  events           TaskEvent[]
  assignedTasks    AssignedTask[]
  @@index([piUserId, status])
}

model AssignedTask {
  id            String   @id @default(uuid())
  sessionId     String
  taskCatalogId String
  taskVersion   Int
  status        String
  assignedAt    DateTime @default(now())
  startedAt     DateTime?
  completedAt   DateTime?
  session       TestSession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  task          TaskDefinition @relation(fields: [taskCatalogId, taskVersion], references: [taskCatalogId, version])
  @@index([sessionId, status])
}

model TaskEvent {
  id               String             @id @default(uuid())
  sessionId        String
  clientEventId    String
  taskCatalogId    String
  taskVersion      Int
  eventType        TelemetryEventType
  clientTimestamp  DateTime
  clientSequence   Int
  serverSequence   Int
  payload          Json
  eventFingerprint String
  schemaVersion    String
  serverReceivedAt DateTime           @default(now())
  createdAt        DateTime           @default(now())
  session          TestSession        @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  observedEvidence ObservedEvidenceRecord?
  @@unique([sessionId, clientEventId])
  @@unique([sessionId, serverSequence])
  @@index([sessionId, taskCatalogId, taskVersion])
}

model ObservedEvidenceRecord {
  id             String         @id @default(uuid())
  sessionId      String
  taskId         String
  source         EvidenceSource @default(OBSERVED)
  type           String
  eventId        String         @unique
  serverSequence Int
  observedAt     DateTime
  status         EvidenceStatus @default(UNKNOWN)
  facts          Json
  event          TaskEvent      @relation(fields: [eventId], references: [id], onDelete: Restrict)
  @@index([sessionId, taskId])
}

model DeclaredEvidenceRecord {
  id               String         @id @default(uuid())
  sessionId        String
  taskId           String
  source           EvidenceSource @default(DECLARED)
  declarationType  String
  declaredAt       DateTime
  payload          Json
  @@index([sessionId, taskId])
}

model DerivedEvidenceRecord {
  id                  String             @id @default(uuid())
  sessionId           String
  taskId              String
  source              EvidenceSource     @default(DERIVED)
  type                String
  status              EvidenceStatus
  verificationResult  VerificationResult
  confidence          ConfidenceLevel
  basis               Json
  fingerprint         String             @unique
  derivedAt           DateTime           @default(now())
  contradictions      EvidenceContradictionRecord[]
  @@index([sessionId, taskId])
}

model EvidenceContradictionRecord {
  id                String @id @default(uuid())
  derivedEvidenceId String
  type              String
  eventIds          String[]
  description       String
  detectedAt        DateTime @default(now())
  derivedEvidence   DerivedEvidenceRecord @relation(fields: [derivedEvidenceId], references: [id], onDelete: Cascade)
  @@index([derivedEvidenceId])
}

model FrictionSignalRecord {
  id          String             @id @default(uuid())
  sessionId   String
  taskId      String
  type        FrictionSignalType
  severity    FrictionSeverity
  eventIds    String[]
  metrics     Json
  threshold   Json?
  detectedAt  DateTime @default(now())
  @@index([sessionId, taskId])
  @@index([type])
}

model FrictionAssessmentRecord {
  id                  String               @id @default(uuid())
  sessionId           String
  taskId              String
  classification      FrictionClassification
  signalIds            String[]
  metrics             Json
  baselineVersion     String
  fingerprint         String               @unique
  assessedAt          DateTime             @default(now())
  @@index([sessionId, taskId])
}

model ProductEvidenceSnapshot {
  id                 String                     @id @default(uuid())
  recordFingerprint  String                     @unique
  evidenceDatasetId  String
  sessionId          String
  taskCatalogId      String
  taskVersion        Int
  pioneerId          String
  datasetVersion     String
  verificationResult VerificationResult
  frictionClass      FrictionClassification
  payload            Json
  generatedAt        DateTime
  createdAt          DateTime                   @default(now())
  @@index([sessionId])
  @@index([taskCatalogId, taskVersion])
  @@index([pioneerId])
  @@index([verificationResult])
  @@index([frictionClass])
}
```


## 6. Task assignment


```typescript
export interface TaskDefinition {
  taskCatalogId: string;
  version: number;
  active: boolean;
  repeatable: boolean;
  targetCoverage: number;
  weight: number;
}

export interface AssignmentCandidate extends TaskDefinition {
  appId?: string;
}

export class VersionedAssignmentEngine {
  select(candidates: AssignmentCandidate[]): AssignmentCandidate | null {
    const eligible = candidates
      .filter(c => c.active)
      .sort((a, b) =>
        b.weight - a.weight ||
        a.taskCatalogId.localeCompare(b.taskCatalogId) ||
        a.version - b.version
      );

    return eligible[0] ?? null;
  }
}
```

Production assignment must additionally consult Pioneer history, repeatability, task/version coverage, app coverage and the database partial unique index. The final insert must be protected by the database constraint; an in-memory check is insufficient.


## 7. Session lifecycle


```typescript
export class SessionLifecycleService {
  async completeSession(id: string, piUserId: string) {
    return this.transition(id, piUserId, 'COMPLETED');
  }

  async abortSession(id: string, piUserId: string) {
    return this.transition(id, piUserId, 'ABORTED');
  }

  private async transition(
    id: string,
    piUserId: string,
    next: SessionStatus,
  ) {
    const updated = await this.repo.updateMany({
      where: { id, piUserId, status: SessionStatus.IN_PROGRESS },
      data: { status: next },
    });

    if (updated.count !== 1) {
      throw new ConflictException('Invalid session transition');
    }

    return this.repo.findById(id);
  }
}
```


## 8. Event fingerprint


```typescript
import { createHash } from 'node:crypto';

function sortObjectKeys(value: unknown): unknown {
  if (value instanceof Date) return value.toISOString();
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    return value;
  }

  const input = value as Record<string, unknown>;
  return Object.fromEntries(
    Object.keys(input)
      .sort()
      .map(key => [key, sortObjectKeys(input[key])]),
  );
}

export function fingerprintEvent(input: {
  sessionId: string;
  clientEventId: string;
  taskCatalogId: string;
  taskVersion: number;
  eventType: string;
  clientSequence: number;
  payload: Record<string, unknown>;
}): string {
  const canonical = [
    input.sessionId,
    input.clientEventId,
    input.taskCatalogId,
    input.taskVersion,
    input.eventType,
    input.clientSequence,
    sortObjectKeys(input.payload),
  ];

  return createHash('sha256')
    .update(JSON.stringify(canonical))
    .digest('hex');
}
```


## 9. Event ingestion contract


```typescript
export interface IngestEventDto {
  clientEventId: string;
  taskCatalogId: string;
  taskVersion: number;
  eventType: TelemetryEventType;
  clientTimestamp: string;
  clientSequence: number;
  payload: Record<string, unknown>;
  schemaVersion: string;
}

export async function ingestEvent(dto: IngestEventDto, sessionId: string) {
  validateTimestamp(dto.clientTimestamp);
  await assertSessionOwnedAndInProgress(sessionId);
  await assertTaskAssigned(sessionId, dto.taskCatalogId, dto.taskVersion);

  const existing = await findByClientEventId(sessionId, dto.clientEventId);

  if (existing) {
    const incoming = fingerprintEvent({
      sessionId,
      clientEventId: dto.clientEventId,
      taskCatalogId: dto.taskCatalogId,
      taskVersion: dto.taskVersion,
      eventType: dto.eventType,
      clientSequence: dto.clientSequence,
      payload: dto.payload,
    });

    if (existing.eventFingerprint !== incoming) {
      throw new ConflictException('IDEMPOTENCY_CONFLICT');
    }

    return existing;
  }

  const sequence = await atomicallyIncrementAndReturnSequence(sessionId);

  return createTaskEvent({
    sessionId,
    ...dto,
    eventFingerprint: fingerprintEvent({ sessionId, ...dto }),
    serverSequence: sequence,
  });
}
```


## 10. Batch ingestion


```typescript
export interface BatchIngestEventsDto {
  sessionId: string;
  events: Array<IngestEventDto>;
}

// Hard limits:
// 1 <= events.length <= 100
// process in clientSequence order
// domain rejection is item-scoped
// infrastructure failure is batch-fatal
// duplicates are idempotent
// serverSequence remains canonical persisted order
```


## 11. Observed evidence mapper


```typescript
const OBSERVED_EVENT_MAPPING: Record<TelemetryEventType, string> = {
  TASK_STARTED: 'TASK_STARTED',
  TASK_STEP_COMPLETED: 'TASK_STEP_COMPLETED',
  TASK_SUBMITTED: 'TASK_SUBMITTED',
  TASK_FAILED: 'TASK_FAILED',
  VIEW_RENDERED: 'VIEW_RENDERED',
  ACTION_EXECUTED: 'ACTION_EXECUTED',
  EVIDENCE_ATTACHED: 'EVIDENCE_ATTACHED',
};

export class EvidenceMapper {
  async mapTaskEvent(eventId: string) {
    const existing = await this.repo.findByEventId(eventId);
    if (existing) return existing;

    const event = await this.events.findById(eventId);
    const type = OBSERVED_EVENT_MAPPING[event.eventType];

    return this.repo.create({
      sessionId: event.sessionId,
      taskId: event.taskCatalogId,
      source: EvidenceSource.OBSERVED,
      type,
      eventId: event.id,
      serverSequence: event.serverSequence,
      observedAt: event.serverReceivedAt,
      status: EvidenceStatus.UNKNOWN,
      facts: {
        eventType: event.eventType,
        clientSequence: event.clientSequence,
        serverSequence: event.serverSequence,
        clientTimestamp: event.clientTimestamp.toISOString(),
        schemaVersion: event.schemaVersion,
        stepCode: extractStepCode(event.payload),
        actionCode: extractActionCode(event.payload),
      },
    });
  }
}
```


## 12. Reconciliation


```typescript
export interface RuleEvaluation {
  ruleKey: string;
  passed: boolean;
  applicable: boolean;
  status?: VerificationResult;
  contradictions: EvidenceContradiction[];
  metrics?: Record<string, number>;
  eventIds: string[];
}

export function resolveVerification(
  rules: RuleEvaluation[],
): VerificationResult {
  const applicable = rules.filter(r => r.applicable);

  if (applicable.some(r => r.contradictions.length > 0)) {
    return VerificationResult.CONTRADICTORY;
  }

  if (applicable.some(r => r.status === VerificationResult.INSUFFICIENT_EVIDENCE)) {
    return VerificationResult.INSUFFICIENT_EVIDENCE;
  }

  if (applicable.some(r => !r.passed)) {
    return VerificationResult.INSUFFICIENT_EVIDENCE;
  }

  if (applicable.some(r => r.status === VerificationResult.PARTIAL)) {
    return VerificationResult.PARTIAL;
  }

  return VerificationResult.VERIFIED;
}
```

- Requirement coverage evaluates required semantic step codes.
- Strict sequence compares serverSequence order against required order.
- Timing uses canonical server-received evidence timing.
- Declaration consistency reconciles Pioneer claims with observed evidence.
- Declaration-alone claims without meaningful functional evidence remain INSUFFICIENT_EVIDENCE.
- Inputs are sorted deterministically.
- Derived evidence stores its complete basis and contradictions.

## 13. Friction detector


```typescript
export interface FrictionBaseline {
  taskId: string;
  expectedDurationMs?: number;
  durationP75Ms?: number;
  durationP90Ms?: number;
  expectedRetryCount?: number;
  expectedFailureRate?: number;
  version: string;
}

export interface FrictionSignal {
  type: FrictionSignalType;
  severity: FrictionSeverity;
  sessionId: string;
  taskId: string;
  eventIds: string[];
  metrics: Record<string, number>;
  threshold?: { expected?: number; observed?: number; unit: string };
}

export function classifyFriction(
  declared: DeclaredEvidenceRecord[],
  signals: FrictionSignal[],
): FrictionClassification {
  const hasDeclared = declared.length > 0;
  const hasObserved = signals.length > 0;
  const high = signals.some(s => s.severity === FrictionSeverity.HIGH);

  if (signals.length >= 3 && high) {
    return FrictionClassification.FRICTION_ANOMALY;
  }
  if (hasDeclared && hasObserved) {
    return FrictionClassification.CONFIRMED_FRICTION;
  }
  if (hasDeclared) {
    return FrictionClassification.DECLARED_ONLY_FRICTION;
  }
  if (hasObserved) {
    return FrictionClassification.OBSERVED_FRICTION;
  }
  return FrictionClassification.NORMAL;
}
```

- Verification and friction are independent.
- Verified + High friction remains VERIFIED.
- Declared-only friction remains distinct from observed friction.
- Signals are traceable to immutable TaskEvent IDs.
- Friction is never converted into Pioneer quality.

## 14. ProductEvidenceRecord


```typescript
export interface ProductEvidenceRecord {
  evidenceDatasetId: string;
  sessionId: string;
  taskCatalogId: string;
  taskVersion: number;

  lineage: {
    eventIds: string[];
    observedEvidenceIds: string[];
    declaredEvidenceIds: string[];
    derivedEvidenceId: string;
    verificationId: string;
    frictionAssessmentFingerprint: string;
  };

  rawEvidenceSummary: {
    totalEventsCount: number;
    startServerSequence: number;
    endServerSequence: number;
    firstEventTimestamp: Date;
    lastEventTimestamp: Date;
  };

  verification: {
    verificationId: string;
    result: VerificationResult;
    confidence: ConfidenceLevel;
    ruleEvaluationsCount: number;
    verifiedAt: Date;
  };

  friction: {
    assessmentFingerprint: string;
    classification: FrictionClassification;
    detectedSignalsCount: number;
    signalTypes: FrictionSignalType[];
    highestSeverity: FrictionSeverity;
  };

  temporalMetrics: {
    totalDurationMs: number;
    activeExecutionMs?: number;
    idleMs?: number;
  };

  behavioralMetrics: {
    retryCount: number;
    failureCount: number;
    backtrackCount: number;
  };

  evidenceCompleteness: {
    expectedStepCount: number;
    uniqueObservedStepCount: number;
    ratio: number;
  };

  datasetVersion: string;
  generatedAt: Date;
  recordFingerprint: string;
}
```


## 15. Lineage integrity validator


```typescript
export enum DatasetIntegrityViolation {
  FOREIGN_SESSION_LINEAGE = 'FOREIGN_SESSION_LINEAGE',
  FOREIGN_TASK_LINEAGE = 'FOREIGN_TASK_LINEAGE',
  TASK_VERSION_MISMATCH = 'TASK_VERSION_MISMATCH',
  MISSING_SOURCE_EVENT = 'MISSING_SOURCE_EVENT',
  MISSING_OBSERVED_EVIDENCE = 'MISSING_OBSERVED_EVIDENCE',
  MISSING_DECLARED_EVIDENCE = 'MISSING_DECLARED_EVIDENCE',
  MISSING_DERIVED_EVIDENCE = 'MISSING_DERIVED_EVIDENCE',
  VERIFICATION_BINDING_MISMATCH = 'VERIFICATION_BINDING_MISMATCH',
  FRICTION_BINDING_MISMATCH = 'FRICTION_BINDING_MISMATCH',
  SEQUENCE_RANGE_MISMATCH = 'SEQUENCE_RANGE_MISMATCH',
  TIMESTAMP_RANGE_MISMATCH = 'TIMESTAMP_RANGE_MISMATCH',
  COMPLETENESS_BASIS_MISMATCH = 'COMPLETENESS_BASIS_MISMATCH',
  INVALID_LINEAGE_CARDINALITY = 'INVALID_LINEAGE_CARDINALITY',
}

export class DatasetIntegrityException extends Error {
  constructor(
    public readonly violation: DatasetIntegrityViolation,
    details: string,
  ) {
    super(`[DatasetIntegrityException] ${violation}: ${details}`);
  }
}
```

Validator requirements: all lineage artifacts share session/task/version; every event ID resolves to a TaskEvent; observed IDs resolve; declared IDs resolve; derived basis is traceable; sequence/timestamp ranges are derived from source events; verification and friction bindings match; completeness is based on requirements/evidence; foreign lineage is rejected rather than silently filtered.


## 16. Canonical fingerprint


```typescript
export interface CanonicalFingerprintPayload {
  sessionId: string;
  taskCatalogId: string;
  taskVersion: number;
  lineage: ProductEvidenceRecord['lineage'];
  rawEvidenceSummary: {
    totalEventsCount: number;
    startServerSequence: number;
    endServerSequence: number;
    firstEventTimestamp: string;
    lastEventTimestamp: string;
  };
  verification: {
    verificationId: string;
    result: string;
    confidence: string;
    ruleEvaluationsCount: number;
    verifiedAt: string;
  };
  friction: {
    assessmentFingerprint: string;
    classification: string;
    detectedSignalsCount: number;
    signalTypes: string[];
    highestSeverity: string;
  };
  temporalMetrics: {
    totalDurationMs: number;
    activeExecutionMs?: number;
    idleMs?: number;
  };
  behavioralMetrics: {
    retryCount: number;
    failureCount: number;
    backtrackCount: number;
  };
  evidenceCompleteness: {
    expectedStepCount: number;
    uniqueObservedStepCount: number;
    ratio: number;
  };
  datasetVersion: string;
}

export function fingerprintRecord(
  payload: CanonicalFingerprintPayload,
): string {
  const canonical = canonicalizeForFingerprint(payload);
  return createHash('sha256')
    .update(JSON.stringify(canonical))
    .digest('hex');
}
```

- Explicit allow-list only.
- Object keys recursively sorted.
- Dates normalized to ISO.
- Set-like lineage arrays and signalTypes are unique/sorted.
- Sequence-sensitive arrays are never globally sorted.
- evidenceDatasetId, generatedAt and recordFingerprint are excluded.

## 17. Snapshot persistence


```typescript
export async function createSnapshot(
  record: ProductEvidenceRecord,
  pioneerId: string,
) {
  const canonical = buildCanonicalFingerprintPayload(record);
  const hash = fingerprintRecord(canonical);

  if (hash !== record.recordFingerprint) {
    throw new Error('RECORD_FINGERPRINT_MISMATCH');
  }

  try {
    return await prisma.productEvidenceSnapshot.create({
      data: {
        recordFingerprint: record.recordFingerprint,
        evidenceDatasetId: record.evidenceDatasetId,
        sessionId: record.sessionId,
        taskCatalogId: record.taskCatalogId,
        taskVersion: record.taskVersion,
        pioneerId,
        datasetVersion: record.datasetVersion,
        verificationResult: record.verification.result,
        frictionClass: record.friction.classification,
        payload: canonical,
        generatedAt: record.generatedAt,
      },
    });
  } catch (error) {
    if (isUniqueRecordFingerprintConflict(error)) {
      return prisma.productEvidenceSnapshot.findUniqueOrThrow({
        where: { recordFingerprint: record.recordFingerprint },
      });
    }
    throw error;
  }
}
```

The P2002 handler must verify that the unique target is the recordFingerprint constraint before treating the error as an idempotent duplicate. pioneerId is operational/query metadata and is not part of the canonical fingerprint.


## 18. Snapshot read integrity


```typescript
export async function readVerifiedSnapshot(recordFingerprint: string) {
  const row = await repo.findByFingerprint(recordFingerprint);

  const payload = parseCanonicalPayload(row.payload);
  const recomputed = fingerprintRecord(payload);

  if (recomputed !== row.recordFingerprint) {
    throw new Error('SNAPSHOT_TAMPERED');
  }

  assertProjectionMatchesPayload(row, payload);

  return mapSnapshotToDomain(row, payload);
}
```


## 19. Analytics boundary


```typescript
export interface AnalyticsSnapshotRecord {
  recordFingerprint: string;
  taskCatalogId: string;
  taskVersion: number;
  datasetVersion: string;
  verification: {
    result: VerificationResult;
  };
  friction: {
    classification: FrictionClassification;
    signalTypes: FrictionSignalType[];
    highestSeverity: FrictionSeverity;
  };
  temporalMetrics: {
    totalDurationMs: number;
  };
  behavioralMetrics: {
    retryCount: number;
    failureCount: number;
    backtrackCount: number;
  };
}

export interface IAnalyticsSnapshotRepository {
  findForAnalytics(query: {
    taskCatalogId?: string;
    taskVersion?: number;
  }): Promise<AnalyticsSnapshotRecord[]>;
}
```

Analytics must import only the snapshot repository boundary. It must not import TaskEvent, EvidenceMapper, ReconciliationEngine, FrictionDetector, ProductEvidenceAggregator or raw evidence records.


## 20. Task analytics


```typescript
export interface TaskPerformanceMetrics {
  taskCatalogId: string;
  taskVersion: number;
  totalExecutions: number;
  verificationBreakdown: {
    verifiedCount: number;
    partialCount: number;
    insufficientCount: number;
    contradictoryCount: number;
    verifiedRatio: number;
  };
  durationDistributionMs: {
    min: number | null;
    p50: number | null;
    p75: number | null;
    p90: number | null;
    max: number | null;
  };
  behavioralTotals: {
    totalRetries: number;
    totalFailures: number;
    totalBacktracks: number;
  };
  analyticsEngineVersion: string;
  percentileAlgorithm: string;
}

export const ANALYTICS_ENGINE_VERSION = '1.0.0';
export const PERCENTILE_METHOD_R7_LINEAR_V1 = 'PERCENTILE_METHOD_R7_LINEAR_V1';

export function calculateR7Percentile(
  sortedValues: number[],
  p: number,
): number | null {
  const n = sortedValues.length;
  if (n === 0) return null;
  if (n === 1) return sortedValues[0];
  if (p <= 0) return sortedValues[0];
  if (p >= 1) return sortedValues[n - 1];

  const h = 1 + (n - 1) * p;
  const k = Math.floor(h);
  const gamma = h - k;

  if (k >= n) return sortedValues[n - 1];

  return sortedValues[k - 1] +
    gamma * (sortedValues[k] - sortedValues[k - 1]);
}
```


## 21. UX friction analytics


```typescript
export interface UXFrictionMetrics {
  taskCatalogId: string;
  taskVersion: number;
  totalAssessed: number;
  classificationBreakdown: {
    normalCount: number;
    declaredOnlyCount: number;
    observedCount: number;
    confirmedCount: number;
    anomalyCount: number;
  };
  severityBreakdown: {
    noneCount: number;
    lowCount: number;
    mediumCount: number;
    highCount: number;
  };
  topSignalTypes: Array<{
    signalType: FrictionSignalType;
    occurrenceCount: number;
  }>;
  analyticsEngineVersion: string;
}
```

Signal frequency is snapshot-level: one snapshot containing three signal types contributes one occurrence to each type. Pioneer quality/reputation/rank/leaderboard metrics are forbidden.


## 22. Full replay


```typescript
export type ReplayResult =
  | { status: 'MATCH'; fingerprint: string }
  | { status: 'MISMATCH'; expected: string; actual: string }
  | { status: 'INVALID_GRAPH'; reason: string };

export async function replay(
  recordedFingerprint: string,
  graph: EvidenceGraph,
): Promise<ReplayResult> {
  try {
    const record = await aggregateEvidenceGraph(graph);
    const payload = buildCanonicalFingerprintPayload(record);
    const actual = fingerprintRecord(payload);

    if (actual === recordedFingerprint) {
      return { status: 'MATCH', fingerprint: actual };
    }

    return {
      status: 'MISMATCH',
      expected: recordedFingerprint,
      actual,
    };
  } catch (error) {
    if (error instanceof DatasetIntegrityException) {
      return { status: 'INVALID_GRAPH', reason: error.message };
    }
    throw error;
  }
}
```


## 23. Required test matrix

- Assignment: concurrent requests produce exactly one active logical task.
- Session: concurrent complete/abort produces exactly one successful transition.
- Event ingestion: duplicate same identity is idempotent; same identity with changed fingerprint is rejected.
- Batch ingestion: 1–100 accepted; >100 rejected; cross-user session rejected.
- Observed mapping: same event maps to one observed record under concurrency.
- Reconciliation: contradiction blocks VERIFIED.
- Reconciliation: declaration alone cannot produce VERIFIED.
- Friction: verified + high friction remains VERIFIED.
- Friction: declared-only, observed-only, confirmed and anomaly classifications behave deterministically.
- Lineage: foreign session/task/version fails explicitly.
- Aggregator: no mutation of source records.
- Fingerprint: operational metadata changes do not change fingerprint.
- Fingerprint: semantic changes do change fingerprint.
- Snapshot: concurrent writes are first-writer-wins by recordFingerprint.
- Snapshot: tampered payload is rejected on read.
- Analytics: row order permutation produces identical output.
- Analytics: task versions never merge.
- Percentiles: R7 implementation matches fixed expected fixtures.
- Replay: authentic graph MATCH; valid tampered graph MISMATCH; invalid graph INVALID_GRAPH.

## 24. Security and governance

- piUserId must come from authenticated server context, not trusted client input.
- Raw payload must be sanitized before entering observed facts.
- TaskEvents are append-only at the application boundary.
- Snapshot repository exposes no update/delete methods.
- Foreign lineage is rejected; never silently filtered.
- Unknown and insufficient states are neutral/insufficient, never positive evidence.
- Round 3 does not produce Pioneer quality, reputation, rank or leaderboard scores.
- TEC AI consumes downstream evidence/analytics; it does not become the owner of institutional truth.

## 25. Build order


```text
Step 0  Confirm research decision / campaign requirements.
Step 1  Contracts + enums + Prisma schema.
Step 2  Task catalog + assignment + concurrency.
Step 3  Session lifecycle + ownership.
Step 4  Event ingestion + idempotency + server sequence.
Step 5  Batch ingestion.
Step 6  Observed/Declared evidence.
Step 7  Reconciliation.
Step 8  Friction.
Step 9  ProductEvidenceRecord + lineage.
Step 10 Deterministic fingerprint + replay.
Step 11 Snapshot persistence + tamper detection.
Step 12 Analytics.
Step 13 Full end-to-end replay/audit.
Step 14 Only after passing gates: declare Round 3 Engine complete.
```


## 26. Critical distinction: specification vs implementation

The supplied Master Specification is the canonical design reference. This document turns that design into an implementation-oriented package layout, contracts, schema and reference code. It must not be used to claim that the implementation already exists. Every phase must pass real tests against the actual database before being labeled sealed or verified.


## 27. Future extraction after Round 3


```text
Round 3
   ↓
Reference implementation
   ↓
Generic Evidence Core
   ↓
@tec/evidence-sdk
   ↓
Other TEC products / research programs
   ↓
Product Evidence Platform
   ↓
Analytics
   ↓
TEC AI Product Intelligence
```
