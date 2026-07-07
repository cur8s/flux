#!/usr/bin/env bash
# k3d lifecycle library — sourced by the cluster:* tasks and by
# artifact:push (which needs the local registry's host port).
#
# Each cluster gets its own local OCI registry (<name>-registry). No host
# ports are mapped — Flux needs no ingress — so multiple clusters coexist
# without port conflicts.
#
# k3d/kubectl/jq come pinned from mise [tools]; docker is the one tool
# mise does not manage, so it is the only dependency worth checking.

require_docker() {
  command -v docker &>/dev/null || { echo "❌ docker not found (the one tool mise does not manage)" >&2; exit 1; }
}

get_registry_port() {
  # k3d may name the registry container "<name>" or "k3d-<name>"; try both.
  local port
  for c in "$1" "k3d-$1"; do
    port=$(docker inspect "$c" 2>/dev/null | \
      jq -r '.[0].NetworkSettings.Ports["5000/tcp"][0].HostPort // empty')
    [ -n "$port" ] && { echo "$port"; return; }
  done
  echo "unknown"
}

get_api_port() {
  docker inspect "k3d-$1-serverlb" 2>/dev/null | \
    jq -r '.[0].NetworkSettings.Ports["6443/tcp"][0].HostPort // "unknown"'
}

cluster_exists() {
  k3d cluster list -o json 2>/dev/null | jq -e ".[] | select(.name == \"$1\")" >/dev/null 2>&1
}

get_cluster_state() {
  cluster_exists "$1" || { echo "missing"; return; }
  local running
  running=$(docker ps --filter "label=k3d.cluster=$1" --format '{{.ID}}' | wc -l | tr -d ' ')
  [ "$running" -gt 0 ] && echo "running" || echo "stopped"
}
