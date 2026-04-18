#!/usr/bin/env bash
set -euo pipefail

PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$PROFILE_DIR/manifest.yaml"

err(){ printf "ERROR: %s\n" "$*" >&2; }
info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }

have(){ command -v "$1" >/dev/null 2>&1; }

install_system(){
  if have rpm-ostree; then
    info "rpm-ostree detected: installing minimal SYSTEM layer (may require reboot)"
    sudo rpm-ostree install git openssh-clients podman toolbox wl-clipboard jq xclip || true
    info "If new packages were layered, reboot before continuing."
    return
  fi
  if have dnf; then
    info "dnf detected: installing minimal SYSTEM layer"
    sudo dnf install -y git openssh-clients podman toolbox wl-clipboard jq xclip || true
    return
  fi
  err "No rpm-ostree/dnf found; cannot apply SYSTEM layer"
  exit 2
}

install_brew(){
  err "brew not found. Install Homebrew/Linuxbrew, then re-run."
  err "macOS: https://brew.sh"
  err "Linuxbrew: https://docs.brew.sh/Homebrew-on-Linux"
  exit 2
}

install_user(){
  if ! have brew; then
    install_brew
  fi
  info "Installing USER packages via brew (manifest-driven)."
  awk '
    $0 ~ /^\s*brew:\s*$/ {in=1; next}
    in && $0 ~ /^\s*- / {gsub(/^\s*- /, ""); print; next}
    in && $0 ~ /^\s*[^-[:space:]]/ {exit}
  ' "$MANIFEST" | while read -r pkg; do
    [[ -z "$pkg" ]] && continue
    info "brew install $pkg"
    brew install "$pkg" || true
  done
}

install_shell_spine(){
  local dst="${XDG_CONFIG_HOME:-$HOME/.config}/sourceos/shell"
  mkdir -p "$dst"
  cp -f "$PROFILE_DIR/shell/common.sh" "$dst/common.sh"
  info "shell spine installed: $dst/common.sh"
  info "Enable by sourcing it from your shell rc (zshrc/bashrc)."
}

apply_gnome_baseline(){
  local script="$PROFILE_DIR/gnome/apply.sh"
  if [[ -x "$script" ]]; then
    info "Applying GNOME baseline (best-effort)"
    "$script" || warn "GNOME baseline apply failed (non-fatal)"
  else
    warn "GNOME baseline script not found: $script"
  fi
}

apply_gnome_extensions(){
  local script="$PROFILE_DIR/gnome/extensions-install.sh"
  if [[ -x "$script" ]]; then
    info "Applying GNOME extension pinset (best-effort)"
    "$script" || warn "GNOME extensions apply failed (non-fatal)"
  else
    warn "GNOME extensions installer not found: $script"
  fi
}

main(){
  [[ -f "$MANIFEST" ]] || { err "manifest missing: $MANIFEST"; exit 2; }
  install_system
  install_user
  install_shell_spine
  apply_gnome_baseline
  apply_gnome_extensions
  info "installed workstation-v0 (linux-dev)"
  info "next: ./doctor.sh"
}

main "$@"
