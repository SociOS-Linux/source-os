#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

"$ROOT/build/office-suite/scripts/verify_office_desktop_entry.sh"

if [[ -x "$ROOT/build/office-suite/scripts/verify_office_suite_profile.sh" ]]; then
  "$ROOT/build/office-suite/scripts/verify_office_suite_profile.sh"
fi

if [[ -x "$ROOT/build/office-suite/scripts/install_sourceos_office_shell_smoke.sh" ]]; then
  "$ROOT/build/office-suite/scripts/install_sourceos_office_shell_smoke.sh"
fi

echo "office shell verification passed"
