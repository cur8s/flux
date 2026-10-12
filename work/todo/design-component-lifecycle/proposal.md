<!-- Provenance: the owner's lifecycle proposal, copied from ~/Downloads/cur8s-component-lifecycle-proposal.md on 2026-10-11 and recorded here unedited. Its relative links assume this location. -->

# Proposal: Consistent component lifecycle across Cur8s repositories

**Status:** Proposed — design direction agreed in discussion; unresolved details are explicitly identified below.  
**Scope:** The Flux repository and future component repositories such as cert-manager, Envoy Gateway, and CloudNativePG.  
**Implementation policy:** This document specifies the intended contract. It does not claim the current tasks implement it.

## 1. Purpose

Cur8s consists of independently maintained repositories, each packaging one opinionated Kubernetes component. A developer should be able to enter any component repository, discover the same task vocabulary, understand what each step does, and run its test lifecycle without learning a new orchestration system.

The common interface is [mise](https://mise.jdx.dev/) tasks, named `<object>:<action>`. Repositories may implement tasks differently, but an identically named task must have the same externally observable meaning. Keep task scripts small, explicit, and easy to inspect; use mise dependencies or short orchestration tasks to compose operations rather than hiding complex workflows in shell scripts.

This is a **component lifecycle** convention, not a requirement for a single shared repository or centralized toolchain version registry.

## 2. Architectural invariants

1. **Static desired state.** Capture upstream inputs and transform them into final Kubernetes YAML *before* interacting with the cluster. Do not render from live cluster information or allow runtime Helm conditionals to change the selected resources. Kubernetes/version incompatibility is a validation failure, not a reason to silently change manifests.
2. **Traceable inputs.** Preserve fetched upstream files byte-for-byte in Git. Keep authored overlays and transformation scripts separately in Git. A Git commit must make the upstream inputs, relevant tool pins, transformation logic, and rendered result inspectable together.
3. **Reviewable output.** Commit the final rendered YAML so `git diff` shows precisely what changes. Regeneration must not depend on timestamps, random IDs, machine-local paths, or cluster state.
4. **OCI as the distribution contract.** Every component's installable output is an OCI artifact, independent of whether its upstream arrives as a Helm chart, raw manifests, or another format. The rendered tree is the source content for OCI packaging; the tree is not itself a registry artifact.
5. **Test what is distributed.** Stage an artifact candidate in the k3d registry and verify it through Flux. The follow-on packaging work should ensure the *exact tested OCI digest* is what is later published; do not independently rebuild a potentially different artifact during publication.
6. **Repository independence.** Each repository chooses and pins its own mise-managed tools and has its own deterministic inputs, isolated cluster name, tests, and publication decision. Do not require coordinated tool-version changes across component repos.
7. **Declarative dependencies.** Components are integrated via Flux sources and Kustomizations with explicit ordering and readiness conditions. Do not create an imperative installation chain for every transitive component dependency.
8. **Debuggable test cleanup.** Successful end-to-end tests delete the test cluster; failed tests preserve it and report its name and inspection commands. Preserve the original test failure exit status.
9. **Explicit publication.** Validating locally does not implicitly publish to a remote registry. Remote publication remains a separately requested action. Respect the repository's existing immutability and release-channel requirements.

The repo's existing work item records additional requirements for provenance records, mirrored runtime images, OCI layouts and safe publication in [`requirements.md`](requirements.md). Those are not superseded by this proposal.

## 3. Repository responsibilities and dependencies

The Flux repository is the root: it must be able to bootstrap its own locally rendered installation into an empty cluster. Other component repositories bootstrap a pinned **published** Cur8s Flux release into their local test cluster. A component with prerequisites (for example Envoy Gateway requiring cert-manager) stages pinned published OCI artifacts for its prerequisites, then lets Flux reconcile those prerequisites before installing the candidate component.

The pins used **for a particular test** must be explicit and reproducible. Independent repositories do not mean unpinned test dependencies. Higher-level platform-composition repositories assemble pinned component artifacts and provide integrated end-to-end examples and tests.

A repo should not fetch or rebuild another component's upstream distribution to test a dependency: consume that component's released OCI contract.

## 4. Proposed mise namespace contract

These names are intentionally few. Examples use `mise run <task>`; the mise CLI can also be invoked using its supported shorthand.

| Task | Contract | Status |
| --- | --- | --- |
| `upstream:fetch` | Fetch the selected upstream release and preserve it unmodified in the committed source-input area. | Agreed |
| `build:clean` | Delete **only generated** build outputs; never delete captured upstream sources or authored overlays. | Agreed |
| `build:render` | Clean and regenerate the complete reviewable manifest tree from locally captured inputs and authored transformations. | Agreed |
| `cluster:create` | Create this repo's named k3d cluster with its associated local registry; install no component. | Agreed |
| `cluster:status` | Show the named test cluster's state. | Agreed |
| `cluster:delete` | Delete the named test cluster and associated test resources. | Agreed |
| `flux:boot` | Install the Cur8s Flux distribution into an existing cluster and wait for its controllers to be usable. | Agreed name; implementation differs for Flux repo |
| `flux:status` | Show Flux source and reconciliation state for the named cluster. | Agreed |
| `flux:reconcile` | Force immediate reconciliation of the component owned by this repository. | Agreed intent; exact target selection to specify |
| `test:run` | Orchestrate a complete isolated end-to-end validation and conditional cluster cleanup. | Candidate; not yet finalized |

### Naming guidance

- The namespace is an object or subsystem (`upstream`, `build`, `cluster`, `flux`, `test`), and the action is a simple verb (`fetch`, `render`, `create`, `boot`, `reconcile`).
- Use **`flux:boot`**, not `flux:bootstrap`, in the new interface. Preserve a temporary alias if a migration requires it.
- Do not create a new name merely to wrap an infrequently used CLI operation. Add shared tasks when repeated use demonstrates a stable common meaning.
- OCI artifact packaging, local push/install/verification, and remote publication still need a deliberately chosen public task vocabulary. Existing `artifact:*` tasks and `release` remain migration inputs, **not silently adopted as finalized names**.

## 5. Task contracts in detail

### `upstream:fetch`

Read the repo's pinned upstream version or source identity. Obtain source files using the tool appropriate to the component (for example `gh`, Helm, or a project CLI). Record exactly what was downloaded, with no edits or normalization to the captured content. The fetch operation is **explicit**; it must not be a hidden network side effect of ordinary rendering.

Fetching may deliberately replace the previously captured release when a version pin is changed. Any download integrity metadata must live outside the untouched upstream payload. The provenance format and checksum verification strategy should follow [`requirements.md`](requirements.md).

### `build:clean` and `build:render`

`build:clean` removes generated output (such as `oci/<component>/`) but preserves `src/<component>/artifacts/` and all authored sources. `build:render` always invokes or depends on `build:clean` first. It consumes the checked-in upstream files plus checked-in configuration, applies predictable transformations, and writes static, complete YAML and appropriate inert artifact metadata.

Keep the separation between `upstream:fetch` and `build:render`: a developer should be able to regenerate and diff outputs without re-downloading upstream. `build:render` must fail clearly when required captured inputs are absent.

A drift check can invoke render and require a clean `git diff` against committed fetched inputs, tool pins and generated outputs as appropriate. Do not let a test quietly update committed baseline files and then report success.

### `cluster:*`

All repositories expose the same three operations. Use a unique default cluster name per component, plus an explicit override for testing/parallel use. `cluster:create` provides an empty k3d Kubernetes cluster and reachable local OCI registry; it does **not** bootstrap Flux. All commands targeting the cluster must consistently use the requested cluster/context, not the current default kubectl context.

Do not make `cluster:delete` a dependency of ordinary build/render steps.

### `flux:boot`

In the **Flux repository**, apply the *locally rendered Flux install manifest* to the newly created cluster. Then wait until the necessary Flux controllers are available. This step establishes the bootstrap runtime; separate OCI-source and self-management configuration can then transition control to Flux.

In **other component repositories**, use a pinned, published Cur8s Flux bootstrap manifest/release and wait for the same usable runtime. The bootstrap source is the one intentional per-repository implementation difference; the task's postcondition is the same.

A bootstrap does not in itself assert that the current component has been installed or passed its tests. Avoid referencing mutable, unpinned `latest` bootstrap content.

### `flux:status` and `flux:reconcile`

`flux:status` is a discoverable shortcut for the common Flux CLI status query on the specified cluster. `flux:reconcile` forces immediate reconciliation of **the current component**, not every Kustomization in the cluster. The implementation must identify its own Flux source/Kustomization target(s) by a repo-owned convention, rather than requiring the developer to remember flags and resource names.

**Open design detail:** a component may have multiple `crds`, `deploy`, and `post-install` Kustomizations. Decide which single target, or ordered set of targets, `flux:reconcile` addresses and whether source reconciliation is included. Document the result in the task help. Do not guess an arbitrary resource name.

## 6. Declarative installation stages

For each component, use consistent stage directories/Kustomizations when applicable:

1. `crds` — optional: install custom resource definitions as a separate, generally infrequently changing unit.
2. `deploy` — required: install the controller/application.
3. `post-install` — optional: install component-specific platform defaults after the controller is available.

For example, cert-manager's `post-install` stage may create the conventional `platform-issuer` ClusterIssuer that subsequent components rely upon. Encode dependencies and readiness explicitly in Flux, using the actual health semantics appropriate to each dependency. The three stages are *deployment structure*, not mise task namespaces.

A later design may introduce a stable, component-wide or layer-wide readiness synchronization point. This was discussed but **not decided** and must not be invented as a mandatory convention in this implementation.

## 7. Intended local lifecycle

```text
upstream:fetch               # explicitly capture/change upstream inputs; commit them
       |
       v
build:render                 # clean -> transform -> committed review tree under oci/
       |
       v
[package candidate OCI]      # future finalized task; preserve candidate/digest
       |
       v
cluster:create               # isolated k3d + local registry
       |
       v
flux:boot                    # local render for Flux repo; pinned release elsewhere
       |
       v
[stage dependency OCI]       # published pinned packages, if this component needs them
       |
       v
[push/install candidate OCI] # local registry and Flux OCIRepository/Kustomization
       |
       v
[test and verify readiness]  # exercise controller/component behavior
       |
       +-- pass --> delete test cluster; candidate eligible for separate publication
       |
       +-- fail --> preserve test cluster; print diagnostics; return failing status
```

Brackets mark lifecycle operations whose **task names are not yet settled**, not permission to omit them. Rendering is performed on the developer/CI host, not inside Kubernetes. The cluster evaluates the rendered result.

Tests should validate readiness and component-specific outcomes, not merely that `kubectl apply` exits zero. The Flux repo must additionally verify that Flux can take over reconciliation of its own OCI artifact.

## 8. Task implementation style

- Place executable tasks under `.mise/tasks/<namespace>/<action>` and declare task descriptions/arguments with the repo's mise header convention. Keep supporting assets elsewhere under `.mise/` so they are not accidentally discovered as tasks.
- Prefer small, readable scripts (rough target: ~15 lines) with `set -euo pipefail`, straightforward commands, and explicit failures. This is a readability goal, not a hard line-count test.
- Use mise dependency composition when ordering is unambiguous and supported by the pinned mise version; use a short orchestration script where cleanup traps, sequence, or error propagation make that clearer.
- Do not add needless one-command wrapper files solely to satisfy an arbitrary number of scripts.
- Mise manages and pins specialised user-space tools per repo (for example k3d, kubectl, Flux, Kustomize or Helm). Assume commonplace developer utilities such as `curl`/`jq` per documented prerequisites. Docker/daemon access is a host-level prerequisite, not a mise installation target.
- Ensure commands work on supported macOS and Linux developer hosts. Avoid undisclosed GNU-only flags or platform-dependent text/archiving output.
- Keep documentation, task help, and implementation consistent. `mise tasks` remains the command-discovery mechanism.

## 9. Agent implementation guidance (incremental migration)

The currently checked-in interface is **not** the proposed one. In particular, the repo currently uses `artifact:fetch`, `artifact:render`, `artifact:build`, `flux:bootstrap`, `test:drift`, `test:e2e`, `artifact:push|deploy|verify`, and `release`. It also has `upstream:check`. Treat these as implementation starting points, not as evidence that the new vocabulary is already present.

Suggested migration sequence:

1. Inventory existing task entry points, their callers, task arguments, documentation, tests and CI workflows. Read [`../../../mise.toml`](../../../mise.toml), [the architecture overview](../../../docs/architecture/00-overview.md) and [`../plan-lifecycle-implementation/overview.md`](../plan-lifecycle-implementation/overview.md).
2. Preserve the current working Flux installation and release behavior while changing names; do not combine a task-interface refactor with unnecessary controller changes.
3. Implement `upstream:fetch` by adapting the existing fetch logic, ensuring fetched input is not deleted as a side effect of `build:render` or `build:clean`.
4. Implement `build:clean` and `build:render`; have render clean and transform the checked-in inputs without contacting upstream. Update or adapt drift verification.
5. Keep the existing `cluster:create|status|delete` contract, adjusting only inconsistencies or naming/help where needed.
6. Rename or alias `flux:bootstrap` to `flux:boot`, preserve the local-render bootstrap behavior, and implement a repo-owned `flux:reconcile` after choosing the intended resource targeting rule. Keep `flux:status`.
7. Preserve the already functional end-to-end test while adapting it to the new command surface; keep success-cleanup/failure-preservation semantics and explicit local-registry use.
8. Resolve the remaining package/test/publish names and exact-tested-digest requirement **before** replacing the publishing workflow. Do not make a best-guess remote publication redesign as part of this naming change.
9. Update root task documentation, architecture and user guide once behavior really changes. Follow [`../../../docs/standards/repository-entry-files-standard.md`](../../../docs/standards/repository-entry-files-standard.md). Keep design material under `work/`; do not link to `work/` from durable docs.

### Acceptance criteria for the agreed subset

- Every agreed task appears under its specified mise name and has helpful `mise run <task> --help` / `mise tasks` discovery information.
- Repeated `build:render` using the same recorded inputs/toolchain yields byte-identical files and no Git diff.
- `build:render` never refetches upstream; `build:clean` never deletes upstream inputs.
- `cluster:create` produces an otherwise empty component-specific cluster and its local registry.
- `flux:boot` can bootstrap the Flux repo from locally rendered files without a published Flux release; it fails clearly on an unusable cluster.
- `flux:status` and `flux:reconcile` operate only on the requested cluster; reconciliation targets the current component, using a documented rule.
- The end-to-end test operates with a local OCI candidate and reports health failures; success cleans up the cluster, failure preserves it and returns nonzero.
- The remote publish path is not invoked by rendering, bootstrapping, status inspection, or local tests.
- Existing functional behavior is covered by migrated tests, and CI/documentation are updated together with renamed tasks.

## 10. Open decisions — do not silently resolve

- The final namespace/task names for local OCI packaging, registry staging, Flux installation/verification, and remote publication.
- Whether `test:run` is the final orchestrator name or whether separate `test:drift` / `test:e2e` commands remain part of the stable public vocabulary.
- The exact `flux:reconcile` target convention when a component contains multiple reconciliation stages.
- The digest-preserving on-disk OCI packaging/copying mechanism and provenance-record format, as detailed in [`requirements.md`](requirements.md).
- The point at which mirrored runtime images are staged and how to do so without accidental remote publication.
- Any universal component-ready synchronization Kustomization beyond the three optional/required installation stages.

These questions require targeted experiments or follow-up owner decisions. The agreed task subset can be implemented independently, provided that implementation does not preclude the later OCI and publication requirements.
