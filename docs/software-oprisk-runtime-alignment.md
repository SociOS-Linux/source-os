# Software Operational Risk Runtime Alignment

## Purpose

This note records how `SociOS-Linux/source-os` aligns to the software operational risk governance pack proposed in `SocioProphet/socioprophet-standards-storage` PR #72.

## Why this repo is in scope

The current upstream README positions `source-os` as the main SourceOS implementation hub for workstation profile and bootstrap tooling, with implementation-facing installers, configuration, and runtime posture.

That makes this repo the correct downstream owner for the **runtime / distro / packaging** implications of software operational risk.

## Expected responsibilities

### 1. Runtime dependency posture

`source-os` SHOULD document and enforce how critical runtime services depend on:

- package managers,
- registries,
- mirrors,
- bootstrap installers,
- update channels,
- and local-first fallback paths.

### 2. Packaging and installer risk

This repo SHOULD eventually express the runtime policy around:

- package-manager trust boundaries,
- lock / pin / mirror strategy,
- install-time execution risk,
- update rollback capability,
- and operator-visible recovery guidance.

### 3. Critical service mapping

The runtime should identify critical user-visible service paths such as:

- install,
- update,
- recover,
- verify,
- and restore.

These service paths SHOULD map back to the normative operational-risk taxonomy.

### 4. Control ownership

The runtime layer SHOULD own controls that primarily affect duration and severity, including:

- graceful degradation,
- mirror and cache posture,
- recovery / rollback workflows,
- local-first fallback paths,
- and operator-visible trust-state surfaces.

## Immediate backlog

1. Document package-manager trust boundaries and fallback posture.  
2. Map installer and update flows to the software operational-risk framework.  
3. Add runtime-visible recovery / rollback expectations.  
4. Cross-reference the standards pack after PR #72 lands.
