#!/usr/bin/env bash
# Component identity facts — the single authoring point for self-description,
# documented in docs/architecture.md. artifact:render writes these facts into
# the cur8s.yaml release descriptor; artifact:push attaches
# the same facts as cur8s.io/* OCI manifest annotations. Two emitters,
# one source: they cannot drift.
#
# component_facts loads:
#   CUR8S_COMPONENT          component name
#   CUR8S_UPSTREAM_PROJECT   upstream project slug
#   CUR8S_UPSTREAM_DIGEST    sha256 of the fetched upstream manifest
#   CUR8S_SOURCE             source repository URL
#   CUR8S_DOCS               documentation URL

component_facts() {
  local root="${MISE_CONFIG_ROOT:?}"
  source "$root/scripts/lib/version.sh"
  load_flux_version "$root/version.env"
  CUR8S_COMPONENT="flux"
  CUR8S_UPSTREAM_PROJECT="fluxcd/flux2"
  CUR8S_SOURCE="https://github.com/cur8s/flux"
  CUR8S_DOCS="https://github.com/cur8s/flux"

  local lock="$root/src/flux/artifacts/FETCH.lock"
  [ -f "$lock" ] || { echo "❌ FETCH.lock missing (run 'mise run artifact:fetch')" >&2; return 1; }
  CUR8S_UPSTREAM_DIGEST="$(awk '/digest:/ {print $2}' "$lock")"
}
