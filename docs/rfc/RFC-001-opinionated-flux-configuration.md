# RFC-001: The Opinionated Flux Configuration

**Status:** Accepted

The platform-wide law — Flux is the GitOps engine, which controllers are
permitted, why the rest are forbidden — lives in the flagship:
[cur8s RFC-006: Flux as the GitOps Engine](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-006-flux-as-the-gitops-engine.md).
This RFC is the component's own contract: exactly what this package
installs, and the surface it commits to.

## Core Rule

**The artifact installs exactly three controllers — source-controller,
kustomize-controller, notification-controller — in the `flux-system`
namespace, rendered from `flux install --export` with metadata-only
marks added. No helm-controller, no image-automation controllers, no
feature gates.**

## The Configuration

- **Controllers:** exactly the three, generated with
  `flux install --components=source-controller,kustomize-controller,notification-controller --export`.
  The opinion is encoded in the component list — the forbidden
  controllers are simply never installed.
- **Namespace:** `flux-system`.
- **No feature gates.** The install is exactly what the flux CLI
  produces for the three controllers. A gate is adopted deliberately,
  as a reviewed change qualified by the e2e suite against the tracked
  version — never carried by default.
- **source-watcher excluded:** an upstream *sample* controller used to
  demonstrate the ExternalArtifact API, not a production component.
- **Metadata-only marks:** every rendered object carries the
  `cur8s.io/component=flux` label, the artifact carries the `cur8s.yaml`
  release descriptor, and pushes attach `cur8s.io/*` manifest
  annotations. Marks never touch selectors or pod templates.

The rendered result is committed (`oci/flux/`) so every version bump or
configuration change is a reviewable diff — render once, reconcile
forever ([cur8s RFC-005](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-005-static-runtime-manifests.md)).

## The API Surface

Installing this artifact defines ten CRDs; they are the component's
public API, and narrowing or breaking this surface is a major version
event:

- `source.toolkit.fluxcd.io`: GitRepository, OCIRepository, Bucket,
  HelmRepository, HelmChart, ExternalArtifact
- `kustomize.toolkit.fluxcd.io`: Kustomization
- `notification.toolkit.fluxcd.io`: Alert, Provider, Receiver

Two honest edges: the Helm-source CRDs exist because source-controller
owns them, but with helm-controller absent there is no `HelmRelease`
kind and nothing that reconciles charts in-cluster; and ExternalArtifact
is served by source-controller upstream — this package neither enables
nor qualifies any consumer of it.

## Forbidden Patterns

- Adding helm-controller or the image-automation controllers to the
  component list.
- Enabling a feature gate without a reviewed, e2e-qualified change.
- Hand-editing `oci/` — the tree is rendered from `src/`, and the drift
  gate (`test:drift`) fails on any divergence.

## Scope

This RFC defines what this package installs and the API surface it
commits to. Version derivation is
[cur8s RFC-011: Component Versioning](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-011-component-versioning.md);
how the engine first comes up is [RFC-002](RFC-002-flux-bootstrap-contract.md).

## Revisions

Initial version — descends from the pre-alignment RFC-015, reduced to
the component's own contract (2026-07-07).
