#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Bootstrap build script
# -----------------------------------------------------------------------------
# This script:
#   1. Syncs vendored dependencies.
#   2. Builds rendered manifests for core platform components.
#   3. Writes the generated YAMLs into the platform/ directory.
#
# Dependencies:
#   - git
#   - vendir
#   - kustomize
#   - helm
# -----------------------------------------------------------------------------

# ANSI escape code for bold text
BOLD=$(tput bold)
RESET=$(tput sgr0)

section() {
  echo
  echo "${BOLD}$1${RESET}"
}

# --- Tool Version Check ------------------------------------------------------

section "🧰 Tool versions"
echo "vendir:    $(vendir version | head -n1)"
echo "kustomize: $(kustomize version | head -n1)"
echo

# --- Setup -------------------------------------------------------------------

# Ensure vendir syncs dependencies before building
section "🔄 Syncing dependencies with vendir..."
vendir sync

# Determine repository root
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Output manifest paths
FLUX_OUT="${REPO_ROOT}/releases/2.7/flux.yaml"

# --- Build Flux --------------------------------------------------------------
section "🚀 Building Flux manifests..."
kustomize build > "${FLUX_OUT}"

# --- Summary -----------------------------------------------------------------
echo
section "✅ Build completed. Generated manifests:"
cat <<EOF
  - ${FLUX_OUT}
EOF
echo
