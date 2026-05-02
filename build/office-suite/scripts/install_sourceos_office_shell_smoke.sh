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
VERIFY_BIN="$HOME/.local/bin/office_shell_verify.sh"
CLOUD_BIN="$HOME/.local/bin/office_cloud_handoff.sh"
MIME_FILE="$XDG_CONFIG_HOME/mimeapps.list"
TEST_DOC="$TMPDIR/demo.txt"
echo "SourceOS office shell smoke" > "$TEST_DOC"

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

[[ -x "$VERIFY_BIN" ]] || {
  echo "office shell installer smoke failed: missing office_shell_verify helper" >&2
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

OUT="$(SOURCEOS_OFFICE_MODE=cloud "$SOURCEOS_OFFICE_BIN" open "$TEST_DOC")"
case "$OUT" in
  http://*|https://*) ;;
  *)
    echo "office shell installer smoke failed: installed sourceos-office open path did not return URL" >&2
    exit 1
    ;;
esac

VERIFY_OUT="$($SOURCEOS_OFFICE_BIN verify)"
[[ "$VERIFY_OUT" == *"office shell verification passed"* ]] || {
  echo "office shell installer smoke failed: installed verify path did not pass" >&2
  exit 1
}

echo "office shell installer smoke passed"
