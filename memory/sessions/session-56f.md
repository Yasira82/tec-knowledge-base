# SESSION 56f — deployed, and the 404 that only the other service's log could show

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Phase 2.1 went from merged to **running in production**, and the last step between those
two was a bug no test in this repo could have caught.

### The deploy, verified rather than assumed

| Step | Evidence |
|---|---|
| Schema | `information_schema` query in `db-identity` returned **3 rows** — `nexus_runs.input` · `nexus_runs.user_id` · `nexus_steps.output` |
| identity-service | ACTIVE on the #313 commit; all consumers booted, including `Nexus Consumer (payment-completed → run resume)` |
| commerce-service | ACTIVE; `/commerce/orders/reserve` · `/release` · `/subscriptions/renewable` all mapped |
| asset-service | ACTIVE; `/api/assets/marketplace/:id/lock` · `/unlock` · `/buy` all mapped |

Each line is a thing that was **looked at**, not inferred from a merge.

### The bug: every asset step was a 404 (tec-core-backend #313)

`tec-asset-service` calls `setGlobalPrefix('api')`. The asset steps built
`/assets/marketplace/:id/lock`; the service mounts `/api/assets/marketplace/:id/lock`.
Every dispatch in `asset-transfer-saga` would have 404'd → step FAILED → saga rollback.
Visible rather than silent — the dispatcher fails closed — but wrong on every run.

**Why it was missed, and this is the part that generalises.** Nothing else in the
platform calls asset-service *directly*: the gateway reaches it through a `pathRewrite`,
and **that rewrite is where the prefix was already written down**. Nexus is the first
direct caller, so there was no precedent to copy. Commerce was right by luck rather than
care — it sets no prefix at all.

> **A unit test with a mocked `fetch` cannot tell you where a service mounts.** The suite
> was green and the code was wrong, because the only source of that fact is the *other
> service*. It was found by reading the callee's boot log — the same move that found the
> trailing space in a Railway name (Session 46 §6) and the `--skip-generate` hint
> (Session 56c). Three times now, the answer was printed by the tool and not read.

**The fix moves the prefix off the step and onto the service** (`asset: { prefix: '/api' }`).
Repeat a prefix per step and the next asset step is one omission away from the same 404;
declare it once and that step cannot get it wrong. `baseUrlOf` also tolerates an env value
that already carries the prefix — `/api/api/assets` is the same 404 wearing a hat.

### A second lesson, about error responses

GitHub returned `500`/`502` on six consecutive attempts to open the KB pull request. I
reported that it could not be opened and asked for it to be opened by hand. **It had
already been created on the first attempt** (#142) — the write succeeded and the response
failed.

> **A 5xx on a write means UNKNOWN, not FAILED.** The same discipline this platform
> applies to a dispatch timeout — *"ambiguity resolves to did-not-happen, because the
> idempotency key makes the retry safe"* — has a mirror image: when the retry is **not**
> idempotent, check whether the thing exists before saying it does not. Reporting a
> failure that did not happen is the same error as reporting a success that did not.

### Status

- **2.1 is now `[Runtime Verified]` for deployment, not yet for execution.** The services
  are live and reachable on the right paths; no run has been driven end to end. That last
  step is a real `checkout-saga` or `subscription-renewal` against production.
- `/api/ready` fleet rollout (1.3) still open across the 20+ apps.
