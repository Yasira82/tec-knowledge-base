# TEC Life — privacy in two tiers: which words may go where (decision draft, 2026-10-23)

> Truth State: **[Planned State]** — nothing in this file is built. Governance State: **[Draft]** —
> a proposal for the owner to read, correct and approve **before any code** (owner, 2026-10-23:
> «اه» to "a decision document first, you review it and approve before any code").
> Verification: **[Documentation Verified]** for what Life does today (code read on 2026-10-23);
> provider terms are **[Assumed]** until each "to verify" line in §6 is checked against the
> provider's own terms page or DPA. Continues `audits/LIFE_AI_AS_BUILT_2026-10-20.md` (how Life's
> AI works) and `audits/LIFE_MEMORY_AND_HUMAN_BUILDING_2026-10-23.md`. Life's charter is C-106
> (§5 privacy and sovereignty); this file proposes, it does not amend it.

## 1. Why this document exists

Today every word a person writes to Life goes to **one provider, Groq**, and nowhere else. That
was chosen because Life's first conversations were about smoking, relapse, grief and faith.

The owner's direction (2026-10-23):

- «ما كل الناس بتستخدم ال ai عادي اهم حاجه يكون الاستخدام مفيد» — people use AI everywhere; what
  matters is that it helps.
- «لو حبيت انزل مستقبلا صور و تسجل صوتي» — images and voice are coming.
- «مش كل اليوزرز هيكون عن الإدمان والاكتئاب … ناس هتبقى عاوزه بزنس … مش عاوز احصر التطبيق انو
  يبقى نفسي» — Life is not only a psychological app; some people come for their business.

Both are right, and they pull against each other. One rule for everything either keeps Life on
one provider's free budget forever (the eval runs of 2026-10-23 already pushed real users from
the 120b model to the 20b one), or sends a person's relapse to a provider that trains on it. The
proposal: **the sensitivity of the conversation decides the provider, not the person.**

## 2. What Life does today (code-read, 2026-10-23)

| Item | Today |
|---|---|
| Provider for Life's talk | Groq only — `life-talk.controller.ts`. The model list never leaves Groq; `LIFE_TALK_MODELS_EXTRA` adds Groq model names only |
| Retention | **Confirmed 2026-10-23: Global ZDR and Inference APIs ZDR both enabled** (decision 0). Before that it was only a comment in the controller's header. Groq's default (no ZDR) is "not kept, except temporary logs of up to 30 days to troubleshoot reliability or investigate abuse". Until the owner confirms the Data Controls setting (§8, decision 0), "Groq keeps nothing" is **not** a statement Life may make |
| What is removed before sending | Numbers, emails, links (`minimise.ts`) |
| What is kept by TEC | Nothing from the conversation, unless the person confirms a summary at the end |
| Search | Tavily, only when the person asks; only a general topic is sent, never their words |
| Consent shown | `session-copy.ts` `introAi` — the words go to "an AI model"; "the model's provider does not keep it for us". The provider is **not named** on screen; the privacy page names only "infrastructure providers" |

The consent does not name the provider **on purpose**: the owner decided earlier that Life shows
people no technical detail. It said nothing false even before decision 0. With ZDR confirmed,
"the model's provider does not keep it for us" is now verified, not just promised. §5a is
therefore not used (decision 3).

## 3. The proposal — two tiers

### Tier A — sensitive: Groq only, always

What a person says about **their body, their mind, their faith, their family, their money or the
people around them** never leaves Groq, whatever they agreed to elsewhere.

Life already recognises these topics: they are cards in `life-talk/cards.ts`. Proposed **Tier A
cards**:

`smoking` · `health` · `fitness` · `feeling` · `anger` · `loneliness` · `confidence` · `faith` ·
`conflict` · `parenting` · `grief` · `lost` · `people` · `circumstances` · `money`

Plus, always Tier A:

- any reply where the safety rule fires (self-harm, harm to others, danger). Keeping these on
  Groq is a privacy rule, not the safety response: that stays what it is today — the prompt's
  Safety section and the crisis guidance — and is not weakened by this document;
- any message the classifier cannot place (**unknown = sensitive**, P6 fail closed).

`money` is Tier A because Life's prompt already forbids inferring finances the person did not
state; a person's debts are as private as their health.

### Tier B — general: may use another provider, only with the person's explicit consent

Proposed **Tier B cards**: `career` · `business` · `skill` · `decision` · `focus` · `time` ·
`procrastination`

The conversation-state cards (`frustration`, `resolve`, `decided`, `relapse`, `experiences`,
`success`, `plan`, `growth`) are not topics; they do not move a conversation into Tier B on
their own. `relapse` points at a struggle and keeps the conversation in Tier A.

