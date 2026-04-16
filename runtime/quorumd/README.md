# quorumd

Minimal validator quorum daemon scaffold for the SourceOS runtime.

## Purpose

This module is responsible for:

- receiving validator inputs and evidence references
- producing verdict records
- aggregating votes into a quorum outcome
- feeding session receipts and quarantine release / termination flows

## Current state

The current scaffold provides:

- a simple `main.rs` that emits a deterministic example decision
- a `lib.rs` helper that aggregates a majority verdict from a list of votes

## Next implementation steps

1. replace the in-process example input with audit-stream consumption
2. attach contract-compatible `ValidatorDecision` payload emission
3. bind quorum results to `QuarantineReceipt` and `SessionReceipt`
4. add weighted threshold and watcher-role logic
