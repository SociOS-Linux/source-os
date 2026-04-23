# sourceos-shell service graph note

The Linux realization layer currently models the `sourceos-shell` runtime as a four-service graph:

- `sourceos-shell`
- `sourceos-router`
- `sourceos-pdf-secure`
- `sourceos-docd`

These services are grouped by the `sourceos-shell.target` scaffold.

## Intent

This target is a Linux realization placeholder that captures the expected runtime grouping before the actual product/runtime repo exists.

## Follow-on

Once `SourceOS-Linux/sourceos-shell` exists, the placeholder ExecStart values should be replaced with real package/service paths and the current scaffold checks should be upgraded into service-graph checks.
