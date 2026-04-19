#!/usr/bin/env bash
set -euo pipefail

# Install GNOME autostart entry for Albert.
# Purpose: ensure Albert is running so `albert toggle` hotkey works reliably.

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }

have(){ command -v "$1" >/dev/null 2>&1; }

is_gnome(){
  [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] && return 0
  [[ "${DESKTOP_SESSION:-}" == *gnome* ]] && return 0
  return 1
}

main(){
  if ! is_gnome; then
    warn "GNOME not detected; skipping autostart"
    exit 0
  fi

  local autostart_dir
  autostart_dir="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
  mkdir -p "$autostart_dir"

  local desktop_file="$autostart_dir/albert.desktop"

  cat > "$desktop_file" <<'EOF'
[Desktop Entry]
Type=Application
Name=Albert
Comment=Albert launcher
Exec=albert
Terminal=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=1
OnlyShowIn=GNOME;
EOF

  info "installed autostart entry: $desktop_file"

  if ! have albert; then
    warn "albert not found on PATH; autostart entry created anyway"
  fi
}

main "$@"
