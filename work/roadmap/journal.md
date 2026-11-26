# Journal

## Purpose

This document records accomplishments, decisions, and learning over time, explaining what
changed and why it mattered. It preserves the story of progress as [Areas](areas.md) and
[Iteration](iteration.md) evolve. Design and research outcomes count alongside implemented features.

## Format

Months use H2 headings. Each entry uses an H3 heading with a date and short descriptive title,
followed by concise bullets about accomplishments, decisions, and learning. Include commits,
work notes, or other evidence when useful. Horizontal rules separate months. Draft entries retain
"Draft" in the heading until reviewed.

An iteration closeout entry summarizes the week's results and learning, followed by a shell
code block that retrieves its final committed account. Use the commit containing that account,
before the completed weekly section was removed from the rolling document:

```shell
git show <commit-id>:work/roadmap/iteration.md
```

---

## November 2026

### 2026-11-26 — Standardize mise configuration and task scripts (Draft)

- **Accomplishments:** Reviewed and standardized every mechanical aspect of `mise.toml`,
  `mise.lock`, and the bash scripts under `.mise/`, applied the conventions across the repository
  (commits `2988bdd` through `7640762`), and published durable standards in
  [Mise standard](../../docs/standards/mise-standard.md) and
  [Bash script standard](../../docs/standards/bash-script-standard.md). Wired both standards into
  [docs/README.md](../../docs/README.md) and [AGENTS.md](../../AGENTS.md), and aligned
  [Local development](../../docs/how-to/00-local-development.md).
- **Key decisions:**
  - Consolidated tasks into five zero-argument namespaces (`upstream:`, `build:`, `dev:`,
    `verify:`, `release:`) with file tasks under `.mise/tasks/` and standalone executed helpers
    under `.mise/cluster/` (`cluster.sh`, `install-component.sh`, `push-artifact.sh`,
    `k3d-config.yaml`).
  - Kept task scripts strictly linear (no functions, `case`, or `trap`); drove component-specific
    cluster wiring through `FLUX_BOOTSTRAP_MANIFEST` and `FLUX_SYNC_MANIFESTS` in `mise.toml`.
  - Pinned Kubernetes/pipeline tools plus `shellcheck` with literal versions locked across four
    platforms in `mise.lock` (backend priority: default registry → `github:` → digest-pinned
    `docker run`); left host utilities (`docker`, `git`, `bash`, `curl`, `openssl`, `jq`) on the
    host.
  - Disambiguated registry and URL naming (`RELEASE_REGISTRY`, `registry_container`,
    `registry-host-address` / `registry-cluster-address`, `oci_repository_url` vs. `artifact_url`,
    `UPSTREAM_PROJECT`) and simplified `install-component.sh` to a single `dev|verify` argument.
  - Kept local k3d cluster names deterministic (`<component>-dev`, `<component>-verify`) under the
    single-checkout assumption, with `switchCurrentContext: false` and no host-specific registry
    mirrors.
- **Learning:** Keeping `mise-standard.md` and `bash-script-standard.md` free of both Bash 101
  boilerplate and Cur8s-specific lifecycle/k3d architecture keeps them short, non-obvious, and
  reusable across repositories.
- **Verification:** `bash -n .mise/cluster/*.sh .mise/tasks/*/*`,
  `mise exec -- shellcheck .mise/cluster/*.sh .mise/tasks/*/*` (0 warnings), `mise run dev:update`
  against `flux-dev`, `mise run verify:run` (fresh drift check, `flux-verify` bootstrap,
  reconciliation to Ready on `verify@sha256:...`, and cluster cleanup), and `git diff --check` all
  passed.
- **Handoff:** Historical cross-repo lifecycle proposals under
  [Design cross-repo patterns for non-Flux components](../parked/design-cross-repo-component-lifecycle/overview.md)
  still need reconciling with the settled five-namespace task layout when that parked work resumes.

### 2026-11-26 — Adopt capability naming and independent SemVer (Draft)

- **Accomplishments:** Switched the package identity from `flux` to the `gitops` capability name
  (`ghcr.io/cur8s/gitops`), replaced upstream-derived `CUR8S_REVISION` versioning in `mise.toml`
  with an explicitly authored independent SemVer (`0.1.0`) validated via `CUR8S_TAG`, updated
  deploy overlay labels (`cur8s.io/component: gitops`) and sync manifests (`OCIRepository/gitops`,
  `Kustomization/gitops`), re-rendered `artifacts/rendered/`, renamed the GitHub repository from
  `cur8s/flux` to `cur8s/gitops`, and updated durable documentation across `README.md`,
  `docs/product/`, `docs/architecture/`, `docs/how-to/00-local-development.md`,
  `docs/user-guide.md`, and `docs/standards/repository-entry-files-standard.md` (commits `05f3ca1`,
  `080b3fa`, `fd7572b`).
