#!/usr/bin/env bash
set -euo pipefail

# Install the profile-local `sourceos` helper CLI to user scope.
# Target: ~/.local/bin/sourceos
#
# IMPORTANT:
# - We do NOT copy the helper script itself into ~/.local/bin.
# - Instead we install a small wrapper that pins the profile directory in
#   $XDG_CONFIG_HOME/sourceos/profile.path and execs the profile-local helper.
#
# Rationale:
# - The helper CLI is profile-scoped (linux-dev/workstation-v0). Copying it out of
#   the profile directory breaks relative-path assumptions and can drift.

PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMPL="$PROFILE_DIR/bin/sourceos"

DEST_DIR="${HOME}/.local/bin"
DEST="$DEST_DIR/sourceos"

CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sourceos"
PROFILE_FILE="$CFG_DIR/profile.path"

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }
err(){ printf "ERROR: %s\n" "$*" >&2; }

main(){
  [[ -x "$IMPL" ]] || { err "sourceos helper missing: $IMPL"; exit 2; }

  mkdir -p "$DEST_DIR"
  mkdir -p "$CFG_DIR"

  # Persist the profile dir
  printf '%s\n' "$PROFILE_DIR" > "$PROFILE_FILE"

  # Install wrapper
  cat > "$DEST" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

PROFILE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/sourceos/profile.path"
PROFILE_DIR="$(cat "$PROFILE_FILE" 2>/dev/null || true)"

if [[ -z "$PROFILE_DIR" ]]; then
  echo "ERROR: SourceOS profile path file missing or empty: $PROFILE_FILE" >&2
  echo "Re-run the workstation profile installer to regenerate it." >&2
  exit 2
fi

export SOURCEOS_PROFILE_DIR="$PROFILE_DIR"
exec "$PROFILE_DIR/bin/sourceos" "$@"
EOF

  chmod +x "$DEST"

  info "installed wrapper: $DEST"
  info "pinned profile dir: $PROFILE_FILE"

  if [[ ":$PATH:" != *":$DEST_DIR:"* ]]; then
    warn "~/.local/bin is not on PATH. Add one line to your shell rc:"
    warn "  export PATH=\"$DEST_DIR:\$PATH\""
  fi
}

main "$@"
