# Flux Package User Guide

The Cur8s Flux package publishes an opinionated configuration of [Flux](https://fluxcd.io) as an
immutable OCI artifact. It configures Flux to reconcile static manifests through deterministic
composition while deliberately excluding features that perform runtime templating or make decisions
from live cluster state.

## Installed controllers

The package installs only the Flux controllers required by its operating model.

- **Source Controller** acquires immutable, versioned deployment artifacts.
- **Kustomize Controller** reconciles the manifests contained in those artifacts.
- **Notification Controller** reports reconciliation events without influencing control flow.

The remaining Flux controllers are intentionally excluded.

### Source Controller

The Source Controller acquires deployment artifacts. It installs the following source APIs:

- `OCIRepository`
- `GitRepository`
- `Bucket`
- `HelmRepository`
- `HelmChart`
- `ExternalArtifact`

#### Recommended usage

Use **`OCIRepository`** as the canonical source for released configuration.

OCI registries provide a common distribution platform for both application images and deployment
artifacts, allowing them to share the same build, publish, promotion, signing, verification,
replication, and access-control workflows.

OCI artifacts create a clean separation between **authoring** and **distribution**. Git remains the
place where deployment configuration is authored, reviewed, and versioned. CI renders and validates
the final manifests, publishes them as immutable OCI artifacts, and clusters reconcile those
artifacts directly. The cluster never reconstructs deployment artifacts from source.

OCI artifacts are the preferred deployment unit because they:

- are immutable and content-addressable
- are independent of the source repository
- promote unchanged across environments
- integrate naturally with existing registry infrastructure
- support the broader OCI ecosystem, including signing, verification, replication, and lifecycle
  management

Use **`GitRepository`** when consuming configuration directly from source rather than from a
released artifact. This is appropriate during active development or when publishing OCI artifacts is
not practical. Once configuration is packaged as a release artifact, prefer publishing it as an OCI
artifact and consuming it through `OCIRepository`.

#### Other source APIs

The remaining source APIs are installed by the upstream Source Controller but are not part of the
package's recommended operating model.

- **`Bucket`** supports object stores such as Amazon S3, Google Cloud Storage, and Azure Blob
  Storage as sources for deployment artifacts. This package recommends OCI registries instead
  because they provide a more natural distribution model for immutable, versioned release artifacts.
- **`HelmRepository`** and **`HelmChart`** support acquiring Helm charts. Without the Flux Helm
  Controller, they never produce `HelmRelease` resources and do not perform in-cluster chart
  reconciliation.
- **`ExternalArtifact`** supports in-cluster artifact composition. It enables advanced workflows
  such as combining multiple sources into a single deployment artifact or splitting a monorepo into
  independently deployable artifacts. This package assembles deployment artifacts before they reach
  the cluster and publishes them as OCI artifacts instead, so `ExternalArtifact` is not part of the
  recommended operating model.

### Kustomize Controller

The Kustomize Controller reconciles the manifests contained in deployment artifacts acquired by the
Source Controller.

#### Static manifests only

The package's operating model requires reconciliation to be deterministic from declared inputs. A
deployment artifact may contain complete manifests or Kustomize composition whose output depends
only on files in the artifact and explicitly declared values. It must not contain Helm charts,
conditionals, dependency lookups, or generators that vary output according to live cluster state.

How deployment artifacts are produced is intentionally outside the controller's responsibility.
Helm, Kustomize, Jsonnet, CUE, ytt, or any other build-time tooling may be used to construct
deployment artifacts before publication. Build time resolves templates, dependencies, and choices;
at reconciliation time, Kustomize performs only deterministic structural composition and the
explicit value substitution described below.

This design deliberately separates **artifact construction** from **artifact reconciliation**.
Deployment artifacts are assembled during the build process; the Kustomize Controller mechanically
composes and reconciles their declared content.

#### Explicit substitution is allowed

The package permits Flux's `postBuild.substituteFrom` mechanism as a narrow composition step for
explicit environment values. Substitution occurs during reconciliation, but it does not construct
new resources, evaluate conditions, fetch dependencies, or inspect live cluster state.

Values are substituted only from explicitly declared `ConfigMap` and `Secret` resources that form
part of the cluster's declared state. Every input to reconciliation remains explicit and
discoverable.

Unlike runtime templating, `postBuild.substituteFrom` does not change the structure of the
manifests. The controller substitutes declared values into a structure that was fixed before
publication.

The complete desired state remains discoverable by inspecting the GitOps repository together with
the explicitly referenced `ConfigMap` and `Secret` resources. This is the package's limited
composition model for environment-specific inputs.

### Notification Controller

The Notification Controller reports reconciliation events.

Notifications are informational only. They do not trigger deployments, orchestrate workflows, or
influence reconciliation. Their purpose is to report the state of the GitOps engine without becoming
another control plane.

## Excluded controllers

The package deliberately excludes several Flux controllers because they violate its operating model.

### Helm Controller

The Helm Controller renders templates during reconciliation. A `HelmRelease` can produce different
manifests depending on the Kubernetes version, installed APIs, CRDs, or other cluster state. The
same chart and values can therefore produce different deployment artifacts across clusters or over
time.

This package constructs deployment artifacts before they reach the cluster. Flux reconciles the
published manifests; it never renders templates during reconciliation.

### Image automation controllers

The Image Reflector Controller and Image Automation Controller work together to automate container
image updates.

The Image Reflector Controller continuously scans container registries for new image tags. The Image
Automation Controller applies image selection policies, updates image references in a Git
repository, and commits those changes automatically as new images become available. Together they
automate updating deployment artifacts to reference newly published container images.

This package intentionally excludes image automation because image selection belongs to the build
and release process, not cluster reconciliation. Deployment artifacts are expected to reference
explicitly selected image versions before publication. Flux reconciles those declared versions; it
never discovers or selects newer versions automatically.

### Source Watcher

Source Watcher implements Flux's in-cluster artifact composition capability. It constructs
deployment artifacts by combining or partitioning existing sources and publishes them as
`ExternalArtifact` resources.

This package assembles deployment artifacts before they reach the cluster and publishes them as OCI
artifacts. Because in-cluster artifact composition falls outside the recommended operating model,
`source-watcher` is not installed.

## Installation and operation

The package is installed once and then continuously manages its own installation. Each release is
published through two matching channels:

1. An immutable OCI artifact (`oci://ghcr.io/cur8s/flux:<version>`), which is the steady-state
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
  https://github.com/cur8s/flux/releases/download/<version>/install.yaml
```

After the controllers have started:

1. Create an `OCIRepository` referencing the desired package version.
2. Apply the package's `sync.yaml` `Kustomization`.
3. Allow Flux to begin managing its own installation.

From this point onward, Flux manages its own installation.

### Normal operation

During normal operation, the cluster continuously reconciles the OCI artifact referenced by
`OCIRepository/flux`.

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
- `OCIRepository/flux` is Ready
- `Kustomization/flux` is Ready

For local development, `mise run cluster:verify` performs these checks.
