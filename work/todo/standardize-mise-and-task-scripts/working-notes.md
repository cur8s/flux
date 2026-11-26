# Working notes: mise and task-script conventions

The consolidated record of review decisions, for the documentation phase to publish from. Each
entry separates owner decisions from observations and proposals.

## Review by namespace

The owner chose to review the task namespaces one at a time, starting with `cluster` because it is
identical across component repositories. Whether this replaces the plan's topic-by-topic rounds is
not yet decided.

### Clusters (formerly the `cluster` namespace)

**Owner decisions (2026-10-14):**

- **No `cluster:*` tasks.** Nobody runs a bare cluster operation on its own; mise tasks such as
  `dev:create` and `test:run` remain the entry points.
- **One helper, `.mise/cluster.sh`, run rather than sourced,** copied identically into every
  component repository alongside `.mise/k3d-config.yaml`. It has one function per operation and
  dispatches on its first argument: `create`, `delete`, `status`, `registry-port`, and `context`.
- **Clusters are addressed by role, `dev` or `test`,** and the helper derives the name,
  `<component>-dev` or `<component>-test`. Passing both a role and a name was rejected: the name is
  fully determined by the role. This removed `CLUSTER_NAME`, `TEST_CLUSTER_NAME`, and the name-prefix
  guard, since no caller-supplied name can reach another repository's cluster.
- **The helper guards `CUR8S_COMPONENT` and `KUBECONFIG`** with `${VAR:?}`: unset or empty, it stops
  before any k3d call. Unset `KUBECONFIG` would make k3d write to `~/.kube/config`.
- **Contracts:** `create` fails clearly when the cluster exists and returns once the API server
  accepts requests and the registry answers; the following tasks do not need the node to be Ready.
  `delete` succeeds when the cluster is already gone and surfaces other failures. `status` reports
  whether the cluster exists, whether its API is reachable, and its registry endpoint, exiting
  non-zero only when the cluster does not exist.
- **Scripts as simple as possible:** no checks k3d already performs and no `sed`/`awk` pipelines.
- **`status` checks the API the way a user would:** `kubectl get nodes`, not the lower-level
  `/readyz` endpoint, and with no `--request-timeout`; a hung API server is rare locally and
  visible when it happens.
- **`in-cluster-registry` stays,** so the registry naming and its internal port live only in the
  helper.

**Applied:**

- `.mise/cluster.sh` implements the decisions; `.mise/tasks/cluster/` is removed.
- `dev:create|status|delete` and `flux:*` take an optional `[cluster]` argument, default `dev`, and
  `oci:publish` a `--cluster` flag, each restricted with usage `choices "dev" "test"`, so mise rejects
  other values before the script runs. `test:run` and `test:destroy` always use `test`.
- The test cluster is now `flux-test` (formerly `flux-e2e`); the `e2e` artifact tag is unchanged.
- One addition beyond the agreed operations: `in-cluster-registry`, which prints
  `<name>-registry:5000` for `dev:create`'s OCIRepository URL, so callers never spell cluster names.
- Verified: guard and argument errors; `status` on a missing cluster exits 1; `test:destroy` on a
  missing cluster exits 0; `test:run` passed; `dev:create`, `dev:status`, `flux:reconcile`, and
  `dev:delete` worked on `flux-dev`; no containers left behind.

**Observed with k3d 5.9.0** (disposable clusters, and the v5.9.0 source in `pkg/client/cluster.go`,
`registry.go`, `runtimes/docker/node.go`, and `pkg/types/k3slogs.go`):

- `k3d cluster create` on an existing name fails immediately with "a cluster with that name
  already exists".
- `k3d cluster delete` exits 0 for a missing cluster and removes the registry made by
  `--registry-create`.
- `k3d cluster list <name>` exits 1 for a missing cluster; it succeeds for a stopped one, whose API
  refuses connections and whose registry has no published port.
- `wait: true` waits for the server log line "k3s is up and running", meaning the API server
  serves requests. `--registry-create` creates the registry container during preparation but starts
  it with the helper nodes after the servers, and k3d waits only for the load balancer among
  helpers. Nothing waits for the registry, hence the `curl --retry .../v2/` check.
- Neither Docker nor k3d reports registry readiness: `registry:2` defines no `HEALTHCHECK`, Docker
  has no wait-until-healthy command, and k3d's registry ready log line is unused during creation.
