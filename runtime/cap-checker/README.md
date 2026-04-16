# cap-checker

Temporary runtime scaffold for capability enforcement.

## Purpose

This module is responsible for:

- evaluating operation requests against active capability grants
- checking scope constraints over labels, nodes, edges, and runtime surfaces
- linking runtime mutations to policy decisions and capability identifiers
- producing deny records and evidence references for audit

## Planned shape

- capability data model
- selector matching over runtime objects and graph references
- middleware adapters for runtime operations
- property tests for non-escalation and monotonic scope enforcement

## Contract dependencies

This module should align with:

- `CapabilityToken`
- `PolicyDecision`
- `ExecutionDecision`
- `ReplayEnvelope`

## Temporary status

This README marks the module landing zone until runtime code is moved into a dedicated `SourceOS-Linux` runtime repository.
