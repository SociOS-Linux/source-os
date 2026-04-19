#!/usr/bin/env bash
set -euo pipefail

fail=0

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; fail=1; }

have(){ command -v "$1" >/dev/null 2>&1; }

check(){
  local bin=$1
  if have "$bin"; then
    info "ok: $bin"
  else
    err "missing: $bin"
  fi
}

gnome_detect(){
  [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] && return 0
  [[ "${DESKTOP_SESSION:-}" == *gnome* ]] && return 0
  return 1
}

check_gnome_extension(){
  local uuid=$1
  if ! have gnome-extensions; then
    warn "gnome-extensions missing; cannot validate extension: $uuid"
    return 0
  fi

  if gnome-extensions list | grep -qx "$uuid"; then
    info "gnome-ext present: $uuid"
  else
    warn "gnome-ext missing: $uuid"
  fi
}

check_sourceos_binding(){
  if ! have sourceos; then
    err "missing: sourceos"
    return
  fi

  local expected
  expected="$(cd "$(dirname "$0")" && pwd)"

  local got
  got="$(sourceos profile path 2>/dev/null || true)"

  if [[ -z "$got" ]]; then
    err "sourceos present but 'sourceos profile path' failed"
    return
  fi

  if [[ "$got" != "$expected" ]]; then
    err "sourceos points to different profile dir: got=$got expected=$expected"
    return
  fi

  info "ok: sourceos (profile bound)"
}

check_launcher(){
  # Require at least one launcher for the SourceOS palette on GNOME.
  if have fuzzel || have wofi || have rofi; then
    info "ok: launcher (fuzzel/wofi/rofi)"
    return
  fi
  err "missing: launcher (need fuzzel/wofi/rofi for sourceos palette)"
}

main(){
  info "doctor: linux-dev/workstation-v0"

  # SYSTEM expectations
  check git
  check ssh
  check podman
  check toolbox
  check wl-copy
  check jq

  # X11 fallback clipboard
  if have xclip; then
    info "ok: xclip"
  else
    info "note: xclip missing (only needed on X11)"
  fi

  # USER expectations
  check brew

  # SourceOS helper
  check_sourceos_binding

  # Core CLI must-haves
  check fzf
  check atuin
  check bat
  check zoxide
  check eza
  check yazi
  check gum
  check direnv
  check rg
  check fd
  check tmux
  check lazygit
  check gh
  check tig

  # Additional
  check sesh
  check procs
  check sd
  check entr
  check curlie

  # JSON
  check jnv
  check gojq

  # File motion
  check rclone
  check mc
  check rsync

  # GNOME expectations
  if gnome_detect; then
    check_launcher

    if have gsettings; then
      info "gnome: detected; gsettings present"

      local base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"
      local custom0="${base}custom0/"
      local bindings
      bindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings || true)
      info "gnome: custom-keybindings = ${bindings}"
      local hk
      hk=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${custom0} binding 2>/dev/null || true)
      if [[ -n "$hk" ]]; then
        info "gnome: hotkey binding = ${hk}"
      fi

    else
      warn "gnome: detected but gsettings missing"
    fi

    check_gnome_extension 'dash-to-dock@micxgx.gmail.com'
    check_gnome_extension 'appindicatorsupport@rgcjonas.gmail.com'

  else
    info "gnome: not detected (ok)"
  fi

  if [[ $fail -ne 0 ]]; then
    info "doctor: FAIL"
    exit 2
  fi

  info "doctor: OK"
}

main "$@"
