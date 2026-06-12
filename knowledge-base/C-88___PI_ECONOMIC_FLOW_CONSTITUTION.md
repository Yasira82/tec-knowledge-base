# C-88 — PI ECONOMIC FLOW CONSTITUTION

## TEC Ecosystem — Economic Flow Governance & Pi Amount Lifecycle

> Status: ACTIVE — Economic Governance Layer
> Authority: Platform Architecture + Economic Governance
> Version: 1.0 — June 2026
> Truth State: [Current State] — invariants active | [Planned State] — fee model post-Portal
> Governance State: [ADR Approved]
> Verification State: [Documentation Verified]
> Authority Scope: [Platform]

---

# PREAMBLE

```
C-47 defines kernel invariants for the platform.
C-88 defines economic flow governance for Pi specifically:
  — how Pi moves through TEC
  — who the economic actors are
  — what TEC guarantees to each actor
  — how every Pi amount is traceable
  — what constitutes an economic violation
```

Documentation Inflation Justification:
```
✅ New authority: Economic flow governance (not covered in C-47 or ADRs)
✅ New verification: Pi amounts traceable end-to-end through defined flow
✅ New runtime behavior: Fee model + settlement guarantees + economic audit trail
```

---

# 1. ECONOMIC ACTOR MODEL

Four actors participate in TEC economic flows:

| Actor | Role | Identity Source | Authority |
|-------|------|----------------|----------|
| User | Economic participant — sends and receives Pi | Pi Network + tec-auth-service | Pi principal |
| Merchant | Economic producer — receives Pi for goods/services | tec-commerce-service + tec-auth-service | Verified merchant role |
| Platform | TEC infrastructure — routes and settles | Platform Governance (C-00) | ADR-004 |
| Pi Network | Settlement layer — final authority on Pi balances | External — Pi Foundation | Blockchain |

## Actor Invariants

```
1. User identity ALWAYS resolves to ONE Pi principal.
2. Merchant identity ALWAYS verified before receiving Pi.
3. Platform NEVER holds Pi on behalf of users (no custodial model).
4. Pi Network is the FINAL authority on all balance states.
```

---

# 2. PI FLOW MAP

## User → Merchant Payment (Mode 2 — Direct)

```
User initiates payment
      │
      ▼
Pi Browser wallet
  Pi.createPayment(amount, memo, metadata)
      │
      ▼
tec-payment-service
  POST /payment/create  (backend-first — C-76)
  → creates internal Payment record [PENDING]
      │
      ▼
Pi.onReadyForServerApproval
  POST /payment/approve  (BFF → Gateway → payment-service)
  → payment-service approves with Pi Network
  → Payment state: [PENDING] → [APPROVED]
      │
      ▼
Pi Browser wallet
  User confirms in Pi Browser
      │
      ▼
Pi.onReadyForServerCompletion
  POST /payment/complete  (BFF → Gateway → payment-service)
  → payment-service completes with Pi Network
  → LedgerEntry created (DECIMAL(20,8))
  → Payment state: [APPROVED] → [COMPLETED]
      │
      ▼
Pi Network blockchain
  Settlement confirmed
      │
      ▼
Event: payment.completed.v1
  → tec-analytics-service (metrics)
  → tec-notification-service (user receipt)
  → tec-commerce-service (order fulfillment trigger)
```

## User → Hub Payment (Mode 1 — Hub Redirect)

```
User initiates from app navigated from Hub
  isHubNavigation() === true
      │
      ▼
Redirect: /hub?pay=1&amount=X&memo=Y&product_id=Z
      │
      ▼
Hub PaymentModal
  Executes Mode 2 flow on behalf of the originating app
  Uses Hub's Pi App ID (not the app's)
      │
      ▼
Same flow as Mode 2 from Hub's context
```

## Constitutional Rule
```
/hub?pay=1 is the ONLY approved Hub payment URL.
Hub NEVER processes payment at /hub/pay.
Apps NEVER initiate payment without isHubNavigation() check.
```

---

# 3. PI AMOUNT LIFECYCLE

Every Pi amount in TEC follows this lifecycle:

```
[Initiated]   → user expressed intent (client-side only, not recorded)
[Created]     → tec-payment-service created internal Payment record
[Approved]    → Pi Network approved the payment
[Completed]   → Pi Network settled the payment + LedgerEntry created
[Failed]      → Pi Network or TEC rejected — no Pi moved
[Cancelled]   → User or governance cancelled before completion
[Refunded]    → Compensating payment issued (separate flow)
```

## Amount Governance Rules

```
✅ DECIMAL(20,8) for ALL Pi amounts in database
✅ String representation in ALL API responses (never JS Number)
✅ LedgerEntry created for EVERY balance mutation
✅ balance >= 0 enforced at DB constraint level
✅ Every Pi amount carries: actorId + correlationId + timestamp

❌ NEVER store Pi amount as JavaScript Number (floating point loss)
❌ NEVER complete a payment without prior approval
❌ NEVER create a LedgerEntry without an authoritative event
❌ NEVER allow wallet balance to go negative
```

## Amount Traceability

Every Pi amount is traceable through:
```
payment_id  → tec-payment-service (TRUTH OWNER)
  ↓
correlation_id → traces across all services
  ↓
ledger_entry_id → tec-wallet-service (TRUTH OWNER of balance)
  ↓
pi_payment_id → Pi Network (FINAL AUTHORITY)
```

