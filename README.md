# source-os

This is the main SociOS Linux SourceOS repository.

## Role

`source-os` is the Linux realization home for the SourceOS control-plane stack. It carries host roles, profiles, images, builders, and Linux-facing integration surfaces that realize the AgentPlane contract on Linux hosts.

## Current surfaces

- `docs/repository-layout.md` — repository shape and intent
- `docs/agentplane-integration.md` — contract boundary with AgentPlane and shared standards
- `docs/mesh/` — mesh Linux estate integration planning, path-template mapping, and staged workstreams
- `linux/` — concrete Linux-facing templates for systemd-networkd, NetworkManager, nftables, and helper units
- `profiles/` / `modules/` — Nix realization surfaces

## Boundary rule

Shared schemas and canonical vocabulary belong in `SocioProphet/socioprophet-agent-standards`, not here.