- k3d picks the registry's host port at creation. Three places expose it: Docker's documented
  `inspect` field `NetworkSettings.Ports["5000/tcp"][0].HostPort` (chosen: one command, no pipes;
  fails when the registry is stopped), the standard `local-registry-hosting` ConfigMap in
  `kube-public` (needs parsing of embedded YAML; k3d only warns if writing it fails), and the
  undocumented `k3s.registry.port.external` container label.

**Input for the lifecycle design todo:** the [lifecycle proposal](../design-component-lifecycle/proposal.md)
records `cluster:create|status|delete` as agreed, with a default name plus an explicit override.
These decisions supersede that and need reconciling there.

**Open for the owner:**

- Two checkouts of the same component (clones or git worktrees) compute the same cluster names,
  and k3d names are global to the Docker host: one checkout's `delete` or `test:run` cleanup removes
  the other's cluster. Options: a checkout-specific name suffix, or refusing to delete a cluster
  whose context is not in this checkout's `KUBECONFIG`. Two different components coexist without
  conflict (observed: separate containers, networks, host ports, and kubeconfigs).
- The zot pull-through mirror at `host.k3d.internal:5051` in `.mise/k3d-config.yaml`: keep, make
  opt-in, or move to user-level configuration.
- Kubernetes runtime pinning stays with the implementation planning todo.

### Flux bootstrap (`flux:boot` removed)

**Owner decisions (2026-11-24):**

- **No `flux:boot` task.** With `cluster:*` removed, there is no standalone setup flow that starts
  from a bare cluster, so `flux:boot` was a confusing leftover in `mise tasks`. Inline its two
  `kubectl` commands (server-side apply of `artifacts/rendered/deploy/flux.yaml` and waiting for
  controller Deployments to be `Available`) into `dev:create`, leaving the `flux:` namespace purely
  for inspecting and reconciling a running cluster (`flux:status`, `flux:reconcile`, `flux:watch`).

**Applied:**

- Removed `.mise/tasks/flux/boot` and inlined the controller apply and `Available` wait into
  `.mise/tasks/dev/create`.
- Updated `mise.toml` header comments and
  [Publication and self-management](../../../docs/architecture/03-publication-and-self-management.md).
- Verified: `mise tasks` no longer lists `flux:boot`; `mise run test:run` passed (drift check,
  inlined bootstrap in `dev:create`, local OCI publish, reconciliation to Ready, and test cluster
  cleanup).

**Input for the lifecycle design todo:** the [lifecycle proposal](../design-component-lifecycle/proposal.md),
[task namespace reference](../design-component-lifecycle/task-namespaces-proposal.md), and
[Flux bootstrap proposal](../design-component-lifecycle/flux-bootstrap-proposal.md) record
`flux:boot` as agreed/decided. This decision supersedes that and needs reconciling there.

### `dev` and `test` namespaces (`flux:` folded into `dev:`)

**Owner decisions (2026-11-24):**

- **Fold the remaining `flux:` tasks into `dev:` and remove the `flux:` namespace.** `flux:status`
  folds into `dev:status`, `flux:reconcile` becomes `dev:reconcile`, and `flux:watch` becomes
  `dev:watch`. One namespace for all local cluster work avoids remembering whether an operation is
  under `dev:` or `flux:` and eliminates the `flux` tool/component name collision.
- **Specialize `dev:*` to the `dev` cluster only (no `[cluster]` argument).** Passing `test` to
  `dev:*` or `flux:*` was confusing; `dev:*` always targets `dev` (`<component>-dev`), while
  `test:*` owns the ephemeral `test` cluster (`<component>-test`). On failure, `test:run` prints
  Flux state and copy-pasteable `mise exec` commands for inspecting `test`.
- **Add `dev:update` for the local iteration loop.** Renders, publishes to `dev`'s local registry
  under `:dev`, and reconciles Flux (`build:render` → `oci:publish --cluster dev --tag dev` →
  `dev:reconcile`). Chosen over `dev:publish` to keep `publish` reserved for formal releases and
  over `dev:push` for lifecycle symmetry with `dev:create` / `dev:status` / `dev:delete`.
- **Both `dev:create` and `dev:update` run `build:render` first** (`depends=["build:render"]`),
  since rendering is offline and ~80ms, preventing stale pushes while `oci:publish` remains
  render-free.
