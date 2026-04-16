# watchdog-validator

Temporary runtime scaffold for the SourceOS watchdog / validator subsystem.

## Purpose

This module is responsible for:

- detecting policy drift, attestation failure, and egress-policy violations
- triggering quarantine actions
- collecting evidence references
- emitting audit records
- preparing validator packets for quorum review
- linking quarantine and replay outcomes back into session receipts

## Planned components

- `main.rs` — event loop / orchestration
- `attestation.rs` — TPM / integrity bridge
- `quarantine.rs` — overlay and cgroup-eBPF quarantine entrypoints
- `audit_anchor.rs` — adapter into the runtime anchor subsystem
- `replay_packer.rs` — deterministic envelope preparation

## Contract dependencies

This module should align with the following contract types from `SourceOS-Linux/sourceos-spec`:

- `ReplayEnvelope`
- `AuditAnchorRecord`
- `ValidatorDecision`
- `QuarantineReceipt`
- `ExceptionLedgerEntry`

## Temporary status

This README marks the module landing zone until code is moved into a dedicated `SourceOS-Linux` runtime repository.
