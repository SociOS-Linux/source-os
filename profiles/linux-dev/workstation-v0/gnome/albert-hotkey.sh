#!/usr/bin/env bash
set -euo pipefail

# Configure a GNOME custom keybinding for Albert.
# We bind Super+Space to `albert toggle` by default.
# We also avoid collision with GNOME input-source switching by moving that to Alt+Shift.

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }

have(){ command -v "$1" >/dev/null 2>&1; }

is_gnome(){
  [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] && return 0
  [[ "${DESKTOP_SESSION:-}" == *gnome* ]] && return 0
  return 1
}

main(){
  if ! have gsettings; then
    warn "gsettings missing; cannot set hotkey"
    exit 0
  fi

  if ! is_gnome; then
    warn "GNOME not detected; skipping hotkey"
    exit 0
  fi

  # Move input source switching away from Super+Space (macOS uses Cmd+Space for search).
  # GNOME typically uses: org.gnome.desktop.wm.keybindings switch-input-source / switch-input-source-backward
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L']" || true
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_R']" || true

  # Add a custom keybinding for Albert.
  # Path style: /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/
  local base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"
  local custom0="${base}custom0/"

  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['${custom0}']" || true

  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${custom0} name "Albert" || true
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${custom0} command "albert toggle" || true
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${custom0} binding "<Super>space" || true

  info "Albert hotkey set: <Super>Space → albert toggle"
  info "Input source switching moved to Alt+Shift (L/R)"
}

main "$@"