- **Align cleanup verb to `delete`:** rename `test:destroy` to `test:delete` to match `dev:delete`.
- **Share cluster setup via `.mise/env.sh`:** component-specific helper called by `dev:create` and
  `test:run`, keeping `.mise/cluster.sh` identical across component repositories.

**Applied:**

- Created `.mise/env.sh` and `.mise/tasks/dev/update`.
- Moved `flux:reconcile` and `flux:watch` into `.mise/tasks/dev/`, folded `flux:status` into
  `.mise/tasks/dev/status`, removed `.mise/tasks/flux/`, and removed `[cluster]` arguments from all
  `dev:*` tasks.
- Renamed `.mise/tasks/test/destroy` to `.mise/tasks/test/delete`; updated `.mise/tasks/test/run`
  to call `.mise/env.sh` and print `mise exec` inspection commands plus `mise run test:delete` on
  failure.
- Updated `mise.toml`, `.mise/README.md`, [00-local-development.md](../../../docs/how-to/00-local-development.md),
  [01-source-to-artifact.md](../../../docs/architecture/01-source-to-artifact.md), and
  [03-publication-and-self-management.md](../../../docs/architecture/03-publication-and-self-management.md).
- Verified: `mise tasks` lists the 13 tasks across 5 namespaces; `mise run test:run` passed (drift
  check, `.mise/env.sh create test e2e`, reconciliation, and `flux-test` cleanup); `mise run
  test:delete` exited 0 on missing `flux-test`; `mise run dev:status` and `mise run dev:update`
  (including `build:render`, local `oci:publish`, and `dev:reconcile`) passed against the existing
  `flux-dev` cluster; `dev:create` cleanly ran `build:render` and failed on the already-existing
  `flux-dev` cluster without disturbing it.

**Input for the lifecycle design todo:** supersedes the `flux:` namespace and `test:destroy` in
the [lifecycle proposal](../design-component-lifecycle/proposal.md) and
[task namespace reference](../design-component-lifecycle/task-namespaces-proposal.md), and adds
`dev:update`. Reconcile those documents during the lifecycle design todo.

### `verify` and `release` namespaces (replacing `test:` and `oci:`)

**Owner decisions (2026-11-24):**

- **Replace `test:` with `verify:` (`verify:run`, `verify:clean`).** Interactive testing already
  happens on `dev`; Workflow 4 is the automated release-readiness gate (drift + fresh end-to-end
  cluster verification). `verify:clean` removes any leftover verify cluster kept after a failure.
  The second cluster role in `.mise/cluster.sh` becomes `verify` (`<component>-verify`).
- **Replace `oci:publish` with `release:publish` and extract `.mise/oci-push.sh`.** Keeps
  `build:` strictly offline and reserves `release:` for explicit remote publication. Moving the
  shared `flux push artifact` + `cur8s.io/*` annotations logic into `.mise/oci-push.sh` (`local
  dev|verify <tag>` vs. `remote <tag>`) lets `release:publish` drop the `--cluster` flag so it
  only ever targets `REGISTRY`.
- **Full 5-namespace cross-repo standard:** `upstream:` (`check`, `fetch`), `build:` (`clean`,
  `render`), `dev:` (`create`, `update`, `status`, `reconcile`, `watch`, `delete`), `verify:`
  (`run`, `clean`), and `release:` (`publish`).

**Applied:**

- Created `.mise/oci-push.sh` (identical across component repos) and `.mise/tasks/release/publish`;
  removed `.mise/tasks/oci/`.
- Created `.mise/tasks/verify/run` and `.mise/tasks/verify/clean`; removed `.mise/tasks/test/`.
- Updated `.mise/cluster.sh`, `.mise/env.sh`, `.mise/tasks/dev/update`, `.mise/tasks/build/render`,
  and `.mise/tasks/upstream/check` for `verify` role and `.mise/oci-push.sh`.
- Updated `mise.toml`, `.mise/README.md`, [00-local-development.md](../../../docs/how-to/00-local-development.md),
  [01-source-to-artifact.md](../../../docs/architecture/01-source-to-artifact.md),
  [02-artifact-contents-and-metadata.md](../../../docs/architecture/02-artifact-contents-and-metadata.md),
  and [03-publication-and-self-management.md](../../../docs/architecture/03-publication-and-self-management.md).
