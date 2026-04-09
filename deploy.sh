#!/bin/bash
# Deploy script: copies index.html to language subdirectories for each calculator
# Usage: ./deploy.sh [calculator-dir]
# If no dir specified, deploys all calculators

set -e

LANGS="en ru fi"

deploy_calc() {
  local dir="$1"
  if [ ! -f "$dir/index.html" ]; then
    echo "Skip $dir (no index.html)"
    return
  fi
  for lang in $LANGS; do
    mkdir -p "$dir/$lang"
    cp "$dir/index.html" "$dir/$lang/index.html"
  done
  echo "Deployed $dir -> $LANGS"
}

if [ -n "$1" ]; then
  deploy_calc "$1"
else
  for dir in */; do
    [ -f "$dir/index.html" ] && deploy_calc "$dir"
  done
fi
