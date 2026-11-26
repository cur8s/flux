# Flux Package User Guide

> [!NOTE]
> Use this guide to install, operate, upgrade, and recover the Cur8s Flux package.

Read [the package's opinion](product/02-the-opinion.md) for controller selection, source
recommendations, and the unresolved Receiver webhook contract. Follow
[Pre-rendered manifests](product/01-pre-rendered-manifests.md) for the reconciliation model.

## Installation and operation

The package is installed once and then continuously manages its own installation. Each release
must provide two matching distribution forms:

1. An immutable OCI artifact (`oci://ghcr.io/cur8s/gitops:<version>`), which is the steady-state
   deployment source.
2. A bootstrap manifest (`install.yaml`), attached to the GitHub release.

The bootstrap manifest exists because `kubectl` can apply YAML directly but cannot apply an
`oci://` reference. It is used only during the initial installation. Once the
controllers have started, the cluster continuously reconciles the OCI artifact, and the bootstrap
manifest is no longer involved in normal operation.

### Bootstrap

Flux comes up on a bare cluster with zero pre-existing secrets. Its images pull anonymously from
`ghcr.io`, and no Flux `ServiceAccount` references an `imagePullSecret`. A missing required input
must block reconciliation visibly rather than trigger a hidden or guessed default.

Install the GitOps engine by applying the release manifest:

```sh
kubectl apply --server-side -f \
  https://github.com/cur8s/gitops/releases/download/<version>/install.yaml
```

After the controllers have started:

1. Create an `OCIRepository` referencing the desired package version.
2. Apply the package's `sync.yaml` `Kustomization`.
3. Allow Flux to begin managing its own installation.

From this point onward, Flux manages its own installation.

### Normal operation

During normal operation, the cluster continuously reconciles the OCI artifact referenced by
`OCIRepository/gitops`.

The external cluster definition remains the authoritative source of intent: it records which
immutable artifact version the cluster should reconcile. The OCI artifact is the deployment
payload, not a replacement for that declaration.

Upgrading the GitOps engine consists only of changing the artifact version referenced by the cluster
definition. The deployment artifact itself is immutable, and no controller discovers or selects
newer versions automatically.

Cluster-specific concerns—such as registry credentials, identity, or environment-specific
configuration—remain external to this package. They determine **which** deployment artifact is
reconciled, not **how** that artifact behaves.

### Upgrades

To upgrade the GitOps engine, update the version referenced by `OCIRepository` and allow
reconciliation to converge.

Because deployment artifacts are immutable, every upgrade is an explicit decision made outside the
cluster.

### Recovery

If the GitOps engine itself becomes unavailable:

1. Reapply the matching version's `install.yaml`.
2. Restore the declared `OCIRepository`.
3. Reapply the package's `sync.yaml`.

Flux will reconcile the declared deployment artifact and restore the installation.

After recovery, verify that:

- all three controller Deployments are Ready
- `OCIRepository/gitops` is Ready
- `Kustomization/gitops` is Ready

The local development task waits for source and Kustomization readiness during `dev:create`.
Use `mise run dev:status` to inspect an existing environment: `Kustomization/gitops` waits for the
controller Deployments before it reports Ready.
