#!/usr/bin/env bash
# Install Flux and this component into an existing local cluster from artifacts/rendered/.
# Identical across Cur8s component repos; component-specific inputs come from
# FLUX_BOOTSTRAP_MANIFEST and FLUX_SYNC_MANIFESTS in mise.toml [env].
# Run by dev:create and verify:run after .mise/cluster/cluster.sh create; not a mise task.
#
#   .mise/cluster/install-component.sh dev|verify <tag>
set -euo pipefail
: "${CUR8S_COMPONENT:?must be set (mise.toml [env]); run through mise}"
: "${KUBECONFIG:?must be set (mise.toml [env]); run through mise}"
: "${FLUX_BOOTSTRAP_MANIFEST:?must be set (mise.toml [env]); run through mise}"
: "${FLUX_SYNC_MANIFESTS:?must be set (mise.toml [env]); run through mise}"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 dev|verify <tag>" >&2
  exit 1
fi

cluster="$1"
tag="$2"
component="$CUR8S_COMPONENT"
context="$(.mise/cluster/cluster.sh context "$cluster")"

# Bootstrap Flux; server-side apply handles the large CRDs cleanly.
kubectl --context "$context" apply --server-side -f "$FLUX_BOOTSTRAP_MANIFEST"
kubectl --context "$context" -n flux-system wait deploy --all --for=condition=Available --timeout=3m

.mise/cluster/push-artifact.sh local "$cluster" "$tag"

# Point Flux at this component's local OCI artifact, then apply the repo's
# declarative cluster manifests (Kustomizations, test ConfigMaps, and any
# pinned prerequisite sources).
flux --context "$context" create source oci "$component" \
  --url "oci://$(.mise/cluster/cluster.sh in-cluster-registry "$cluster")/$component" \
  --tag "$tag" --insecure --interval 1m
kubectl --context "$context" apply -f "$FLUX_SYNC_MANIFESTS"

# Wait for every source and Kustomization in this disposable cluster to converge.
kubectl --context "$context" -n flux-system wait ocirepository --all \
  --for=condition=Ready --timeout=5m
kubectl --context "$context" -n flux-system wait kustomization --all \
  --for=condition=Ready --timeout=5m
echo "✅ $component installed on $cluster ($context)"
