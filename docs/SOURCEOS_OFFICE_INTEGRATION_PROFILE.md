# SourceOS Office Integration Profile

## Purpose

This document defines the SourceOS-side office integration profile for the workspace office suite program.

`source-os` is the Linux realization home for host roles, profiles, images, builders, and Linux-facing integration surfaces. This office profile should realize the local and desktop side of the workspace office stack defined in `SocioProphet/prophet-workspace` and the cloud/runtime services defined in `SocioProphet/prophet-platform`.

## SourceOS responsibilities

The Linux and desktop layer should own:
- LibreOffice defaults and compatibility tuning
- local office file associations and MIME defaults
- font substitution and template packaging
- local office smoke tests and round-trip verification
- local semantic extraction hooks for documents
- desktop shell behavior for opening office files and handing off cloud edit sessions when required

## Boundary rule

Shared schemas and canonical runtime vocabulary should stay in upstream product/runtime repositories. `source-os` should realize those contracts as Linux profiles, host roles, and desktop integration.

## Planned filesystem surfaces

- `build/office-suite/`
- `build/office-suite/profiles/`
- `configs/libreoffice/`
- `configs/fontconfig/`
- `configs/mime/`

## First host profile modes

- `sovereign` — ODF-first local profile
- `interoperability` — OOXML-friendly local profile
- `migration` — preserve source format and emit compatibility warnings
- `cloud` — default behavior for cloud editor handoff and versioned saveback

## Cross-repo integration

### With `prophet-workspace`

Product/domain semantics for docs, sheets, slides, files, collaboration, AI assistance, and workflow agents belong there.

### With `prophet-platform`

Cloud document control, WOPI host behavior, office runtime schemas, AI actions, and workflow runtime belong there.
