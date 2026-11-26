#!/usr/bin/env bash
# Install Flux and this component into an existing local cluster from artifacts/rendered/.
# Runs Flux preflight checks, bootstraps Flux from FLUX_BOOTSTRAP_MANIFEST, waits for
# Flux CRDs and controller Deployments to become ready, pushes the rendered artifact to
# the cluster's local OCI registry, applies FLUX_SYNC_MANIFESTS, and waits until all
# Flux sources and Kustomizations in flux-system report Ready.
# Run by dev:create and verify:run after .mise/cluster/cluster.sh create; not a mise task.
#
#   .mise/cluster/install-component.sh dev|verify
set -euo pipefail
: "${CUR8S_COMPONENT:?must be set (mise.toml [env]); run through mise}"
: "${KUBECONFIG:?must be set (mise.toml [env]); run through mise}"
: "${FLUX_BOOTSTRAP_MANIFEST:?must be set (mise.toml [env]); run through mise}"
: "${FLUX_SYNC_MANIFESTS:?must be set (mise.toml [env]); run through mise}"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 dev|verify" >&2
  exit 1
fi

# Target cluster (dev|verify); also used as the local OCI tag in its isolated registry.
target_cluster="$1"
artifact_tag="$target_cluster"

# Run Flux preflight checks before bootstrapping controller manifests.
# Server-side apply handles the large CRDs cleanly.
# Wait for Flux CRDs to be Established and controller Deployments Available
# before creating any Flux custom resources.
kube_context="$(.mise/cluster/cluster.sh context "$target_cluster")"
flux --context "$kube_context" check --pre
kubectl --context "$kube_context" apply --server-side -f "$FLUX_BOOTSTRAP_MANIFEST"
kubectl --context "$kube_context" wait crd -l app.kubernetes.io/part-of=flux \
  --for=condition=Established --timeout=2m
kubectl --context "$kube_context" -n flux-system \
  wait deploy --all --for=condition=Available --timeout=3m

# Push the rendered artifact from the host to the cluster's local registry
# (localhost:<port>) before creating the OCIRepository so Flux finds it immediately.
registry_host_address="$(.mise/cluster/cluster.sh registry-host-address "$target_cluster")"
.mise/cluster/push-artifact.sh "$registry_host_address" "$artifact_tag"

# Point Flux (inside the cluster) at that same local registry via its in-cluster
# address (<cluster>-registry:5000), then apply the repo's declarative sync manifests.
registry_cluster_address="$(.mise/cluster/cluster.sh registry-cluster-address "$target_cluster")"
oci_repository_url="oci://${registry_cluster_address}/${CUR8S_COMPONENT}"
flux --context "$kube_context" create source oci "$CUR8S_COMPONENT" \
  --url "$oci_repository_url" \
  --tag "$artifact_tag" --insecure --interval 1m
kubectl --context "$kube_context" apply -f "$FLUX_SYNC_MANIFESTS"

# Wait for every source and Kustomization in this disposable cluster to converge.
kubectl --context "$kube_context" -n flux-system \
  wait ocirepository --all --for=condition=Ready --timeout=5m
kubectl --context "$kube_context" -n flux-system \
  wait kustomization --all --for=condition=Ready --timeout=5m

echo "✅ $CUR8S_COMPONENT installed on $target_cluster ($kube_context)"
