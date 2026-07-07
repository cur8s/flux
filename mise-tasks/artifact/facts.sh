#!/usr/bin/env bash
# Component identity facts — the single authoring point for
# self-description (flagship RFC-013). artifact:render writes these
# facts into the cur8s.yaml release descriptor; artifact:push attaches
# the same facts as cur8s.io/* OCI manifest annotations. Two emitters,
# one source: they cannot drift.
#
# component_facts loads:
#   CUR8S_COMPONENT          component name
#   CUR8S_VERSION            component version (VERSION file, RFC-011)
#   CUR8S_UPSTREAM_PROJECT   upstream project slug
#   CUR8S_UPSTREAM_VERSION   upstream part of the version
#   CUR8S_CONFIG_REVISION    config-revision part ("" when none)
#   CUR8S_UPSTREAM_DIGEST    sha256 of the fetched upstream manifest
#   CUR8S_SOURCE             source repository URL
#   CUR8S_DOCS               documentation URL

component_facts() {
  local root="${MISE_CONFIG_ROOT:?}"
  CUR8S_COMPONENT="flux"
  CUR8S_UPSTREAM_PROJECT="fluxcd/flux2"
  CUR8S_SOURCE="https://github.com/cur8s/flux"
  CUR8S_DOCS="https://github.com/cur8s/flux"

  CUR8S_VERSION="$(cat "$root/VERSION")"
  # RFC-011 (flagship): <upstream-version>[-<config-revision>]
  if [[ "$CUR8S_VERSION" =~ ^(v[0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)$ ]]; then
    CUR8S_UPSTREAM_VERSION="${BASH_REMATCH[1]}"
    CUR8S_CONFIG_REVISION="${BASH_REMATCH[2]}"
  else
    CUR8S_UPSTREAM_VERSION="$CUR8S_VERSION"
    CUR8S_CONFIG_REVISION=""
  fi

  local lock="$root/src/flux/artifacts/FETCH.lock"
  [ -f "$lock" ] || { echo "❌ FETCH.lock missing (run 'mise run artifact:fetch')" >&2; return 1; }
  CUR8S_UPSTREAM_DIGEST="$(awk '/digest:/ {print $2}' "$lock")"
}
