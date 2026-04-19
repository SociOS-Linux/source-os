# Workstation (GNOME / CLI-first)

This directory documents the **SourceOS Workstation Profile v0** lane.

Placement rule:
- `profiles/` contains concrete environment-specific realization surfaces.
- This `docs/workstation/` directory explains how to apply and validate those profiles.

## Primary realization

- `profiles/linux-dev/workstation-v0/`

## Workstation v0 goals

- CLI-first developer experience with keyboard-first navigation.
- GNOME baseline customization via GSettings and pinned extensions (no GNOME core forks).
- Albert as an **action bus** with `sourceos` actions.
- Local status/doctor surfaces that can be opened from the launcher.

## Apply

From the repo:

```bash
./profiles/linux-dev/workstation-v0/install.sh
```

## Validate

```bash
./profiles/linux-dev/workstation-v0/doctor.sh
```

Or via the installed helper:

```bash
sourceos doctor
sourceos status --json
```

## Nix-first support

This repository is Nix-native. A dev shell is provided:

```bash
nix develop .#workstation-v0
```

Notes:
- The workstation devShell is best-effort; missing nixpkgs attrs will be reported on entry.
- The profile installers still support non-Nix systems using `dnf/rpm-ostree` and `brew` where applicable.

## Trust boundaries

- Third-party RPM repo enablement (Albert OBS fallback) is gated behind:

```bash
export SOURCEOS_ALLOW_THIRDPARTY_REPOS=1
```

Without this, the installer prints explicit instructions and exits nonzero.

## Related docs

- `docs/repository-layout.md`
- `docs/agentplane-integration.md`
