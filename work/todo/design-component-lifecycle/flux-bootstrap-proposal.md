<!-- Provenance: the owner's Flux bootstrap proposal, copied from ~/Downloads/cur8s-flux-bootstrap-proposal.md on 2026-10-11 and recorded here unedited. -->

# Cur8s Flux Bootstrap and Self-Management

**Status:** Proposed architecture decision (reflecting the latest October 11, 2026 discussions)  
**Date:** October 11, 2026  
**Scope:** Cur8s GitOps package, initial Flux installation, self-management, and publication

## 1. Summary

Cur8s will bootstrap Flux in **two distinct steps**. First, an operator applies a versioned, static installation manifest to a cluster using `kubectl apply -f`. This installs the controllers and custom resource definitions (CRDs) required to consume Flux resources. Second, the **consuming repository** applies its own `OCIRepository` and `Kustomization` resources, directing Flux to reconcile its installation from the versioned Cur8s GitOps OCI artifact.

The two steps use **separate files and separate apply operations**. The Cur8s GitOps publisher owns the reusable controller installation content; each consuming repository owns the configuration that points its cluster at an OCI package and version. Once self-management is active, ordinary installation changes and upgrades flow through Flux reconciliation rather than manual reapplication.

The static release asset and OCI package must derive from the **same generated controller installation manifest**. Publication is required to be **byte-for-byte reproducible** for identical inputs.

## 2. Problem and goals

Flux cannot manage its own installation until a sufficient subset of Flux controllers and CRDs exists in the cluster. Cur8s therefore needs a bootstrap path that does not depend on Flux already running, while still converging on declarative, version-pinned self-management.

We want to:

1. Bootstrap a new cluster with a simple, auditable `kubectl apply -f` operation.
2. Use the same canonical installation resources for bootstrap and subsequent reconciliation, rather than maintain two potentially divergent implementations.
3. Allow different consuming repositories and clusters to select different GitOps package versions and source configurations.
4. Keep reusable package content separate from deployment-specific state.
5. Publish immutable, versioned artifacts with deterministic output.
6. Make the common local development operations easy to invoke without memorizing Flux CLI flags.

## 3. Approaches considered

### Option A — One bootstrap YAML containing everything

Produce a single `bootstrap.yaml` containing the controller installation resources plus an `OCIRepository` and `Kustomization` that immediately establish self-management.

**Advantages:** One URL and one visible operator command; initial installation and self-management appear bundled.

**Drawbacks:** The file couples a reusable controller package to a particular OCI endpoint, version, namespace, and consuming-repository policy. Custom resources are also being applied at the same time as the CRDs they depend on, complicating ordering and failure handling. More importantly, different consumers may legitimately want different self-management configurations.

**Decision:** **Not selected.** This was explicitly superseded in the later audio discussion by separate files and apply operations.

### Option B — Separate static installation and self-management files

Publish the reusable controller installation as static YAML. Apply it first. Apply a second file containing the consuming repository's `OCIRepository` and `Kustomization` after the relevant CRDs and controllers are available.

**Advantages:** Clear bootstrap boundary and ordering; no cluster-specific configuration in the reusable package; independent version selection by each consumer; simpler reuse across different repository layouts.

**Trade-off:** Two intentional apply operations instead of one.

**Decision:** **Selected.** The ability to bootstrap different consuming repositories in different ways was a central reason for this choice.

### Option C — Bootstrap directly from OCI

Use the published OCI artifact as the sole installation source, even on an empty cluster.

**Advantages:** One distribution channel and no separate static release asset.

**Drawbacks:** A plain `kubectl apply -f` cannot directly consume a Flux OCI artifact. Additional tooling would be needed before Flux is installed, defeating the intended minimal bootstrap command.

**Decision:** **Not selected** as the initial bootstrap mechanism. OCI remains the normal self-management source once Flux is running.

### Option D — Maintain separate bootstrap and runtime manifests

Generate or maintain an independently optimized bootstrap manifest and a separate manifest for Flux self-management.

**Advantages:** Maximum freedom to customize each phase.

**Drawbacks:** Risk that installation resources drift apart, creating surprising changes when Flux first reconciles itself.

**Decision:** **Not selected.** Bootstrap and OCI publication should share the same generated installation content.

## 4. Selected design

### 4.1 Phase 1: install the minimum viable Flux controllers

The Cur8s GitOps release provides a static YAML asset containing the selected Flux installation resources, including the CRDs needed by phase 2. The operator applies that asset to the target cluster:

```sh
kubectl apply -f https://github.com/<org>/<repo>/releases/download/v<VERSION>/flux-install.yaml
```

The URL and filename here are illustrative; the final publication path must be defined by the repository.

We discussed **`source-controller` and `kustomize-controller`** as the essential components for the chosen OCI/Kustomization reconciliation path. Whether additional controllers, such as `notification-controller`, are included in the canonical Cur8s GitOps installation should be determined by the package definition, rather than assumed to be mandatory for the minimum bootstrap.

**This static YAML is installation content, not self-management configuration.** It does not need to contain a cluster-specific `OCIRepository` or `Kustomization`.

Before phase 2, the bootstrap procedure must ensure the required CRDs are established and the relevant controllers are ready; simply issuing two immediately consecutive commands is not a guarantee of readiness.

### 4.2 Phase 2: attach Flux to its own OCI release

A separate manifest, **owned by the consuming repository**, defines:

- An `OCIRepository` that selects an explicit Cur8s GitOps OCI artifact version.
- A Flux `Kustomization` that references this source and selects the correct installation content.

The operator applies this manifest only after phase 1 is ready:

```sh
kubectl apply -f path/to/flux-self-management.yaml
```

