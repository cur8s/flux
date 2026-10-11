---
title: "Create the Cur8s test harness"
summary: "Build and release a reusable command-based k3d/k3s test substrate for Cur8s package repositories."
---

# Handoff: create `cur8s/cur8s-test-harness`

Assume the GitHub repository `cur8s/cur8s-test-harness` already exists. This is a
request to implement its initial release as a small, versioned suite of shell
commands. Work in that new repository and first read its repository instructions
(`AGENTS.md`, `README`, and existing configuration) before making changes.

## Why this exists

Cur8s is splitting its upstream monorepo into independently released package
repositories, including Flux, cert-manager, and others. Every package needs a local
and CI-friendly Kubernetes environment for end-to-end testing. Those environments
must behave the same across repositories and must not silently change Kubernetes
version when k3d changes.

The harness provides only the common *test substrate*: local k3d/k3s lifecycle, an
optional local OCI registry, prerequisite checks, readiness, diagnostics, and a
Kubernetes-version assertion. A consuming package retains responsibility for its own
artifact build and push, installation/bootstrap, controller readiness, semantic
acceptance checks, and e2e cleanup policy.

The public boundary is a set of commands installed on `PATH`, not a Bash library
that package scripts source. The harness may organize its own implementation with
sourced libraries internally, but command names, flags, stdout formats, and exit
codes are its stable external contract.

## Reference material to inspect before implementing

Use the active code, not stale monorepo documentation, as the source of behavior to
reuse and improve.

1. The main extraction source is
   [`scripts/cluster`](/Users/adib/dev/cur8s/monorepo-cur8s/scripts/cluster). It is
   a Bash CLI with `create`, `reset`, `exists`, `env`, `status`, `delete`, and
   `purge`; it checks Docker/k3d/kubectl/jq, creates a local registry, waits for it,
   reports ports, and handles interactive versus CI recreation.
2. Also inspect the monorepo's
   [`scripts/k3d-config.yaml`](/Users/adib/dev/cur8s/monorepo-cur8s/scripts/k3d-config.yaml),
   [`scripts/make/e2e`](/Users/adib/dev/cur8s/monorepo-cur8s/scripts/make/e2e), and
   [`scripts/lib`](/Users/adib/dev/cur8s/monorepo-cur8s/scripts/lib). The e2e script
   demonstrates what belongs to a consumer rather than the harness.
3. Compare the newer, narrower Flux implementation:
   [`mise-tasks/cluster/k3d.sh`](/Users/adib/dev/cur8s/flux/mise-tasks/cluster/k3d.sh),
   [`cluster:create`](/Users/adib/dev/cur8s/flux/mise-tasks/cluster/create), and
   [`test:e2e`](/Users/adib/dev/cur8s/flux/mise-tasks/test/e2e). It has useful
   registry discovery and success-cleanup/failure-preservation behavior.
4. Note the current version inputs, but do not copy them blindly:
   - The monorepo's [`src/KUBERNETES_VERSION`](/Users/adib/dev/cur8s/monorepo-cur8s/src/KUBERNETES_VERSION)
     is `1.33.0`. It is passed only to Helm `--kube-version` through
     [`common.mk`](/Users/adib/dev/cur8s/monorepo-cur8s/common.mk), **not** to k3d.
     Its k3d runtime is therefore the changing k3d default. Correct this design in
     the harness; do not preserve the defect.
   - The monorepo's Flux component is `v2.8.6` at
     [`src/core/flux/config/VERSION`](/Users/adib/dev/cur8s/monorepo-cur8s/src/core/flux/config/VERSION).
   - The standalone Flux package is now `FLUX_VERSION=2.9.0` in
     [`version.env`](/Users/adib/dev/cur8s/flux/version.env). It currently pins k3d
     `5.9.0` and kubectl `1.36.2` in
     [`mise.toml`](/Users/adib/dev/cur8s/flux/mise.toml), but has not yet been
     migrated to the harness.

For a package migration, re-check the current Kubernetes GA N-1 target and the
pinned component's upstream Kubernetes support at that time. Do not infer a current
support range from this handoff.

