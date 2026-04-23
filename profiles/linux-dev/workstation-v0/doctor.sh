#!/usr/bin/env bash
set -euo pipefail

fail=0
EMIT_JSON=0

RESULT_LEVELS=()
RESULT_NAMES=()
RESULT_MESSAGES=()

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; fail=1; }

have(){ command -v "$1" >/dev/null 2>&1; }

parse_args(){
  local arg
  for arg in "$@"; do
    case "$arg" in
      --json)
        EMIT_JSON=1
        ;;
      *)
        err "unknown argument: $arg (use --json)"
        exit 2
        ;;
    esac
  done
}

record_result(){
  RESULT_LEVELS+=("$1")
  RESULT_NAMES+=("$2")
  RESULT_MESSAGES+=("$3")
}

json_escape(){
  local s=${1:-}
  s=${s//\\/\\\\}
  s=${s//"/\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

count_level(){
  local needle=$1
  local count=0
  local i
  for ((i=0;i<${#RESULT_LEVELS[@]};i++)); do
    if [[ "${RESULT_LEVELS[$i]}" == "$needle" ]]; then
      count=$((count + 1))
    fi
  done
  printf '%d' "$count"
}

emit_json(){
  local i
  local ok=true
  if [[ $fail -ne 0 ]]; then
    ok=false
  fi

  printf '{'
  printf '"kind":"sourceos.doctor"'
  printf ',"profile":"linux-dev/workstation-v0"'
  printf ',"ok":%s' "$ok"
  printf ',"summary":{'
  printf '"ok":%s' "$(count_level ok)"
  printf ',"warn":%s' "$(count_level warn)"
  printf ',"error":%s' "$(count_level error)"
  printf ',"info":%s' "$(count_level info)"
  printf '}'
  printf ',"results":['
  for ((i=0;i<${#RESULT_LEVELS[@]};i++)); do
    [[ $i -gt 0 ]] && printf ','
    printf '{"level":"%s","name":"%s","message":"%s"}' \
      "$(json_escape "${RESULT_LEVELS[$i]}")" \
      "$(json_escape "${RESULT_NAMES[$i]}")" \
      "$(json_escape "${RESULT_MESSAGES[$i]}")"
  done
  printf ']'
  printf '}'
  printf '\n'
}

check(){
  local bin=$1
  if have "$bin"; then
    info "ok: $bin"
    record_result ok "$bin" "present"
  else
    err "missing: $bin"
    record_result error "$bin" "missing"
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
    record_result warn "gnome-extension:$uuid" "gnome-extensions missing; cannot validate"
    return 0
  fi

  if gnome-extensions list | grep -qx "$uuid"; then
    info "gnome-ext present: $uuid"
    record_result ok "gnome-extension:$uuid" "present"
  else
    warn "gnome-ext missing: $uuid"
    record_result warn "gnome-extension:$uuid" "missing"
  fi
}

check_sourceos_binding(){
  if ! have sourceos; then
    err "missing: sourceos"
    record_result error "sourceos-binding" "sourceos not found on PATH"
    return
  fi

  local expected
  expected="$(cd "$(dirname "$0")" && pwd)"

  local got
  got="$(sourceos profile path 2>/dev/null || true)"

  if [[ -z "$got" ]]; then
    err "sourceos present but 'sourceos profile path' failed"
    record_result error "sourceos-binding" "sourceos profile path failed"
    return
  fi

  if [[ "$got" != "$expected" ]]; then
    err "sourceos points to different profile dir: got=$got expected=$expected"
    record_result error "sourceos-binding" "profile mismatch"
    return
  fi

  info "ok: sourceos (profile bound)"
  record_result ok "sourceos-binding" "profile bound"
}

check_launcher(){
  if have fuzzel || have wofi || have rofi; then
    info "ok: launcher (fuzzel/wofi/rofi)"
    record_result ok launcher "present (fuzzel/wofi/rofi)"
    return
  fi
  err "missing: launcher (need fuzzel/wofi/rofi for sourceos palette)"
  record_result error launcher "missing (need fuzzel/wofi/rofi)"
}

check_input_backend(){
  if have input-remapper-control; then
    info "ok: input backend (input-remapper)"
    record_result ok input-backend "input-remapper"
    return
  fi
  if have xremap; then
    info "ok: input backend (xremap compatibility)"
    record_result ok input-backend "xremap"
    return
  fi
  if have xkeysnail; then
    info "ok: input backend (xkeysnail / kinto compatibility)"
    record_result ok input-backend "xkeysnail"
    return
  fi

  warn "no keyboard remap backend detected (input-remapper/xremap/xkeysnail)"
  record_result warn input-backend "missing (input-remapper/xremap/xkeysnail)"
}

check_fusuma_lane(){
  local cfg="${XDG_CONFIG_HOME:-$HOME/.config}/fusuma/config.yml"
  local svc="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/sourceos-fusuma.service"

  if have fusuma; then
    info "ok: fusuma"
    record_result ok fusuma "binary present"
  else
    warn "fusuma missing"
    record_result warn fusuma "binary missing"
  fi

  if [[ -f "$cfg" ]]; then
    info "ok: fusuma config"
    record_result ok fusuma-config "$cfg"
  else
    warn "fusuma config missing: $cfg"
    record_result warn fusuma-config "missing"
  fi

  if [[ -f "$svc" ]]; then
    info "ok: fusuma user service"
    record_result ok fusuma-service "$svc"
  else
    warn "fusuma user service missing: $svc"
    record_result warn fusuma-service "missing"
  fi

  if id -nG "$USER" 2>/dev/null | grep -qw input; then
    info "ok: user is in input group"
    record_result ok input-group "present"
  else
    warn "user is not in input group (fusuma may lack device access)"
    record_result warn input-group "missing"
  fi
}

check_lampstand_lane(){
  local search_helper="$(cd "$(dirname "$0")" && pwd)/bin/sourceos-search.sh"

  if [[ -f "$search_helper" ]]; then
    info "ok: sourceos search helper"
    record_result ok sourceos-search-helper "$search_helper"
  else
    warn "sourceos search helper missing: $search_helper"
    record_result warn sourceos-search-helper "missing"
  fi

  if have lampstand; then
    info "ok: lampstand"
    record_result ok lampstand "binary present"
    return
  fi

  if have python3 && python3 -c 'import lampstand.cli' >/dev/null 2>&1; then
    info "ok: lampstand python module"
    record_result ok lampstand "python module importable"
    return
  fi

  warn "lampstand missing (search surface exists but backend is unavailable)"
  record_result warn lampstand "missing backend"
}

main(){
  parse_args "$@"

  info "doctor: linux-dev/workstation-v0"

  check git
  check ssh
  check podman
  check toolbox
  check wl-copy
  check jq

  if have xclip; then
    info "ok: xclip"
    record_result ok xclip "present"
  else
    info "note: xclip missing (only needed on X11)"
    record_result info xclip "missing optional (only needed on X11)"
  fi

  check brew
  check_sourceos_binding

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

  check sesh
  check procs
  check sd
  check entr
  check curlie

  check jnv
  check gojq

  check rclone
  check mc
  check rsync
  check_lampstand_lane

  if gnome_detect; then
    record_result info gnome "detected"
    check_launcher
    check_input_backend
    check_fusuma_lane

    if have gsettings; then
      info "gnome: detected; gsettings present"
      record_result ok gsettings "present"

      local base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"
      local custom0="${base}custom0/"
      local bindings
      bindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings || true)
      info "gnome: custom-keybindings = ${bindings}"
      record_result info gnome-custom-keybindings "$bindings"
      local hk
      hk=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${custom0} binding 2>/dev/null || true)
      if [[ -n "$hk" ]]; then
        info "gnome: hotkey binding = ${hk}"
        record_result info gnome-hotkey "$hk"
      fi

    else
      warn "gnome: detected but gsettings missing"
      record_result warn gsettings "missing on GNOME host"
    fi

    check_gnome_extension 'dash-to-dock@micxgx.gmail.com'
    check_gnome_extension 'appindicatorsupport@rgcjonas.gmail.com'

  else
    info "gnome: not detected (ok)"
    record_result info gnome "not detected"
  fi

  if [[ "$EMIT_JSON" == "1" ]]; then
    emit_json
  fi

  if [[ $fail -ne 0 ]]; then
    info "doctor: FAIL"
    exit 2
  fi

  info "doctor: OK"
}

main "$@"
