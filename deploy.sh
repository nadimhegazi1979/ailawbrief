#!/bin/bash
# Publish AI Law Brief to GitHub Pages (ailawbrief.com).
# Run by the ailawbrief-daily-update scheduled task after content changes.
set -e
export PATH="$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"

# The cloud routine also pushes to main — sync first so histories never diverge.
git pull --rebase --autostash origin main

# Regenerate the sitemap with today's date so crawlers see content freshness.
cat > sitemap.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://ailawbrief.com/</loc>
    <lastmod>$(date +%Y-%m-%d)</lastmod>
    <changefreq>daily</changefreq>
  </url>
</urlset>
EOF

git add -A
if git diff --cached --quiet; then
  echo "No changes to deploy."
else
  git commit -m "Content update $(date '+%Y-%m-%d')

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
  git push origin main
  echo "Pushed — GitHub Pages will rebuild ailawbrief.com in ~1 minute."
fi

# Enforce HTTPS once GitHub has issued the certificate (harmless no-op until then).
gh api -X PUT repos/nadimhegazi1979/ailawbrief/pages -f cname=ailawbrief.com -F https_enforced=true >/dev/null 2>&1 || true
