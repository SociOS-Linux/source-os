#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

export XDG_DATA_HOME="$TMPDIR/share"
export XDG_CONFIG_HOME="$TMPDIR/config"
export HOME="$TMPDIR/home"
mkdir -p "$HOME"

"$ROOT/build/office-suite/scripts/install_sourceos_office_shell.sh" >/dev/null

DESKTOP_FILE="$XDG_DATA_HOME/applications/sourceos-office.desktop"
OPEN_BIN="$HOME/.local/bin/sourceos-office-open"
SOURCEOS_OFFICE_BIN="$HOME/.local/bin/sourceos-office"
CLOUD_BIN="$HOME/.local/bin/office_cloud_handoff.sh"
MIME_FILE="$XDG_CONFIG_HOME/mimeapps.list"

[[ -f "$DESKTOP_FILE" ]] || {
  echo "office shell installer smoke failed: missing desktop entry" >&2
  exit 1
}

[[ -x "$OPEN_BIN" ]] || {
  echo "office shell installer smoke failed: missing office open launcher" >&2
  exit 1
}

[[ -x "$SOURCEOS_OFFICE_BIN" ]] || {
  echo "office shell installer smoke failed: missing sourceos-office command" >&2
  exit 1
}

[[ -x "$CLOUD_BIN" ]] || {
  echo "office shell installer smoke failed: missing cloud handoff helper" >&2
  exit 1
}

[[ -f "$MIME_FILE" ]] || {
  echo "office shell installer smoke failed: missing MIME defaults" >&2
  exit 1
}

OUT="$($SOURCEOS_OFFICE_BIN help)"
[[ "$OUT" == *"usage: sourceos-office"* ]] || {
  echo "office shell installer smoke failed: sourceos-office help mismatch" >&2
  exit 1
}

echo "office shell installer smoke passed"
