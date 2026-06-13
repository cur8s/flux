# RFC-015: Flux as the GitOps Engine

**Status:** Accepted

The foundation needs a system that continuously reconciles declared intent
without introducing new sources of authority, runtime interpretation, or hidden
state. Given the constraints already established — externalized intent
([RFC-005](RFC-005-declarative-cluster-control.md)), static runtime manifests
([RFC-006](RFC-006-static-runtime-manifests.md)), semantic versioning with no
runtime version selection
([RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md)) — a
continuously-running, pull-based reconciler is mandatory. This foundation uses
**Flux**, and this RFC defines *how* Flux is used and constrained. Flux is this
repository's one component; the opinionated configuration it publishes is
specified here.

## Core Rule

**The GitOps engine is Flux, used in a restricted, opinionated configuration:
source-controller, kustomize-controller, and notification-controller only.
helm-controller and the image-automation controllers are forbidden.**

Flux fits the foundation's constraints directly. It is modular (include only the
controllers required, forbid the rest), headless by design — no UI, all
interaction through the Kubernetes API
([RFC-004](RFC-004-headless-platform.md)) — and pull-based and declarative,
reconciling mechanically toward declared intent.

## Permitted Controllers

Each permitted controller exists to enforce a specific architectural rule:

- **source-controller** — materializes versioned, externalized artifacts (OCI,
  Git) into the cluster, enforcing
  [RFC-005](RFC-005-declarative-cluster-control.md). It fetches intent; it does
  not generate or interpret it.
- **kustomize-controller** — applies fully-rendered static manifests and
  maintains convergence, enforcing
  [RFC-006](RFC-006-static-runtime-manifests.md). Kustomize overlays are
  permitted because they perform deterministic structural composition, not
  runtime interpretation; post-build substitution
  ([RFC-007](RFC-007-environment-specific-inputs.md)) is pure value
  substitution.
- **notification-controller** — emits reconciliation events for observability.
  Informational only; it never triggers actions or influences control flow,
  preserving the headless model.

## Forbidden Controllers

- **helm-controller** — performs in-cluster chart rendering, dependency
  resolution, and release-state tracking, reintroducing runtime interpretation
  and mutable state in direct conflict with
  [RFC-006](RFC-006-static-runtime-manifests.md). Helm charts may be used **only
  at build time** to render static YAML; the cluster never reconciles
  `HelmRelease` resources.
- **image-reflector-controller** / **image-automation-controller** — would let
  Flux *select* and advance versions on its own, crossing version boundaries
  that were never declared, in conflict with
  [RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md). Flux may
  *apply* a declared version; it may never *select* one.

## The Opinionated Configuration

This repository publishes one specific configuration, tracking upstream Flux per
[RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md):

- **Controllers:** exactly the three above, generated with
  `flux install --components=source-controller,kustomize-controller,notification-controller --export`.
  The opinion is encoded in the component list — the forbidden controllers are
  simply never installed.
- **Namespace:** `flux-system`.
- **ExternalArtifact feature gate:** enabled on kustomize-controller via an
  overlay patch, so the cluster can consume `ExternalArtifact` sources produced
  by external providers. The gate is **qualified against each tracked Flux
  version** by the repository's e2e before publication; the per-version status
  is recorded in the component's `notes.md`.
- **source-watcher excluded:** source-watcher is an upstream *sample* controller
  used to demonstrate the ExternalArtifact API, not a production component.
  Enabling the capability (the feature gate) does not require shipping the demo
  producer. A real external-artifact producer is adopted deliberately, if and
  when a layer needs one.

The rendered manifest is committed (`oci/flux/deploy/flux.yaml`) so every
version bump or config change is a reviewable diff
([RFC-006](RFC-006-static-runtime-manifests.md)).

## Bootstrap & Self-Management

Flux is the chicken-and-egg case: the artifact is reconciled by the engine being
installed. It is therefore dual-published and bootstrapped per
[RFC-011](RFC-011-bootstrap-contract.md) — `kubectl apply` of the HTTP-addressed
install manifest brings the controllers up, then an `OCIRepository` +
`Kustomization` make Flux self-manage from the OCI artifact. Flux comes up with
zero pre-existing secrets and pulls its images from `ghcr.io`.

## Alternatives Considered

- **Argo CD** — rich, UI-driven, encourages interaction through its dashboard.
  That is an additional operational surface the foundation avoids; it requires a
  headless reconciler driven solely by declarative state and the Kubernetes API
  ([RFC-004](RFC-004-headless-platform.md)).
- **Carvel** — aligns philosophically (build-time rendering, deterministic
  artifacts, small composable tools), but Flux has a larger contributor base,
  broader adoption, and stronger vendor-independent momentum. For a foundation
  optimizing for longevity, ecosystem stability is decisive.

## Forbidden Patterns

- Adopting helm-controller or image-automation controllers.
- Reconciling `HelmRelease` resources (Helm is build-time only).
- Treating an upstream Flux version bump as anything other than a tested,
  recorded version advance ([RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md)).

## Scope

This RFC defines how Flux is used and constrained, and the opinionated
configuration this repository publishes. It does not define artifact
distribution ([RFC-010](RFC-010-component-repositories-and-oci-distribution.md))
or the bootstrap mechanism in full
([RFC-011](RFC-011-bootstrap-contract.md)).

## Revisions

Initial version.
