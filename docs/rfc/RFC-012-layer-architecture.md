# RFC-012: Layer Architecture

**Status:** Accepted

A platform with a meaningful number of components has a meaningful number of
*kinds* of component: some establish foundational mechanisms (GitOps,
certificates, secrets), some route traffic, some observe, some store state.
These groups have different stability profiles, change cadences, and blast
radii. Treated as a flat pile, the questions *"what does X depend on?"*, *"can I
update Y safely?"*, *"what must run before Z?"* become answerable only by
reading everything. A layer model makes those relationships first-class and
structural rather than archaeological.

## Core Rule

**The platform is composed of named layers. Each layer is an independent
repository with a single named responsibility, declares its dependencies on
other layers explicitly, and provides a documented contract to the layers above
it. Layers form a directed acyclic graph; cycles are forbidden.**

In this model **a layer is a repository** ([RFC-010](RFC-010-component-repositories-and-oci-distribution.md)).
This foundation repository is the base layer: it provides the GitOps engine
([RFC-015](RFC-015-flux-as-the-gitops-engine.md)) that every other layer depends
on directly or transitively.

## What Constitutes a Layer

A subset of functionality is a layer when:

- it has a coherent, nameable responsibility (*"brings up declarative control"*,
  *"routes traffic"*, *"observes the cluster"*);
- its components interact more tightly with each other than with anything
  outside it;
- removing or replacing it is a deliberate architectural change, not a routine
  update;
- its contract to the layers above can be stated in a few sentences.

*"Things that ship together"* is not a layer. *"Everything else"* is not a
layer.

## Dependencies Form a Cross-Repository DAG

Layers declare their dependencies explicitly, and the graph is acyclic. Because
each layer is a separate repository, a dependency edge is **realized in the
cluster**, not in a build: the cluster wires each layer's Flux `Kustomization`
with `dependsOn` ([RFC-008](RFC-008-declarative-readiness.md)) and points it at
the upstream layer's published artifact
([RFC-010](RFC-010-component-repositories-and-oci-distribution.md)).

A layer may reach **upstream** (consume the contract of a layer it depends on);
it may never reach **downstream**. Every consumed dependency is named — implicit
or "convenient" cross-layer references are forbidden.

## What a Layer Provides: Its Contract

A layer's contract is the named set of things layers above it may rely on:

- **CRDs** it installs, that downstream layers may create resources of;
- **Named resources** it creates, that downstream layers may reference by their
  well-known names;
- **Configuration keys** it introduces
  ([RFC-013](RFC-013-layer-configuration.md)).

The contract is what makes a layer a stable unit; changing it may force
downstream layers to adapt, and is therefore a major-version event for the layer
([RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md)). A layer
consumes another layer's **contract**, never its repository internals or build
output.

## Layering Discipline

A layer may only create custom resources whose CRDs are installed by itself or
by a layer it declares as a dependency. Kubernetes rejects a custom resource
whose CRD is absent; a layer that violates this cannot reconcile, and the layer
that owns the CRD is downstream and cannot install it without inverting the
dependency direction. This is the bootstrap-deadlock failure mode. Consequently,
a cross-layer interaction lives in the layer that installs the relevant CRD
(e.g. monitoring scrape definitions for another layer's controllers live in the
observability layer, using cross-namespace selection).

## The Verify Model

Installation is verifiable at three tiers, mirroring the structure:

- **Component verify** — checks what a single component owns (*"is this
  Deployment ready?"*). Lives with the component.
- **Layer verify** — assumes every component in the layer and every dependency
  layer is verified; checks that the components compose into the layer's
  contract. Lives with the layer.
- **Integration verify** — assumes every layer is verified; checks cross-layer
  flows no single layer owns. Lives with the cluster/composition artifact.

A failure at one tier short-circuits the tiers above it.

## One Repository, One Layer, One Artifact

In the monorepo this layering was a convention inside one tree. Split into
repositories it becomes cleaner: one repository is one layer is one published
artifact, with one version line and one e2e. The dependency DAG is expressed
once, in the cluster that composes the layers.

## Forbidden Patterns

- Cycles in the layer dependency graph.
- A layer creating custom resources whose CRDs are not installed by itself or a
  declared dependency.
- A layer consuming a contract from a layer it has not declared as a dependency.
- A layer reaching into another layer's repository internals or build output
  rather than its published contract.
- Merging layers without architectural justification ("they are both small" is
  not justification).

## Scope

This RFC defines what a layer is, how layers compose across repositories, and
how they are verified. It does not enumerate any specific layer's contract
(those live in each layer's own repository and RFCs), nor define the
configuration mechanism ([RFC-013](RFC-013-layer-configuration.md)) or
distribution mechanics
([RFC-010](RFC-010-component-repositories-and-oci-distribution.md)).

## Revisions

Initial version.
