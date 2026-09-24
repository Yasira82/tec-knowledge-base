# SESSION 54 — the Testnet gate was closed; then someone actually used it

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Session 53 proved each app could take **one** Test-Pi payment. This session was what
happened when the owner used the Testnet the way a person does — pay in the Hub, walk
into an app, pay there — and it did not work. Full engineering record:
`audits/PI_TESTNET_PAYMENT_LATENCY_2026-09-11.md`.

### Where the fleet actually stands

| Repo | Merged | Testnet payment |
|---|---|---|
| `tec-app` (Hub) | **#209 → #226** (18) | works, both modes |
| `tec-system` | **#29 → #34** (6) | works, both modes — the reference app |
| `tec-core-backend` | **#293** | reconciliation reads Testnet payments with the Testnet key |
| **the other 21 apps** | **none merged** | **still broken on Testnet, both modes** |

> The last row is the headline. Each of those 21 carries 2–4 commits on
> `claude/tec-knowledge-base-review-6wzngc` with an **open PR**. Until they merge, only
> the Hub and System can take a Testnet payment at all. Mainnet is unaffected throughout.

### The five defects, in the order each exposed the next

1. **ADR-007 was blind to the Testnet Hub.** The guard tested a substring of the
   *Mainnet* Hub only, so every hop from `tec-app-frontend.vercel.app` read as
   standalone: the app ran `Pi.init()` inside a Hub-owned session and sat in
   `Pi.authenticate` forever. **No error is raised — the bridge simply never replies.**
   Now `HUB_HOSTS` + hostname matching (the substring form also matched
   `hub.tecosystem.app.attacker.com`, and that fails **open**).
2. **The Mode-1 chain on the Hub was a straight line** — navigate → auth settles →
   create → modal mounts → *then* warm the Pi session. Four serial steps before the
   handshake began; it now runs beside them.
3. **Two concurrent `Pi.authenticate` calls, produced by the guard against them.**
   `withAuthGate` serialized the two call sites and a login is adopted, not repeated —
   then the *tap* threw away a healthy 1.2-second-old handshake to start a fresh one,
   because it had been written to avoid inheriting a stalled warm-up. It now joins.
4. **Cancel returned to the Hub, and `return_url` was an open redirect** carrying
   `payment_id` + `txid` to any origin named. Now allowlisted against the SSO list
   (extracted so the two consumers cannot drift), matched on **origin**, not prefix.
5. **`/pi-test` paid under a key source that exists nowhere**, so it reported a failure
   production would never have. *A diagnostic that tests a different path from the one
   it is diagnosing sends you hunting the wrong bug.*

### What is still slow — and the decision NOT to fix it

Pay in the Hub, then in an app: the **first** payment after arriving takes tens of
seconds. The reverse order is instant. The trace shows our side is clean — one
handshake, at 0.0s, joined by the tap — so **the wait is inside `Pi.authenticate`**
itself, a Pi app-context switch, paid **once**. **Testnet only; Mainnet is instant.**

The structural cause is the shape of the environment, not the code:

```
Mainnet   hub.tecosystem.app          <->  <app>.tecosystem.app    ONE domain
Testnet   tec-app-frontend.vercel.app <->  tec-<app>.vercel.app    TWO unrelated sites
```

`vercel.app` is on the **public suffix list** — separate cookie jars, separate
partitions, nothing shared. A `-test.tecosystem.app` pairing would give Testnet
Mainnet's shape; **the code is written and open in a PR on all 25 repos, and the
domains are deliberately NOT being created**: it is not a diagnosed cause, the pain is
confined to a test environment, and the cost is ~48 manual Vercel + Pi Portal steps that
can break Testnet payments which currently work. Merging the code is additive and free,
so the option stays open. **Revisit only if it is seen on Mainnet.**

### The recurring shape — sixth instance

A **build-time constant answering a question only the request can answer**:
`APP_URL` · `sandbox` · `HUB_URL` · `appId` · the Hub's app-grid routes · ADR-007's hub
referrer. One build, two hosts. And three axes that keep being conflated: the **host**
picks the Pi *app*, the app's **key** picks the *network*, **`sandbox`** points at Pi's
*Sandbox environment* — a third thing.

### Process

- **A merged PR cannot carry new work.** A commit landed on a branch whose PR had
  already merged and was invisible. Pushing and opening the PR are **one step**.
- **A fleet sweep must check what it overwrites.** A stash-and-switch dropped an
  unmerged commit in two repos; found by auditing all 25 for the expected content, and
  restored. Prove each branch holds only merged history *before* a force-push.
