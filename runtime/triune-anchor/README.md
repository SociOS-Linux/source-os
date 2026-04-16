# triune-anchor

Temporary runtime scaffold for append-only audit anchoring.

## Purpose

This module is responsible for:

- appending structured audit records
- maintaining a rolling root over appended entries
- exposing root / append operations to runtime components
- preparing witness/signer references for downstream validator logic

## Planned shape

- append-only NDJSON log format
- entry hash + rolling root computation
- CLI / library split for local operator use and runtime integration

## Contract dependencies

This module should emit records compatible with:

- `AuditAnchorRecord`
- `TelemetryEvent`
- `ValidatorDecision`
- `QuarantineReceipt`

## Temporary status

This README marks the module landing zone until runtime code is moved into a dedicated `SourceOS-Linux` runtime repository.