## Decisions already made

- Repository name: `cur8s/cur8s-test-harness`.
- The harness has its own SemVer release stream, independent of Flux, cert-manager,
  Kubernetes, and k3d releases.
- Consumers install a released harness archive with Mise's GitHub backend. Do not
  make raw URL-executed Mise tasks, experimental remote task includes, or a GitHub
  Action the primary implementation.
- The release is a portable archive containing executable shell commands in `bin/`.
  It must work on macOS Apple Silicon and Linux x86_64 without architecture-specific
  binaries.
- A package owns the exact Kubernetes patch it tests. That is necessary because
  Mise must know the value before it resolves that package's `kubectl` tool. The
  harness receives the value as an explicit command option, derives the k3s image,
  and fails if the running server does not match.
- Cur8s tests the newest reviewed GA patch in its selected N-1 minor. This is a
  deliberate repository update, not an unreviewed runtime lookup for a `latest` tag.
  Use a human-readable k3s release tag such as
  `rancher/k3s:v1.35.6-k3s1`, not an image digest.
- `jq` is a host prerequisite for the shell implementation, not a version-pinned
  Mise contract. The harness must check for it and give an actionable error.

## Initial public command contract

Start with narrow, useful commands. Do not invent Flux-, cert-manager-, or
platform-specific commands.

```text
cur8s-preflight check [--require docker] [--require k3d] [--require kubectl] [--require jq]

cur8s-cluster create \
  --name <name> \
  --kubernetes-version <major.minor.patch> \
  [--k3s-packaging-revision <suffix>] \
  [--registry] \
  [--config <k3d-config.yaml>] \
  [--recreate]

cur8s-cluster status --name <name>
cur8s-cluster env --name <name> --format dotenv
cur8s-cluster assert-version \
  --name <name> --kubernetes-version <major.minor.patch>
cur8s-cluster delete --name <name> [--registry]
```

`create` derives the server image exactly as:

```text
rancher/k3s:v<KUBERNETES_VERSION>-<K3S_PACKAGING_REVISION>
```

The default packaging revision may be `k3s1`, but it must be an explicit override
because K3s can change it. Pass the derived value to `k3d cluster create --image`.
Never accept k3d's default k3s image.

`assert-version` must obtain the server version using the named k3d context and fail
unless it begins with `v<KUBERNETES_VERSION>` (K3s adds its own suffix, such as
`+k3s1`). When kubectl is available, also report its client version for diagnostics;
the consumer will pin it to the same Kubernetes patch.

For `env --format dotenv`, reserve stdout exclusively for shell-safe assignments so
consumers can use it safely:

```bash
eval "$(cur8s-cluster env --name flux-e2e --format dotenv)"
```

At minimum export documented values for cluster name, kube context, host registry
address/port, and in-cluster registry address. Human progress, warnings, and errors
go to stderr. Other commands may use human-readable stdout.

The harness should create a per-cluster local registry named `<cluster>-registry`
when `--registry` is selected, wait for its `/v2/` endpoint, and report both
`localhost:<host-port>` and `<cluster>-registry:5000`. This is generic enough for
Cur8s packages because their artifacts are OCI artifacts tested through Flux, but a
consumer must be able to omit it.

## Explicit extraction boundary

Reuse from the monorepo and Flux code:

- Docker, k3d, kubectl, and jq checks; include a Docker-daemon reachability check.
- Cluster existence, state, create, delete, reset/recreate, status, and registry
  port discovery.
- Bounded API and registry readiness polling.
- Stable non-interactive behavior suitable for CI.
- Helpful diagnostics and preserving a failed e2e cluster when the *consumer* asks
  to preserve it.

Do **not** copy these into the generic harness:

- The monorepo's hard-coded dual load-balancer ports `80` and `8080`, default host
  ports, or platform gateway assumptions.
- Flux bootstrap, OCI artifact push, source/Kustomization creation, or Flux-specific
  logs and readiness checks.
- The monorepo's package and platform `verify.sh` resource checks; those encode
  particular CRDs and workloads.