---

# 4. ECONOMIC INVARIANTS (Pi-Specific)

These are STRONGER than the C-47 kernel — Pi-specific financial rules:

```
INV-E1: Pi amounts are NEVER approximated.
        DECIMAL(20,8) in DB. String in API. No rounding before settlement.

INV-E2: No Pi moves without a bi-directional audit trail.
        Every debit has a corresponding event. Every credit has a source.

INV-E3: Payment completion requires Pi Network confirmation.
        TEC CANNOT mark a payment [COMPLETED] without Pi Network response.

INV-E4: Wallet balance is ALWAYS the sum of LedgerEntries.
        No balance mutation outside tec-wallet-service.

INV-E5: Fee extraction (when implemented) MUST be declared in payment metadata.
        No hidden fees. No silent deductions.

INV-E6: Pi amounts in transit are owned by NO ONE.
        [Approved] → [Completed] window: Pi is in Pi Network custody.
        TEC has no claim on Pi in this window.

INV-E7: Every payment involves exactly ONE merchant or platform recipient.
        No split payments in v1.
```

---

# 5. SETTLEMENT GUARANTEES

What TEC guarantees to economic actors:

## To Users
```
✅ Your Pi amount is exactly what Pi Network confirms — TEC never modifies amounts
✅ Every payment is traceable with a payment_id you can verify
✅ Failed payments result in zero Pi movement — no partial charges
✅ You will receive a notification for every completed payment
✅ You may dispute a payment through the governance process
```

## To Merchants
```
✅ Payment approval precedes order fulfillment — no fulfillment before payment
✅ Your merchant identity is always derived from your authenticated session
✅ Revenue figures are DECIMAL(20,8) accuracy — never rounded
✅ Order state transitions are immutable once terminal
✅ Pi amounts displayed to you are the same as what Pi Network confirms
```

## To Platform
```
✅ All economic flows go through tec-payment-service (single point of truth)
✅ Outbox pattern guarantees at-least-once delivery to Pi Network
✅ Circuit breaker protects platform from Pi Network instability
✅ Every economic event carries full ActorContext for governance
```

---

# 6. FEE MODEL GOVERNANCE

> Truth State: [Planned State] | Commitment: [Tentative] | Gate: Portal submission

```
Fee Model Principles (when implemented):
  1. Fees are declared in payment metadata BEFORE execution
  2. Fee amounts are DECIMAL(20,8) — no rounding
  3. Fee recipient is explicitly declared (Platform vs third-party)
  4. Users see fee amount BEFORE confirming payment
  5. Fee governance requires ADR — not a product decision
  6. INV-E5 applies: no hidden fees ever

Current State: No fee model implemented.
Fee implementation requires: new ADR + Pi Network policy compliance check
```

---

# 7. ECONOMIC AUDIT TRAIL

For every P0/P1 economic operation, the audit trail MUST contain:

```typescript
interface EconomicAuditEntry {
  entryId:        string;    // UUID
  paymentId:      string;    // tec-payment-service ID
  piPaymentId?:   string;    // Pi Network payment ID
  actorId:        string;    // who initiated
  actorType:      'user' | 'service' | 'admin';
  correlationId:  string;    // traces entire flow
  causationId:    string;    // what event caused this
  amount:         string;    // DECIMAL(20,8) as string — never number
  currency:       'PI';      // always PI for now
  fromState:      PaymentState;
  toState:        PaymentState;
  timestamp:      string;    // ISO 8601 — committed_at is authoritative (C-86)
  piNetworkRef?:  string;    // Pi Network transaction reference
}
```

---

# 8. ECONOMIC VIOLATION CLASSIFICATION

| Violation | Severity | Response | Recovery |
|-----------|----------|----------|----------|
| Pi amount stored as Number | P0 | Immediate hotfix | Data migration |
| Payment completed without approval | P0 | Revert + incident | Manual reconciliation |
| Wallet balance went negative | P0 | Circuit break | Ledger audit |
| Missing LedgerEntry for mutation | P1 | Alert + freeze | Manual entry with audit |
| Fee applied without declaration | P1 | Rollback + user credit | ADR required |
| Payment state terminal transition | P0 | Reject + alert | New payment required |
| Missing ActorContext on payment | P1 | Reject + audit | Re-submit with context |

---

# 9. RELATIONSHIP TO OTHER CONTENTS

| Content | Relationship |
|---------|-------------|
| C-47 Kernel Spec | C-88 extends INV-1 and INV-4 for Pi-specific rules |
| ADR-004 Outbox | C-88 defines what flows through the outbox |
| ADR-007 Payment Ownership | C-88 defines the full lifecycle ADR-007 protects |
| C-86 Temporal Governance | C-88 flows use committed_at as temporal authority |
| C-87 Execution Governance | C-88 economic operations = ExecutionContext required |

---

# FINAL STATEMENT

```
Pi is not data. Pi is economic reality.
Every Pi amount is a governance event.
Every payment is a constitutional act.

TEC does not process payments.
TEC governs economic flows.

The difference:
  Processing = move Pi from A to B
  Governing  = ensure Pi moves with full authority,
               full traceability, full audit trail,
               and zero approximation.
```
