#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <writer> <output-file>" >&2
  exit 1
fi

KIND="$1"
OUTPUT="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

case "$KIND" in
  writer)
    if [[ -f "$SCRIPT_DIR/sourceos-default-writer.fodt" ]]; then
      TEMPLATE="$SCRIPT_DIR/sourceos-default-writer.fodt"
    else
      TEMPLATE="$ROOT/build/office-suite/templates/sovereign/sourceos-default-writer.fodt"
    fi
    ;;
  *)
    echo "unsupported office kind: $KIND" >&2
    exit 2
    ;;
esac

mkdir -p "$(dirname "$OUTPUT")"
cp "$TEMPLATE" "$OUTPUT"
echo "$OUTPUT"
