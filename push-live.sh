#!/bin/bash
# Push all calculators live: deploy lang copies, commit, push to all remotes + Cloudflare Pages
set -e

MSG="${1:-Update}"

# Deploy language copies
bash deploy.sh alkoholikalkulaator
bash deploy.sh automaksu-kalkulaator
bash deploy.sh alkoholi-laskuri

# Commit everything
git add -A
git diff --cached --quiet && echo "Nothing to commit" || {
  git commit -m "$MSG

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"

  # Push to main repo (automaksu GitHub Pages)
  git push origin main

  # Push alkoholi subtree to its own GitHub repo
  git push alkoholi $(git subtree split --prefix=alkoholikalkulaator):main --force

  # Push Finnish site subtree to its own GitHub repo
  git push laskuri $(git subtree split --prefix=alkoholi-laskuri):main --force
}

# Deploy to Cloudflare Pages
export CLOUDFLARE_API_TOKEN=$(cat ~/.cloudflare-token)
npx wrangler@3 pages deploy alkoholikalkulaator --project-name=alkoholikalkulaator --branch=main --commit-dirty=true
npx wrangler@3 pages deploy alkoholi-laskuri --project-name=alkoholi-laskuri --branch=main --commit-dirty=true
# Victoriae lives in a DIFFERENT Cloudflare account (manipulusvictoriae@gmail.com).
# It authenticates via `npx wrangler@3 login` (OAuth), not the API token above, so the
# token is unset inside this subshell — otherwise it would target the wrong account.
(unset CLOUDFLARE_API_TOKEN; \
  CLOUDFLARE_ACCOUNT_ID=191773288e50a7c06b8a6345a882a821 \
  npx wrangler@3 pages deploy victoriae --project-name=restorebeauty --branch=main --commit-dirty=true)

echo ""
echo "✓ All live!"
