# AI Law Brief — ailawbrief.com

A single-file static website tracking global laws AND court cases on generative AI (text, image, video, audio).

## Files
- `index.html` — the entire site: design, data, and logic in one self-contained file. No build step, no dependencies (the only external resource is Google Fonts).
- `robots.txt` — welcomes all crawlers, explicitly including AI/answer-engine bots (GPTBot, ClaudeBot, PerplexityBot, Google-Extended, CCBot); points to the sitemap.
- `llms.txt` — a summary of the site for AI assistants (llmstxt.org convention): coverage, entry structure, how to cite.
- `sitemap.xml` — regenerated with the current date by `deploy.sh` on every publish.
- `og.png` — 1200×630 social-preview card (referenced by og:image/twitter:image meta tags).

## SEO / AEO
The page injects schema.org JSON-LD at load time, generated from the live data arrays: `WebSite` + `Dataset`, plus an `ItemList` of `Legislation` objects (one per law, with `legislationIdentifier` = the formal citation) and an `ItemList` of `LegalCase` objects. Because it's generated from `LAWS`/`CASES`, it stays correct as entries change — no maintenance needed. JS-rendering crawlers (Google, Bing) see it; text-only AI crawlers get `llms.txt`, the meta tags, and the raw array text in the page source.

## Page structure
The page is a three-tab interface — **Laws & Regulations** (global + US federal), **US State Laws** (all 50 states with a color-coded clickable tile map), and **Case Law**. The laws and cases tabs have per-tab search and multi-select filter pills (values within a group combine as OR, groups as AND, "All" exclusive, click-again to toggle off). The states tab has a single-select coverage-level filter. A "Recent developments" strip under the hero lists the latest changes. Tabs deep-link via `#laws` / `#states` / `#cases`; entries deep-link via `#<entry-id>` (state-tagged laws auto-open inside their state card; states via `#state-XX`).

## How to update the tracker
All content lives in `index.html` in four clearly marked JavaScript arrays near the bottom of the file — `LAWS`, `CASES`, `STATES`, and `RECENT`:

0a. **`const STATES = [...]`** — one object per US state: `{code, name, level, summary, laws: [{name, year, status, note}]}`. `level`: `comprehensive` | `targeted` | `deepfake-only` | `proposed-only` | `none`; law `status`: `in-force` | `enacted` | `proposed`. Keep summaries ≤25 words and law notes ≤14 words — this tab is deliberately concise. Detailed LAWS entries link into state cards via their `usState: "XX"` field (they render under "Deep dives" and are excluded from the global laws tab).
0b. **`const RECENT = [...]`** — the "Recent developments" strip: `{d: "Aug 13", t: "one-line description", id: "related-entry-id"}`, newest first, cap at 8.

1. **`const LAWS = [...]`** — one object per law. To add a law, copy an existing entry and edit its fields:
   - `status`: `in-force` | `partially-in-force` | `enacted-not-yet-effective` | `proposed` | `guidance` | `enjoined`
   - `modalities`: any of `text`, `image`, `video`, `audio`, or `all`
   - `region`: `Europe` | `Americas` | `Asia-Pacific` | `Middle East` (a new region also needs a filter pill and an entry in `REGION_ORDER`)
2. **`const CASES = [...]`** — one object per court case:
   - `caseStatus`: `pending` | `decided` | `settled` | `on-appeal`
   - `issues`: tags from the `ISSUE_LABEL` map (training-data, fair-use, output-infringement, right-of-publicity, voice-cloning, defamation, product-liability, free-speech, trademark, dmca, constitutional-challenge, consumer-protection)
   - `modalities` and `region`: same values as laws

Every law and case entry carries a **`citation`** field — the formal legal citation (OJ citation, Public Law number, code section, docket number, or neutral citation). Citations are NOT displayed on the cards (removed Aug 2026 for a cleaner UX) but are kept in the data: they feed the page's schema.org structured data (`legislationIdentifier`) and full-text search, so keep populating the field for new entries. Where a precise codified cite can't be verified, use the bill/session form.

Entries may also carry a **`commentary`** array — curated "Commentary & analysis" links (law-firm client alerts, academic articles, think-tank pieces): `{title, source, url, type}` where `type` is `law-firm` | `academic` | `think-tank` | `official`. Rule: every URL must be verified to load and to discuss the specific instrument before being added — never guess URLs. Keep it to 2–3 high-quality pieces per entry.

Also update the **"Last reviewed"** date in the hero section (`id="last-updated"`) whenever entries change.

Stats (law count, case count, jurisdiction count, in-force count) are computed automatically.

## Automatic daily updates
Primary: a **GitHub Actions workflow** (`.github/workflows/daily-update.yml`) runs daily at 14:00 UTC (7:00 AM Pacific) on GitHub's servers — independent of any local machine. It uses `anthropics/claude-code-action` with an Anthropic API key stored as the `ANTHROPIC_API_KEY` repository secret, re-verifies watch items, scans for developments, updates the data arrays, and publishes via `deploy.sh`. Trigger manually from the Actions tab ("Run workflow") or `gh workflow run daily-update.yml`.

(Legacy: a Claude-desktop-app scheduled task `ailawbrief-daily-update` exists but is disabled — it only ran while the app was open. A paused claude.ai cloud routine also exists, blocked on enterprise GitHub App access.)

