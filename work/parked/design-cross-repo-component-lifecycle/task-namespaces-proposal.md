<!-- Provenance: the owner's mise task namespace reference, copied from ~/Downloads/cur8s-mise-task-namespaces.md on 2026-10-12 and recorded here unedited. -->

# Cur8s — Mise Task Namespace Reference

This document describes the proposed `mise` task organization for the Cur8s Flux project, incorporating the decisions from our October 11, 2026 discussions.

The objective is to provide a consistent developer interface for building, testing, bootstrapping, publishing, and operating Flux without requiring developers to remember the underlying CLI commands and flags.

## 1. Namespace overview

| Namespace | Responsibility |
|---|---|
| `upstream:` | Acquire and manage upstream Flux artifacts |
| `build:` | Generate deterministic, reproducible deployment artifacts |
| `cluster:` | Manage disposable Kubernetes clusters for local development and testing |
| `flux:` | Bootstrap and operate Flux within a Kubernetes cluster |
| `dev:` | Manage the complete local development environment |
| `test:` | Execute integration tests and clean up test environments |
| `oci:` | Publish generated artifacts to an OCI registry |

Tasks follow the naming convention `<namespace>:<action>` and are invoked through `mise run`.

## 2. `upstream:` — Upstream artifacts

Responsible for acquiring the upstream Flux distribution used to build the Cur8s package.

| Task | Description |
|---|---|
| `upstream:fetch` | Retrieve the exact upstream Flux release identified by the project's pinned version. |

### `upstream:fetch`

Downloads or otherwise retrieves the upstream Flux artifacts required for the build.

The task must respect the pinned upstream version rather than implicitly selecting the latest available release. Repeated executions against the same upstream version should produce identical inputs. The task does not modify the Kubernetes cluster.

## 3. `build:` — Artifact generation

Responsible for generating deployable artifacts from pinned upstream inputs and project configuration.

| Task | Description |
|---|---|
| `build:clean` | Remove generated build artifacts. |
| `build:render` | Generate the Flux manifests and package artifacts. |

### `build:clean`

Removes generated files produced by the build process while preserving source configuration and pinned dependencies.

### `build:render`

Runs the required tooling, including the appropriate Flux CLI commands, to produce deployment artifacts.

Requirements:

- Builds must be deterministic.
- Identical inputs must produce byte-for-byte identical outputs.
- Rendering must not require an active Kubernetes cluster.
- The generated artifacts must be suitable for publication and independent verification.

Reproducibility is an explicit architectural decision, not merely a desirable property.

## 4. `cluster:` — Kubernetes cluster lifecycle

Provides commands for managing a disposable Kubernetes cluster independently of Flux.

| Task | Description |
|---|---|
| `cluster:create` | Create a local Kubernetes cluster. |
| `cluster:status` | Inspect the local cluster's state. |
| `cluster:delete` | Delete the local Kubernetes cluster. |

### `cluster:create`

Creates the Kubernetes environment needed for local development and integration tests. The cluster implementation is an internal detail of the task.

### `cluster:status`

Displays whether the cluster exists and whether its Kubernetes API is reachable.

### `cluster:delete`

Deletes the local cluster and its associated resources. This is an infrastructure operation and must remain independent of Flux installation and configuration.

## 5. `flux:` — Flux operations

Provides convenient wrappers around frequently used Flux CLI operations. This namespace operates against the Kubernetes cluster selected by the current context.

| Task | Description |
|---|---|
| `flux:boot` | Bootstrap the minimal Flux installation. |
| `flux:status` | Display Flux installation and reconciliation status. |
| `flux:reconcile` | Trigger immediate reconciliation of the project's Flux configuration. |
| `flux:watch` | Continuously display Flux status for monitoring. |

### `flux:boot`

Bootstraps Flux into an existing Kubernetes cluster using the project's published bootstrap manifest.

The bootstrap architecture separates two concerns:

1. Installing the minimal Flux controllers necessary to begin reconciliation.
2. Handing control to the published Flux configuration distributed through OCI.

