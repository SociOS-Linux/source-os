#!/usr/bin/env bash
set -euo pipefail

# Install the profile-local `sourceos` helper CLI to user scope.
# Target: ~/.local/bin/sourceos

PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$PROFILE_DIR/bin/sourceos"
DEST_DIR="${HOME}/.local/bin"
DEST="$DEST_DIR/sourceos"

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; }

main(){
  [[ -x "$SRC" ]] || { err "sourceos helper missing: $SRC"; exit 2; }

  mkdir -p "$DEST_DIR"
  cp -f "$SRC" "$DEST"
  chmod +x "$DEST"

  info "installed: $DEST"

  if [[ ":$PATH:" != *":$DEST_DIR:"* ]]; then
    warn "~/.local/bin is not on PATH. Add one line to your shell rc:"
    warn "  export PATH=\"$DEST_DIR:\$PATH\""
  fi
}

main "$@"