## Publishing
Deployed via **GitHub Pages** from https://github.com/nadimhegazi1979/ailawbrief (main branch, root). The `CNAME` file binds the custom domain ailawbrief.com; DNS at GoDaddy points the apex to GitHub Pages' A records and `www` to `nadimhegazi1979.github.io`.

To publish changes: run `./deploy.sh` (commits and pushes; Pages rebuilds in about a minute). The daily scheduled task runs it automatically after content updates. Git pushes authenticate through the GitHub CLI (`~/.local/bin/gh`, token in the macOS keychain).

## Content status
Entry statuses were verified against official sources in October 2026. Known watch items at that date:

**Laws:**
- **EU Digital Omnibus**: RESOLVED Aug 2026 — Regulation (EU) 2026/1744, OJ 24.7.2026, in force Jul 27, 2026; cited on the EU AI Act entry. High-risk (Annex III) duties now deferred to Dec 2, 2027.
- **Denmark deepfake copyright amendment**: RESOLVED Oct 2026 — revised bill (L 49) reintroduced Oct 8, 2026 by Culture Minister Zenia Stampe; still "proposed." Watch for passage and a Jan 1, 2027 commencement.
- **Italy**: RESOLVED Oct 2026 — D.Lgs. 179/2026 (G.U. n. 234, 8.10.2026, in force Oct 23, 2026) closed the Law 132/2025 delegation. Watch for AgID/ACN enforcement practice.
- **Saudi Arabia**: RESOLVED Oct 2026 — added as a LAWS entry (Royal Decree M/169, art. 26 AI-training exception, in force Aug 12, 2026). Watch for SAIP implementing regulations defining the proportionality limits.
- **China**: RESOLVED Oct 2026 — TC260 AI Safety Governance Framework 3.0 published Sep 14, 2026. Watch for the promised mandatory national standard on AI-agent applications.
- **Spain**: still a bill — approved as a Proyecto de Ley May 26, 2026, published by Congress Jun 12, 2026; committee stage ongoing.
- **Brazil PL 2338**: rapporteur Aguinaldo Ribeiro confirmed (Aug 24, 2026) the Chamber vote waits until after the October 2026 elections. Watch the Nov–Dec session.
- **Australia**: National Cabinet agreed the framework Aug 26, 2026; Commonwealth bill expected early 2027 — will flip from guidance to binding.
- **Utah AI Policy Act**: sunsets Jul 1, 2027 unless reauthorized.
- **South Korea**: fine enforcement begins ~early 2027 after the one-year grace period ends Jan 22, 2027.
- **California**: SB 1000 took effect immediately on signing (Sep 30, 2026); AB 2713, SB 1111 and AB 1609 are operative in 2027 — flip those state-entry rows to `in-force` in January.

**Cases:**
- **Thomson Reuters v. Ross** — RESOLVED Sep 29, 2026: 3d Cir. affirmed; first appellate ruling that AI training was not fair use, expressly carved out from generative AI. Watch for a cert petition.
- **Doe v. GitHub** — RESOLVED Sep 16, 2026: 9th Cir. (No. 24-7700) affirmed dismissal of the § 1202(b) claims; the training-stage CMI theory survives for a future case that pleads it.
- **OpenAI MDL** — cross-SJ motions filed Sep 4, 2026; OpenAI/Microsoft responses due Oct 23, replies Nov 6. Judge Stein's fair-use ruling is the biggest pending item.
- **Kohls v. Bonta** — 9th Cir., fully briefed: election-deepfake laws (also flips the AB 2839/2655 law entry if reversed).
- **xAI v. Bonta** — 9th Cir. oral argument set for Nov 18, 2026: AB 2013 training-data transparency.
- **CJEU "Like Company" (C-250/25)** — AG Szpunar's opinion slipped from Sep 3; now reported for Nov 19, 2026. Judgment months later. Could affect both GEMA appeals.
- **Getty v. Stability (UK)** — Court of Appeal, hearing expected late 2026/2027: are model weights infringing copies?
- **Bartz v. Anthropic** — settlement final; fee-side appeals pending; first payments expected on or before Nov 15, 2026.
- **Kadrey v. Meta** — interlocutory appeal denied Jul 2026; Chhabria said final judgment would follow shortly. Expect a 9th Cir. appeal — flip to on-appeal when entered.
- **Eight state AGs v. OpenAI** — filed Oct 14, 2026 in eight state courts; watch for removal fights, MTDs, and more states joining.
- **Andersen v. Stability** — trial continued to Apr 5, 2027.
- **GEMA v. OpenAI / v. Suno** — Munich appeals pending.
- **xAI v. Weiser** — may be amended or mooted after Colorado replaced its AI Act.
- **Reddit v. SerpApi/Perplexity** — discovery phase; watch for the docket number to upgrade the citation.
- **xAI v. Ellison** — PI denied Sep 4, 2026; Eighth Circuit appeal expected; MTD pending in district court.
- **Massachusetts** — synthetic-CSAM amendment still in economic-development conference committee.
- **Federal Rules of Evidence** — the Advisory Committee's proposed Rule 901(c) on authenticating possibly AI-fabricated evidence was discussed Oct 15, 2026; track if it advances.
