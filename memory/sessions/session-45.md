# SESSION 45 — TEC AI: the assistant stops being a second front door (21 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (tec-app #165 ·
> #166 · #167 · #168 merged; **#169 open**). The CEO runtime-verified #165–#168 in the Pi
> Browser on both surfaces. Constitutional detail: **C-104 §5.4–5.6**.

Session 44 made the assistant *answer*. This one made it a product: it renders what the
model actually emits, keeps its conversations, and has a menu that belongs to it.

| PR | What it closed |
|----|----------------|
| **#165** | Session state runtime-verified + hardened: "new chat" **archives** instead of deleting; stop keeps the partial; retry resends verbatim |
| **#166** | Markdown **tables** + mobile bubble width. A table now scrolls inside its bubble; before, `minWidth: 100%` + `word-break: break-all` shredded cells into `hub.tec / osyste / m.app` — a fix of mine that caused the thing it was meant to fix |
| **#167** | The intermittent **white strip** at the bottom of the page: `body` was painted, `html` was not, so overscroll exposed the UA's white canvas. `html { background: var(--black); color-scheme: dark }` |
| **#168** | The **shared assistant menu** — archived chats · starter questions · reply settings · support — replacing the `/ai` panel of Hub links |
| **#169** | The menu's own rough edges: a fourth tab clipped off-screen, an open menu fighting the chat on a phone, and `/ai` carrying a private Support panel the drawer did not have |

### The constitutional part (C-104 §5.6)

The `/ai` page had a "SERVICES" panel: **TEC Hub · Pay with Pi · My Dashboard · Digital
Assets** — direct routes into the platform, offered from a page the user had **not signed
in from**. The assistant had quietly become an alternative entrance beside *sign in with
Pi*, which C-47 names as the single entry point. It was **replaced, not relocated**.

The assistant still points at an app — through a **nav chip inside a reply**, where the
destination answers a question the user asked. A recommendation is earned by context; a
private menu of app links is a bypass.

The guard test asserts the **rule**, not the symptom: it walks every tab and checks the
scheme/host of every `href` — only `wa.me` / `t.me` / `mailto:` / `tel:` pass, and a
**relative** href fails. The first version asserted "no `<a>` at all" and had to be
rewritten the moment support gained legitimate outbound links.

### The drift, a fourth time

The drawer had no welcome (#164), then no menu (#168), then no support (#169) — each
found by the CEO on a phone, not by us. The structural answer is now written as law in
C-104 §5.6: **one component, both surfaces**; a capability on one AI surface and not the
other is a defect, not a roadmap item.

### Honest status
- `[Runtime Verified]`: streaming · markdown incl. tables · `dir="auto"` on real Arabic
  replies · archives · settings · the theme fix — all confirmed on both surfaces.
- `[Code Verified]` only: **#169** (open at time of writing) and `/api/ai/health`, which
  has still never been run against production keys.
- **Unchanged and still owed:** `ANTHROPIC_API_KEY` is unset, and the Claude branch still
  hardcodes a single 2024 model id with **no** candidate-list fallback — the exact defect
  §5.2 was written about. It must be fixed BEFORE that key is ever added.
