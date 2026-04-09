#!/bin/bash
# Push all calculators live: deploy lang copies, commit, push to all remotes
set -e

MSG="${1:-Update}"

# Deploy language copies
bash deploy.sh alkoholikalkulaator
bash deploy.sh automaksu-kalkulaator

# Commit everything
git add -A
git diff --cached --quiet && echo "Nothing to commit" && exit 0
git commit -m "$MSG

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"

# Push to main repo
git push origin main

# Push alkoholi subtree to its own repo
git push alkoholi $(git subtree split --prefix=alkoholikalkulaator):main --force

echo ""
echo "✓ All live!"
