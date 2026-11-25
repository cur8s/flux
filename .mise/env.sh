#!/usr/bin/env bash
# Create a local cluster running Flux managing itself from artifacts/rendered/.
# Run by dev:create and verify:run; not a mise task.
#
#   .mise/env.sh dev|verify <tag>
set -euo pipefail
: "${CUR8S_COMPONENT:?must be set (mise.toml [env]); run through mise}"
: "${KUBECONFIG:?must be set (mise.toml [env]); run through mise}"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 dev|verify <tag>" >&2
  exit 1
fi

cluster="$1"
tag="$2"
component="$CUR8S_COMPONENT"
context="$(.mise/cluster.sh context "$cluster")"

.mise/cluster.sh create "$cluster"

# Bootstrap Flux from this repo's local render; server-side apply handles the large CRDs cleanly.
kubectl --context "$context" apply --server-side -f artifacts/rendered/deploy/flux.yaml
kubectl --context "$context" -n flux-system wait deploy --all --for=condition=Available --timeout=3m

.mise/oci-push.sh local "$cluster" "$tag"

# Hand Flux its own artifact: the OCIRepository the artifact's sync.yaml
# sources from, then sync.yaml. Bumping the tag is how the cluster upgrades.
flux --context "$context" create source oci "$component" \
  --url "oci://$(.mise/cluster.sh in-cluster-registry "$cluster")/$component" \
  --tag "$tag" --insecure --interval 1m
kubectl --context "$context" apply -f artifacts/rendered/sync.yaml

# sync.yaml sets wait: true, so Ready means Flux health-checked every
# resource the artifact applied.
kubectl --context "$context" -n flux-system wait --for=condition=Ready --timeout=5m \
  "ocirepository/$component" "kustomization/$component"
echo "✅ $cluster environment ready ($context)"
