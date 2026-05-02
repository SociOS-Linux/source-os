# Agent Operating Instructions

Work issue-first.

## Executor policy

**Copilot is the primary executor** for bounded issue-first PR work in this repository.

- Assign issues to Copilot to produce verifiable GitHub work artifacts (PR, branch, commit, or merge).
- Codex may be used as a reviewer, cross-repo analyst, or backup executor — it is not the default executor.
- Codex issue comments alone are **not** delivery artifacts. Delivery is only confirmed when GitHub shows a PR, branch, commit, or merge.
- The issue body must contain the full task specification because Copilot may not see later issue comments after assignment.

Rules:

- One repo, one issue, one PR.
- Inspect the live repository before editing.
- Use the GitHub issue body as the source of truth.
- Keep scope bounded to the issue body.
- Do not broaden scope without asking in the issue.
- Do not touch unrelated files.
- Prefer existing repo patterns and validation commands.
- Add tests, fixtures, validators, or docs with implementation changes when appropriate.
- Do not claim production readiness unless acceptance criteria prove it.
- Include validation evidence in the PR body.
- Leave known gaps explicit.

PR body must include:

- What changed.
- Exact commands run.
- Pass/fail output summary.
- Known gaps.
- Anything blocked.

Never:

- Commit secrets, tokens, credentials, or private keys.
- Invent release URLs, checksums, SBOMs, or provenance.
- Claim live ingestion when only fixture validation exists.
- Claim production or safety-critical authority from advisory data.
- Modify workflows, boot/install/recovery, host mutation, runtime admission, or release automation unless the issue explicitly requests that scope.

High-risk paths require explicit review and narrow scope:

- `.github/workflows/**` when privileged.
- boot, install, recovery, host mutation, and release paths.
- secrets, tokens, credentials, and signing material.
- runtime admission, policy enforcement, production infrastructure, and deployment automation.
- defense, public-safety, or effects-linked execution.

For high-risk work, prefer this progression:

1. docs/spec first;
2. fixtures second;
3. tests third;
4. dry-run fourth;
5. real mutation only behind explicit review.

Repository-specific notes:

- `SociOS-Linux/source-os` is a Linux realization repository for SourceOS/SociOS work.
- Workstation changes should preserve bounded GNOME defaults and avoid fragile shell replacement.
- Mac-on-Linux work must distinguish implemented behavior from proposed/future parity.
- Validation helpers should emit simple, parseable output where possible.
- Keep implementation authority clear: contracts/specs belong in `SourceOS-Linux/sourceos-spec`; concrete Linux realization belongs here.
