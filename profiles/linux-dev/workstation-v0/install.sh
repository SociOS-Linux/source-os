#!/usr/bin/env bash
set -euo pipefail

PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$PROFILE_DIR/manifest.yaml"

err(){ printf "ERROR: %s\n" "$*" >&2; }
info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }

have(){ command -v "$1" >/dev/null 2>&1; }

autopatch_enabled(){
  case "${SOURCEOS_AUTOPATCH_SHELL:-0}" in
    1|true|TRUE|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

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
  err "brew not found. Install brew first, then re-run."
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

install_sourceos_cli(){
  local script="$PROFILE_DIR/bin/install-sourceos-cli.sh"
  if [[ -x "$script" ]]; then
    info "Installing SourceOS helper CLI to ~/.local/bin"
    "$script" || warn "sourceos CLI install failed (non-fatal)"
  else
    warn "sourceos CLI installer not found: $script"
  fi
}

patch_shell_rc_if_enabled(){
  if ! autopatch_enabled; then
    return 0
  fi

  local script="$PROFILE_DIR/bin/patch-shell.sh"
  if [[ -x "$script" ]]; then
    info "Autopatch enabled: patching shell rc files"
    "$script" apply || warn "shell rc patch failed (non-fatal)"
  else
    warn "autopatch enabled but patch helper missing: $script"
  fi
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

apply_launcher_install(){
  local script="$PROFILE_DIR/gnome/launcher-install.sh"
  if [[ -x "$script" ]]; then
    info "Installing launcher (best-effort)"
    "$script" || warn "launcher install failed (non-fatal)"
  else
    warn "launcher install script not found: $script"
  fi
}

apply_palette_hotkey(){
  local script="$PROFILE_DIR/gnome/palette-hotkey.sh"
  if [[ -x "$script" ]]; then
    info "Setting palette hotkey (best-effort)"
    "$script" || warn "palette hotkey setup failed (non-fatal)"
  else
    warn "palette hotkey script not found: $script"
  fi
}

main(){
  [[ -f "$MANIFEST" ]] || { err "manifest missing: $MANIFEST"; exit 2; }
  install_system
  install_user
  install_shell_spine
  install_sourceos_cli
  patch_shell_rc_if_enabled
  apply_gnome_baseline
  apply_gnome_extensions
  apply_launcher_install
  apply_palette_hotkey
  info "installed workstation-v0 (linux-dev)"
  info "next: ./doctor.sh"
}

main "$@"
