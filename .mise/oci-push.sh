#!/usr/bin/env bash
# Push artifacts/rendered/ as an OCI artifact with cur8s.io/* annotations.
# Run by release:publish and .mise/env.sh; not a mise task.
#
#   .mise/oci-push.sh local dev|verify <tag>
#   .mise/oci-push.sh remote <tag>
set -euo pipefail
: "${CUR8S_COMPONENT:?must be set (mise.toml [env]); run through mise}"
: "${CUR8S_FLUX_VERSION:?must be set (mise.toml [env]); run through mise}"
: "${CUR8S_UPSTREAM_PROJECT:?must be set (mise.toml [env]); run through mise}"
: "${FLUX_TAG:?must be set (mise.toml [env]); run through mise}"
: "${CUR8S_DOCS:?must be set (mise.toml [env]); run through mise}"

usage() {
  echo "usage: $0 local dev|verify <tag> | $0 remote <tag>" >&2
  exit 1
}

artifact=artifacts/rendered
[ -d "$artifact" ] || { echo "❌ $artifact/ not rendered (run 'mise run build:render')" >&2; exit 1; }

case "${1:-}" in
  local)
    [[ $# -eq 3 ]] || usage
    registry="localhost:$(.mise/cluster.sh registry-port "$2")"
    tag="$3"
    # The k3d-local registry is anonymous. A globally-configured docker
    # credential helper (e.g. Docker Desktop's "desktop" credsStore) will be
    # invoked for it anyway and can hang indefinitely on a localhost registry.
    # Point this push at a throwaway docker config with no credsStore so the
    # OCI client uses anonymous auth.
    DOCKER_CONFIG="$(mktemp -d)"; export DOCKER_CONFIG
    echo '{"auths":{}}' > "$DOCKER_CONFIG/config.json"
    trap 'rm -rf "$DOCKER_CONFIG"' EXIT
    ;;
  remote)
    [[ $# -eq 2 ]] || usage
    : "${REGISTRY:?must be set (mise.toml [env]); run through mise}"
    registry="$REGISTRY"
    tag="$2"
    ;;
  *) usage ;;
esac

url="oci://${registry}/${CUR8S_COMPONENT}:${tag}"
echo "📦 $url"
# The same identity facts the descriptor asserts, readable from the
# registry without pulling the artifact; see
# docs/architecture/02-artifact-contents-and-metadata.md. Source and
# revision ride flux push's standard OCI annotations — they are
# push-time facts, deliberately absent from the committed descriptor.
flux push artifact "$url" \
  --path="$artifact" \
  --source="$(git config --get remote.origin.url || echo unknown)" \
  --revision="$(git branch --show-current)@sha1:$(git rev-parse HEAD)" \
  --annotations="cur8s.io/component=${CUR8S_COMPONENT}" \
  --annotations="cur8s.io/version=${CUR8S_FLUX_VERSION}" \
  --annotations="cur8s.io/upstream=${CUR8S_UPSTREAM_PROJECT}" \
  --annotations="cur8s.io/upstream-version=${FLUX_TAG}" \
  --annotations="cur8s.io/docs=${CUR8S_DOCS}" \
  --timeout=5m
echo "✅ published $url"