- A global policy to delete a consumer's cluster on test completion. The consuming
  e2e task owns its success cleanup and failure-preservation policy.

Use a minimal default k3d config (one server, zero agents). A consumer may supply a
package-specific config or further options when it needs ingress, special ports, or
distribution settings. Make unsupported combinations fail clearly rather than
silently ignoring them.

## Proposed repository layout

Adapt this to the new repository's conventions rather than treating it as a mandate:

```text
bin/
  cur8s-preflight
  cur8s-cluster
lib/
  cli.sh
  docker.sh
  k3d.sh
  registry.sh
  versions.sh
  wait.sh
config/
  default-k3d.yaml
tests/
  ...
scripts/
  package-release-archive.sh
README.md
```

Keep `lib/` private to the harness. Only executable commands in `bin/` are a
consumer-facing API.

## Release and Mise consumption

Cut a harness release such as `v0.1.0` and publish a GitHub Release asset named, for
example, `cur8s-test-harness_0.1.0.tar.gz`. The archive should extract a `bin/`
directory whose executables retain their executable bits.

A consuming package can use the released command suite like this:

```toml
[env]
# Package-owned test target. This must be present before Mise resolves tools.
KUBERNETES_VERSION = "1.35.6"
K3S_PACKAGING_REVISION = "k3s1"

[tools]
kubectl = "{{ env.KUBERNETES_VERSION }}"
k3d = "5.9.0"
"github:cur8s/cur8s-test-harness" = {
  version = "0.1.0",
  asset_pattern = "cur8s-test-harness_{{ version }}.tar.gz",
  bin_path = "bin",
}
```

And an e2e task would look conceptually like:

```bash
cur8s-preflight check --require docker --require k3d --require kubectl --require jq
cur8s-cluster create \
  --name "$CLUSTER" \
  --kubernetes-version "$KUBERNETES_VERSION" \
  --k3s-packaging-revision "$K3S_PACKAGING_REVISION" \
  --registry
cur8s-cluster assert-version \
  --name "$CLUSTER" --kubernetes-version "$KUBERNETES_VERSION"

# Package-owned build, install/bootstrap, readiness, and semantic checks follow.
```

Verify the exact GitHub backend configuration with the installed/current Mise
documentation before finalizing it. The release archive is the artifact contract;
the commands must work without Mise too when invoked directly with their required
host tools on `PATH`.

## Delivery plan

1. Inspect the new repository, the listed source files, and current Mise GitHub
   backend documentation. Write a concise README that defines the command contract,
   host prerequisites, configuration ownership, and release consumption example.
2. Implement `cur8s-preflight` and `cur8s-cluster` with strict Bash behavior and
   clear errors. Begin with create/status/env/assert-version/delete; add reset only
   if it remains small and testable.
3. Add automated tests for argument validation, image construction, dotenv output,
   failure behavior, and Docker/k3d command construction. Run a real disposable
   k3d smoke test where Docker is available: create a registry-backed cluster using
   an explicit image, assert its version, verify emitted environment values, then
   delete it.
4. Package the release archive, inspect its contents and executable permissions,
   and verify a fresh consumer fixture can use Mise to install the release and run
   both commands. Do not release/push unless the user explicitly authorizes it.
5. Only after v0.1.0 exists, create follow-up work to migrate the standalone Flux
   package. Its current runtime-pinning plan lives at
   [`work/todo/pin-kubernetes-test-runtime/plan.md`](/Users/adib/dev/cur8s/flux/work/todo/pin-kubernetes-test-runtime/plan.md).

## Completion criteria for the initial release

- A versioned release archive exposes the documented commands via Mise's GitHub
  backend on macOS and Linux.
- Commands create a k3d cluster from the requested k3s image rather than a k3d
  default, and assert the actual server version.
- A registry-backed cluster can be consumed by a package e2e task without
  package-specific behavior in the harness.
- The command contract, output formats, errors, and host prerequisites are
  documented.
- The harness itself has automated coverage plus a proportionate real k3d smoke
  test.
- No Flux, cert-manager, or monorepo-specific bootstrap/verification behavior is
  embedded in the harness.
