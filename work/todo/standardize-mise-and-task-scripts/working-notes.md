# Working notes: mise and task-script conventions

The consolidated record of review decisions, for the documentation phase to publish from. Each
entry separates owner decisions from observations and proposals.

## Review by namespace

The owner chose to review the task namespaces one at a time, starting with `cluster` because it is
identical across component repositories. Whether this replaces the plan's topic-by-topic rounds is
not yet decided.

### `cluster`

**Owner decision (2026-10-14): task contracts.**

- `cluster:create` fails clearly when a cluster with the name already exists.
- `cluster:delete` succeeds when the cluster is already gone; any other failure surfaces.
- `cluster:status` reports whether the cluster exists, whether its API is reachable, and its
  registry endpoint. It exits non-zero only when the cluster does not exist; a stopped or
  unhealthy cluster is reported, not failed.

**Observed with k3d 5.9.0** (disposable `flux-probe` cluster):

- `k3d cluster create` on an existing name fails immediately with "a cluster with that name
  already exists", so `cluster:create` needs no check of its own.
- `k3d cluster delete` exits 0 for a missing cluster and removes the registry made by
  `--registry-create`. The former `k3d registry delete ... 2>/dev/null || true` was redundant and
  hid real errors; it was removed.
- `k3d cluster get` still succeeds for a stopped cluster; its API refuses connections and its
  registry has no published port.

**Observed in the k3d v5.9.0 source** (`pkg/client/cluster.go`, `registry.go`,
`runtimes/docker/node.go`): `--registry-create` creates the registry container during cluster
preparation but does not start it. The registry joins the cluster's helper nodes, which start
after the servers, and k3d waits only for the load balancer among helpers. `wait: true` therefore
does not cover the registry, and the `curl --retry .../v2/` readiness check in `cluster:create` is
the only guarantee that the registry answers when the task reports success. The k3d registry docs
say nothing about ordering or readiness.

**Owner decision (2026-10-14): `cluster:create` readiness.** It returns when the API server
accepts requests and the registry answers; the following tasks do not need the node to be Ready.

**Observed:** neither Docker nor k3d reports registry readiness. `registry:2` defines no Docker
`HEALTHCHECK`, Docker has no wait-until-healthy command, and k3d defines a registry ready log line
but never waits for it during cluster creation. k3d's own `wait: true` covers only the server log
line "k3s is up and running". k3d picks the registry's host port at creation and records it in the
standard `local-registry-hosting` ConfigMap in `kube-public` (KEP-1755), which it writes last,
only warning if that fails, and in an undocumented `k3s.registry.port.external` container label.

**Applied:** `cluster:create` reads the registry host endpoint from the ConfigMap, which also proves
the API server accepts requests, fails if it is missing, then polls `/v2/` with curl.
`cluster:delete` and `cluster:status` were rewritten to the contracts. `test:run` passed and left
no containers.

**Open for the owner:**

- Duplication: the name-prefix guard (three copies), the `docker port` registry lookup still in
  `cluster:status` and `oci:publish` (candidates for the ConfigMap read), and `k3d-<name>` context
  derivation (six places). Proposal: keep task files self-contained.
- The zot pull-through mirror at `host.k3d.internal:5051` in `.mise/k3d-config.yaml`: keep, make
  opt-in, or move to user-level configuration.
- Flux-specific comment "this repo only tests Flux bootstrap" in the shared k3d config.
- `switchCurrentContext: true` is unnecessary because every task passes `--context`.
- Kubernetes runtime pinning stays with the implementation planning todo.
