#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

"$ROOT/build/office-suite/scripts/install_office_desktop_entry.sh"
"$ROOT/build/office-suite/scripts/verify_office_desktop_entry.sh"

if [[ -x "$ROOT/build/office-suite/scripts/verify_office_suite_profile.sh" ]]; then
  "$ROOT/build/office-suite/scripts/verify_office_suite_profile.sh"
fi

echo "SourceOS office shell install completed"
