# الجولة التالتة — قائمة الإطلاق (14 نوفمبر 2026)

> Truth State: **[Current State]** للكود (`tec-core-backend` و`tec-app` على `main`) ·
> **[Planned State]** للإطلاق · Governance: قرار المالك في
> `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` §4b. مفيش حاجة هنا اتنفذت لسه.

الجولة جاهزة في الكود من 30 أكتوبر (tec-core-backend #472 · tec-app #321)، والشرط اللي كان
موقفها (تغيير الأسرار بعد اختراق Railway) خلص يوم 11 نوفمبر. القائمة دي هي اللي فاضل، بالترتيب.

## 1. قبل أي حاجة — فحص على الموبايل (Pi Browser)

ده "Left open 1" من الجلستين 62 و63. من غيره ممكن نفتح جولة الناس متقدرش تخلص مهامها فيها.

1. افتح Pi Browser ← `hub.tecosystem.app` ← سجّل دخول.
2. افتح `hub.tecosystem.app/hub/campaign` — لازم الصفحة تظهر من غير خطأ.
3. من صفحة الحملة افتح **Commerce** و**Assets** و**Zone** (ضغطة من الصفحة، مش من شبكة التطبيقات —
   الزيارة من الشبكة مش بتتحسب عند Pi).
4. في كل واحد افتح `/pi-test`: لازم يقول إن تسجيل الدخول بـ Pi نجح وإن الوصول اتسجل.
5. اعمل دفعة صغيرة في تطبيق واحد (مثلاً Assets Pro)، وتأكد إن المحفظة فتحت والدفع خلص.

لو أي خطوة فشلت: صوّرها وابعتهالي، ومتفتحش الجولة.

## 2. متغيرات Railway — على `tec-platform-service` (مش identity)

الحملة اتنقلت لـ `tec-platform-service` يوم 15 أكتوبر (#428). متغيرات الجولة التانية كانت على
`tec-identity-service`، فلازم تتأكد إنها موجودة على platform:

| المتغير | القيمة | ليه |
|---|---|---|
| `CAMPAIGN_MODE` | `pick` | يشغّل الجولة التالتة (من غيره بتشتغل زي الجولة التانية) |
| `CAMPAIGN_APPS` | `tec,commerce,ecommerce,assets,life,zone` | الستة اللي اخترتهم (5 أكتوبر) |
| `CAMPAIGN_APPS_PER_PIONEER` | `6` | كل واحد ياخد الستة |
| `CAMPAIGN_REWARD_PI` | `0.85` | لكل تطبيق — 5.1π للستة |
| `CAMPAIGN_SEATS` | `25` | الميزانية: 25 × 5.1 = **127.5π** |
| `CAMPAIGN_HOLD_HOURS` | `48` | المقعد يرجع لو مفيش تقرير خلال 48 ساعة (ده الافتراضي) |
| `CAMPAIGN_TARGET` | (فاضي) | الستة دول بالظبط، مش "الدومينات اللي لسه مفتحتش" |
| `CAMPAIGN_REQUIRE_ARRIVAL` | (فاضي) | الضغطة تكفي؛ المراجعة بتاعتك هي البوابة |
| `CAMPAIGN_VISITS_FROM` | وقت الفتح بالظبط، مثلاً `2026-11-20T18:00:00Z` | **مهم:** ده اللي بيبدأ جولة جديدة — تجربتك القديمة ومقاعدها مش هتتحسب |

- `CAMPAIGN_VISITS_FROM` اتحط **آخر حاجة**، في لحظة الفتح. قبلها الصفحة بتاعة الجولة لسه على
  الجولة القديمة.
- بعد ما تحط المتغيرات، Railway بيعمل redeploy لوحده. استنى لحد ما يبقى Active.

## 3. الدفع للفائزين — يدوي

- محفظة الـ Hub على Mainnet اعتبرناها محروقة (30 أكتوبر)، فمفيش A2U. المكافأة بتتبعت **من
  محفظتك بإيدك**، وبعدها `Mark sent` في `/hub/admin/campaign` — والصفحة بتتأكد من السلسلة إن
  التحويل حصل فعلاً.
- جهّز **127.5π** على الأقل في المحفظة اللي هتدفع منها، قبل الفتح.
- المبلغ بيتثبت على كل claim لحظة ما يتعمل، فمتغيرش `CAMPAIGN_REWARD_PI` بعد الفتح.

## 4. المراجعة — كل يوم

- `/hub/admin/campaign`: كل تقرير **Approve** أو **Needs revision** بملاحظة (عمرها ما تبقى رفض).
- العلامة جنب التقرير: `partial` = التطبيق شاف تسجيل الدخول · `declared` = مشافهوش. `declared`
  مش رفض أوتوماتيكي، بس اقرأه بعناية.
- التقرير المنسوخ من تطبيق لتطبيق بيترفض من الخدمة نفسها (#472).
- `/hub/admin/campaign/diagnose` لو حد اشتكى إن مهمة مش بتفتح.
- اقرأ أسباب التوقف (funnel) بعد أول 48 ساعة: لو أغلبها "كتير / طويل"، اللي يتغير هو
  `CAMPAIGN_APPS_PER_PIONEER`، مش المكافأة.

## 5. الإعلان

بعد ما 1–4 يخلصوا. نفس المكان والأسلوب بتوع الجولة التانية: r/PiNetwork، flair
**Pi Apps** + **Brand Affiliate**، من غير ترويج مدفوع، ورابط عليه
`utm_source=reddit&utm_campaign=pi-reward-r3`. المسودة في §7.

## 6. ما بعد الفتح

- كل تطبيق محتاج **5 Pioneers موثقين KYC** يسجلوا دخول فيه، قبل **19 ديسمبر 2026** (موعد Pi
  للدومينات). الـ 25 مقعد × 6 تطبيقات بيغطي ده لو 5 بس كمّلوا كل التطبيقات.
- لما Pi يوافق على دومين، ضيفه لـ `PI_CLAIMED_APPS` على platform-service.
- الجولة اللي بعدها (لما الـ 25 مقعد يخلصوا): ستة تطبيقات تانيين، `CAMPAIGN_APPS` جديدة و
  `CAMPAIGN_VISITS_FROM` جديد — نفس المكافأة.

## 7. مسودة الإعلان (Reddit — إنجليزي)

> **TEC Round 3 — try 6 Pi apps, tell us what happened, earn 5.1 π**
>
> We build TEC, a set of Pi apps (Hub, Commerce, Ecommerce, Assets, Life, Zone…). Round 3 is
> not "click and leave": we want to know what actually happens when a Pioneer uses them.
>
> **How it works**
> 1. Open **hub.tecosystem.app/hub/campaign** in Pi Browser and sign in with Pi.
> 2. Tap **Get my apps** — you get 6 apps, each with one small task.
> 3. After each one, write a short report: what happened, whether something went wrong, and
>    what was clear or useful. A report that found nothing wrong counts too.
> 4. We read every report. If one needs more detail, we ask — we never reject.
> 5. All 6 approved → **5.1 π** (0.85 π each), sent to your Mainnet wallet.
>
> **The fine print, plainly:** 25 seats this round. A seat is yours from the moment you get
> your apps; it goes back to the pool if you send no report within 48 hours. No payment is
> needed at any step. Rewards are sent by hand after review, so allow a few days.
> One claim per person and per wallet.
>
> Questions in the comments — we answer all of them.

النسخة العربي (لو هتنشر في جروب عربي):

> **الجولة التالتة من TEC — جرّب 6 تطبيقات Pi، قولنا حصل إيه، واكسب 5.1 π**
>
> افتح **hub.tecosystem.app/hub/campaign** من Pi Browser وسجّل دخول. اضغط **Get my apps** —
> هتاخد 6 تطبيقات، لكل واحد مهمة صغيرة. بعد كل تطبيق اكتب تقرير قصير: حصل إيه، فيه مشكلة ولا لأ،
> وإيه اللي كان واضح أو مفيد. التقرير اللي ملقاش مشاكل محسوب برضه. بنقرا كل تقرير، ولو محتاج
> تفاصيل أكتر بنطلبها — عمرنا ما بنرفض. الستة يتقبلوا ← **5.1 π** على محفظتك (Mainnet).
>
> 25 مقعد بس في الجولة دي. المقعد بتاعك من لحظة ما تاخد التطبيقات، ويرجع لو مبعتش تقرير في 48
> ساعة. مفيش أي دفع مطلوب منك. المكافأة بتتبعت بعد المراجعة، فممكن تاخد كام يوم.

## Related Documents

- `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` — the decision (§4b)
- C-133 (growth layer) · C-134 (Pioneer runtime) · C-123 §14 (sign-in door)
- `memory/sessions/session-62.md` · `session-63.md` — the phone check left open