- Verified: `mise tasks` lists the 13 tasks across `upstream`, `build`, `dev`, `verify`, and
  `release`; `mise run verify:run` passed (drift check, `flux-verify` bootstrap, `.mise/oci-push.sh
  local verify e2e`, reconciliation, and cleanup); `mise run verify:clean` exited 0 on missing
  `flux-verify`; `mise run dev:update` passed against `flux-dev` (4.35s); `mise run release:publish
  --help` shows `--tag` only (no `--cluster`).

**Input for the lifecycle design todo:** supersedes `test:run`, `test:destroy`, and `oci:publish`
in the [lifecycle proposal](../design-component-lifecycle/proposal.md) and
[task namespace reference](../design-component-lifecycle/task-namespaces-proposal.md). Reconcile
those documents during the lifecycle design todo.

### Task descriptions (`#MISE description`)

**Owner decisions (2026-11-24):**

- **Keep `#MISE description` short and scannable:** one imperative phrase, roughly ≤ 60 characters
  (fits in an 80-column `mise tasks` table without wrapping), no parenthetical caveats or
  semicolons, plain English instead of env var names, and consistent terminology (`push` for local
  dev pushes, `publish` reserved for `release:publish`).

**Applied:**

- Tightened `#MISE description` across all tasks under `.mise/tasks/` so `mise tasks` scans cleanly
  without wrapping.
- Hardened `release:publish` (2026-11-24): removed `--tag` override (always publishes
  `CUR8S_FLUX_VERSION` to `REGISTRY`) and added a clean git working tree check before pushing.
- Hardened `dev:update` (2026-11-24): delegated to `.mise/env.sh update dev dev` (keeping
  `dev:update` identical across component repos), added a clear error when the dev cluster is not
  running, and applied `artifacts/rendered/sync.yaml` before reconciling so sync edits take effect.
- Hardened `verify:run` (2026-11-24): fail fast with a `verify:clean` hint before fetching or
  rendering when a leftover `flux-verify` cluster already exists.

### Bash script linearity

**Owner decisions (2026-11-25):**

- **Keep task scripts as simple and linear as possible:** every script under `.mise/tasks/` reads
  top-to-bottom with no functions, `case` dispatchers, or `trap` handlers. Multi-action dispatch
  stays only in shared `.mise/*.sh` helpers (`.mise/cluster.sh`, `.mise/oci-push.sh`).

**Applied:**

- Replaced `cleanup()` + `trap` in `.mise/tasks/verify/run` with a linear `if ... else ... fi`.
- Inlined the `update` steps directly into `.mise/tasks/dev/update` and simplified `.mise/env.sh`
  to a single linear script (`.mise/env.sh dev|verify <tag>`) with no functions or `case` dispatch.
- Verified: `bash -n` on all scripts under `.mise/`, `mise run dev:update` (4.73s against
  `flux-dev`), and `mise run verify:run` (passed and cleaned up `flux-verify`).
- Fixed 3 script bugs (2026-11-25):
  - Renamed Flux-specific env vars in `mise.toml` to component-agnostic names (`UPSTREAM_VERSION`,
    `CUR8S_REVISION`, `UPSTREAM_TAG`, `CUR8S_VERSION`) so `.mise/oci-push.sh`, `release:publish`,
    and `upstream:check` are truly identical across component repos.
  - Guarded `git diff ... | head -n 100 || true` in `verify:run` so `SIGPIPE` under `pipefail`
    does not abort before printing the drift error message.
  - Added detached-HEAD fallback (`git describe --tags --exact-match` → `HEAD`) for `--revision`
    in `.mise/oci-push.sh`.
- Standardized bash style and comments (2026-11-25):
  - Always use `[[ ... ]]` (never `[ ... ]`), one statement per line (no semicolon-packed
    assignments or inline `{ ...; exit 1; }` blocks), introduce derived variables just in time
    where they are first used, and use full readable variable names (`input`, `output`,
    `target_cluster`, `artifact_tag`, `kube_context`, `in_cluster_registry`, `exit_code`,
    `artifact_dir`, `tracked_paths`).
  - Helpers open with purpose, callers, and usage comments; every task script opens with a short
    contract/precondition comment after `set -euo pipefail` (without narrating obvious commands).
  - Wrapped multi-step guidance in `upstream:check` into a readable heredoc.
