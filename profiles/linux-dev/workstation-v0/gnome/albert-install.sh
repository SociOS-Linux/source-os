#!/usr/bin/env bash
set -euo pipefail

# Install Albert on Fedora-based systems.
# We prefer distro packaging for stability.
# Safe to run repeatedly.

info(){ printf "INFO: %s\n" "$*" >&2; }
warn(){ printf "WARN: %s\n" "$*" >&2; }

have(){ command -v "$1" >/dev/null 2>&1; }

is_gnome(){
  [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] && return 0
  [[ "${DESKTOP_SESSION:-}" == *gnome* ]] && return 0
  return 1
}

os_id(){
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    echo "${ID:-linux}"
  else
    echo "linux"
  fi
}

install_fedora(){
  # Prefer rpm-ostree when available.
  if have rpm-ostree; then
    info "Installing Albert via rpm-ostree (may require reboot)"
    sudo rpm-ostree install albert || true
    return
  fi

  if have dnf; then
    info "Installing Albert via dnf"
    sudo dnf install -y albert || true
    return
  fi

  warn "No rpm-ostree/dnf found; cannot install Albert"
}

main(){
  if have albert; then
    info "albert already present"
    exit 0
  fi

  if ! is_gnome; then
    warn "GNOME not detected; skipping Albert install"
    exit 0
  fi

  local id
  id="$(os_id)"

  if [[ "$id" == "fedora" ]]; then
    install_fedora
  else
    warn "Unsupported distro for Albert install (id=$id). Install Albert manually."
    exit 0
  fi

  if have albert; then
    info "albert installed"
  else
    warn "albert not found after install attempt. You may need to enable additional repos or install manually."
  fi
}

main "$@"
