#!/usr/bin/env bash
set -euo pipefail

# Install Albert on Fedora-based systems.
# Strategy:
#   1) Try native repos (dnf/rpm-ostree).
#   2) If not available, *optionally* add the OBS repo from home:manuelschneid3r and retry.
#
# Trust note:
# - Adding a third-party RPM repo expands the host trust boundary.
# - Therefore the OBS fallback is gated behind:
#     SOURCEOS_ALLOW_THIRDPARTY_REPOS=1

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

allow_thirdparty_repos(){
  case "${SOURCEOS_ALLOW_THIRDPARTY_REPOS:-0}" in
    1|true|TRUE|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

fedora_obs_repofile_url(){
  local v
  v="$(os_version_id)"

  if [[ "$v" == "rawhide" || "$v" == "Rawhide" || -z "$v" ]]; then
    echo "https://download.opensuse.org/repositories/home:manuelschneid3r/Fedora_Rawhide/home:manuelschneid3r.repo"
    return
  fi

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

print_obs_instructions(){
  local url
  url="$(fedora_obs_repofile_url)"
  warn "OBS fallback is disabled by default (trust boundary expansion)."
  warn "To allow enabling the OBS repo automatically, set:"
  warn "  export SOURCEOS_ALLOW_THIRDPARTY_REPOS=1"
  warn "Then re-run this installer."
  warn "If you prefer manual install, repo file URL is: $url"
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

  warn "Albert not found in native repos."

  if ! allow_thirdparty_repos; then
    print_obs_instructions
    exit 2
  fi

  warn "Third-party repos allowed; attempting OBS repo fallback"
  try_install_with_obs

  if have albert; then
    info "albert installed (OBS repo)"
  else
    warn "albert not found after install attempts."
    warn "You may need to install manually from software.opensuse.org for your Fedora version."
    exit 2
  fi
}

main "$@"
