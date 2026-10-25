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
# Victoriae lives in a DIFFERENT Cloudflare account (manipulusvictoriae@gmail.com),
# so it uses its own scoped API token rather than the one above. Create the token at
# dash.cloudflare.com -> My Profile -> API Tokens with Pages:Edit on account
# 191773288e50a7c06b8a6345a882a821, then: pbpaste > ~/.cloudflare-token-victoriae
(
  VICTORIAE_TOKEN_FILE="$HOME/.cloudflare-token-victoriae"
  if [ ! -s "$VICTORIAE_TOKEN_FILE" ]; then
    echo ""
    echo "✗ Skipping victoriae: $VICTORIAE_TOKEN_FILE is missing or empty."
    echo "  Create a Pages:Edit token for account 191773288e50a7c06b8a6345a882a821 and save it there."
    exit 0
  fi
  export CLOUDFLARE_API_TOKEN=$(tr -d '[:space:]' < "$VICTORIAE_TOKEN_FILE")
  export CLOUDFLARE_ACCOUNT_ID=191773288e50a7c06b8a6345a882a821
  npx wrangler@3 pages deploy victoriae --project-name=restorebeauty --branch=main --commit-dirty=true
)

echo ""
echo "✓ All live!"