### The rules that make it safe

0. **One gate over the whole payload.** The tier is decided for **everything the request would
   carry** — every earlier turn, the kept notes, the «أنا أصبحت…» sentence, the plan's lead and any
   search result — not only the new message. A Tier B request is built only from parts that each
   passed; if any part is Tier A or cannot be checked, the whole request goes to Groq.
1. **The tier is decided in code, before anything is sent** — never by the other provider. Today's
   card words are keywords, and keywords miss meaning: «ساعدني أقرر» about a divorce is a decision
   *and* a family matter; a business question about personal debt is `money`. Two answers to that,
   in order: (a) the default is A, so a miss keeps the words on Groq rather than leaking them;
   (b) if keywords prove too coarse, a classifier may run **on Groq** (where the words already
   are) — never on the Tier B provider. Tier B starts with a narrow allow-list, not a wide one.
2. **Sticky, within the conversation.** Once a conversation touches a Tier A topic, it stays
   Tier A to its end. A person who starts with their business and then says their marriage is
   falling apart has said something Tier A; the next reply and every one after it go to Groq.
   **Across conversations** nothing carries hidden: a new conversation starts unclassified, and
   what the person kept is filtered by rule 4 — never by a flag the person cannot see.
3. **Mixed = A.** A message that touches a Tier A and a Tier B topic is Tier A.
4. **Memory follows the same line.** Tier B requests carry only kept notes whose own topic is
   Tier B. A kept note about smoking never goes to a Tier B provider, even inside a business
   conversation.
5. **Off by default.** Tier B is used only after the person switches it on themselves, in a
   consent separate from the one they already gave (§5). Without it, everything stays on Groq —
   exactly today's behaviour.
6. **Withdrawable.** One switch in Settings; turning it off takes effect on the next message.
7. **Named.** The consent names the provider, says whether it keeps or trains on the words, and
   says which topics never go to it.
8. **Logged without words.** Each reply logs its tier and provider (`life.talk tier=B
   provider=…`), never the words — so the eval and the owner can see the split.

### What Tier B buys, honestly

- **Capacity.** A second daily budget; real people stop falling back to the smallest model on a
  busy day.
- **Strength.** Possibly stronger models for planning, writing and business questions.

It buys nothing for the people who need Life most: their conversations stay on Groq. **The first
step for them is more Groq models (`allam-2-7b`, being tested), not Tier B.**

## 4. Voice and images

### Voice — can stay on Groq

