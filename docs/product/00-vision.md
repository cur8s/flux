# Vision

> [!NOTE]
> Read this document to understand whom the Cur8s Flux package serves, the problem it addresses,
> and the boundaries that guide its design.

## Audience and problem

The Cur8s Flux package serves operators building and maintaining Cur8s cluster definitions. They
need a GitOps engine whose installation and reconciliation behavior they can understand, reproduce,
and recover with limited time and attention.

Versioning configuration is only part of that problem. If the cluster renders templates or selects
versions during reconciliation, the declared inputs can leave important decisions unresolved.
Operators then have to reconstruct those decisions to explain differences between environments or
restore a failed installation.

## Approach

The package provides an opinionated Flux installation distributed as an immutable OCI artifact.
Deployment artifacts are constructed before they reach the cluster. Flux continuously reconciles
their static manifests, with deterministic composition and explicitly declared environment values.
The intended state remains inspectable from the artifact and its declared inputs.

The supported operating model keeps version selection outside reconciliation. A cluster definition
declares which artifact version to use; changing that declaration is an explicit operator decision.
The package includes the source, kustomize, and notification controllers. It excludes in-cluster
Helm rendering, image automation, and in-cluster artifact composition.

This constrained surface gives Cur8s a dependable GitOps foundation: operators can review the
deployment payload before installation, compare intended state across environments, and return to
a known version without reconstructing how it was built.

## Success

The package succeeds when operators can:

- Bootstrap the GitOps engine on a bare Kubernetes cluster without pre-existing secrets or
  `imagePullSecrets` for its installation.
- Identify the exact deployment artifact and declared inputs their cluster reconciles.
- Make upgrades deliberately by changing the declared artifact version.
- Restore the GitOps engine from the matching installation manifest and cluster definition.

Every published version must have a green end-to-end run proving that the installation starts and
Flux takes over managing itself from the artifact.

## Boundaries

This repository produces the Cur8s `gitops` capability package (`ghcr.io/cur8s/gitops`), owning the
opinionated Flux installation and its independent Semantic Version contract. Cur8s packages use
short capability names rather than upstream product names so package versions are not confused with
upstream software versions; see
[Capability package naming and version identity](../architecture/03-publication-and-self-management.md#version-identity-and-immutable-publication)
for the agreed Cur8s capability set and versioning policy. Consuming cluster definitions own their
artifact sources, selected versions, credentials, and integration with other components.

It serves the Cur8s operating model rather than every Flux use case. Application and component
authors may choose their build-time rendering tools; the resulting artifacts must follow the
package's reconciliation model. Detailed installation and recovery procedures belong in the
[user guide](../user-guide.md), and the package mechanisms belong in
[architecture](../architecture/00-overview.md).
