#!/usr/bin/env bash
set -euo pipefail

# Patch fish config to source SourceOS fish spine.
# Idempotent marker block.
# Modes:
# - apply (default)
# - dry-run
# - revert (remove the marker block)
#
# CI/test hook:
# - SOURCEOS_FISH_CONFIG may override the fish config path.

MODE="${1:-apply}"  # apply|dry-run|revert

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; }

marker_start="# >>> sourceos workstation-v0 (fish) >>>"
marker_end="# <<< sourceos workstation-v0 (fish) <<<"

fish_cfg(){
  if [[ -n "${SOURCEOS_FISH_CONFIG:-}" ]]; then
    printf '%s\n' "$SOURCEOS_FISH_CONFIG"
  else
    printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
  fi
}

has_block(){
  local f=$1
  grep -Fqx "$marker_start" "$f" 2>/dev/null
}

block(){
  cat <<EOF
${marker_start}
# Added by SourceOS Workstation v0
set spine_path "\${XDG_CONFIG_HOME:-\$HOME/.config}/sourceos/shell/common.fish"
if test -f "\$spine_path"
  source "\$spine_path"
end
${marker_end}
EOF
}

apply_to_file(){
  local f=$1

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

revert_from_file(){
  local f=$1

  if [[ ! -e "$f" ]]; then
    warn "fish config not found (skipping): $f"
    return 0
  fi

  if ! has_block "$f"; then
    info "no patch block present: $f"
    return 0
  fi

  if [[ "$MODE" == "dry-run" ]]; then
    info "would revert: $f"
    return 0
  fi

  local tmp
  tmp="$(mktemp)"

  awk -v s="$marker_start" -v e="$marker_end" '
    $0 == s {skip=1; next}
    $0 == e {skip=0; next}
    skip {next}
    {print}
  ' "$f" > "$tmp"

  mv "$tmp" "$f"
  info "reverted: $f"
}

main(){
  case "$MODE" in
    apply|dry-run|revert) ;;
    *)
      err "unknown mode: $MODE (use apply|dry-run|revert)"
      exit 2
      ;;
  esac

  local f
  f="$(fish_cfg)"

  if [[ "$MODE" == "revert" ]]; then
    revert_from_file "$f"
  else
    apply_to_file "$f"
  fi

  info "done"
}

main "$@"
