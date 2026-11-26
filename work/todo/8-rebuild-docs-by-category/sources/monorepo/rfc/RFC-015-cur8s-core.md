## RFC-015: Cur8s Core

**Status:** Accepted

Cur8s defines a **core layer** that establishes declarative control, secret
distribution, and trust within a cluster. This layer is the foundation
everything else in the Platform depends on, and it is the part of Cur8s that
must reach a stable contract first so the rest of the Platform can evolve on
top of it.

Core is one specific application of the layer pattern defined in
[RFC-013](RFC-013-cur8s-layer-architecture.md). This RFC defines what the
core layer specifically is: its components, its contract, its versioning,
its bootstrap properties, and what it explicitly does not include.

## The Problem

Some parts of the Platform have a fundamentally different stability profile
than others.

The components that bring up GitOps reconciliation, materialize secrets from
external stores, and issue certificates have stable upstream APIs, well-known
operational patterns, and high blast radius if broken. Application-tier
components — gateways, databases, observability stacks, log collectors — have
faster-moving upstreams, frequent feature additions, and lower blast radius
when individual components are upgraded.

Treating these two groups identically forces every change to ride the same
release cadence and the same compatibility surface. A Grafana point release
becomes coupled to a Flux upgrade. A new observability feature can't ship
until the next foundational change is ready. Worse, the foundational layer
itself can never reach a stable 1.0 contract while it remains entangled with
parts of the Platform that are still in motion.

The problem is therefore **not whether to layer the Platform**, but how to
introduce a stable kernel without violating Cur8s' user-facing contract that
a release is a single, continuously advancing version
([RFC-007](RFC-007-single-continuously-advancing-version-line.md)).

## Core Rule

**Cur8s defines a core layer composed of Flux, External Secrets Operator,
and cert-manager. This layer is published as a separate, internally
versioned OCI artifact. A Cur8s release pins a specific core version. The
user installs a Cur8s release; the pinned core version is invisible.**

The core layer is the load-bearing foundation of the Platform: GitOps
reconciliation, secret synchronization, and certificate issuance. Every
other component in Cur8s depends on it directly or transitively. Removing
or replacing any of the three would change what Cur8s fundamentally is.

## Composition

The core layer contains exactly the following components:

- **Flux** — the GitOps reconciliation engine, constrained as defined in
  [RFC-008](RFC-008-flux-as-the-gitops-engine.md). source-controller,
  kustomize-controller, and notification-controller only.
- **External Secrets Operator** — the mechanism that synchronizes secret
  material from an external secrets store, as defined in
  [RFC-012](RFC-012-external-secrets.md).
- **cert-manager** — the certificate issuance and lifecycle controller,
  used by other platform components to obtain TLS material.

No other components are part of core. Components that operate on top of
this foundation — gateways, databases, observability, log collection — are
explicitly outside core regardless of how essential they are to a particular
deployment.

## CRD Surface Contract

Cur8s commits to using only the following Kubernetes API surface from the
core components. This is what stabilizes core's contract and what allows
core to reach 1.0 ahead of the rest of the Platform.

- **Flux**
  - `OCIRepository` (`source.toolkit.fluxcd.io/v1`)
  - `Kustomization` (`kustomize.toolkit.fluxcd.io/v1`)
- **External Secrets Operator**
  - `ClusterSecretStore` (`external-secrets.io/v1`)
  - `ExternalSecret` (`external-secrets.io/v1`)
- **cert-manager**
  - `ClusterIssuer` (`cert-manager.io/v1`)
  - `Certificate` (`cert-manager.io/v1`)

This list is the **stable surface**. Changes to it — adopting an additional
kind, advancing to a new API version, or restricting an existing one — are
breaking changes for core's contract and require a core major version
increment.