- **Key decisions:**
  - Confirmed via GitHub API (`404`) that no package had been published to `ghcr.io/cur8s/flux`, so
    no legacy OCI tag migration was needed.
  - Started `gitops` at bare pre-1.0 SemVer `0.1.0` (`CUR8S_VERSION = "0.1.0"`, validated by
    derived `CUR8S_TAG` per `MISE-004`) until release hardening completes.
  - Kept `cur8s.io/release-descriptor/v1` and internal `upstream/flux.yaml` /
    `artifacts/rendered/deploy/flux.yaml` filenames unchanged while renaming the package and GitHub
    repository to `gitops`.
  - Recorded the eight agreed Cur8s capability package names (`gitops`, `certificates`, `secrets`,
    `gateway`, `postgres`, `metrics`, `logging`, `grafana`) and carried the independent SemVer
    rationale (rejected alternatives, compatibility-contract bump policy, and provenance/BOM
    trade-offs) into
    [Publication and self-management](../../docs/architecture/03-publication-and-self-management.md#version-identity-and-immutable-publication).
- **Verification:** `git diff --check`, `bash -n .mise/cluster/*.sh .mise/tasks/*/*`,
  `mise exec -- shellcheck .mise/cluster/*.sh .mise/tasks/*/*`, `MISE-004` malformed-version
  rejection check (`v0.1.0`), `mise run dev:create` / `dev:status` / `dev:reconcile` /
  `dev:delete` (confirming `gitops-dev`, `OCIRepository/gitops`, `Kustomization/gitops`, and
  `cur8s.io/component=gitops` on all three controllers), and `mise run verify:run` passed on
  `05f3ca1`; `mise run build:render` and `git diff --check` passed after updating repo URLs in
  `080b3fa`; trailing-whitespace check passed on docs-only `fd7572b`.
- **Original proposal:** The unedited versioning proposal removed with
  `work/todo/1-adopt-capability-naming-and-semver/` remains in Git history:

```shell
git show fd7572b:work/todo/1-adopt-capability-naming-and-semver/versioning-proposal.md
```

### 2026-11-26 — Move self-management Kustomization out of the package (Draft)

- **Accomplishments:** Removed `sync.yaml` from `src/config/` and `artifacts/rendered/` (stopping
  `.mise/tasks/build/render` from copying it), relocated this repository's local dev/verify
  self-management `Kustomization` to [`test/sync.yaml`](../../test/sync.yaml) (with
  [`test/README.md`](../../test/README.md) and `FLUX_SYNC_MANIFESTS = "test/sync.yaml"` in
  `mise.toml`), added an explicit Flux CRD `Established` readiness check
  (`kubectl wait crd -l app.kubernetes.io/part-of=flux --for=condition=Established --timeout=2m`)
  to [`.mise/cluster/install-component.sh`](../../.mise/cluster/install-component.sh), rewrote
  [User guide](../../docs/user-guide.md) with a complete copy-and-paste production bootstrap path,
  and updated durable documentation across `src/README.md`, `docs/README.md`,
  `docs/product/01-pre-rendered-manifests.md`, `docs/how-to/00-local-development.md`, and
  `docs/architecture/` (commit `ce5a6c7`).
- **Key decisions:**
  - Placed the repo-local dev/verify sync fixture at `test/sync.yaml` (rather than
    `.mise/cluster/sync.yaml`) so `.mise/cluster/` stays identical across component repositories.
  - Kept the production self-management manifest (`OCIRepository` + `Kustomization`) as a
    documented copy-and-paste example in [User guide](../../docs/user-guide.md) only, rather than
    publishing a third release asset.
  - Used `kubectl wait crd -l app.kubernetes.io/part-of=flux --for=condition=Established` in
    `install-component.sh` so all Flux CRDs installed by `FLUX_BOOTSTRAP_MANIFEST` are established
    before any Flux custom resources are applied, while keeping the helper identical across
    component repositories.
- **Verification:** `mise run build:render`, `bash -n .mise/cluster/*.sh .mise/tasks/*/*`,
  `mise exec -- shellcheck .mise/cluster/*.sh .mise/tasks/*/*` (0 warnings), `git diff --check`,
  `mise run dev:create` / `dev:update` / `dev:status` / `dev:delete`, and `mise run verify:run` on
  committed `ce5a6c7` (fresh drift check, `gitops-verify` bootstrap with all 10 Flux CRDs
  `Established` and all 3 controllers `Available`, reconciliation to `Ready` on
  `verify@sha256:e63d2842`, and cluster cleanup) all passed.
- **Original proposal:** The unedited Flux bootstrap proposal removed with
  `work/todo/2-move-self-management-to-consumer/` remains in Git history:

```shell
git show ce5a6c7:work/todo/2-move-self-management-to-consumer/flux-bootstrap-proposal.md
```

### 2026-11-26 — Clarify the Notification Receiver contract (Draft)

- **Accomplishments:** Resolved the Notification Controller `Receiver` contract and updated
  [The package's opinion](../../docs/product/02-the-opinion.md),
  [Product README](../../docs/product/README.md), [Documentation strategy](../../docs/README.md),
  and [User guide](../../docs/user-guide.md) (commit `62b51b4`).
- **Key decisions:**
  - Kept the upstream `notification-controller` surface (`Receiver` CRD, `webhook-receiver`
    ClusterIP Service, and `allow-webhooks` NetworkPolicy) unmodified; upstream unconditionally
    registers `ReceiverReconciler` and starts its port `9292` webhook server with no disable flag.
  - Documented both outgoing reporting (`Alert`, `Provider`) and incoming webhooks (`Receiver`) as
    optional operator opt-ins: the package configures none of them and does not expose
    `webhook-receiver` outside the cluster.
  - Clarified that webhook-triggered reconciliation of already-declared resources is compatible with
    Cur8s' model, contrasting it explicitly with the excluded Image Reflector and Image Automation
    controllers (which discover versions and rewrite configuration).
- **Verification:** `git diff --check` and `git diff --cached --check` passed; verified no remaining
  unresolved contract references, trailing whitespace, or `work/` boundary violations in `README.md`
  and `docs/`. No manifests or overlays changed.

### 2026-11-26 — Pin the Kubernetes test runtime (Draft)

- **Accomplishments:** Pinned the local `dev` and `verify` Kubernetes test runtime to the latest
  reviewed GA patch of the current Kubernetes GA N-1 minor (`KUBERNETES_VERSION = "1.36.6"`,
  derived `K3S_IMAGE = "rancher/k3s:v1.36.6-k3s1"`, matching `kubectl` pin across all four
  `mise.lock` platforms), passed `--image "$K3S_IMAGE"` explicitly in
  [`.mise/cluster/cluster.sh`](../../.mise/cluster/cluster.sh), added client/server version
  assertions after cluster creation, added `flux check --pre` in
  [`.mise/cluster/install-component.sh`](../../.mise/cluster/install-component.sh), and documented
  the compatibility contract, verification boundary, and runtime advance procedure in
  [User guide](../../docs/user-guide.md#kubernetes-compatibility),
  [Architecture overview](../../docs/architecture/00-overview.md#verification-responsibilities),
  [Publication and self-management](../../docs/architecture/03-publication-and-self-management.md#verification-scope-and-remaining-publication-work),
  and [Local development](../../docs/how-to/00-local-development.md#advance-the-kubernetes-test-runtime)
  (commits `9999769`, `8fed67b`).
- **Companion `mise.toml` and metadata cleanups:** While wiring the pin, simplified and clarified
  `mise.toml` and cross-repo metadata conventions (commits `8932ce6`, `d9627ec`, `0d2e08f`,
  `44beeae`, `eb9c7d3`, `9f6bf53`):
  - Replaced bare `UPSTREAM_PROJECT` with full URL `UPSTREAM_SOURCE` (updating `cur8s.yaml` to
    `upstream.source` and OCI/Kustomization annotations to `cur8s.io/upstream-source`).
  - Renamed component-scoped variables (`CUR8S_COMPONENT`, `CUR8S_VERSION`, `CUR8S_SOURCE`,
    `CUR8S_DOCS`) to `COMPONENT_*` and renamed `RELEASE_REGISTRY` to `CUR8S_REGISTRY` so
    `CUR8S_*` stays reserved for org-wide values.
  - Renamed `FLUX_SYNC_MANIFESTS` to `FLUX_SYNC_PATH` to clarify it takes a single repo file or
    directory path.
  - Simplified `[env]` by grouping raw inputs linearly above derived templates, removing inline
    Tera `throw(...)` validation conditionals and `COMPONENT_TAG` (`MISE-004`), and moving
    `[tools]` after `[env]` so `flux2` and `kubectl` reference `{{ env.UPSTREAM_VERSION }}` and
    `{{ env.KUBERNETES_VERSION }}` directly (`MISE-003`).
- **Key decisions:**
  - Selected Kubernetes `1.36.6` rather than the `1.35.x` example from the earlier plan because
    Kubernetes `1.37` reached GA on 2026-08-26 (making `1.36` the current GA N-1 minor) and Flux
    `v2.9.0` supports Kubernetes `1.34`–`1.36`.
  - Placed both the client/server version assertion and `flux check --pre` in the shared
    `.mise/cluster/` helpers so both `dev:create` and `verify:run` enforce the same runtime checks.
  - Kept the Kubernetes runtime advance procedure in
    [Local development](../../docs/how-to/00-local-development.md#advance-the-kubernetes-test-runtime)
    rather than introducing a new `CONTRIBUTING.md`.
- **Verification:** Verified `rancher/k3s:v1.36.6-k3s1` publishes both `linux/amd64` and
  `linux/arm64` via `docker manifest inspect`; verified `mise lock`, `mise install`, `mise env`,
  `mise run upstream:check`, `mise run build:render`, `bash -n`, `shellcheck` (0 warnings),
  `git diff --check`, and full `mise run verify:run` (confirming `client=v1.36.6`,
  `server=v1.36.6+k3s1`, `flux check --pre` passed, Flux bootstrap, OCI push, self-management
  `Ready`, and cluster cleanup).
- **Deferred:** Testing the pinned `rancher/k3s` image on GitHub Actions `linux/amd64` runners
  remains parked in [Finalize the CI workflows](../parked/finalize-ci-workflows/overview.md) until
  live CI workflows are restored.
