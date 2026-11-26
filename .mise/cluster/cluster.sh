#!/usr/bin/env bash
# Manage this repository's local k3d clusters (dev and verify).
# Tasks run this helper; it is not a mise task. Clusters are named from
# CUR8S_COMPONENT and the target: <component>-dev and <component>-verify.
#
#   .mise/cluster/cluster.sh create|delete|status|registry-host-address|registry-cluster-address|context dev|verify
#
# Each cluster gets its own local OCI registry: container <name>-registry,
# reached in-cluster as <name>-registry:5000 and from the host on a port k3d
# picks, so clusters coexist without port conflicts.
set -euo pipefail
: "${CUR8S_COMPONENT:?must be set (mise.toml [env]); run through mise}"
# k3d writes contexts here; unset, it would write ~/.kube/config.
: "${KUBECONFIG:?must be set (mise.toml [env]); run through mise}"
: "${KUBERNETES_VERSION:?must be set (mise.toml [env]); run through mise}"
: "${K3S_IMAGE:?must be set (mise.toml [env]); run through mise}"

usage() {
  echo "usage: $0 create|delete|status|registry-host-address|registry-cluster-address|context dev|verify" >&2
  exit 1
}
[[ $# -eq 2 ]] || usage
case "$2" in dev | verify) ;; *) usage ;; esac
cluster_name="$CUR8S_COMPONENT-$2"
kube_context="k3d-$cluster_name"
registry_container="$cluster_name-registry"

registry_host_address() {
  local port
  port="$(docker inspect -f '{{(index .NetworkSettings.Ports "5000/tcp" 0).HostPort}}' "$registry_container")"
  echo "localhost:$port"
}

# Create the cluster from K3S_IMAGE, verify client and server Kubernetes
# versions match KUBERNETES_VERSION, and wait until the local registry responds.
# Fails if a cluster with the same name already exists.
create() {
  # Create the k3d cluster and its dedicated local OCI registry.
  # k3d waits for the Kubernetes API server before returning.
  k3d cluster create "$cluster_name" \
    --config .mise/cluster/k3d-config.yaml \
    --image "$K3S_IMAGE" \
    --registry-create "$registry_container"

  # Query both client and server Kubernetes versions and fail fast if either
  # diverges from KUBERNETES_VERSION (allowing k3s' +k3s... server suffix).
  local version_json client_version server_version expected_version
  expected_version="v${KUBERNETES_VERSION}"
  version_json="$(kubectl --context "$kube_context" version -o json)"
  client_version="$(jq -r '.clientVersion.gitVersion' <<<"$version_json")"
  server_version="$(jq -r '.serverVersion.gitVersion' <<<"$version_json")"
  echo "ℹ️  kubernetes versions: client=$client_version server=$server_version (expected $expected_version)"
  if [[ "$client_version" != "$expected_version" ]]; then
    echo "❌ kubectl client version $client_version does not match expected $expected_version" >&2
    exit 1
  fi
  if [[ "$server_version" != "$expected_version" && "$server_version" != "${expected_version}+"* ]]; then
    echo "❌ Kubernetes server version $server_version does not match expected $expected_version (+k3s suffix allowed)" >&2
    exit 1
  fi

  # Wait for the local OCI registry to accept requests (k3d does not wait for it).
  local address
  address="$(registry_host_address)"
  curl -sf --retry 30 --retry-delay 2 --retry-all-errors "http://$address/v2/" >/dev/null
  echo "✅ cluster $cluster_name (context $kube_context), registry $address (in-cluster $registry_container:5000)"
}

# Succeeds when the cluster is already gone; k3d removes its registry too.
delete() {
  k3d cluster delete "$cluster_name"
}

# Fails only when the cluster does not exist; a stopped or unhealthy cluster
# is reported, not failed.
status() {
  k3d cluster list "$cluster_name"
  if kubectl --context "$kube_context" get nodes >/dev/null 2>&1; then
    echo "api: reachable"
  else
    echo "api: unreachable"
  fi
  local address
  if address="$(registry_host_address 2>/dev/null)"; then
    echo "registry: $address (in-cluster $registry_container:5000)"
  else
    echo "registry: not running"
  fi
}

case "$1" in
  create) create ;;
  delete) delete ;;
  status) status ;;
  registry-host-address) registry_host_address ;;
  registry-cluster-address) echo "$registry_container:5000" ;;
  context) echo "$kube_context" ;;
  *) usage ;;
esac
