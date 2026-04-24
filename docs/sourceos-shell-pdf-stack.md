# sourceos-shell PDF stack note

This note tracks the Linux realization scaffold for the PDF lane during the `sourceos-shell` rollout.

## Current Linux-facing surfaces

The Linux realization currently carries service scaffolds for:

- `sourceos-pdf-secure`
- `sourceos-docd`

These are represented both as systemd unit files under `linux/systemd/` and as service declarations in `modules/nixos/sourceos-shell/default.nix`.

## Intent

This is the Linux realization slice of the broader PDF lane tracked in `#93`.

The future `SourceOS-Linux/sourceos-shell` runtime repo should own the actual PDF derivation, signing, validation, and viewing behavior. `source-os` should only keep the host/service realization and validation hooks.

## Validation scaffold

The current Linux realization adds a dedicated contract-style check at:

- `tests/sourceos-shell-pdf-stack-contract.nix`

This check verifies that the PDF-related runtime scaffolds and module hooks remain present and aligned.
