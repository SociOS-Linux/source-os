#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BIN_DIR="$HOME/.local/bin"

"$ROOT/build/office-suite/scripts/install_office_desktop_entry.sh"
"$ROOT/build/office-suite/scripts/verify_office_desktop_entry.sh"

mkdir -p "$BIN_DIR"
cp "$ROOT/build/office-suite/scripts/sourceos-office" "$BIN_DIR/sourceos-office"
cp "$ROOT/build/office-suite/scripts/office_shell_verify.sh" "$BIN_DIR/office_shell_verify.sh"
chmod +x "$BIN_DIR/sourceos-office" "$BIN_DIR/office_shell_verify.sh"

if [[ -x "$ROOT/build/office-suite/scripts/verify_office_suite_profile.sh" ]]; then
  "$ROOT/build/office-suite/scripts/verify_office_suite_profile.sh"
fi

echo "installed sourceos-office to $BIN_DIR/sourceos-office"
echo "installed office_shell_verify.sh to $BIN_DIR/office_shell_verify.sh"
echo "SourceOS office shell install completed"
