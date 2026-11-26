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

# Returns once the API server accepts requests (k3d's wait: true) and the
# registry answers (k3d starts it after the server and does not wait for it).
# k3d fails on an existing name.
create() {
  k3d cluster create "$cluster_name" --config .mise/cluster/k3d-config.yaml --registry-create "$registry_container"
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
