# Workstation (GNOME / CLI-first)

This directory documents the **SourceOS Workstation Profile v0** lane.

Placement rule:
- `profiles/` contains concrete environment-specific realization surfaces.
- This `docs/workstation/` directory explains how to apply and validate those profiles.

## Primary realization

- `profiles/linux-dev/workstation-v0/`

## Runbook

- [RUNBOOK.md](RUNBOOK.md) — operational “how we actually use it” steps

## CI

Workstation scripts are guarded by the `workstation-scripts` GitHub Actions workflow:
- shellcheck
- bash -n
- a small `sourceos status --json` smoke parse

The Lampstand provisioning/search lane is guarded by the `workstation-lampstand` workflow:
- installer syntax checks
- `sourceos-search.sh` syntax checks
- stubbed `pipx` smoke proving the installer writes the user unit
- stubbed Lampstand smoke for query, health, stats, and index commands
- stubbed unit smoke for status, restart, enable, and logs commands

It triggers on PRs and main pushes touching:
- `profiles/linux-dev/workstation-v0/**`
- `docs/workstation/**`

Workflow files:
- `.github/workflows/workstation-scripts.yml`
- `.github/workflows/workstation-lampstand.yml`

## Workstation v0 goals

- CLI-first developer experience with keyboard-first navigation.
- GNOME baseline customization via GSettings and pinned extensions (no GNOME core forks).
- Open-source launcher palette (Wayland-first): `sourceos palette` uses fuzzel (primary) with wofi/rofi fallbacks.
- Lampstand-backed local search surface via `sourceos search`, with the launcher treated as an action bus rather than a second filesystem index.
- Primary keyboard remap lane: `input-remapper` on Fedora/GNOME.
- Compatibility remap lanes: `xremap` and `kinto` (explicit compatibility path, not default).
- Touchpad gesture lane: `fusuma`.
- Mac-like GNOME behavior pack: left-side window controls, hot corners off, 12h clock, Files on `Super+E`, Terminal on `Super+Return`, dock favorites seeded.
- Local status/doctor surfaces that can be opened from the launcher (`sourceos status --open`, `sourceos doctor --open`).

## Apply

From the repo:

  ./profiles/linux-dev/workstation-v0/install.sh

The profile installer provisions Lampstand best-effort through:

  ./profiles/linux-dev/workstation-v0/bin/install-lampstand.sh

Lampstand install behavior:
- `pipx` is the user-space installer.
- local checkout is preferred from `$SOURCEOS_LAMPSTAND_SRC` or `~/dev/lampstand` when present.
- otherwise the installer falls back to `git+https://github.com/SocioProphet/lampstand.git`.
- when `lampstandd` is available, the installer writes `sourceos-lampstand.service` under the user systemd directory.

## Validate

  ./profiles/linux-dev/workstation-v0/doctor.sh

Or via the installed helper:

  sourceos doctor
  sourceos status --json
  sourceos search 'report OR invoice' --snippet

## Lampstand runtime commands

Search and runtime inspection are exposed through the same workstation helper so the launcher remains an action bus and Lampstand remains the file-search authority:

  sourceos search 'report OR invoice' --snippet
  sourceos search health --open
  sourceos search stats --open
  sourceos search index --root "$HOME"

The helper also exposes local unit inspection and log retrieval:

  sourceos search service status --open
  sourceos search service restart
  sourceos search service enable
  sourceos search service logs --open

## Nix-first support

This repository is Nix-native. A dev shell is provided:

  nix develop .#workstation-v0

Lampstand is also exposed as a Nix package:

  nix build .#lampstand

Notes:
- The workstation devShell includes the repo-local Lampstand package in addition to best-effort nixpkgs CLI tools.
- The workstation devShell is best-effort; missing nixpkgs attrs will be reported on entry.
- The profile installers still support non-Nix systems using dnf/rpm-ostree and brew where applicable.

## Trust boundaries

- Workstation v0 avoids non-open launchers.
- Launcher install is best-effort via distro packages (Fedora: fuzzel) and does not silently enable third-party repos.
- Kinto is treated as an explicit compatibility lane rather than the default Wayland-first path.
- File search should resolve through Lampstand when available; the launcher must not run a redundant second file-search pass.
- Lampstand is installed in user space and exposed through a user service, not as a mandatory host-system package.

## Related docs

- `docs/repository-layout.md`
- `docs/agentplane-integration.md`
