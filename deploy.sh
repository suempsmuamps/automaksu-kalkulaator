#!/bin/bash
# Deploy script: copies index.html to language subdirectories for each calculator
# Usage: ./deploy.sh [calculator-dir]
# If no dir specified, deploys all calculators

set -e

get_langs() {
  case "$1" in
    alkoholi-laskuri) echo "sv en ru et" ;;
    *)                echo "en ru fi" ;;
  esac
}

deploy_calc() {
  local dir="$1"
  if [ ! -f "$dir/index.html" ]; then
    echo "Skip $dir (no index.html)"
    return
  fi
  local langs=$(get_langs "$dir")
  for lang in $langs; do
    mkdir -p "$dir/$lang"
    cp "$dir/index.html" "$dir/$lang/index.html"
  done
  echo "Deployed $dir -> $langs"
}

if [ -n "$1" ]; then
  deploy_calc "$1"
else
  for dir in */; do
    dir="${dir%/}"
    [ -f "$dir/index.html" ] && deploy_calc "$dir"
  done
fi
