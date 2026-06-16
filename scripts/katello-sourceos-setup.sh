#!/usr/bin/env bash
# Sets up SourceOS content structure in a running Foreman+Katello instance.
# Run after the foreman-installer bootstrap completes.
#
# Usage:
#   FOREMAN_URL=https://127.0.0.1:8443 \
#   FOREMAN_USER=admin \
#   FOREMAN_PASSWORD=<password> \
#   ORG=SocioProphet \
#   ./scripts/katello-sourceos-setup.sh
#
# Idempotent: re-running skips objects that already exist.

set -euo pipefail

FOREMAN_URL="${FOREMAN_URL:-https://127.0.0.1:8443}"
FOREMAN_USER="${FOREMAN_USER:-admin}"
FOREMAN_PASSWORD="${FOREMAN_PASSWORD:?FOREMAN_PASSWORD required}"
ORG="${ORG:-SocioProphet}"

HAMMER="hammer --server ${FOREMAN_URL} --username ${FOREMAN_USER} --password ${FOREMAN_PASSWORD}"

echo "=== SourceOS Katello content setup ==="
echo "Foreman: ${FOREMAN_URL}  Org: ${ORG}"

# ── 1. Lifecycle environments ─────────────────────────────────────────────
# Mirrors source-os/channels: dev → candidate → stable
echo "--- lifecycle environments"
$HAMMER lifecycle-environment create --organization "${ORG}" \
    --name dev --prior Library 2>/dev/null || echo "  dev: exists"
$HAMMER lifecycle-environment create --organization "${ORG}" \
    --name candidate --prior dev 2>/dev/null || echo "  candidate: exists"
$HAMMER lifecycle-environment create --organization "${ORG}" \
    --name stable --prior candidate 2>/dev/null || echo "  stable: exists"

# ── 2. Product ────────────────────────────────────────────────────────────
echo "--- product"
$HAMMER product create --organization "${ORG}" \
    --name "SourceOS" \
    --description "SourceOS Linux image artifacts and Nix binary cache" \
    2>/dev/null || echo "  SourceOS product: exists"

# ── 3. Repositories ───────────────────────────────────────────────────────
echo "--- repositories"

# Nix binary cache (file-type repo; populated by nix copy --to http://katello)
$HAMMER repository create --organization "${ORG}" \
    --product "SourceOS" \
    --name "nix-cache-aarch64-linux" \
    --content-type file \
    --url "https://cache.nixos.org" \
    --download-policy immediate \
    2>/dev/null || echo "  nix-cache-aarch64-linux: exists"

# SourceOS system closure artifacts (file-type; Nix store paths exported as NAR)
$HAMMER repository create --organization "${ORG}" \
    --product "SourceOS" \
    --name "sourceos-closures-aarch64" \
    --content-type file \
    2>/dev/null || echo "  sourceos-closures-aarch64: exists"

# ── 4. Content view ───────────────────────────────────────────────────────
echo "--- content view"
$HAMMER content-view create --organization "${ORG}" \
    --name "sourceos-builder-aarch64" \
    --description "SourceOS builder image content view for aarch64 (Asahi/M2)" \
    2>/dev/null || echo "  sourceos-builder-aarch64: exists"

$HAMMER content-view add-repository --organization "${ORG}" \
    --name "sourceos-builder-aarch64" \
    --product "SourceOS" \
    --repository "nix-cache-aarch64-linux" \
    2>/dev/null || echo "  nix-cache-aarch64-linux already in view"

$HAMMER content-view add-repository --organization "${ORG}" \
    --name "sourceos-builder-aarch64" \
    --product "SourceOS" \
    --repository "sourceos-closures-aarch64" \
    2>/dev/null || echo "  sourceos-closures-aarch64 already in view"

# Publish version 1.0 to Library
echo "--- publishing content view (this may take a minute)"
$HAMMER content-view publish --organization "${ORG}" \
    --name "sourceos-builder-aarch64" \
    --description "Initial publish — dev channel bootstrap"

# Promote to dev lifecycle environment
echo "--- promoting to dev"
CV_VERSION=$($HAMMER --output json content-view version list \
    --organization "${ORG}" \
    --content-view "sourceos-builder-aarch64" | python3 -c \
    "import json,sys; vs=json.load(sys.stdin); print(sorted(vs,key=lambda v:v['ID'])[-1]['Version'])")

$HAMMER content-view version promote \
    --organization "${ORG}" \
    --content-view "sourceos-builder-aarch64" \
    --version "${CV_VERSION}" \
    --to-lifecycle-environment dev

echo "=== Setup complete ==="
echo "Content view 'sourceos-builder-aarch64' published and promoted to dev."
echo "Next: nix build and push the builder-aarch64 closure:"
echo "  nix build .#nixosConfigurations.builder-aarch64.config.system.build.toplevel"
echo "  nix copy --to 'http://127.0.0.1:8101?compression=zstd' ./result"
