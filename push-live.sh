#!/bin/bash
# Push all calculators live: deploy lang copies, commit, push to all remotes + Cloudflare Pages
set -e

MSG="${1:-Update}"

# Deploy language copies
bash deploy.sh alkoholikalkulaator
bash deploy.sh automaksu-kalkulaator

# Commit everything
git add -A
git diff --cached --quiet && echo "Nothing to commit" || {
  git commit -m "$MSG

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"

  # Push to main repo (automaksu GitHub Pages)
  git push origin main

  # Push alkoholi subtree to its own GitHub repo
  git push alkoholi $(git subtree split --prefix=alkoholikalkulaator):main --force
}

# Deploy alkoholi to Cloudflare Pages
export CLOUDFLARE_API_TOKEN=$(cat ~/.cloudflare-token)
npx wrangler pages deploy alkoholikalkulaator --project-name=alkoholikalkulaator --branch=main --commit-dirty=true

echo ""
echo "✓ All live!"
