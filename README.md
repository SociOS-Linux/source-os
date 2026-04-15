# SourceOS (SociOS-Linux)

This repository is the **main SourceOS implementation hub** in the `SociOS-Linux` org.

It is intentionally **implementation-facing**.

- **Design/RFCs** live in `SociOS-Linux/enhancements` (CoreOS/Silverblue-style enhancement process).
- **Typed contracts** live in `SourceOS-Linux/sourceos-spec` (canonical schema + OpenAPI/AsyncAPI).

This repo implements the **workstation profile** and the **bootstrap tooling** that turns the design into a usable system.

## Current focus: Workstation Profile v0

Workstation Profile v0 is a reproducible, CLI-first workstation for GNOME/CoreOS/Silverblue-derived systems.

It standardizes:

- A modern terminal toolchain (fzf/atuin/bat/zoxide/yazi/eza/gum/direnv/etc.) as a manifest.
- A layered install strategy compatible with immutable hosts:
  - SYSTEM (rpm-ostree minimal)
  - USER (Linuxbrew/Homebrew + per-repo toolchains)
  - TOOLBOX (isolated builds / AUR bridge)
- A launcher action surface (Albert) for “actions-first” invocation.

See `workstation/` for implementation.

## Repo layout

```
source-os/
  workstation/
    profiles/
      workstation-v0/
        manifest.yaml
        install.sh
        doctor.sh
        config/
          shell/
          tmux/
          albert/
          gnome/
```

## Usage (local)

### Apply workstation profile

```bash
./workstation/profiles/workstation-v0/install.sh
```

### Verify profile

```bash
./workstation/profiles/workstation-v0/doctor.sh
```

## Safety/Trust

- This repo provides **installers** and **configuration**, not a second execution authority.
- Agentic actions surfaced by launcher/CLI must map cleanly onto the canonical execution/audit plane.

Related:
- Enhancement PR: `SociOS-Linux/enhancements` (Workstation Profile v0)
- ADR PR: `SourceOS-Linux/sourceos-spec` (Workstation/execution boundary)
