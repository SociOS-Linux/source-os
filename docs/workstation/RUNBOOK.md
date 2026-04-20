# Workstation v0 Runbook (linux-dev)

This runbook is the operational “how we actually use it” guide for the **SourceOS Workstation Profile v0**.

Target profile:
- `profiles/linux-dev/workstation-v0/`

Key properties:
- CLI-first, keyboard-first.
- GNOME customization is **behavioral** (GSettings + extensions), no GNOME core forks.
- `sourceos` is installed as a **profile-pinned wrapper** (stable command surface).
- SourceOS uses an **open-source launcher palette** (Wayland-first) for Super+Space.

---

## 0) Preconditions

We assume:
- Fedora / Silverblue / CoreOS-derived host, or any Linux host with `dnf` or `rpm-ostree`.
- GNOME session if you want the GNOME integration.

Quick checks:

```bash
uname -a && echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-}" && command -v rpm-ostree || true && command -v dnf || true
```

If Homebrew/Linuxbrew is not installed, install it first.

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
  - fish spine config to `$XDG_CONFIG_HOME/sourceos/shell/common.fish`
  - GNOME baseline + extensions
  - open-source launcher (fuzzel preferred) + SourceOS palette hotkey
  - `sourceos` helper wrapper into `~/.local/bin`

### Optional: autopatch shell/fish config

If you want the installer to also patch your shell config files, run:

```bash
SOURCEOS_AUTOPATCH_SHELL=1 ./profiles/linux-dev/workstation-v0/install.sh
```

Unified command surface:

```bash
sourceos fix all dry-run
sourceos fix all apply
sourceos fix all revert

sourceos fix shell dry-run
sourceos fix shell apply
sourceos fix shell revert

sourceos fix fish dry-run
sourceos fix fish apply
sourceos fix fish revert
```

`fix all` orchestrates:
- bash/zsh rc patch helper
- fish config patch helper

Low-level helpers remain available too:

```bash
./profiles/linux-dev/workstation-v0/bin/patch-all.sh dry-run
./profiles/linux-dev/workstation-v0/bin/patch-all.sh apply
./profiles/linux-dev/workstation-v0/bin/patch-all.sh revert

./profiles/linux-dev/workstation-v0/bin/patch-shell.sh dry-run
./profiles/linux-dev/workstation-v0/bin/patch-shell.sh apply
./profiles/linux-dev/workstation-v0/bin/patch-shell.sh revert

./profiles/linux-dev/workstation-v0/bin/patch-fish.sh dry-run
./profiles/linux-dev/workstation-v0/bin/patch-fish.sh apply
./profiles/linux-dev/workstation-v0/bin/patch-fish.sh revert
```

---

## 2) Launcher palette (open-source)

SourceOS uses an open-source launcher palette for Super+Space.

Priority order:
1) `fuzzel` (Wayland-first, MIT)
2) `wofi` (GPL-3.0-only)
3) `rofi` (GPL)
4) terminal fallback: `fzf`

The palette is invoked by:

```bash
sourceos palette
```

The palette includes:
- fix all configs (dry-run/apply/revert)
- fix shell rc (dry-run/apply/revert)
- fix fish config (dry-run/apply/revert)
- status / doctor
- profile apply
- common TUI tools

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
- `<Super>space` → `sourceos palette`

If GNOME doesn’t pick it up immediately, log out/in.

### Extensions

The profile enables:
- dash-to-dock
- appindicator

On `rpm-ostree`, GNOME shell extensions may require reboot/logout after install.

---

## 6) One-line acceptance test

After install, this should succeed:

```bash
sourceos status --json && sourceos doctor
```

And on GNOME, you should be able to:
- press `<Super>space` to open the SourceOS palette
- run SourceOS actions from the palette

---

## References

- `docs/workstation/README.md`
- `profiles/linux-dev/workstation-v0/`
