#!/usr/bin/env bash
set -euo pipefail

# Validate workstation-v0 keyboard/remap policy without requiring root access.
# Emits key=value lines for doctor/status or CI consumption.

have(){ command -v "$1" >/dev/null 2>&1; }

profile_dir(){
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

backend(){
  printf '%s\n' "${SOURCEOS_REMAP_BACKEND:-input-remapper}"
}

template_path(){
  printf '%s/sourceos/input/xremap-macos-compat.yml\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

main(){
  local pdir b tmpl
  pdir="$(profile_dir)"
  b="$(backend)"
  tmpl="$(template_path)"

  printf 'profile_dir=%s\n' "$pdir"
  printf 'selected_backend=%s\n' "$b"

  case "$b" in
    input-remapper|xremap|kinto)
      printf 'backend_valid=yes\n'
      ;;
    *)
      printf 'backend_valid=no\n'
      ;;
  esac

  if have input-remapper-control; then
    printf 'input_remapper=present\n'
  else
    printf 'input_remapper=missing\n'
  fi

  if have xremap; then
    printf 'xremap=present\n'
  else
    printf 'xremap=missing\n'
  fi

  if have xkeysnail; then
    printf 'xkeysnail=present\n'
  else
    printf 'xkeysnail=missing\n'
  fi

  if [[ -f "$tmpl" ]]; then
    printf 'xremap_template=present\n'
  else
    printf 'xremap_template=missing\n'
  fi
  printf 'xremap_template_path=%s\n' "$tmpl"

  if [[ -f "$pdir/gnome/input-install.sh" ]]; then
    printf 'input_installer=present\n'
  else
    printf 'input_installer=missing\n'
  fi
}

main "$@"
