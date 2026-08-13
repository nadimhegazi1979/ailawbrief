# AI Law Brief — ailawbrief.com

A single-file static website tracking global laws AND court cases on generative AI (text, image, video, audio).

## Files
- `index.html` — the entire site: design, data, and logic in one self-contained file. No build step, no dependencies (the only external resource is Google Fonts).

## Page structure
The page is a two-tab interface — **Laws & Regulations** and **Case Law** — each tab with its own search box and filter pills (region, modality, status; the cases tab adds an issue filter). Tabs deep-link via `#laws` / `#cases`, and individual entries deep-link via `#<entry-id>` (auto-opens the right tab and card).

## How to update the tracker
All content lives in `index.html` in two clearly marked JavaScript arrays near the bottom of the file:

1. **`const LAWS = [...]`** — one object per law. To add a law, copy an existing entry and edit its fields:
   - `status`: `in-force` | `partially-in-force` | `enacted-not-yet-effective` | `proposed` | `guidance` | `enjoined`
   - `modalities`: any of `text`, `image`, `video`, `audio`, or `all`
   - `region`: `Europe` | `Americas` | `Asia-Pacific` | `Middle East` (a new region also needs a filter pill and an entry in `REGION_ORDER`)
2. **`const CASES = [...]`** — one object per court case:
   - `caseStatus`: `pending` | `decided` | `settled` | `on-appeal`
   - `issues`: tags from the `ISSUE_LABEL` map (training-data, fair-use, output-infringement, right-of-publicity, voice-cloning, defamation, product-liability, free-speech, trademark, dmca, constitutional-challenge, consumer-protection)
   - `modalities` and `region`: same values as laws

Every law and case entry carries a **`citation`** field — the formal legal citation (OJ citation, Public Law number, code section, docket number, or neutral citation) — shown in the card next to the `officialLink`. Where a precise codified cite couldn't be verified, the citation uses the bill/session form (e.g. "Tex. HB 149, 89th Leg. (2025)"), which is always accurate; upgrade to code sections when verified.

Also update the **"Last reviewed"** date in the hero section (`id="last-updated"`) whenever entries change.

Stats (law count, case count, jurisdiction count, in-force count) are computed automatically.

## Automatic daily updates
A scheduled task (`ailawbrief-daily-update`, 7:03 AM daily, managed in the Claude desktop app under "Scheduled") re-verifies watch items, scans for new laws and rulings, updates the arrays and the last-reviewed date, and runs `deploy.sh` if it exists. Runs happen while the app is open; a missed run fires at next launch.

## Publishing
Deployed via **GitHub Pages** from https://github.com/nadimhegazi1979/ailawbrief (main branch, root). The `CNAME` file binds the custom domain ailawbrief.com; DNS at GoDaddy points the apex to GitHub Pages' A records and `www` to `nadimhegazi1979.github.io`.

To publish changes: run `./deploy.sh` (commits and pushes; Pages rebuilds in about a minute). The daily scheduled task runs it automatically after content updates. Git pushes authenticate through the GitHub CLI (`~/.local/bin/gh`, token in the macOS keychain).

## Content status
Entry statuses were verified against official sources in August 2026. Known watch items at that date:

**Laws:**
- **EU Digital Omnibus**: confirm the final Official Journal citation and exact Art. 50(2) transition wording.
- **Denmark deepfake copyright amendment**: commencement date (reported Mar 31, 2026) should be confirmed against the consolidated act on retsinformation.dk.
- **Spain**: still a bill; committee vote expected autumn 2026.
- **Brazil PL 2338**: Chamber of Deputies vote anticipated around Aug 2026.
- **Australia**: legislated "Australian Standards for AI" announced July 2026 — could flip from guidance to binding.
- **Utah AI Policy Act**: sunsets Jul 1, 2027 unless reauthorized.
- **South Korea**: fine enforcement begins ~early 2027 after grace period.

**Cases (pending decisions that could land any week):**
- **Thomson Reuters v. Ross** — 3d Cir., argued Jun 11, 2026: first appellate ruling on AI-training fair use.
- **Doe v. GitHub** — 9th Cir., argued Feb 11, 2026: DMCA § 1202(b) identicality.
- **Kohls v. Bonta** — 9th Cir., fully briefed: election-deepfake laws (also flips the AB 2839/2655 law entry if reversed).
- **xAI v. Bonta** — 9th Cir., argued Jul 2026: AB 2013 training-data transparency (also affects the AB 2013 law entry).
- **Getty v. Stability (UK)** — Court of Appeal, hearing date TBD: are model weights infringing copies?
- **Bartz v. Anthropic** — objector-appeal window open after Jul 20, 2026 final approval.
- **Kadrey v. Meta** — final judgment imminent; expect status change to on-appeal.
- **Andersen v. Stability** — trial reportedly set Sep 8, 2026 (date from secondary sources; confirm on docket).
- **GEMA v. OpenAI / v. Suno** — Munich appeals pending.
- **xAI v. Weiser** — may be amended or mooted after Colorado replaced its AI Act.
