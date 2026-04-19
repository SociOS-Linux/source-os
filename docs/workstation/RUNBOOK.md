# Workstation v0 Runbook (linux-dev)

This runbook is the operational “how we actually use it” guide for the **SourceOS Workstation Profile v0**.

Target profile:
- `profiles/linux-dev/workstation-v0/`

Key properties:
- CLI-first, keyboard-first.
- GNOME customization is **behavioral** (GSettings + extensions), no GNOME core forks.
- `sourceos` is installed as a **profile-pinned wrapper** (stable command surface).
- Albert is installed best-effort; third-party repo fallback is **opt-in**.

---

## 0) Preconditions

We assume:
- Fedora / Silverblue / CoreOS-derived host, or any Linux host with `dnf` or `rpm-ostree`.
- GNOME session if you want the GNOME+Albert integration.

Quick checks:

```bash
uname -a && echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-}" && command -v rpm-ostree || true && command -v dnf || true
```

If Homebrew/Linuxbrew is not installed, install it first (inspect scripts before running):
- https://brew.sh
- https://docs.brew.sh/Homebrew-on-Linux

---

## 1) Apply the profile (repo-local)

From the repo root:

```bash
./profiles/linux-dev/workstation-v0/install.sh
```

Notes:
- On `rpm-ostree`, the installer may layer SYSTEM packages and you may need to reboot.
- The installer will install:
  - SYSTEM baseline (git/ssh/podman/toolbox/wl-clipboard/jq/xclip)
  - USER toolset via `brew` (manifest-driven)
  - shell spine config to `$XDG_CONFIG_HOME/sourceos/shell/common.sh`
  - GNOME baseline + extensions + Albert hotkey
  - `sourceos` helper wrapper into `~/.local/bin`

---

## 2) Trust boundary: Albert install fallback

Albert install logic:
1. Try native repos (`dnf` / `rpm-ostree`).
2. If not available, **do not** automatically add third-party repos.

To allow the optional OBS repo fallback, explicitly opt in:

```bash
export SOURCEOS_ALLOW_THIRDPARTY_REPOS=1
./profiles/linux-dev/workstation-v0/install.sh
```

If you do not set this, the installer will print the exact `.repo` URL and exit non-zero for the Albert install step.

---

## 3) Ensure PATH includes ~/.local/bin

`sourceos` is installed to `~/.local/bin/sourceos`.

Check:

```bash
command -v sourceos && echo "$PATH" | tr ':' '\n' | head
```

If missing:
- Add `export PATH="$HOME/.local/bin:$PATH"` to your shell rc.

---

## 4) Validate health

Terminal validation:

```bash
sourceos status
sourceos status --json
sourceos doctor
```

Launcher-friendly reports:

```bash
sourceos status --open
sourceos doctor --open
```

Exit codes:
- `0` = OK
- `2` = FAIL (missing required components)

---

## 5) GNOME integration

### Hotkey

The profile applies a GNOME custom keybinding:
- `<Super>space` → `albert toggle`

If GNOME doesn’t pick it up immediately, log out/in.

### Extensions

The profile enables:
- dash-to-dock
- appindicator

On `rpm-ostree`, GNOME shell extensions may require reboot/logout after install.

---

## 6) Albert integration (SourceOS actions)

Albert must be running for the hotkey to work.

Basic verification:

```bash
command -v albert && albert --help >/dev/null 2>&1 || true
```

The SourceOS Albert plugin lives in `SociOS-Linux/albert` (dev branch) and is intended to provide:
- `SourceOS: status` → `sourceos status --open`
- `SourceOS: doctor` → `sourceos doctor --open`
- plus quick-launch actions (sesh/tmux/k9s/lazygit/lazydocker/yazi)

If you are using a distro-provided Albert package, it may not include this SourceOS plugin. In that case:
- build/install Albert from `SociOS-Linux/albert`, or
- package the plugin into your chosen distribution lane (future workstream).

---

## 7) One-line acceptance test

After install, this should succeed:

```bash
sourceos status --json && sourceos doctor
```

And on GNOME, you should be able to:
- press `<Super>space` to toggle Albert
- run SourceOS actions from inside Albert (when plugin is installed)

---

## References

- `docs/workstation/README.md`
- `profiles/linux-dev/workstation-v0/`
