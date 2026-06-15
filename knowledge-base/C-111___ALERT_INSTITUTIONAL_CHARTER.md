# C-111 — ALERT INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Future Vision
**Governance State:** Draft
**Verification State:** Unverified
**Authority Scope:** Domain
**Decision Status:** Exploratory

---

## 1. MISSION

ALERT is the risk management infrastructure of the TEC platform — the system that monitors economic activity across all apps, detects anomalies and threats in real time, and triggers protective responses before damage occurs.

---

## 2. INSTITUTIONAL ROLE

**System of Infrastructure (Risk Layer)** — The platform's immune system.

```
Settlement → Record → Reasoning → Access → Construction → Production → Economic Activity → SETTLEMENT
                                                                                               ↑
                                                                                             ALERT
                                                                                        (Risk at Settlement)
```

ALERT monitors at the Settlement layer — the point where economic activity converts to finalized Pi transactions. Settlement is where errors are most costly and most difficult to reverse. ALERT catches problems before they reach settlement, or immediately after.

---

## 3. ECONOMIC PURPOSE

ALERT exists to protect the economic integrity of the TEC platform:

- **Fraud Detection**: Unusual payment patterns, velocity checks, geographic anomalies
- **Orphan Payment Detection**: Payments that completed in Pi Network but not recorded in TEC
- **Balance Anomalies**: Wallet balance inconsistencies (Invariant 1 protection)
- **Rate Anomalies**: Sudden spike/drop in payment success rates
- **Infrastructure Risk**: Service degradation before it becomes an outage
- **Regulatory Signals**: KYC gap detection, high-value transaction flagging

Every financial platform has an alert/risk layer. For TEC, ALERT is the difference between catching a payment inconsistency in seconds vs. discovering it in a monthly reconciliation.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Risk detection rules and thresholds
- Alert routing (who gets notified for what type of alert)
- Anomaly detection algorithms
- Alert audit log (every alert created, acknowledged, resolved)
- Automatic protective responses (suspend flagged payment, freeze flagged wallet)
- Reconciliation trigger (orphan payment detection → trigger reconciliation path)

### Does NOT Own
- Payment state (tec-payment-service owns)
- Wallet balance (tec-payment-service owns)
- Identity (tec-auth-service owns)
- Final freeze/unfreeze decision (humans approve — ALERT flags, humans decide)
- Governance changes in response to risk (SYSTEM C-110 handles governance)

### Interface Points
```
Exposes to ecosystem:
  - Alert webhook: POST events to configured operator endpoints
  - Alert API: GET /api/alert/active (current active alerts — admin only)
  - Risk score API: GET /api/alert/risk/{paymentId} (risk score for a payment)
  - Reconciliation trigger: POST /api/alert/reconcile/{paymentId}

Consumed from:
  - tec-analytics-service (4007): event streams for anomaly detection
  - tec-payment-service (4002): payment state changes
  - tec-auth-service (4001): failed auth events
  - Hub (C-100): circuit breaker state changes
  - External: Pi Network payment status (for orphan detection)
```

---

## 5. TECHNICAL ARCHITECTURE

### Planned Stack
- NestJS backend service: `tec-alert-service` (Port 4017 — to be provisioned)
- PostgreSQL: alert records (immutable after creation — Invariant 5)
- Redis: real-time sliding window counters for rate-based detection
- tec-notification-service (4008): delivery of alerts to operators and users
- tec-realtime-service (4009): real-time alert dashboard updates

### Detection Rules Architecture
```typescript
interface AlertRule {
  id: string
  name: string              // e.g. 'payment_velocity_spike'
  description: string
  severity: 'P0' | 'P1' | 'P2'
  condition: AlertCondition // rule engine expression
  cooldownMinutes: number   // prevent alert spam
  autoActions: AlertAction[] // automatic responses
  notifyRoles: string[]     // 'operator' | 'admin' | 'user'
}

type AlertCondition =
  | { type: 'rate_threshold'; metric: string; threshold: number; windowMinutes: number }
  | { type: 'value_anomaly'; metric: string; zScoreThreshold: number }
  | { type: 'absolute_threshold'; metric: string; value: number; comparison: '>' | '<' }
  | { type: 'pattern_match'; eventType: string; pattern: string }
```

### Pre-Built Detection Rules (Phase 1)
```
1. payment_success_rate_drop
   Trigger: 15min payment success rate < 80% (normally > 95%)
   Severity: P0
   Auto-action: Alert operator immediately

2. orphan_payment_detected
   Trigger: Pi Network payment.completed but no TEC record within 5min
   Severity: P0
   Auto-action: Trigger reconciliation job

3. velocity_spike
   Trigger: User initiates > 10 payments in 5min
   Severity: P1
   Auto-action: Flag for review, soft-block pending review

4. balance_invariant_check
   Trigger: Wallet balance < 0 detected in any report
   Severity: P0 (Invariant 1 violation)
   Auto-action: Immediate operator alert, payment suspension

5. auth_failure_burst
   Trigger: > 20 failed auth attempts from same IP in 10min
   Severity: P1
   Auto-action: Rate limit IP, alert operator

6. circuit_breaker_opened
   Trigger: PiCircuitBreaker state = OPEN
   Severity: P1
   Auto-action: Alert operator, monitor for recovery
```

