---
title: "Design the component lifecycle"
summary: "Identify the goals and invariants of a Cur8s component's build-to-publish lifecycle, try candidate designs in disposable experiments, and document the chosen design."
---

# Design the component lifecycle

**Agreed with the owner:**

- This is an interactive design session focused on the problem: consider different approaches,
  try them out to see how they work, then choose.
- The first step is to identify clearly the lifecycle's goals and its invariants, before any
  approach is chosen.
- The remaining todo is **document only**. It ends with agreed goals and invariants, the chosen design with
  the alternatives considered, evidence from the experiments, and durable documentation.
  Implementation is planned afterwards by [Plan the lifecycle implementation](../plan-lifecycle-implementation/overview.md).
- The monorepo at `~/dev/cur8s/monorepo-cur8s` is a reference for what the needs are — its Make
  targets and scripts show what a component build actually did. Its files are referenced, not
  copied here.
- Requirements already identified are folded into this todo rather than kept as separate todos:
  traceable fetching, a locally packaged artifact that is the one tested and published, safe
  publication, and owned images. They are preserved in [requirements](requirements.md).
- The owner has since advanced the design into a [lifecycle proposal](proposal.md), recorded
  unedited. It
  is the current direction: architectural invariants, the namespaces `upstream`, `build`,
  `cluster`, and `flux` with per-task contracts and status, installation stages `crds`, `deploy`,
  and `post-install`, the intended local lifecycle, and the open decisions it says must not be
  resolved silently. Continue from those open decisions.
- The owner's [versioning proposal](versioning-proposal.md), recorded unedited, is the direction
  for versioning: independent SemVer per Cur8s package, upstream versions kept as provenance
  metadata, immutable byte-for-byte reproducible artifacts, and separately versioned platform
  releases defined by an exact bill of materials. Versioning is part of the contract every
  component repository follows, so it is designed here; its open implementation details are open
  decisions of this todo.
- The owner's [Flux bootstrap proposal](flux-bootstrap-proposal.md), recorded unedited, is the
  direction for bootstrap and self-management: a static install manifest applied first, then
  consumer-owned `OCIRepository` and `Kustomization` resources applied separately, with the same
  generated installation bytes behind the release asset and the OCI artifact. Self-management
  resources belong to the consuming repository, not the package; this is decided.
- The owner's [task namespace reference](task-namespaces-proposal.md), recorded unedited,
  consolidates the task vocabulary from the 2026-10-11 discussions: seven namespaces (`upstream`,
  `build`, `cluster`, `flux`, `dev`, `test`, `oci`) and sixteen tasks. It adds `flux:watch`, the
  composite `dev:create|status|delete`, `test:run` and `test:destroy`, and `oci:publish`, and says
  which of these were reaffirmed and which were not.
- The task namespace reference's inventory is applied to the repository, following the lifecycle
  proposal's agreed subset (commit `a6d6186`). Owner decisions made while applying it:
  `test:drift` folds into `test:run`; `upstream:check` stays as a task outside the inventory; and
  tasks reach only clusters the repository created — a repo-local, git-ignored `KUBECONFIG` holds
  their contexts and `cluster:*` refuse names not prefixed with the component. Implementation
  choices to confirm: `flux:*` take a cluster name rather than using the current context;
  `flux:boot` still boots the Flux repository from its local render; `build:render` does not
  package; `dev:create` absorbs `artifact:deploy|verify`; and `oci:publish` replaces
  `artifact:push` and `release`, publishing to a cluster's local registry with `--cluster`.
  Since superseded by the owner (2026-10-14 through 2026-11-26, recorded in
  [Journal](../../roadmap/journal.md)):
  the `cluster:*` tasks became `.mise/cluster/cluster.sh` (with fixed targets `dev` and `verify`),
  `flux:boot` was dropped and the remaining `flux:*` tasks folded into `dev:` (`dev:status`,
  `dev:reconcile`, `dev:watch`), `dev:*` was specialized to `dev` only, `dev:update` was added
  (with both `dev:create` and `dev:update` depending on `build:render`), component installation moved
  into `.mise/cluster/install-component.sh` (single `dev|verify` arg, data-driven via
  `FLUX_BOOTSTRAP_MANIFEST` and `FLUX_SYNC_MANIFESTS`) and OCI pushing into
  `.mise/cluster/push-artifact.sh`, `test:run`/`test:destroy` became `verify:run`/`verify:clean`
  (using the `verify` OCI tag), and `oci:publish` became `release:publish` (targeting
  `RELEASE_REGISTRY`). The `cluster:*`, `flux:*`, `test:*`, and `oci:publish` entries in the
  [lifecycle proposal](proposal.md),
  [task namespace reference](task-namespaces-proposal.md), and
  [Flux bootstrap proposal](flux-bootstrap-proposal.md) need reconciling with this.
- The earlier six-phase proposal, top-level Maven-style phases rather than namespaces, is kept as
  an alternative considered in [candidate: six chained phases](candidate-six-phases.md).

