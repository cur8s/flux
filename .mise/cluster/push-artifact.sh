#!/usr/bin/env bash
# Push artifacts/rendered/ as an OCI artifact with cur8s.io/* annotations.
# Run by release:publish, dev:update, and .mise/cluster/install-component.sh; not a mise task.
#
#   .mise/cluster/push-artifact.sh <registry> <tag>
set -euo pipefail
: "${CUR8S_COMPONENT:?must be set (mise.toml [env]); run through mise}"
: "${CUR8S_VERSION:?must be set (mise.toml [env]); run through mise}"
: "${UPSTREAM_PROJECT:?must be set (mise.toml [env]); run through mise}"
: "${UPSTREAM_TAG:?must be set (mise.toml [env]); run through mise}"
: "${CUR8S_DOCS:?must be set (mise.toml [env]); run through mise}"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <registry> <tag>" >&2
  exit 1
fi

artifact_dir="artifacts/rendered"
if [[ ! -d "$artifact_dir" ]]; then
  echo "❌ $artifact_dir/ not rendered (run 'mise run build:render')" >&2
  exit 1
fi

registry="$1"
artifact_tag="$2"

# Local k3d registries are anonymous. A globally-configured docker credential
# helper (e.g. Docker Desktop's "desktop" credsStore) will still be invoked
# for localhost and can hang indefinitely, so use a throwaway config with no
# credsStore for anonymous auth.
if [[ "$registry" == localhost:* ]]; then
  DOCKER_CONFIG="$(mktemp -d)"
  export DOCKER_CONFIG
  echo '{"auths":{}}' > "$DOCKER_CONFIG/config.json"
  trap 'rm -rf "$DOCKER_CONFIG"' EXIT
fi

artifact_url="oci://${registry}/${CUR8S_COMPONENT}:${artifact_tag}"
ref="$(git branch --show-current)"
if [[ -z "$ref" ]]; then
  ref="$(git describe --tags --exact-match 2>/dev/null || echo HEAD)"
fi
revision="${ref}@sha1:$(git rev-parse HEAD)"

echo "📦 $artifact_url"
# The same identity facts the descriptor asserts, readable from the
# registry without pulling the artifact; see
# docs/architecture/02-artifact-contents-and-metadata.md. Source and
# revision ride flux push's standard OCI annotations — they are
# push-time facts, deliberately absent from the committed descriptor.
flux push artifact "$artifact_url" \
  --path="$artifact_dir" \
  --source="$(git config --get remote.origin.url || echo unknown)" \
  --revision="$revision" \
  --annotations="cur8s.io/component=${CUR8S_COMPONENT}" \
  --annotations="cur8s.io/version=${CUR8S_VERSION}" \
  --annotations="cur8s.io/upstream=${UPSTREAM_PROJECT}" \
  --annotations="cur8s.io/upstream-version=${UPSTREAM_TAG}" \
  --annotations="cur8s.io/docs=${CUR8S_DOCS}" \
  --timeout=5m
echo "✅ pushed $artifact_url"
