#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

"$ROOT/build/office-suite/scripts/install_office_desktop_entry.sh"
"$ROOT/build/office-suite/scripts/verify_office_desktop_entry.sh"

echo "SourceOS office shell install completed"
