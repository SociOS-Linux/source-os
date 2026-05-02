#!/usr/bin/env bash
set -euo pipefail

# Validate the workstation-v0 mac-like GNOME defaults pack.
# Inspects mac-defaults.sh for required settings without running GNOME.
# Emits key=value lines for CI, status, and doctor integration.
# This helper is read-only: it does not modify any settings.

profile_dir(){
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

check_script(){
  local key=$1
  local pattern=$2
  local file=$3
  if grep -qF "$pattern" "$file" 2>/dev/null; then
    printf '%s=present\n' "$key"
  else
    printf '%s=missing\n' "$key"
  fi
}

main(){
  local pdir script overall_ok
  pdir="$(profile_dir)"
  script="$pdir/gnome/mac-defaults.sh"
  overall_ok=no

  if [[ -f "$script" ]]; then
    printf 'mac_defaults_script=present\n'
  else
    printf 'mac_defaults_script=missing\n'
    printf 'mac_defaults_ok=no\n'
    return
  fi

  check_script hot_corners_disabled        "enable-hot-corners false"                    "$script"
  check_script clock_format_12h            "clock-format '12h'"                          "$script"
  check_script locate_pointer_enabled      "locate-pointer true"                         "$script"
  check_script nautilus_double_click       "click-policy 'double'"                       "$script"
  check_script dock_favorites_seed         "favorite-apps"                               "$script"
  check_script files_binding_super_e       'set_custom_binding custom1 "SourceOS Files"' "$script"
  check_script terminal_binding_super_ret  'set_custom_binding custom2 "SourceOS Terminal"' "$script"
  check_script screenshot_binding_3        'set_custom_binding custom3'                  "$script"
  check_script screenshot_binding_4        'set_custom_binding custom4'                  "$script"
  check_script screenshot_binding_5        'set_custom_binding custom5'                  "$script"
  check_script screenshot_binding_6        'set_custom_binding custom6'                  "$script"

  if grep -qF "enable-hot-corners false"                    "$script" &&
     grep -qF "clock-format '12h'"                          "$script" &&
     grep -qF "locate-pointer true"                         "$script" &&
     grep -qF "click-policy 'double'"                       "$script" &&
     grep -qF "favorite-apps"                               "$script" &&
     grep -qF 'set_custom_binding custom1 "SourceOS Files"' "$script" &&
     grep -qF 'set_custom_binding custom2 "SourceOS Terminal"' "$script"; then
    overall_ok=yes
  fi
  printf 'mac_defaults_ok=%s\n' "$overall_ok"
}

main "$@"
