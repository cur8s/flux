#!/usr/bin/env bash
# Push artifacts/rendered/ as an OCI artifact with cur8s.io/* annotations.
# Run by release:publish, dev:update, and .mise/cluster/install-component.sh; not a mise task.
#
#   .mise/cluster/push-artifact.sh <registry> <tag>
set -euo pipefail
: "${COMPONENT_NAME:?must be set (mise.toml [env]); run through mise}"
: "${COMPONENT_VERSION:?must be set (mise.toml [env]); run through mise}"
: "${UPSTREAM_SOURCE:?must be set (mise.toml [env]); run through mise}"
: "${UPSTREAM_TAG:?must be set (mise.toml [env]); run through mise}"
: "${COMPONENT_DOCS:?must be set (mise.toml [env]); run through mise}"

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

# Build the destination OCI reference and Flux's "<ref>@sha1:<commit>" revision
# string (using the current branch, or an exact git tag / "HEAD" when detached).
artifact_url="oci://${registry}/${COMPONENT_NAME}:${artifact_tag}"
ref="$(git branch --show-current)"
if [[ -z "$ref" ]]; then
  ref="$(git describe --tags --exact-match 2>/dev/null || echo HEAD)"
fi
revision="${ref}@sha1:$(git rev-parse HEAD)"

echo "📦 $artifact_url"
# Push artifacts/rendered/ with OCI manifest metadata so the artifact can be
# inspected in the registry without pulling it: --source/--revision record git
# provenance at push time, and cur8s.io/* mirrors cur8s.yaml.
flux push artifact "$artifact_url" \
  --path="$artifact_dir" \
  --source="$(git config --get remote.origin.url || echo unknown)" \
  --revision="$revision" \
  --annotations="cur8s.io/component=${COMPONENT_NAME}" \
  --annotations="cur8s.io/version=${COMPONENT_VERSION}" \
  --annotations="cur8s.io/upstream-source=${UPSTREAM_SOURCE}" \
  --annotations="cur8s.io/upstream-version=${UPSTREAM_TAG}" \
  --annotations="cur8s.io/docs=${COMPONENT_DOCS}" \
  --timeout=5m
echo "✅ pushed $artifact_url"
