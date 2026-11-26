#!/usr/bin/env bash
# Install Flux and this component into an existing local cluster from artifacts/rendered/.
# Bootstraps Flux from FLUX_BOOTSTRAP_MANIFEST, pushes the rendered artifact to the
# cluster's local OCI registry, applies FLUX_SYNC_MANIFESTS, and waits until all Flux
# sources and Kustomizations in flux-system report Ready.
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

# Resolve target cluster role, OCI tag, component name, and kubectl context.
cluster="$1"
tag="$2"
component="$CUR8S_COMPONENT"
context="$(.mise/cluster/cluster.sh context "$cluster")"

# Bootstrap Flux; server-side apply handles the large CRDs cleanly.
kubectl --context "$context" apply --server-side -f "$FLUX_BOOTSTRAP_MANIFEST"
kubectl --context "$context" -n flux-system wait deploy --all --for=condition=Available --timeout=3m

# Push the rendered artifact from the host to the cluster's local registry
# before creating the OCIRepository so Flux finds it immediately.
.mise/cluster/push-artifact.sh local "$cluster" "$tag"

# Point Flux (inside the cluster) at the same local registry via its in-cluster
# hostname, then apply the repo's declarative sync manifests.
registry="$(.mise/cluster/cluster.sh in-cluster-registry "$cluster")"
artifact_url="oci://${registry}/${component}"
flux --context "$context" create source oci "$component" \
  --url "$artifact_url" \
  --tag "$tag" --insecure --interval 1m
kubectl --context "$context" apply -f "$FLUX_SYNC_MANIFESTS"

# Wait for every source and Kustomization in this disposable cluster to converge.
kubectl --context "$context" -n flux-system wait ocirepository --all \
  --for=condition=Ready --timeout=5m
kubectl --context "$context" -n flux-system wait kustomization --all \
  --for=condition=Ready --timeout=5m
echo "✅ $component installed on $cluster ($context)"
