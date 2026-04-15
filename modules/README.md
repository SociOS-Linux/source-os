# Modules

Reusable NixOS and operational modules live here.

Suggested initial module lanes:

- `nixos/`
- `build/`
- `promotion/`
- `telemetry/`
- `secrets/`

These modules realize SourceOS host and image behavior on Linux.
They should reference shared control-plane terms from `SocioProphet/socioprophet-agent-standards` rather than redefining them locally.
