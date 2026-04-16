#!/usr/bin/env bash
set -euo pipefail

fail=0

info(){ printf "INFO: %s\n" "$*" >&2; }
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

  if [[ $fail -ne 0 ]]; then
    info "doctor: FAIL"
    exit 2
  fi

  info "doctor: OK"
}

main "$@"
