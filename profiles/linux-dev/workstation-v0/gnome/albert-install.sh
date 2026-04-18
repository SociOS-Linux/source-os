#!/usr/bin/env bash
set -euo pipefail

# Install Albert on Fedora-based systems.
# Strategy:
#   1) Try native repos (dnf/rpm-ostree).
#   2) If not available, add the OBS repo from home:manuelschneid3r and retry.
#
# This keeps the workstation “don’t think about it” while still remaining explicit
# about trust boundaries: adding a third-party RPM repo is a trust expansion.

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

os_version_id(){
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    echo "${VERSION_ID:-}"
  else
    echo ""
  fi
}

fedora_obs_repofile_url(){
  # OBS provides a yum repo file per Fedora version.
  # Example URLs from software.opensuse.org for Fedora_41+ and Rawhide.
  local v
  v="$(os_version_id)"

  # Rawhide is sometimes expressed as 'rawhide' or empty.
  if [[ "$v" == "rawhide" || "$v" == "Rawhide" || -z "$v" ]]; then
    echo "https://download.opensuse.org/repositories/home:manuelschneid3r/Fedora_Rawhide/home:manuelschneid3r.repo"
    return
  fi

  # Numeric Fedora releases
  echo "https://download.opensuse.org/repositories/home:manuelschneid3r/Fedora_${v}/home:manuelschneid3r.repo"
}

install_obs_repo(){
  local url
  url="$(fedora_obs_repofile_url)"

  local dest="/etc/yum.repos.d/home:manuelschneid3r.repo"

  info "Adding OBS repo for Albert (home:manuelschneid3r): $url"

  if have curl; then
    curl -fsSL "$url" | sudo tee "$dest" >/dev/null
  elif have wget; then
    wget -qO- "$url" | sudo tee "$dest" >/dev/null
  else
    warn "Neither curl nor wget found; cannot add OBS repo automatically"
    return 1
  fi

  info "Repo file installed: $dest"
}

try_install_native(){
  if have rpm-ostree; then
    info "Trying rpm-ostree install albert"
    sudo rpm-ostree install albert || true
    return 0
  fi

  if have dnf; then
    info "Trying dnf install albert"
    sudo dnf install -y albert || true
    return 0
  fi

  warn "No rpm-ostree/dnf found; cannot install Albert"
  return 1
}

try_install_with_obs(){
  install_obs_repo || return 1

  # Retry install now that repo is present.
  if have rpm-ostree; then
    info "Retrying rpm-ostree install albert (with OBS repo)"
    sudo rpm-ostree install albert || true
    return 0
  fi

  if have dnf; then
    info "Retrying dnf install albert (with OBS repo)"
    sudo dnf install -y albert || true
    return 0
  fi

  return 1
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

  if [[ "$id" != "fedora" ]]; then
    warn "Unsupported distro for Albert install (id=$id). Install Albert manually."
    exit 0
  fi

  try_install_native

  if have albert; then
    info "albert installed (native repos)"
    exit 0
  fi

  warn "Albert not found in native repos; attempting OBS repo fallback"
  try_install_with_obs

  if have albert; then
    info "albert installed (OBS repo)"
  else
    warn "albert not found after install attempts."
    warn "You may need to install manually from software.opensuse.org for your Fedora version."
  fi
}

main "$@"
