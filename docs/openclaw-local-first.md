# OpenClaw local-first deployment doctrine

This document defines how OpenClaw may be used inside the SourceOS Linux realization boundary.

## Purpose

OpenClaw is acceptable here only as a **bounded delegated-action runtime** for a single trust boundary. In SourceOS terms, it is an operator-adjacent gateway cell, not the canonical policy system, not the evidence canon, not the promotion plane, and not the truth-maintenance layer.

## What OpenClaw is for

OpenClaw is useful when it stays close to the human operator, close to local state, and inside a narrow authority envelope. The intended uses are:

- local repository navigation and summarization
- controlled assistance over local developer workspaces
- bounded read-mostly investigation of logs, configs, and traces
- drafting actions that still require explicit human review or external policy approval

## What OpenClaw is not for

OpenClaw must not be treated as:

- the SourceOS control plane
- the SourceOS policy canon
- the SourceOS signing authority
- a shared enterprise super-bot spanning multiple users or teams
- a hard-truth system for provenance, attestation, or release state
- a model-training platform

Those concerns remain outside the OpenClaw cell and belong to the appropriate standards, control-plane, and evidence surfaces.

## Core trust rule

**One gateway equals one trust boundary.**

A single OpenClaw gateway instance maps to one human operator or one tightly bounded operating cell with aligned authority. Session identifiers are routing handles, not a substitute for authorization boundaries.

Immediate implication:

- no multi-user shared gateway with broad tools
- no organization-wide shared chat bot with common credentials
- no assumption that one channel or session is safely isolated from another when tool authority is shared

## Deployment shape for SourceOS

The default SourceOS shape is a **per-boundary local agent cell**.

Minimum placement rules:

1. one gateway per trust boundary
2. separate OS user, container, or VM per gateway cell
3. loopback bind by default
4. filesystem scope constrained to explicit working directories
5. network egress constrained to an allowlist
6. credentials scoped per cell, not shared across cells

## Local-first requirements

Local-first does not only mean “use a local model.” It means locality must be explicit across the full execution path.

The following are the default expectations:

- local model inference is primary
- local embeddings are primary
- local browser automation is primary when browser automation is enabled at all
- local state, prompts, and artifacts remain on the host unless an outbound dependency is explicitly approved

A deployment is **not** considered local-first if any of the following are silently remote by default:

- embeddings
- browser control or CDP endpoints
- skills or plugins executing outside the local trust boundary
- credential material stored in remote operator services

## Model routing policy

SourceOS should treat model choice as a workload-routing problem, not as ideology.

Initial routing doctrine:

- local models are the default for workspace reasoning, repo navigation, summarization, and bounded drafting
- hosted fallbacks are exceptional and must be declared explicitly per task class
- irreversible or security-sensitive actions must not depend solely on model judgment, whether local or hosted

Local model weakness is a security concern, not just a quality concern. If a local model is too weak for robust instruction hierarchy and tool discipline, the correct answer is not “accept lower safety”; the correct answer is to reduce authority or change the model path.

## Secrets and identity policy

OpenClaw must not become a credential sink.

Required rules:

- use secret references or environment-backed secret injection, not plaintext configuration
- prefer disposable, scoped credentials
- never reuse crown-jewel credentials across multiple gateway cells
- keep signing keys, release keys, long-lived cloud admin credentials, and attestation roots outside the OpenClaw runtime
- separate human identity from service identity and separate both from signing identity

## Tool policy

Initial SourceOS enablement should be conservative.

### Allowed first

- local read-only filesystem access within an approved workspace
- repository inspection
- diff review
- log and trace reading
- drafting of patches, notes, and operational checklists without automatic application

### Disabled first

- browser automation
- remote CDP or browser broker services
- package publication
- registry mutation
- signing operations
- infrastructure mutation
- release promotion
- email, chat, and SaaS connector sprawl
- generic shell execution over sensitive hosts

### Promotion rule

Every newly enabled tool must have:

- an explicit purpose
- a stated blast radius
- a restore path
- a test case for adversarial prompt steering
- a revocation path

## Browser policy

Browser automation is high-risk because it can bridge human sessions, cookies, and ambient authority.

Default SourceOS rule:

- browser automation is off
- remote browser brokers are off
- any later enablement must run in an isolated browser context with disposable credentials and explicit target allowlists

## Evidence and observability

OpenClaw outputs do not become trusted merely because they were locally generated.

Each action path that matters operationally should emit evidence sufficient for replay and review, including:

- human actor or cell identifier
- gateway identifier
- model route
- tool invoked
- input artifact references or digests
- output artifact references or digests
- approval record if any
- effect record and restore handle if any

OpenClaw may assist with operations, but SourceOS remains responsible for durable evidence, provenance, approval, and rollback semantics.

## Network policy

Recommended baseline:

- bind the gateway to loopback by default
- expose remotely only through deliberate, authenticated tunneling or a hardened reverse path
- default-deny inbound network access
- default-deny tool-runner egress except for explicitly required endpoints
- keep model, embedding, and browser endpoints on a short allowlist

## SourceOS placement

This doctrine belongs in `source-os` because it describes Linux realization and host-placement rules for the OpenClaw gateway cell.

The next implementation surfaces should live in this repository under paths such as:

- `modules/nixos/` for service and policy modules
- `profiles/` for environment-specific defaults
- `hosts/` for concrete machine-role realization
- `tests/` for adversarial and regression validation

## Initial implementation profile

Phase 0 should look like this:

- one local developer gateway cell
- one local model path
- local embeddings only
- no browser
n- no shared chat channels
- no production credentials
- read-mostly tools only
- explicit audit logging of tool calls and generated artifacts

Phase 1 may introduce limited write actions, but only after validation of restore semantics, policy gates, and adversarial prompt steering tests.

## Rejection criteria

A proposed OpenClaw deployment should be rejected for SourceOS if any of the following are true:

- one gateway is intended to serve multiple adversarial or semi-trusted users
- remote dependencies are implicit rather than declared
- the gateway holds broad organization credentials
- browser automation is enabled before isolation and disposable credentials exist
- OpenClaw is expected to make authoritative policy or release decisions on its own
- there is no evidence path, no revoke path, or no restore path

## Immediate backlog

1. add a SourceOS module skeleton for a local OpenClaw service unit and state directory layout
2. define a profile-level default that is local-only and loopback-only
3. specify a tool allowlist contract for the first developer cell
4. add adversarial tests for prompt steering, path escape, credential exfiltration, and remote endpoint drift
5. wire emitted artifacts into the broader evidence plane rather than treating OpenClaw logs as sufficient truth

## Bottom line

For SourceOS, OpenClaw is acceptable only as a **per-boundary local agent cell** with narrow tools, explicit locality, bounded credentials, and all hard-lane control functions kept outside the gateway.