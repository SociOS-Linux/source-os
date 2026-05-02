## Executor policy

**Copilot is the primary executor** for bounded issue-first PR work in this repository.

- The issue body is the complete source of truth for every task. Do not rely on later comments; Copilot may not see them after assignment.
- Delivery is confirmed only when GitHub shows a PR, branch, commit, or merge. Issue comments alone — including Codex comments — are **not** delivery artifacts.
- Codex may be used for review, cross-repo analysis, or as a backup executor, but never as the default executor.

---

Use the GitHub issue body as the source of truth.

Before editing:

1. Read the issue.
2. Inspect the repository.
3. Identify existing validation commands.
4. Keep the PR bounded to the issue scope.

When implementing:

- Prefer existing repository patterns.
- Add tests, fixtures, validators, or documentation with the implementation when appropriate.
- Keep generated files only if repository conventions require them.
- Do not modify unrelated workflows or policy files.
- Do not touch unrelated repositories.
- Do not broaden scope without asking in the issue.
- Do not claim production readiness unless the issue explicitly requests and acceptance criteria prove it.

When opening the PR:

- Link the issue.
- Include what changed.
- Include exact validation commands run.
- Include pass/fail output summary.
- List known gaps.
- State non-goals preserved.
- State anything blocked.
- Do not mark ready if validation did not run.

SourceOS-specific boundaries:

- Be conservative around boot, install, recovery, host mutation, release automation, and runtime admission.
- Do not change privileged workflows unless the issue explicitly asks for workflow work.
- Do not add secrets, credentials, private keys, tokens, or signing material.
- Keep Mac-on-Linux workstation work bounded to documented GNOME defaults, helper scripts, validation helpers, package declarations, and docs unless the issue explicitly requests deeper changes.
- Distinguish active behavior from future or proposed parity claims.
- Preserve existing JSON contracts unless the issue explicitly requests a schema change.

Validation expectations:

- Run repo-native validation when available.
- For shell scripts, run `bash -n` and any existing smoke workflows/tests relevant to the changed path.
- For JSON examples or schemas, run `python3 -m json.tool` or repo-native schema validation.
- If a validation command cannot run, explain why and include the error.
