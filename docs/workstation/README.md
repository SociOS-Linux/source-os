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

It triggers on PRs and main pushes touching:
- `profiles/linux-dev/workstation-v0/**`
- `docs/workstation/**`

Workflow file:
- `.github/workflows/workstation-scripts.yml`

## Workstation v0 goals

- CLI-first developer experience with keyboard-first navigation.
- GNOME baseline customization via GSettings and pinned extensions (no GNOME core forks).
- Open-source launcher palette (Wayland-first): `sourceos palette` uses fuzzel (primary) with wofi/rofi fallbacks.
- Local status/doctor surfaces that can be opened from the launcher (`sourceos status --open`, `sourceos doctor --open`).

## Apply

From the repo:

  ./profiles/linux-dev/workstation-v0/install.sh

## Validate

  ./profiles/linux-dev/workstation-v0/doctor.sh

Or via the installed helper:

  sourceos doctor
  sourceos status --json

## Nix-first support

This repository is Nix-native. A dev shell is provided:

  nix develop .#workstation-v0

Notes:
- The workstation devShell is best-effort; missing nixpkgs attrs will be reported on entry.
- The profile installers still support non-Nix systems using dnf/rpm-ostree and brew where applicable.

## Trust boundaries

- Workstation v0 avoids non-open launchers.
- Launcher install is best-effort via distro packages (Fedora: fuzzel) and does not silently enable third-party repos.

## Related docs

- `docs/repository-layout.md`
- `docs/agentplane-integration.md`