The minimal installation includes the Source Controller and Kustomize Controller. The bootstrap process should not require the complete Flux distribution to be installed manually. The longer-term configuration is managed declaratively by Flux itself.

### `flux:status`

Displays the state of Flux and its managed resources, including reconciliation readiness and errors. This task eliminates the need to remember the appropriate Flux CLI flags.

### `flux:reconcile`

Forces immediate reconciliation of the relevant Flux Kustomizations instead of waiting for their scheduled reconciliation intervals. The task targets the components managed by this project rather than indiscriminately reconciling unrelated workloads.

### `flux:watch`

Provides a continuously refreshed, read-only view of Flux reconciliation state. This was included in the broader proposal but was not as firmly settled as `boot`, `status`, and `reconcile`.

## 6. `dev:` — Development environment

Provides high-level workflows that compose lower-level tasks.

| Task | Description |
|---|---|
| `dev:create` | Prepare a complete local development environment. |
| `dev:status` | Display development environment readiness. |
| `dev:delete` | Tear down the development environment. |

### `dev:create`

Orchestrates the tasks required to obtain a usable local development environment. For example, this can include creating the cluster, bootstrapping Flux, and applying the required development configuration. It should reuse the existing `cluster:` and `flux:` tasks instead of duplicating their implementations.

### `dev:status`

Displays the state of the overall development environment, including cluster availability and Flux readiness.

### `dev:delete`

Removes the local development environment and its associated resources. The `dev:` namespace represents composite workflows, whereas `cluster:` and `flux:` expose individually useful operations.

## 7. `test:` — Integration testing

Responsible for exercising the generated artifacts against a disposable Kubernetes environment.

| Task | Description |
|---|---|
| `test:run` | Execute the project's integration tests. |
| `test:destroy` | Remove the test environment and associated resources. |

### `test:run`

Runs the integration test workflow, which may include creating an isolated cluster, installing Flux, applying the generated configuration, and verifying expected behavior. Tests should use the same artifacts intended for publication whenever practical.

### `test:destroy`

Removes infrastructure and resources associated with integration testing. The later discussions favored the name `destroy` rather than the originally proposed `test:delete`. The test environment should remain logically separate from the developer's regular environment.

## 8. `oci:` — Artifact publication

Responsible for publishing generated deployment artifacts to an OCI registry.

| Task | Description |
|---|---|
| `oci:publish` | Publish a validated Flux artifact to the configured OCI registry. |

### `oci:publish`

Publishes the generated Flux package to an OCI registry. Publication must use artifacts produced by the deterministic build process. The publication mechanism must not introduce nondeterministic changes into the contents of the artifacts.

In the later architecture discussions, GitHub Actions was identified as the publication mechanism for the versioned OCI artifact and the corresponding GitHub Release YAML. The local task therefore remains a proposed convenience interface, not a separately confirmed requirement for the final publication workflow.

## 9. Design principles

**Namespace separation.** Each namespace represents a distinct responsibility. A user can manage a cluster without installing Flux, and can bootstrap Flux without invoking the complete development workflow.

**Composition instead of duplication.** Higher-level tasks such as `dev:create` should invoke lower-level tasks rather than reimplementing their functionality.

**Declarative operation.** Bootstrapping establishes the minimum needed for Flux to begin managing its own configuration.

**Reproducibility.** Artifact generation must be byte-for-byte reproducible for identical inputs.

**CLI abstraction.** Mise tasks provide memorable, stable entry points for commands that would otherwise require remembering several CLI arguments.

**Local and CI consistency.** Local workflows and automated workflows should share the same generation and validation logic.

## 10. Complete task inventory

```text
upstream:fetch
build:clean
build:render
cluster:create
cluster:status
cluster:delete
flux:boot
flux:status
flux:reconcile
flux:watch
dev:create
dev:status
dev:delete
test:run
test:destroy
oci:publish
```

**Total:** 7 namespaces, 16 tasks.

This is the consolidated task reference. It distinguishes explicitly reaffirmed decisions from tasks that appeared in the broader proposal and were not subsequently confirmed, so it can serve as an implementation starting point without treating every proposed detail as finalized.
