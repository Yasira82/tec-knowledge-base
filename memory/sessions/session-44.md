# SESSION 44 — TEC AI: the outage was self-inflicted, and the assistant got its UX (21 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (tec-app #162 · #163
> merged; #164 open). Runtime-verified in the Pi Browser by the CEO for the streaming,
> markdown, and provider fixes — the session-state work is merged-but-not-yet-runtime-checked.
> Constitutional detail lives in **C-104 §5.1–5.5**; this is the session record.

### What the user reported, and what it actually was

The assistant was "working, then cutting out, slow, and printing `**` everywhere". Four
separate causes hid behind that one description — and **one of them was ours**.

| Symptom | Real cause |
|---------|-----------|
| Answers stop mid-sentence | The client parsed each network chunk on its own with NO carry-over buffer, so a `data:` frame split across two chunks failed `JSON.parse` and was swallowed by a bare `catch`. Routine on mobile. Also `max_tokens: 1024`, which a normal answer exceeds. |
| "It shows nothing then the whole answer appears" | The stream was already incremental; the drawer accumulated it into a local string and called `setMessages` ONCE at the end. The UI was hiding the typing. |
| `**bold**` printed as asterisks | The bubble rendered the reply as a plain string. |
| **"all providers failed"** | **A regression we introduced — see below.** |

### 🔴 The regression: the candidate list dropped the model that worked

A PR titled *"use current provider models — Groq + Gemini retired the old ones"* had
researched and pinned `gemini-3.6-flash` + `llama-3.1-8b-instant`. A later PR generalised
those pins into candidate **lists** so a retired id could not take the assistant down —
but filled the lists from recollection, and `gemini-3.6-flash` **was not in them at all**,
replaced by four **older** ids. On a free tier the older models are the crowded ones, so
users got *"This model is currently experiencing high demand"*.

**The change whose entire purpose was surviving model rotation is what removed the working
model.** The user caught it: *"the models that were there before you changed them were
free, working 100%, and fast."* They were right; the git history confirmed it.

Two corrections were owed and made: the earlier claim that "the free tier is the cause"
was **wrong** — the free tier was fine, we were pointing at the wrong models.

**Law now in CI** (`models-pinned.test.ts`, C-104 §5.2): a model id production has served
on may not be removed or demoted. *Recognition is not evidence; production traffic is.*

### The blind spot that made it hard to diagnose

Production logged `groq 400:` **with no reason**. A `Response` body is single-use: the
reason was read to classify the failure and read AGAIN to build the log line, and the
second read returned an empty string. The one thing needed to diagnose the outage was the
one thing the code destroyed. Now read once, carried, and the failing **model is named**.

Also fixed: overload (`429`/`503`) was treated as fatal, so Gemini gave up after ONE model
with three healthy candidates unused. And `NOT_CONFIGURED` vs `BUSY` were both HTTP 503,
so a **busy** assistant told the user it was **switched off** — the route now sends an
explicit `code`; the server classifies, the client words it.

### New: `GET /api/ai/health`

Auth-gated probe of every configured provider/model, reporting which answer and why the
others do not, plus the env var to pin a winner. Built because this outage class hit
**three times** and each time the only way to find a working model was to ship a guess and
wait for a user to hit the failure.

### Two surfaces, one implementation (the recurring lesson)

TEC AI is reachable from `/ai` (Hub landing) **and** the `/hub` drawer — two independent
components on the same route. The SSE truncation bug lived in **both** for months; the
`[[go:nx]]` marker leaked on the drawer alone because only the page called the parser.
Shared modules are now listed in C-104 §5.1 and a third surface must import them.

> **The Dashboard has no TEC AI entry point at all** — noted, deliberately out of scope.

### Assistant UX (tec-app #164, open)

Conversation **persistence** (`sessionStorage`, not `localStorage` — C-104 §5.4 records
why), **stop** (keeps the partial answer — stopping is a decision, not a failure),
**retry** (an error bubble was a dead end), **new chat**, copy-reply, an auto-growing
textarea (the drawer's field was single-line — a long question could not be written),
`dir="auto"` everywhere (mixed Arabic+Latin rendered reversed), a real greeting in the
drawer, and `role="log"` + `aria-live` on both transcripts.

**One more silent bug found while reviewing:** the `/ai` welcome was seeded in an effect
keyed on `[user, locale]` that replaced the whole message array — changing language, or
the session resolving late on the C-123 Pi Browser path, **wiped the conversation**.

### Honest status
- `[Runtime Verified]`: streaming · markdown · nav chips · the restored Gemini model.
- `[Code Verified]` only: session state, stop/retry, a11y (#164 merged but not yet
  exercised in prod), and `/api/ai/health` (never yet run against production keys).
- **`ANTHROPIC_API_KEY` is unset** — the chain is **two** providers deep, not three, and
  both were down at the same moment. The Claude branch also still hardcodes a single
  2024 model id with **no** candidate-list fallback: the same defect this session fixed
  for Groq and Gemini, left in place because that key is not set. It must be fixed
  BEFORE that key is ever added.
