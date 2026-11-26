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

# Parse target cluster (dev|verify) and OCI artifact tag.
target_cluster="$1"
artifact_tag="$2"

# Bootstrap Flux; server-side apply handles the large CRDs cleanly.
kube_context="$(.mise/cluster/cluster.sh context "$target_cluster")"
kubectl --context "$kube_context" apply --server-side -f "$FLUX_BOOTSTRAP_MANIFEST"
kubectl --context "$kube_context" -n flux-system wait deploy --all --for=condition=Available --timeout=3m

# Push the rendered artifact from the host to the cluster's local registry
# before creating the OCIRepository so Flux finds it immediately.
.mise/cluster/push-artifact.sh local "$target_cluster" "$artifact_tag"

# Point Flux (inside the cluster) at the same local registry via its in-cluster
# hostname, then apply the repo's declarative sync manifests.
in_cluster_registry="$(.mise/cluster/cluster.sh in-cluster-registry "$target_cluster")"
artifact_url="oci://${in_cluster_registry}/${CUR8S_COMPONENT}"
flux --context "$kube_context" create source oci "$CUR8S_COMPONENT" \
  --url "$artifact_url" \
  --tag "$artifact_tag" --insecure --interval 1m
kubectl --context "$kube_context" apply -f "$FLUX_SYNC_MANIFESTS"

# Wait for every source and Kustomization in this disposable cluster to converge.
kubectl --context "$kube_context" -n flux-system \
  wait ocirepository --all --for=condition=Ready --timeout=5m
kubectl --context "$kube_context" -n flux-system \
  wait kustomization --all --for=condition=Ready --timeout=5m

echo "✅ $CUR8S_COMPONENT installed on $target_cluster ($kube_context)"