- Groq serves `whisper-large-v3` (speech-to-text) on the same account (2,000 requests/day on the
  owner's limits page, 2026-10-23).
- Proposed flow: the person records → the audio goes to Groq's whisper → **the transcript is
  shown to the person to read and correct** → only then is it sent as text, through the normal
  tier rules.
- The audio is never stored by TEC. That is a statement about TEC only: what Groq keeps of the
  audio request follows Groq's retention setting, and the consent must say so.
- A voice is more identifying than text (a voice print, a background, other people in the room).
  So the first use asks once, with the wording fixed by decision 0:
  «يُرسَل تسجيلك الصوتي إلى Groq ليحوَّله إلى نص. لا نحفظ التسجيل؛ [وGroq لا يحتفظ به / وقد
  يحتفظ به Groq مؤقتًا حتى 30 يومًا لأغراض الأمان والتشغيل]».
- To verify: that the account's Zero Data Retention covers the audio endpoints, not only chat (§6).

### Images — need another provider; decided at the moment of use

- No vision model is listed among the account's free models today.
- An image is the most identifying thing a person can send: faces, documents, a house, a screen.
- Proposed rules, for when the owner decides to build it:
  - consent **on each image**, at the moment it is sent, naming the provider;
  - location and camera data (EXIF) stripped before sending;
  - a warning not to send faces, IDs or documents;
  - never inside a Tier A conversation until a provider with no-retention, no-training terms is
    available.
- **Not before the owner approves** — and probably not before Life has income for a paid tier.

## 5. Consent text (drafts — MSA and English)

### a. The existing consent, corrected to name the provider (applies today, with or without Tier B)

Two versions; **which one ships is decided by decision 0**, never chosen for how it sounds.

If Zero Data Retention is confirmed on:

> لكي يرد عليك، يُرسَل ما تكتبه إلى نموذج ذكاء اصطناعي تشغّله شركة Groq. لا نحتفظ به، وGroq لا
> يحتفظ به (خيار عدم الاحتفاظ بالبيانات مفعّل لحسابنا). تُحذف الأرقام والبريد والروابط قبل
> الإرسال — لكن ذلك لا يجعل كلامك مجهول الهوية تمامًا.

> To reply, what you write is sent to an AI model run by Groq. We do not keep it, and Groq does
> not keep it (zero data retention is switched on for our account). Numbers, emails and links are
> removed before it is sent — but that does not make your words fully anonymous.

If it is not confirmed:

> … لا نحتفظ به. قد يحتفظ به Groq مؤقتًا حتى 30 يومًا لأغراض الأمان والتشغيل فقط، ثم يُحذف. …

> … We do not keep it. Groq may keep it temporarily, for up to 30 days, only for security and
> reliability, and then deletes it. …

### b. The Tier B consent (a separate switch, off by default)

> **استخدام نماذج أخرى في المواضيع العامة**
> عندما تتحدث عن عملك أو مشروعك أو تعلّم مهارة أو تنظيم وقتك، يمكن أن يرد عليك نموذج من شركة
> [المزوّد]. [المزوّد] [قد يستخدم كلامك لتحسين خدماته / لا يحتفظ بكلامك] — اقرأ شروطه [رابط].
> أما ما تقوله عن صحتك أو مشاعرك أو إيمانك أو أسرتك أو مالك أو الناس من حولك، فلا يُرسَل إليه
> أبدًا، ويبقى مع Groq وحده. ويمكنك إيقاف هذا في أي وقت من الإعدادات؛ الإيقاف يمنع الإرسال من
> الآن، ولا يمحو ما سبق أن عالجه [المزوّد] — ذلك تحكمه شروطه.

> **Use other models for general topics**
> When you talk about your work, your business, learning a skill or organising your time, a model
> from [provider] may reply. [Provider] [may use your words to improve its services / does not
> keep your words] — read its terms [link]. What you say about your health, your feelings, your
> faith, your family, your money or the people around you is never sent to it; it stays with Groq
> alone. You can switch this off at any time in Settings; switching it off stops sending from now
> on, and does not erase what [provider] has already processed — its terms govern that.

The bracket must be filled with what the provider's terms actually say — never softened.

## 6. Candidate providers for Tier B (searched 2026-10-23)

| Provider (free use) | Trains on the words? | Keeps them? | Verdict |
|---|---|---|---|
| **Groq**, more models (e.g. `allam-2-7b`) | Not stated on the data page; a third-party summary says the DPA prohibits it — **to verify** in the DPA | Not kept by default, **except temporary logs of up to 30 days** for reliability or abuse investigation (longer only if law requires); Zero Data Retention switches that off in Data Controls; data held in GCP, US. Whether ZDR covers the audio endpoints — **to verify** | Same tier as today; needs no new consent. **First step** — after decision 0 |
| **Mistral**, free "Experiment" plan | Yes by default on the free plan; an opt-out exists, set **separately for the API** (not the same switch as Mistral's own apps) — **to verify** on our account | To verify — an opt-out of training is **not** the same as no retention | Only Tier B candidate, and only after both are verified on the account |
| **Google Gemini API**, free tier | Yes — free-tier inputs and outputs are used to improve Google's products, and **human reviewers may read them**. Its terms say plainly: do not submit sensitive, confidential or personal information to the unpaid services | Yes | **Excluded.** Its own terms rule out what Life is. A reviewer also reports an 18+ requirement that excludes apps likely to be used by under-18s — **to verify** on the current terms page, but the first reason is enough |
| **Cerebras** | Unclear — **to verify** | States inference inputs and outputs are not retained — **to verify** in its own terms | A one-time promotional credit, no permanent free tier → not a candidate now |

Sources:
- Groq: https://console.groq.com/docs/your-data
- Gemini (free versus paid data use): https://ai.google.dev/gemini-api/terms · https://ai.google.dev/pricing — a summary at https://simonwillison.net/2024/Oct/17/gemini-terms-of-service/
- Mistral: https://help.mistral.ai/en/articles/323757
- Cerebras: https://www.cerebras.ai/pricing

- Gemini, unpaid services and the warning on sensitive data: https://ai.google.dev/gemini-api/terms

Every row must be re-checked on the provider's own terms page on the day Tier B is built. Terms
change, and this table is true on the date above only. (On 2026-10-23 this session's container
could not open `ai.google.dev` or `console.groq.com` directly; the rows rest on search results
quoting those pages, which is why they say "to verify".)

## 6b. Our own logs — the words must not leak there either

Not sending words to a second provider is worthless if TEC writes them somewhere else.

- **The Life talk log lines (code-read, 2026-10-23):** they carry model, turns, tokens, time,
  guard rules, lead kind, search status. No words — `life-talk.controller.ts`, `search.ts`.
- **Sentry (`tec-ai-service/src/main.ts`):** in production it captures unhandled errors and
  samples 10% of traces. Whether an error event raised during a request carries the **request
  body** depends on the SDK's request-data defaults — **to verify**, and if it does, switch
  request bodies off for the Life routes.
- **To add with Tier B:** a test that asserts no log line or error report from the talk route
  contains any part of the conversation.

## 7. What does not change

- No kept memory without the person's confirmation.
- The eval never runs on real people's words.
- Search stays a general topic only, on request only.
- Payment, identity and the consent rows of C-106 §5 are untouched. Absence of a consent row
  means no: a new `GENERAL_AI` category, if built, is denied for everyone until they switch it
  on.
- The whole of TEC AI (Hub) is outside this document; it has its own chain.

## 8. Decisions for the owner

0. **Confirm Groq's Zero Data Retention on the account** (Groq console → Data Controls), and
   record the date here. Only the owner can see it. Everything Life says about Groq keeping
   nothing depends on it — today's consent included.
   **✅ Done, 2026-10-23 (owner's screenshots, organisation "TEC"):**
   - **Global ZDR: Enabled.** Groq's wording: "input and output data will not be logged", and it
     overrides the per-API settings.
   - **Inference APIs ZDR: Enabled.** That is the switch for the "up to 30 days" storage, the
     default since 15 Oct 2025.
   - **Batch: Off. Fine-tuning & LoRA: Off.**
   So §5a's **first version** ("Groq does not keep it") is the true one. Global ZDR covers the
   whole platform, which includes the audio endpoints (they are inference APIs). If voice is
   built, confirm the setting again on that day.
1. **The line:** are the Tier A and Tier B card lists in §3 right? Should `fitness`, `money` or
   `circumstances` move?
2. **Tier B at all, now?** Or only more Groq models now, and Tier B when Life has a paid provider?
   *Recommended:* more Groq models now; Tier B with Mistral only after its opt-out is verified;
   Gemini's free tier not at all.
3. **The corrected consent (§5a)** — ship it now, independent of Tier B? **Decided 2026-10-23:
   no.** Life shows people no technical detail, and the provider stays unnamed on screen. Today's
   text stays as it is, and it is accurate: ZDR is confirmed. What still holds: the text never claims
   more than the settings give. If Tier B is ever built, its consent must still say that **another**
   company may receive general topics — the wording can be plain, with no provider name in it.
4. **Voice on Groq whisper**, with the transcript shown before sending — approve to build after
   step 1 of quality is done?
5. **Images** — defer until there is income for a paid provider? *Recommended:* yes.
6. **Privacy page and terms** — the public privacy page must name Groq (and any Tier B provider)
   before either is used under that name. Who reviews the wording?

## 9. Order of work, if approved

1. Quality first (already agreed): merge #462 → the `allam-2-7b` test → a judged run with
   calibration. No new feature before that.
2. The corrected consent (§5a) and the privacy page naming Groq — text only.
3. Voice through Groq whisper, transcript shown first.
4. Tier B: the one gate over the whole payload (rule 0); sticky, mixed = A, unknown = A; the
   separate consent row; the memory filter; the tier log; and the logs check of §6b. Each with
   tests **through the real route**, not the classifier alone, and with eval scenarios that try to
   leak a Tier A topic into Tier B:
   - a mixed message;
   - an ambiguous one;
   - a business conversation that turns personal;
   - a business conversation carrying a sensitive kept note;
   - the provider changing mid-conversation.
5. Images — only after decision 5.

## 10. Review log

**2026-10-23, an external review the owner shared.** It agreed with the direction. Its reviewer
could not open this file: they looked in `Tec-core-backend`, where #220 is an unrelated
dependency PR. The file is in `tec-knowledge-base`, PR #220.

Applied:

- Groq's 30-day temporary logs and ZDR stated accurately (§2, §6), and made decision 0.
- Two consent versions, chosen by that fact.
- Voice wording separates TEC's storage from Groq's.
- One gate over the whole payload (rule 0).
- The limits of keyword classification, and where a classifier may run.
- Sticky scoped to one conversation, with no hidden carry-over.
- The safety response kept separate from the privacy rule.
- Mistral's separate API opt-out, and opt-out ≠ no retention.
- Gemini excluded on its own terms.
- Cerebras is promotional credit only.
- Withdrawal stops sending but does not erase.
- The logs and Sentry section (§6b).
- Tests through the real route.

Not applied:

- The Gemini 18+ clause stays "to verify". It could not be confirmed from a primary page in this
  session.
