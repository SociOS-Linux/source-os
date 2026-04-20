#!/usr/bin/env bash
set -euo pipefail

# Patch fish config to source SourceOS fish spine.
# Idempotent marker block.

MODE="${1:-apply}"  # apply|dry-run

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; }

marker_start="# >>> sourceos workstation-v0 (fish) >>>"
marker_end="# <<< sourceos workstation-v0 (fish) <<<"

fish_cfg(){
  echo "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
}

has_block(){
  local f=$1
  grep -Fqx "$marker_start" "$f" 2>/dev/null
}

block(){
  cat <<'EOF'
# >>> sourceos workstation-v0 (fish) >>>
# Added by SourceOS Workstation v0
set spine_path "${XDG_CONFIG_HOME:-$HOME/.config}/sourceos/shell/common.fish"
if test -f "$spine_path"
  source "$spine_path"
end
# <<< sourceos workstation-v0 (fish) <<<
EOF
}

apply(){
  local f
  f="$(fish_cfg)"

  if [[ ! -e "$f" ]]; then
    warn "fish config not found (skipping): $f"
    return 0
  fi

  if has_block "$f"; then
    info "already patched: $f"
    return 0
  fi

  if [[ "$MODE" == "dry-run" ]]; then
    info "would patch: $f"
    return 0
  fi

  {
    printf '\n'
    block
    printf '\n'
  } >> "$f"

  info "patched: $f"
}

main(){
  case "$MODE" in
    apply|dry-run) ;;
    *)
      err "unknown mode: $MODE (use apply|dry-run)"
      exit 2
      ;;
  esac

  apply
  info "done"
}

main "$@"