**Directory layout decided and implemented:** the owner authorized this subset independently of
finishing the lifecycle design. Captured input is `upstream/flux.yaml`, authored configuration is
`src/config/`, and the committed rendered payload is `artifacts/rendered/`. `build:clean` deletes
all of `artifacts/`; ignored `artifacts/oci/` is reserved for future local packaging. The
[layout working notes](working-notes.md) record the decision and its limits. The
[source-to-artifact explanation](../../../docs/architecture/01-source-to-artifact.md) documents the
implemented contract. This settles directory placement, not OCI packaging, versioning, image
ownership, promotion, or consumer ownership of sync.

**Differences to reconcile** between the four proposals, the other todos, and the repository
today — to resolve with the owner, not by assumption:

- Lifecycle proposal section 9 (migration sequence and acceptance criteria) is implementation guidance; this todo is
  document only, so it belongs with
  [Plan the lifecycle implementation](../plan-lifecycle-implementation/overview.md).
- The migration steps and acceptance criteria update CI workflows, but CI is parked in
  [`finalize-ci-workflows`](../../parked/finalize-ci-workflows/overview.md) and `.github/` was
  moved out of the repository.
- Section 8's script style and task composition guidance (about 15 lines, compose with mise
  dependencies) overlaps the mise conventions todo, which owns all aspects of mise and the task
  scripts.
- Section 8 assumes `curl` and `jq` "per documented prerequisites", but the root `README.md`
  lists only mise and Docker; decide whether such tools are mise-managed or assumed.
- Version scheme: `mise.toml` derives `CUR8S_FLUX_VERSION` from the upstream version and
  `CUR8S_FLUX_REVISION` (`v2.9.0`, then `v2.9.0-2`), essentially the upstream-derived Option D the
  versioning proposal rejects; `v2.9.0-2` even sorts before `v2.9.0`. Adopting independent SemVer
  changes `mise.toml`, the `cur8s.yaml` release descriptor, tags, and docs. Check whether any
  version is already published to `ghcr.io/cur8s/flux`; if so, decide how the old and new version
  lines relate.
- Self-management (decided, to apply): the consuming repository owns the `OCIRepository` and
  `Kustomization`, but today's artifact ships `sync.yaml` (`src/config/sync.yaml`,
  `artifacts/rendered/sync.yaml`). The [architecture overview](../../../docs/architecture/00-overview.md#intended-self-management-boundary)
  distinguishes this current layout from the intended ownership change. The user guide's bootstrap
  and recovery steps apply it, and the end-to-end test deploys it. The design must say where the
  end-to-end test's own self-management file lives, acting as the consuming repository (moving it
  only requires updating `FLUX_SYNC_MANIFESTS` in `mise.toml`, since `.mise/cluster/install-component.sh` and
  `dev:update` are now data-driven).
- Controllers: the Flux bootstrap proposal names only source-controller and kustomize-controller as
  essential and leaves notification-controller to the package definition; the package installs all
  three today.
- End-to-end coverage: the Flux bootstrap proposal requires a fresh-cluster test through phase 1,
  readiness, phase 2, first reconciliation, and a subsequent version update; today's test has no
  version update.
- Package naming: the versioning proposal names packages by capability (`cur8s-gitops`,
  `cur8s-certificates`) and does not require one package per upstream product; the direction so
  far is one repository per component, named after it (`flux`, `cert-manager`).
- Publication runner: the versioning and Flux bootstrap proposals both record GitHub Actions as
  the publication mechanism (the latter marks it decided);
  the owner-stated goal below is that publishing works the same from a laptop or GitHub Actions,
  and CI is parked.
- Exact tested digest: the lifecycle proposal requires that the OCI digest `test:run` verified is
  the one published; `oci:publish` pushes the rendered tree again instead of copying a tested
  candidate, and the task namespace reference names no local packaging step.
- Cluster selection: the task namespace reference has the `flux:` tasks act on the current kubectl
  context; the applied tasks take a cluster name, as the lifecycle proposal requires.
- Bootstrap source: the task namespace reference has `flux:boot` use the project's published
  bootstrap manifest; the applied task boots the Flux repository from its local render, as the
  lifecycle proposal requires.
- `build:render` in the task namespace reference "generates the Flux manifests and package
  artifacts"; the applied task renders only, and `oci:publish` packages at push time.
- The platform bill of materials belongs to the future platform repository, which no todo covers
  yet; this todo only defines what a component publishes for it to reference.

**Goals and invariants the owner stated while planning** — inputs to the first step, to confirm
or revise there:

- Task names are consistent across component repositories while each repository keeps freedom in
  how it implements a step, in the spirit of the Maven lifecycle.
- What was downloaded from upstream is captured in the repository so it is clear what it is.
- The OCI artifact can be built and kept locally — not committed, not published — and tested
  there; publishing is a separate later step.
- Every component produces an OCI artifact.
- Publishing works the same from a laptop or GitHub Actions, because the tooling is pinned and the
  tests are self-contained.
- Scripts stay tiny and obvious.
- The directory layout is part of the design: each lifecycle step defines the directories it reads
  and writes, the layout is consistent across component repositories, and each directory's purpose
  is obvious. Authored major directories explain themselves in short READMEs; generated output is
  documented outside `artifacts/` so cleaning cannot delete authored content.

The mise and bash mechanics any design uses follow
[Mise standard](../../../docs/standards/mise-standard.md) and
[Bash script standard](../../../docs/standards/bash-script-standard.md).
