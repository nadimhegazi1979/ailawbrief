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
Entry statuses were verified against official sources in August 2026. Known watch items at that date:

**Laws:**
- **EU Digital Omnibus**: RESOLVED Aug 2026 — confirmed as Regulation (EU) 2026/1744, OJ 24.7.2026, in force Jul 27, 2026; cited on the EU AI Act entry.
- **Denmark deepfake copyright amendment**: downgraded to "proposed" Aug 2026 — the bill appears to have lapsed when the Mar 2026 snap election dissolved parliament before final passage. Watch for reintroduction; confirm against retsinformation.dk.
- **Spain**: still a bill; amendment deadline extended to Sep 16, 2026, committee vote slipping.
- **Brazil PL 2338**: rapporteur says Chamber vote after the October 2026 elections.
- **Australia**: National Cabinet agreed the framework Aug 26, 2026; Commonwealth bill expected early 2027 — will flip from guidance to binding.
- **Utah AI Policy Act**: sunsets Jul 1, 2027 unless reauthorized.
- **South Korea**: fine enforcement begins ~early 2027 after grace period.

**Cases (pending decisions that could land any week):**
- **Thomson Reuters v. Ross** — 3d Cir., argued Jun 11, 2026: first appellate ruling on AI-training fair use.
- **Doe v. GitHub** — 9th Cir., argued Feb 11, 2026: DMCA § 1202(b) identicality.
- **Kohls v. Bonta** — 9th Cir., fully briefed: election-deepfake laws (also flips the AB 2839/2655 law entry if reversed).
- **xAI v. Bonta** — 9th Cir., argued Jul 2026: AB 2013 training-data transparency (also affects the AB 2013 law entry).
- **Getty v. Stability (UK)** — Court of Appeal, hearing date TBD: are model weights infringing copies?
- **Bartz v. Anthropic** — settlement effectively final (window closed Aug 19); fee-side appeals pending; distribution underway.
- **Kadrey v. Meta** — final judgment imminent; expect status change to on-appeal.
- **Andersen v. Stability** — trial continued to Apr 5, 2027.
- **GEMA v. OpenAI / v. Suno** — Munich appeals pending.
- **xAI v. Weiser** — may be amended or mooted after Colorado replaced its AI Act.
- **Reddit v. SerpApi/Perplexity** — discovery phase; watch for the docket number to upgrade the citation.
- **xAI v. Ellison** — PI denied Sep 4, 2026; Eighth Circuit appeal expected; MTD pending in district court.
- **OpenAI MDL** — cross-SJ motions filed Sep 4, 2026 (DOJ statement of interest backs fair use); decision watch through winter.
- **California desk bills** — SB 1111, AB 2713, SB 1000, AB 1609, SB 903 await Newsom's signature/veto by ~Sep 30, 2026.
- **CJEU "Like Company"** — ruling reportedly due Sept 2026; could affect both GEMA appeals (unverified — confirm).
- **Italy** — Law 132/2025 implementing decrees due by the Oct 10, 2026 delegation deadline.
- **Denmark** — watch the Folketing's October session program for deepfake-bill reintroduction.
- **China** — AI Safety Governance Framework 3.0 expected during Cybersecurity Week (Sep 14-20, 2026).
- **Saudi Arabia** — new Copyright Law (in force Aug 1, 2026) reportedly includes a TDM-style AI-training exception; verify against the gazette before adding an entry.
- **Massachusetts** — synthetic-CSAM amendment still in economic-development conference committee.
