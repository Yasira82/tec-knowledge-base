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
| Retention | The controller's header states Groq's Zero Data Retention is on for the account |
| What is removed before sending | Numbers, emails, links (`minimise.ts`) |
| What is kept by TEC | Nothing from the conversation, unless the person confirms a summary at the end |
| Search | Tavily, only when the person asks; only a general topic is sent, never their words |
| Consent shown | `session-copy.ts` `introAi` — the words go to "an AI model"; "the model's provider does not keep it for us". The provider is **not named** on screen; the privacy page names only "infrastructure providers" |

The last row is a gap even without this proposal: the consent never names the provider. §5
proposes the text that fixes it.

## 3. The proposal — two tiers

### Tier A — sensitive: Groq only, always

What a person says about **their body, their mind, their faith, their family, their money or the
people around them** never leaves Groq, whatever they agreed to elsewhere.

Life already recognises these topics: they are cards in `life-talk/cards.ts`. Proposed **Tier A
cards**:

`smoking` · `health` · `fitness` · `feeling` · `anger` · `loneliness` · `confidence` · `faith` ·
`conflict` · `parenting` · `grief` · `lost` · `people` · `circumstances` · `money`

Plus, always Tier A:

- any reply where the safety rule fires (self-harm, harm to others, danger);
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

1. **The tier is decided in code, from the cards, before anything is sent** — never by a model,
   and never by the other provider.
2. **Sticky.** Once a conversation touches a Tier A topic, it stays Tier A to its end. A person
   who starts with their business and then says their marriage is falling apart has said
   something Tier A; the next reply and every one after it go to Groq.
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
- The audio is never stored by TEC.
- A voice is more identifying than text (a voice print, a background, other people in the room).
  So the first use asks once: «يُرسَل تسجيلك الصوتي إلى Groq ليحوَّل إلى نص، ثم يُحذف».
- To verify: that Zero Data Retention covers audio transcription too, not only chat (§6).

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

> لكي يرد عليك، يُرسَل ما تكتبه إلى نموذج ذكاء اصطناعي تشغّله شركة Groq. لا نحتفظ به، ولا تحتفظ
> به Groq. تُحذف الأرقام والبريد والروابط قبل الإرسال — لكن ذلك لا يجعل كلامك مجهول الهوية
> تمامًا.

> To reply, what you write is sent to an AI model run by Groq. We do not keep it, and Groq does
> not keep it. Numbers, emails and links are removed before it is sent — but that does not make
> your words fully anonymous.

### b. The Tier B consent (a separate switch, off by default)

> **استخدام نماذج أخرى في المواضيع العامة**
> عندما تتحدث عن عملك أو مشروعك أو تعلّم مهارة أو تنظيم وقتك، يمكن أن يرد عليك نموذج من شركة
> [المزوّد]. [المزوّد] [قد يستخدم كلامك لتحسين خدماته / لا يحتفظ بكلامك] — اقرأ شروطه [رابط].
> أما ما تقوله عن صحتك أو مشاعرك أو إيمانك أو أسرتك أو مالك أو الناس من حولك، فلا يُرسَل إليه
> أبدًا، ويبقى مع Groq وحده. ويمكنك إيقاف هذا في أي وقت من الإعدادات.

> **Use other models for general topics**
> When you talk about your work, your business, learning a skill or organising your time, a model
> from [provider] may reply. [Provider] [may use your words to improve its services / does not
> keep your words] — read its terms [link]. What you say about your health, your feelings, your
> faith, your family, your money or the people around you is never sent to it; it stays with Groq
> alone. You can switch this off at any time in Settings.

The bracket must be filled with what the provider's terms actually say — never softened.

## 6. Candidate providers for Tier B (searched 2026-10-23)

| Provider (free use) | Trains on the words? | Keeps them? | Verdict |
|---|---|---|---|
| **Groq**, more models (e.g. `allam-2-7b`) | Not stated — **to verify** in Groq's Trust Center / DPA | No by default; Zero Data Retention toggle in Data Controls; data held in GCP, US. The docs page's own description also mentions logs kept up to 30 days — **to verify** which applies | Same tier as today; needs no new consent. **First step.** |
| **Mistral**, free "Experiment" plan | Yes, may — with an opt-out — **to verify** that the opt-out exists for API use and how it is set | To verify | Best free Tier B candidate, if the opt-out holds |
| **Google Gemini API**, free tier | Yes — free-tier inputs and outputs are used to improve Google's products, and **human reviewers may read them** | Yes | Tier B only if the consent says exactly that. Recommended: **not**, until a paid tier |
| **Cerebras** | Unclear — **to verify** | States inference inputs and outputs are not retained — **to verify** in its own terms | No permanent free tier (trial credits only) → not a candidate now |

Sources:
- Groq: https://console.groq.com/docs/your-data
- Gemini (free versus paid data use): https://ai.google.dev/gemini-api/terms · https://ai.google.dev/pricing — a summary at https://simonwillison.net/2024/Oct/17/gemini-terms-of-service/
- Mistral: https://help.mistral.ai/en/articles/323757
- Cerebras: https://www.cerebras.ai/pricing

Every row must be re-checked on the provider's own terms page on the day Tier B is built. Terms
change, and this table is true on the date above only.

## 7. What does not change

- No kept memory without the person's confirmation.
- The eval never runs on real people's words.
- Search stays a general topic only, on request only.
- Payment, identity and the consent rows of C-106 §5 are untouched. Absence of a consent row
  means no: a new `GENERAL_AI` category, if built, is denied for everyone until they switch it
  on.
- The whole of TEC AI (Hub) is outside this document; it has its own chain.

## 8. Decisions for the owner

1. **The line:** are the Tier A and Tier B card lists in §3 right? Should `fitness`, `money` or
   `circumstances` move?
2. **Tier B at all, now?** Or only more Groq models now, and Tier B when Life has a paid provider?
   *Recommended:* more Groq models now; Tier B with Mistral only after its opt-out is verified;
   Gemini's free tier not at all.
3. **The corrected consent (§5a)** — ship it now, independent of Tier B? *Recommended:* yes. The
   person should know the provider's name today.
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
4. Tier B: the classifier in code from the cards (sticky, mixed = A, unknown = A), the separate
   consent row, the memory filter, the tier log — each with tests, and eval scenarios that try to
   leak a Tier A topic into Tier B.
5. Images — only after decision 5.
