#!/usr/bin/env bash
set -euo pipefail

# Patch shell rc files to:
# - ensure $HOME/.local/bin is on PATH
# - source the SourceOS shell spine (`$XDG_CONFIG_HOME/sourceos/shell/common.sh`)
#
# Idempotent: uses a marker block.
# CI/test hook: SOURCEOS_RC_FILES may be set to a colon-separated list of rc files.

MODE="${1:-apply}"  # apply|dry-run

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; }

marker_start="# >>> sourceos workstation-v0 >>>"
marker_end="# <<< sourceos workstation-v0 <<<"

block() {
  # NOTE: Dollar signs are escaped so we do not bake the *current* PATH into the rc file.
  cat <<EOF
${marker_start}
# Added by SourceOS Workstation v0
export PATH="\$HOME/.local/bin:\$PATH"
spine_path="\${XDG_CONFIG_HOME:-\$HOME/.config}/sourceos/shell/common.sh"
if [ -f "\$spine_path" ]; then
  . "\$spine_path"
fi
${marker_end}
EOF
}

rc_candidates() {
  if [[ -n "${SOURCEOS_RC_FILES:-}" ]]; then
    local IFS=':'
    # shellcheck disable=SC2206
    read -r -a arr <<<"${SOURCEOS_RC_FILES}"
    for f in "${arr[@]}"; do
      [[ -n "$f" ]] && printf '%s\n' "$f"
    done
    return 0
  fi

  printf '%s\n' "$HOME/.bashrc" "$HOME/.zshrc"
}

has_block() {
  local f=$1
  grep -Fqx "$marker_start" "$f" 2>/dev/null
}

apply_to_file() {
  local f=$1

  if [[ ! -e "$f" ]]; then
    warn "rc file not found (skipping): $f"
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

  while IFS= read -r rc; do
    apply_to_file "$rc"
  done < <(rc_candidates)

  info "done"
  if [[ "$MODE" == "dry-run" ]]; then
    info "re-run with: $0 apply"
  fi
}

main "$@"
