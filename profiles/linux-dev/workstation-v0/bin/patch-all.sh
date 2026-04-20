#!/usr/bin/env bash
set -euo pipefail

# Composite patch helper for Workstation v0.
# Runs shell and fish patch helpers in a single command surface.
# Modes:
# - apply (default)
# - dry-run
# - revert
#
# Behavior:
# - shell helper is always invoked against bash/zsh rc candidates (or SOURCEOS_RC_FILES test hook)
# - fish helper is invoked opportunistically; if fish config does not exist it exits cleanly

MODE="${1:-apply}"
PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; }

run_one(){
  local label=$1
  local script=$2

  if [[ ! -x "$script" ]]; then
    warn "$label helper missing (skipping): $script"
    return 0
  fi

  info "running $label helper: $script $MODE"
  "$script" "$MODE"
}

main(){
  case "$MODE" in
    apply|dry-run|revert) ;;
    *)
      err "unknown mode: $MODE (use apply|dry-run|revert)"
      exit 2
      ;;
  esac

  run_one shell "$PROFILE_DIR/bin/patch-shell.sh"
  run_one fish "$PROFILE_DIR/bin/patch-fish.sh"

  info "fix-all complete ($MODE)"
}

main "$@"