### Orphan Payment Reconciliation Path
```
Detection: Payment exists in Pi Network, not in TEC records
  → tec-alert-service creates P0 alert
  → Operator notified (< 5min)
  → Manual reconciliation with audit trail (Forbidden Behavior 10 prevented)
  → Alert closed with resolution log

Automated reconciliation cron: every 60min
(Also runs on-demand from ALERT trigger)
```

---

## 6. SECURITY MODEL

### Authentication
- Alert creation: ServiceActor only (internal services)
- Alert viewing: AdminActor + operator roles
- Alert acknowledgment: AdminActor
- Auto-actions: ALERT service executes, all logged

### Authorization
- P0 alerts: immediate notification to all operators
- P1 alerts: on-call operator
- P2 alerts: daily digest
- User-visible alerts: only their own account alerts (via Hub notifications)

### Threat Vectors
| Threat | Mitigation |
|--------|------------|
| Alert flood (DoS via alert generation) | Per-rule cooldown periods |
| Alert suppression attack | Alert log is immutable — suppression is itself an event |
| False positive fatigue | Tunable thresholds + cooldowns — reviewed monthly |
| Auto-action abuse | Auto-actions limited to soft blocks + notifications; hard actions require human |

---

## 7. REVENUE MODEL

### Direct
ALERT is pure infrastructure — no direct revenue.

### Indirect
- Fraud prevention → reduced losses — every prevented fraud incident is revenue retained
- Faster incident response → higher availability → more transactions completed
- Orphan payment detection → payment reconciliation → no lost Pi
- Risk signals to FundX → better lending pool risk management → lower default rates

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| ALERT service availability | ≥ 99.9% | < 99.5% |
| P0 alert detection latency | < 30s from event | > 2min |
| P1 alert detection latency | < 5min from event | > 15min |
| Alert delivery (to operator) | < 1min from alert creation | > 5min |
| Orphan detection latency | < 5min from Pi Network event | > 30min |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| False positive rate | < 5% | Weekly |
| Mean time to acknowledge (P0) | < 10min | Per incident |
| Mean time to resolve (P0) | < 60min | Per incident |
| Orphan payments per week | 0 unresolved at week end | Weekly |

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Payment Integrity**: ALERT is the last defense before Kernel Invariant violations reach settlement
2. **Operator Confidence**: Real-time risk visibility enables confident platform operation
3. **Reconciliation Trigger**: Automated orphan detection prevents manual monthly reconciliation surprises
4. **FundX Risk Input**: ALERT signals inform FundX pool risk assessments
5. **Pi Network Trust**: A monitored platform is a trustworthy platform — ALERT is evidence of operational maturity

---

## 10. FUTURE EVOLUTION

### Phase 1 (MVP — Month 5–6 post-Mainnet)
- Pre-built rules: 6 rules above (payment rate, orphan, velocity, balance, auth, circuit breaker)
- Operator notification via tec-notification-service (4008)
- Alert audit log (immutable)
- Reconciliation trigger integration

### Phase 2 (Month 7–8)
- ML anomaly detection via TEC AI (C-104) integration
- User-visible alerts in Hub notifications (account-level risk alerts)
- Alert dashboard in Hub admin panel
- SYSTEM (C-110) integration for governance-triggered risk responses

### Phase 3 (Month 9‒12)
- Predictive risk: detect risk patterns before they become incidents
- Cross-app correlation: detect patterns spanning multiple apps
- External threat intelligence: Pi Network fraud signals integration
- Automated remediation: for well-understood P2 scenarios

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Before ALERT MVP)**
1. **Provision tec-alert-service** (Port 4017) on Railway
2. **Orphan detection cron**: 60min cron job comparing Pi Network events vs TEC payment records
3. **Immutable alert log**: DB constraint — no UPDATE on alert records after creation

**P1 — High Priority**
4. **Event subscription**: Subscribe to tec-analytics-service event stream for anomaly detection
5. **6 pre-built rules**: Implement and tune initial rule set (see rules above)
6. **Operator notification**: Integration with tec-notification-service for P0/P1 alerts

**P2 — Medium Priority**
7. **Alert dashboard**: Admin UI in Hub admin panel
8. **TEC AI integration**: ML anomaly detection layered on top of rule-based detection
9. **Cooldown tuning**: Monthly review of false positive rate → adjust thresholds

---

## 12. INTEGRATION MAP

```
C-111 (ALERT) receives signals from:
← C-105 (ANALYTICS)  : Event streams for anomaly detection
← tec-core-backend   : payment events, auth events, wallet state
← C-100 (HUB)        : Circuit breaker state changes

C-111 (ALERT) notifies and triggers:
→ C-100 (HUB)        : User-visible alerts via Hub notifications
→ C-109 (NEXUS)      : Emergency feature flag triggers
→ C-110 (SYSTEM)     : Risk signals that may require governance response
→ C-113 (FUNDX)      : Risk signals for lending pool management
→ Operators          : PagerDuty / webhook / notification delivery
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
