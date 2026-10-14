#!/usr/bin/env bash
# Local k3d clusters, identical in every Cur8s component repo. Tasks run this
# helper; it is not a task. A repo has two clusters, named from its component
# and a role: <component>-dev and <component>-test.
#
#   .mise/cluster.sh create|delete|status|registry-port|in-cluster-registry|context dev|test
#
# Each cluster gets its own local OCI registry: container <name>-registry,
# reached in-cluster as <name>-registry:5000 and from the host on a port k3d
# picks, so clusters coexist without port conflicts.
set -euo pipefail
: "${CUR8S_COMPONENT:?must be set (mise.toml [env]); run through mise}"
# k3d writes contexts here; unset, it would write ~/.kube/config.
: "${KUBECONFIG:?must be set (mise.toml [env]); run through mise}"

usage() {
  echo "usage: $0 create|delete|status|registry-port|in-cluster-registry|context dev|test" >&2
  exit 1
}
[[ $# -eq 2 ]] || usage
case "$2" in dev | test) ;; *) usage ;; esac
name="$CUR8S_COMPONENT-$2"
context="k3d-$name"
registry="$name-registry"

registry_port() {
  docker inspect -f '{{(index .NetworkSettings.Ports "5000/tcp" 0).HostPort}}' "$registry"
}

# Returns once the API server accepts requests (k3d's wait: true) and the
# registry answers (k3d starts it after the server and does not wait for it).
# k3d fails on an existing name.
create() {
  k3d cluster create "$name" --config .mise/k3d-config.yaml --registry-create "$registry"
  local port
  port="$(registry_port)"
  curl -sf --retry 30 --retry-delay 2 --retry-all-errors "http://localhost:$port/v2/" >/dev/null
  echo "✅ cluster $name (context $context), registry localhost:$port (in-cluster $registry:5000)"
}

# Succeeds when the cluster is already gone; k3d removes its registry too.
delete() {
  k3d cluster delete "$name"
}

# Fails only when the cluster does not exist; a stopped or unhealthy cluster
# is reported, not failed.
status() {
  k3d cluster list "$name"
  if kubectl --context "$context" get nodes >/dev/null 2>&1; then
    echo "api: reachable"
  else
    echo "api: unreachable"
  fi
  local port
  if port="$(registry_port 2>/dev/null)"; then
    echo "registry: localhost:$port (in-cluster $registry:5000)"
  else
    echo "registry: not running"
  fi
}

case "$1" in
  create) create ;;
  delete) delete ;;
  status) status ;;
  registry-port) registry_port ;;
  in-cluster-registry) echo "$registry:5000" ;;
  context) echo "$context" ;;
  *) usage ;;
esac