- Renamed `.mise/env.sh` → `.mise/cluster-setup.sh` (2026-11-25) so it is not confused with an
  environment-variable file and pairs cleanly with `.mise/cluster.sh` and `.mise/oci-push.sh`.
- Split cluster creation out of `.mise/cluster-setup.sh` and renamed it to `.mise/install.sh`
  (2026-11-25): `dev:create` and `verify:run` now explicitly call `.mise/cluster.sh create`
  followed by `.mise/install.sh`, so `cluster.sh` owns k3d lifecycle exclusively and `install.sh`
  owns installing Flux and this component into an existing cluster.
- Adopted Pattern A — data-driven `.mise/install.sh` and `dev:update` (2026-11-25), informed by
  reviewing `/Users/adib/dev/cur8s/monorepo-cur8s`:
  - Added `FLUX_BOOTSTRAP_MANIFEST` and `FLUX_SYNC_MANIFESTS` to `mise.toml [env]`, and updated
    `.mise/install.sh` to wait on `ocirepository --all` and `kustomization --all` in `flux-system`.
  - `.mise/install.sh`, `.mise/cluster.sh`, `.mise/oci-push.sh`, and every task except
    `upstream:fetch` and `build:render` are now identical across Cur8s component repos.
  - Other component repos express multi-stage Kustomizations (`crds`/`bootstrap`/`deploy`/`finalize`),
    prerequisite `OCIRepository` + `Kustomization` graphs, and `postBuild` ConfigMaps declaratively
    under `FLUX_SYNC_MANIFESTS` rather than in imperative bash.
  - Notes for future component repos and lifecycle design:
    - Once consumer-owned `sync.yaml` moves out of the `flux` package, point `FLUX_SYNC_MANIFESTS`
      at the local test manifest directory without touching `.mise/install.sh`.
    - Components needing functional smoke tests (e.g. `cert-manager` ClusterIssuer check, `grafana`
      Gateway HTTP BasicAuth probe) can add an optional hook called by `verify:run` if present.
    - Multi-stage components (2–4 Kustomizations) need `dev:reconcile` targeting settled in the
      lifecycle design todo.
    - Repos probing HTTP Gateways add host port mappings in `.mise/k3d-config.yaml`.

### Tool pinning boundary and config cleanup

**Owner decisions (2026-11-25):**

- **Pin Kubernetes/pipeline tools in `mise.toml`; leave general system tools on the host.** `flux2`,
  `kustomize`, `kubectl`, and `k3d` are pinned and locked in `mise.lock`; `docker`, `git`, `bash`,
  `curl`, `openssl`, and `jq` are host prerequisites.
- **Keep `mise.toml` header concise:** point to `mise tasks` and `.mise/README.md` rather than
  duplicating the task inventory or stale `#USAGE` notes.
- **Generalize `.mise/k3d-config.yaml`:** remove the Flux-specific comment and set
  `switchCurrentContext: false` since every command passes `--context`.

**Applied:**

- Trimmed `mise.toml` header comment from 49 lines to 10 lines.
- Generalized `.mise/k3d-config.yaml` header and set `switchCurrentContext: false` (left the
  optional `host.k3d.internal:5051` zot mirror block intact).
- Added `jq` to the host utilities list in
  [00-local-development.md](../../../docs/how-to/00-local-development.md).

### Helper script naming (`.mise/*.sh`)

**Owner decisions (2026-11-25):**

- **Multi-action helpers** (dispatching on `$1`): `<noun>.sh` — `.mise/cluster.sh`.
- **Single-action helpers** (linear scripts): `<verb>-<noun>.sh` — `.mise/install-component.sh`,
  `.mise/push-artifact.sh` (and future helpers such as `package-artifact.sh`, `mirror-images.sh`).

**Applied:**

- Renamed `.mise/install.sh` → `.mise/install-component.sh` and `.mise/oci-push.sh` →
  `.mise/push-artifact.sh`, updating all callers, `mise.toml`, `.mise/README.md`, and architecture
  docs.
- Grouped all supporting helpers and config (`cluster.sh`, `install-component.sh`,
  `push-artifact.sh`, `k3d-config.yaml`) under `.mise/cluster/` (2026-11-25) so `.mise/` root holds
  only `README.md`, `cluster/`, and `tasks/`.
