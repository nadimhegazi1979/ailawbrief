#!/bin/bash
# Publish AI Law Brief to GitHub Pages (ailawbrief.com).
# Run by the ailawbrief-daily-update scheduled task after content changes.
set -e
export PATH="$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"

# The cloud routine also pushes to main — sync first so histories never diverge.
git pull --rebase --autostash origin main

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
