#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Verify helpers (self-contained — no external kube-query dependency).
#
# Contract:
#   1. source this file
#   2. call verify_init "${1:-}" once (sets KUBE_CONTEXT, resets FAILED_COUNT)
#   3. use check_* helpers (they print pass/fail and bump FAILED_COUNT)
#   4. exit "$FAILED_COUNT"
# ─────────────────────────────────────────────────────────────────────────────

if [ -n "${__FLUX_VERIFY_LIB_SOURCED:-}" ]; then return 0; fi
__FLUX_VERIFY_LIB_SOURCED=1

REPO_ROOT="${MISE_CONFIG_ROOT:-$(git rev-parse --show-toplevel)}"
# shellcheck source=../../scripts/lib/display.sh
source "$REPO_ROOT/scripts/lib/display.sh"

verify_init() {
  if [ -z "${KUBE_CONTEXT:-}" ]; then
    local cluster="${1:-${CLUSTER_NAME:-flux-dev}}"
    export KUBE_CONTEXT="k3d-$cluster"
  fi
  FAILED_COUNT=0
}

kq() { kubectl --context "${KUBE_CONTEXT}" "$@"; }

# is_deployment_ready <name> <namespace>  → sets KUBE_QUERY_MSG
is_deployment_ready() {
  local name=$1 ns=$2 want have
  want=$(kq -n "$ns" get deploy "$name" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "")
  have=$(kq -n "$ns" get deploy "$name" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "")
  KUBE_QUERY_MSG="${have:-0}/${want:-?} ready"
  [ -n "$want" ] && [ "${have:-0}" = "$want" ]
}

# is_kustomization_ready <name> <namespace>  → sets KUBE_QUERY_MSG
is_kustomization_ready() {
  local name=$1 ns=$2 st
  st=$(kq -n "$ns" get kustomization "$name" \
        -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "")
  KUBE_QUERY_MSG="Ready=${st:-Unknown}"
  [ "$st" = "True" ]
}

# is_ocirepository_ready <name> <namespace>  → sets KUBE_QUERY_MSG
is_ocirepository_ready() {
  local name=$1 ns=$2 st
  st=$(kq -n "$ns" get ocirepository "$name" \
        -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "")
  KUBE_QUERY_MSG="Ready=${st:-Unknown}"
  [ "$st" = "True" ]
}

check_deployment() {
  local n=$1 ns=$2
  if is_deployment_ready "$n" "$ns"; then print_pass "Deployment $ns/$n ($KUBE_QUERY_MSG)"
  else print_fail "Deployment $ns/$n ($KUBE_QUERY_MSG)"; FAILED_COUNT=$((FAILED_COUNT + 1)); fi
}

check_kustomization() {
  local n=$1 ns=$2
  if is_kustomization_ready "$n" "$ns"; then print_pass "Kustomization $ns/$n is Ready"
  else print_fail "Kustomization $ns/$n ($KUBE_QUERY_MSG)"; FAILED_COUNT=$((FAILED_COUNT + 1)); fi
}

check_ocirepository() {
  local n=$1 ns=$2
  if is_ocirepository_ready "$n" "$ns"; then print_pass "OCIRepository $ns/$n is Ready"
  else print_fail "OCIRepository $ns/$n ($KUBE_QUERY_MSG)"; FAILED_COUNT=$((FAILED_COUNT + 1)); fi
}
