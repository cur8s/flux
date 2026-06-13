# RFC-010: Component Repositories & OCI Distribution

**Status:** Accepted

This is the RFC that makes the multi-repository model coherent. A monorepo can
compose a platform implicitly — one build renders everything and a bill of
materials pins the pieces together. Once components live in **separate,
independently-versioned repositories**, that implicit composition has to become
an explicit contract: how each repository publishes its artifact, and how a
cluster assembles many artifacts into one running platform.

## Core Rule

**Each component (layer) is an independent repository that packages one
upstream, renders fully-static manifests, and publishes them as an immutable
OCI artifact at a well-known coordinate. A cluster composes a platform by
declaratively referencing a chosen version of each component artifact. No
build-time step bundles components together; composition happens in the
cluster's declared intent.**

## The Component Repository

A component repository has a fixed shape:

- It tracks exactly **one upstream** and renders it through an opinionated
  overlay into static manifests (`oci/<component>/`), committed to git so every
  change is reviewable as a diff ([RFC-006](RFC-006-static-runtime-manifests.md),
  [RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md)).
- It publishes that tree as an OCI artifact:
  `oci://<registry>/<component>:<version>`.
- The artifact is **self-describing**: alongside the manifests it carries the
  `sync.yaml` (the Flux `Kustomization` that reconciles it), so the artifact
  declares how it is meant to be applied.
- It has its own e2e that qualifies the artifact in isolation.

This repository is one such component (`flux`) and is simultaneously the
foundation every other component depends on.

## Artifact Coordinates

- **Registry:** a registry with no practical anonymous rate limit for
  foundation components (see [RFC-011](RFC-011-bootstrap-contract.md)).
- **Repository name:** the component name (`flux`, `routing`, `postgres`, …).
- **Tag:** the version, per
  [RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md).
- **Digest:** artifacts are content-addressable; a cluster MAY pin by digest.
  Artifacts SHOULD be signed (e.g. cosign) so consumers can verify provenance.

## Composition Happens in the Cluster

A cluster is described by a **cluster artifact** (a per-deployment repository or
directory) that declares which component artifacts, at which versions, this
cluster runs. For each component it wires:

- a Flux `OCIRepository` pointing at `oci://<registry>/<component>:<version>`
  (environment-specific: a local registry in dev, a public registry in prod);
- the component's `Kustomization` (shipped in the artifact), ordered against
  other components with `dependsOn`
  ([RFC-008](RFC-008-declarative-readiness.md));
- the component's configuration inputs
  ([RFC-013](RFC-013-layer-configuration.md)).

There is no umbrella build. The set of `{component → version}` choices *is* the
platform definition for that cluster, and it lives in versioned, external intent
([RFC-005](RFC-005-declarative-cluster-control.md)). Selecting a subset of
components (no postgres, say) is simply declaring fewer of them.

## Cross-Repository Dependencies

A component depends on other components through their **published contract**
([RFC-012](RFC-012-layer-architecture.md)) — installed CRDs, named resources,
and configuration keys — never through their repository internals or build
output. A component declares the other components (and minimum versions) it
requires; the cluster's reconciliation graph realizes those edges with
`dependsOn`. The dependency graph is acyclic.

## Bootstrap Channel

Foundation components face a chicken-and-egg problem: the OCI artifact is
reconciled *by* the very engine being installed. They therefore publish their
install manifest through a second, HTTP-addressable channel for first-touch
bootstrap. This dual-publish rule is defined in
[RFC-011](RFC-011-bootstrap-contract.md).

## Forbidden Patterns

- Bundling multiple components into one artifact at build time "for
  convenience" — composition is the cluster's job, declaratively.
- Mutable or shared tags (`latest`, `stable`) as the reconciled reference.
- A component reaching into another component's repository, build output, or
  internal resources rather than its published contract.
- A single monolithic build that renders all components together (reintroduces
  the monorepo coupling this RFC exists to remove).

## Scope

This RFC defines how independent component repositories publish artifacts and
how a cluster composes them. It does not define the versioning scheme
([RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md)), the layer
contract ([RFC-012](RFC-012-layer-architecture.md)), configuration mechanics
([RFC-013](RFC-013-layer-configuration.md)), or the CI/registry implementation.

## Revisions

Initial version.
