# Proposed SourceOS repository layout

This repository is the Linux realization home for the SourceOS control-plane stack.

## Initial layout

```text
source-os/
├── flake.nix
├── flake.lock
├── hosts/
│   ├── builder-aarch64/
│   ├── canary-x86_64/
│   └── stable-x86_64/
├── modules/
│   ├── nixos/
│   ├── build/
│   ├── promotion/
│   ├── telemetry/
│   └── secrets/
├── profiles/
│   ├── linux-dev/
│   ├── linux-candidate/
│   └── linux-stable/
├── images/
├── builders/
├── channels/
├── tests/
└── docs/
```

## Intent

- `hosts/` carries concrete machine roles.
- `modules/` carries reusable NixOS and operational modules.
- `profiles/` carries environment-specific realization surfaces.
- `images/` carries image definitions.
- `builders/` carries builder configuration and builder-specific realization.
- `channels/` carries realized environment pointers or manifests that line up with the shared control-plane channel vocabulary.

## Relationship to AgentPlane

`agentplane` defines the execution, placement, and promotion model.
This repository realizes that model on Linux hosts and images.

## Relationship to standards

Shared channel and capability terms should be sourced from `socioprophet-agent-standards` rather than redefined ad hoc in this repository.