The file path is illustrative. Exact object names, intervals, namespace, authentication, and OCI coordinates are consumer-specific and are not standardized by this proposal.

At that point Flux reconciles its installation from the versioned OCI artifact. The controller manifests present in that OCI artifact are the same canonical installation content used for bootstrap.

### 4.3 Phase 3: normal lifecycle

After the initial handoff, the consuming repository controls the selected Cur8s GitOps version by changing the OCI source reference and allowing reconciliation. Initial bootstrap is not the normal upgrade mechanism.

The first reconciliation must converge on the already installed resources without unintended replacement or ownership conflicts. The implementation must ensure stable resource names, namespaces, selectors, and installation content across the handoff.

## 5. Artifact ownership and publication

| Artifact or responsibility | Owner | Purpose |
|---|---|---|
| Flux installation generator and configuration | Cur8s GitOps repository | Define the reusable installation |
| Canonical generated installation manifest | Cur8s GitOps repository | Single source of controller installation resources |
| Versioned OCI artifact | Cur8s GitOps publisher | Normal reconciliation and upgrades |
| GitHub Release YAML asset | Cur8s GitOps publisher | Bootstrap before Flux exists |
| `OCIRepository` and `Kustomization` | Consuming repository | Select the installation source and version for a cluster |
| Reconciliation after handoff | Flux in the cluster | Manage its own installed resources |

**Publication requirements:**

1. Generate the controller installation manifest using the pinned Flux CLI and explicit, version-controlled inputs.
2. Reuse the same generated installation bytes as the authoritative payload for the OCI distribution and the static release asset. Packaging envelopes may differ, but they must not independently regenerate or modify controller resource content.
3. Publish both forms under an immutable Cur8s GitOps release version.
4. Ensure that rerunning a publisher with identical inputs produces **byte-identical artifacts**. This includes deterministic ordering, formatting, metadata, and packaging wherever those affect artifact bytes.
5. Use GitHub Actions for the publication workflow, as agreed in the repository discussion.

This publication model follows the independent Cur8s package versioning proposal. The Cur8s GitOps release version identifies the Cur8s distribution and need not equal the upstream Flux version.

## 6. Developer workflow

The repository will provide Mise task aliases for operations that otherwise require remembering detailed Flux CLI invocations.

The shorthand specifically agreed in discussion was:

```sh
mise run flux:boot
```

This is intended to bootstrap a development cluster from the locally generated installation manifest without requiring a round trip through GitHub Releases.

We also discussed shortcuts for **status inspection** and **forcing reconciliation** of the relevant component or package without waiting for its periodic interval. The exact names and command expansion of those additional tasks should be reconciled with the repository's existing conventions; they are conveniences rather than architectural dependencies.

## 7. Why this separation matters

Consider two consuming repositories: the main Flux repository and a repository for another capability such as certificate management. They can reuse the same Cur8s GitOps release while selecting different bootstrap paths, versions, source coordinates, or self-management conventions. There is no reason for the reusable Cur8s package to publish one universal `OCIRepository`/`Kustomization` pair that assumes a particular consumer's state.

Keeping the publisher responsible for **what is installed**, and the consumer responsible for **where it comes from and which version runs**, preserves that flexibility.

## 8. Consequences and implementation requirements

- **The bootstrap operation is intentionally imperative.** It is the limited exception that establishes the machinery required for declarative management.
- **The steady state is declarative.** Version changes happen through the consumer's source declaration and Flux reconciliation.
- **Two separate files and applies are required.** This is a deliberate decision, not unfinished consolidation.
- **Artifact equivalence is required.** Bootstrap content and OCI-managed controller content must not diverge within one release.
- **Consumer configuration is intentionally not published as universal package content.** Each consumer owns its source and Kustomization objects.
- **Reproducibility is a release invariant.** Publishers must be validated for byte-for-byte deterministic results.
- **Ordering and convergence require tests.** A fresh-cluster test should cover phase 1, readiness, phase 2, first reconciliation, and a subsequent version update.

## 9. Decisions and remaining details

| Topic | Status |
|---|---|
| Separate bootstrap and self-management files | **Decided** |
| Apply static YAML before Flux custom resources | **Decided** |
| Store self-management resources in consuming repositories | **Decided** |
| OCI as steady-state distribution source | **Decided** |
| Shared canonical controller installation content across publication forms | **Decided** |
| Byte-for-byte reproducibility of publishers | **Decided** |
| GitHub Actions as publisher | **Decided** |
| `mise run flux:boot` task alias | **Decided** |
| Inclusion of controllers beyond the essential source/kustomize pair | Confirm against package definition |
| Exact release asset name and OCI repository coordinates | Implementation detail |
| Detailed readiness check and first-reconciliation validation | Implementation detail |
| Additional Mise task names | Confirm against repository conventions |

## 10. Proposed architecture decision

> **Cur8s bootstraps Flux by applying a published static controller installation manifest, then separately applying consumer-owned self-management resources.** The first operation installs the Flux CRDs and controllers needed to reconcile OCI sources. The second operation creates the consuming repository's `OCIRepository` and `Kustomization`, pinned to a versioned Cur8s GitOps artifact.
>
> The Cur8s GitOps package owns reusable installation content; consuming repositories own their source selection and self-management configuration. The same canonical generated installation manifest underlies both the GitHub Release bootstrap asset and the OCI distribution. All publishers must produce byte-for-byte reproducible artifacts from identical inputs. Once self-management is established, Flux reconciles and upgrades itself through the consumer's declarative configuration.

**In short:** apply static YAML to start Flux; apply a separate consumer-owned file to make Flux manage itself; use the same versioned installation content on both sides of the handoff.
