#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <query>" >&2
  exit 1
fi

QUERY="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OPEN_HELPER="$ROOT/build/office-suite/scripts/office_open.sh"

SEARCH_OUT="$($ROOT/build/office-suite/scripts/office_search_handoff.sh "$QUERY" 2>/dev/null || true)"
FIRST_PATH="$(printf '%s
' "$SEARCH_OUT" | head -n 1)"

if [[ -z "$FIRST_PATH" ]]; then
  echo "no search results" >&2
  exit 3
fi

if [[ ! -f "$FIRST_PATH" ]]; then
  echo "$FIRST_PATH"
  exit 0
fi

"$OPEN_HELPER" "$FIRST_PATH"
