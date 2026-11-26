# Flux Package User Guide

> [!NOTE]
> Use this guide to install, operate, upgrade, and recover the Cur8s Flux package.

Read [the package's opinion](product/02-the-opinion.md) for controller selection, source
recommendations, and the Notification Controller contract. Follow
[Pre-rendered manifests](product/01-pre-rendered-manifests.md) for the reconciliation model.

## Installation and operation

The package is installed once and then continuously manages its own installation. Each release
provides two matching distribution forms built from the same rendered controller manifests:

1. An immutable OCI artifact (`oci://ghcr.io/cur8s/gitops:<version>`), which is the steady-state
   deployment source.
2. A static bootstrap manifest (`install.yaml`), attached to the GitHub release.

Package versions use independent bare `MAJOR.MINOR.PATCH` Semantic Versions (for example `0.1.0`,
with no `v` prefix on the OCI tag). Upstream Flux versions are recorded separately in the
artifact's `cur8s.yaml` release descriptor and OCI annotations; see
[Version identity and immutable publication](architecture/03-publication-and-self-management.md#version-identity-and-immutable-publication).

The bootstrap manifest exists because `kubectl` can apply YAML directly but cannot apply an
`oci://` reference, and Flux custom resource definitions (CRDs) must exist before Flux resources are
created. It is used only during initial installation or recovery. Once self-management is active,
Flux reconciles the OCI artifact and the bootstrap manifest is no longer involved in normal
operation.

### Bootstrap

Flux comes up on a bare cluster with zero pre-existing secrets when pulling from the public
`ghcr.io/cur8s/gitops` registry. Its controller images pull anonymously from `ghcr.io`, and no Flux
`ServiceAccount` references an `imagePullSecret`. A missing required input must block
reconciliation visibly rather than trigger a hidden or guessed default.

Bootstrap happens in two separate apply operations: install the static controllers first, wait for
CRDs and controllers to become ready, then apply your consuming repository's self-management
resources.

#### 1. Install the static controller manifest

Apply the target release's static bootstrap manifest using server-side apply (required for the
large Flux CRDs):

```sh
kubectl apply --server-side -f \
  https://github.com/cur8s/gitops/releases/download/<version>/install.yaml
```

#### 2. Wait for CRDs and controllers

Do not apply Flux custom resources immediately after `kubectl apply`: wait until the Flux CRDs are
`Established` and all three controller Deployments are `Available`:

```sh
kubectl wait crd -l app.kubernetes.io/part-of=flux \
  --for=condition=Established --timeout=2m
kubectl -n flux-system wait deploy --all \
  --for=condition=Available --timeout=3m
```

#### 3. Apply consumer-owned self-management resources

The consuming repository owns both the `OCIRepository` (where the package comes from and which
version runs) and the self-management `Kustomization` (how Flux reconciles its own installation).
The Cur8s `gitops` package does not ship a `sync.yaml` manifest.

Commit a self-management manifest in your consuming repository (for example,
`flux-self-management.yaml`), setting `spec.ref.tag` to the exact bare SemVer tag you bootstrapped
in step 1:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: gitops
  namespace: flux-system
spec:
  interval: 10m
  url: oci://ghcr.io/cur8s/gitops
  ref:
    # Bare Cur8s SemVer package tag (MAJOR.MINOR.PATCH, no "v" prefix).
    # Optionally add `digest: sha256:...` to pin the exact OCI manifest digest.
    tag: "0.1.0"
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: gitops
  namespace: flux-system
  annotations:
    cur8s.io/docs: https://github.com/cur8s/gitops
    cur8s.io/upstream-source: https://github.com/fluxcd/flux2
spec:
  interval: 10m
  # Select only deploy/ so the inert cur8s.yaml descriptor at the artifact root is ignored.
  path: ./deploy
  prune: true
  wait: true
  sourceRef:
    kind: OCIRepository
    name: gitops
```

Apply your manifest after step 2 succeeds:

```sh
kubectl apply -f flux-self-management.yaml
```

**Public vs. authenticated registries:**

- **Public `ghcr.io/cur8s/gitops`:** Works as shown above with no registry credentials.
- **Private mirror or authenticated registry:** Point `spec.url` at your mirror (for example,
  `oci://registry.example.com/cur8s/gitops`) and add either `secretRef` (referencing a
  `kubernetes.io/dockerconfigjson` Secret in `flux-system`) or a cloud workload-identity `provider`
  (`aws`, `azure`, or `gcp`) to `OCIRepository.spec`:

  ```yaml
  spec:
    interval: 10m
    url: oci://registry.example.com/cur8s/gitops
    secretRef:
      name: oci-registry-auth
    ref:
      tag: "0.1.0"
  ```

#### 4. Verify the handoff

Wait for both self-management resources to report `Ready`:

```sh
kubectl -n flux-system wait ocirepository/gitops --for=condition=Ready --timeout=5m
kubectl -n flux-system wait kustomization/gitops --for=condition=Ready --timeout=5m
```

From this point onward, Flux continuously reconciles its own installation from the declared OCI
artifact.

### Normal operation

During normal operation, the cluster continuously reconciles the OCI artifact referenced by
`OCIRepository/gitops` through `Kustomization/gitops`.

The external cluster definition remains the authoritative source of intent: it records which
immutable artifact version the cluster should reconcile and how reconciliation is configured. The
OCI artifact is the deployment payload, not a replacement for that declaration.

Cluster-specific concerns—such as registry coordinates, credentials, intervals, identity, or
environment-specific configuration—remain external to this package. They determine **which**
deployment artifact is reconciled and **how** the cluster connects to it, not **what** controller
resources the artifact contains.

### Upgrades

Upgrading the GitOps engine consists only of changing the version selected by your consuming
repository's `OCIRepository`:

1. Update `spec.ref.tag` (and `spec.ref.digest` if pinned) on `OCIRepository/gitops` in your
   consuming repository to the target Cur8s SemVer release.
2. Apply or reconcile that change through your cluster's GitOps workflow (or trigger immediately with
   `flux -n flux-system reconcile kustomization gitops --with-source`).
3. Verify that `OCIRepository/gitops`, `Kustomization/gitops`, and all three controller Deployments
   in `flux-system` report `Ready` / `Available`.

Because deployment artifacts are immutable and no controller discovers or selects newer versions
automatically, every upgrade is an explicit decision made outside the cluster. Do not use
`install.yaml` for ordinary upgrades.

### Recovery

If the GitOps engine itself becomes unavailable and cannot reconcile itself, repeat the same
two-step bootstrap sequence using the version already declared in your consuming repository:

1. Reapply the matching version's `install.yaml` with server-side apply (Bootstrap step 1).
2. Wait for the Flux CRDs to be `Established` and controller Deployments `Available` (Bootstrap
   step 2).
3. Reapply your consuming repository's self-management manifest (`OCIRepository` and
   `Kustomization`, Bootstrap step 3).
4. Verify convergence (Bootstrap step 4) and confirm all three controller Deployments are
   `Available`, `OCIRepository/gitops` is `Ready`, and `Kustomization/gitops` is `Ready`.

Flux will reconcile the declared deployment artifact and restore the installation without drifting
from the bootstrapped resources.

For local disposable-cluster testing in this repository, see
[Local development](how-to/00-local-development.md).