Other CRDs published by these projects (Flux's `HelmRelease`, ESO's various
provider-specific generators, cert-manager's ACME-related kinds) are
explicitly **not part of core's contract** and may be excluded entirely.

## Bootstrap Contract

Core comes up from a fresh cluster with **zero pre-existing secrets**.

This is a load-bearing property: it is what allows the rest of the Platform
to deliver image-pull credentials and other secrets *through* core, rather
than requiring those secrets to be in place before core can install.

Core therefore commits to:

- **Pulling its own container images from registries with no practical
  anonymous rate limit.** Today this means `ghcr.io` and `quay.io` only.
  No core image may pull from `docker.io` or any other rate-limited
  registry.
- **Coming up without `imagePullSecrets`.** No `ServiceAccount` in core
  references a pull secret. Pulling core's images must succeed against
  any cluster that can reach the public internet.
- **Failing closed when expected inputs are missing.** If a required
  ConfigMap or external store credential is absent, core's reconciliation
  blocks visibly rather than guessing or defaulting.

A single bootstrap secret is permitted: the credential ESO uses to reach
the external secrets store, as defined in
[RFC-012](RFC-012-external-secrets.md). This is the only secret an operator
introduces manually outside the GitOps loop. Once it is in place, every
other secret — including image-pull credentials for the rest of the
Platform — flows declaratively.

Core's own configuration inputs are operator-supplied identity values
authored at cluster setup, committed to Git rather than delivered through
any Cur8s-managed mechanism. This is structural: core is the layer that
brings those mechanisms up, so its own inputs cannot depend on them being
available. Layers above core may reference these identity values to
locate their own configuration. The specific configuration model is
defined in [RFC-014](RFC-014-cur8s-layer-configuration.md).

## SemVer Commitment

The core layer follows semantic versioning independently of the Platform
release version.

- **Patch** — security and correctness fixes within the existing CRD
  contract and bootstrap contract. Compatible with any consumer that runs
  the current major version line.
- **Minor** — additions to behavior that remain compatible with consumers
  of the current major version line. Adding a new permitted CRD kind to
  the surface contract is a minor increment when no existing kind changes.
- **Major** — any change that removes or alters the CRD surface contract,
  alters the bootstrap contract, removes a component from core, or
  changes the namespace, RBAC, or installation surface in a way that
  requires consumers to adapt.

Component-level upstream version bumps inside core (Flux 2.8 → 2.9,
cert-manager 1.20 → 1.21) do **not** automatically imply a core version
change. Core absorbs upstream churn behind its CRD surface contract.
A core major version is reserved for changes to what core *is*, not what
it depends on.

## Layering Discipline

The general layering discipline rule is defined in
[RFC-013](RFC-013-cur8s-layer-architecture.md): each layer may only
create custom resources whose CRDs it installs itself or that are
installed by a layer it depends on.

Because core has no dependencies, this rule reduces for core to: **core
may only create resources of kinds whose CRDs core installs itself**.
Built-in Kubernetes kinds and core's own CRD surface contract are the
only resources core may create.

Layers that depend on core are not subject to this restriction with
respect to core; they may freely create resources that target or extend
core's installed kinds.

## Forbidden Patterns

Cur8s explicitly forbids:

- adding application-tier components (gateways, databases, observability,
  log collection) to core
- adopting Flux controllers excluded by
  [RFC-008](RFC-008-flux-as-the-gitops-engine.md), most notably
  helm-controller and image-automation-controller, into core
- creating resources in core whose CRDs are owned by other layers
- pulling core images from rate-limited registries
- requiring `imagePullSecrets` on core ServiceAccounts
- treating component-level upstream version changes as core version
  changes

Any of these would compromise either core's stability commitment or its
bootstrap contract.

## Scope

This RFC defines **what the cur8s-core layer is, the contract it commits
to, and the rules that keep it stable as the rest of the Platform evolves**.

It does not define repository layout, build pipeline mechanics, OCI artifact
naming, or the Flux Kustomization graph used to apply core. Those are
implementation concerns and may change without amending this RFC, provided
they continue to satisfy the contracts defined here.

## Revisions

Initial version.
