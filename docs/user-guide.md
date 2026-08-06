# Flux package user guide

This package publishes the Cur8s configuration of [Flux](https://fluxcd.io) as an immutable OCI artifact. It is for the cluster composition and bootstrap tooling that need a GitOps engine, not for configuring Flux feature by feature. The artifact is the one supported installation.

## The operating model

Cur8s records cluster decisions outside the cluster and reconciles them from there. The cluster is an executor: it should not select versions, resolve dependencies, or interpret templates differently according to live state. That boundary keeps desired state reviewable and recoverable. Its platform-wide rationale is [RFC-004: Declarative Cluster Control](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-004-declarative-cluster-control.md) and [RFC-005: Static Runtime Manifests](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-005-static-runtime-manifests.md).

Accordingly, the package installs exactly three controllers in `flux-system`:

- `source-controller` fetches declared, versioned artifacts.
- `kustomize-controller` applies already-rendered manifests.
- `notification-controller` reports reconciliation events without influencing control flow.

It does not install `helm-controller`, either image-automation controller, or `source-watcher`, and it enables no feature gates. Helm controller rendering, dependency resolution, and release state would make runtime behavior depend on the cluster. Image automation would let the cluster choose a new version rather than apply one explicitly declared outside it. `source-watcher` is an upstream sample controller, not part of this production configuration. These restrictions apply [RFC-006: Flux as the GitOps Engine](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-006-flux-as-the-gitops-engine.md).

Build-time Helm is compatible with this model when it produces reviewed, static YAML before publication. Likewise, deterministic Kustomize composition is permitted: given the same inputs it makes the same structural result; it does not branch on live cluster state or fetch and select dependencies at runtime.

## What the artifact provides

The artifact contains the three-controller install, a `sync.yaml` self-management `Kustomization`, and an inert `cur8s.yaml` release descriptor. It also defines the public Flux CRD surface:

- `source.toolkit.fluxcd.io`: `GitRepository`, `OCIRepository`, `Bucket`, `HelmRepository`, `HelmChart`, and `ExternalArtifact`.
- `kustomize.toolkit.fluxcd.io`: `Kustomization`.
- `notification.toolkit.fluxcd.io`: `Alert`, `Provider`, and `Receiver`.

The Helm source kinds are present because source-controller owns them; without `helm-controller`, there is no `HelmRelease` and no in-cluster chart reconciliation. `ExternalArtifact` is served upstream, but this package does not enable or qualify a consumer for it.

## Bootstrap and steady state

Flux must be recoverable on a bare cluster. It needs no pre-existing secrets, uses `ghcr.io` images rather than a practically rate-limited registry, and sets no `imagePullSecrets`. Missing required inputs should stop reconciliation visibly rather than silently supplying a default. The platform's separate secrets layer owns any permitted bootstrap secret; Flux does not.

Each release is available through two matching channels:

1. The OCI artifact, `oci://ghcr.io/cur8s/flux:<version>`, is the steady-state source. A cluster's `OCIRepository` and the artifact's `sync.yaml` make Flux reconcile its own installation from that artifact.
2. The same release attaches `deploy/flux.yaml` unchanged as the GitHub release asset `install.yaml`. This is the HTTP-addressable first-touch path because `kubectl` cannot apply an OCI reference directly.

For first touch, apply the release asset once:

```sh
kubectl apply --server-side -f \
  https://github.com/cur8s/flux/releases/download/<version>/install.yaml
```

After the controllers are available, the cluster composition applies an `OCIRepository` named `flux` and the artifact's `sync.yaml`. Flux then self-manages from the explicit artifact tag. Recovery follows the same sequence: reinstall the release asset, then reapply the declared OCI source and self-management resource.

## Upgrades and verification

The tag is an external, explicit choice. Advancing it upgrades Flux; no runtime controller discovers or selects a replacement. Versions derive from upstream Flux (`vX.Y.Z`), with a `-<n>` suffix only when the Cur8s configuration changes without an upstream change. Published versions are immutable and every candidate must pass the end-to-end qualification described by [RFC-011: Component Versioning](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-011-component-versioning.md).

After bootstrapping or an upgrade, verify that the three deployments, `OCIRepository/flux`, and `Kustomization/flux` are Ready. In a local k3d environment, `mise run cluster:verify` performs those checks; see [CONTRIBUTING.md](../CONTRIBUTING.md) for development commands.

## Limits

This package deliberately does not bootstrap a full platform or choose the artifact versions a cluster uses. It does not provide a UI, Helm releases, automatic image updates, secrets, or environment-specific configuration. Those are declared and composed outside this artifact. The package's job is to fetch immutable intent and reconcile the static result faithfully.
