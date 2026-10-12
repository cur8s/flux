# The package's opinion

> [!NOTE]
> Read this document to understand which Flux capabilities the package installs, how Cur8s
> recommends using them, and where the installed surface is broader than that recommendation.

The [vision](00-vision.md) calls for a predictable GitOps foundation. The package selects a small
Flux controller set for that purpose. Its operating model follows the
[pre-rendered-manifest philosophy](01-pre-rendered-manifests.md): construct deployment artifacts
before publication, declare the version and environment inputs, and reconcile the resulting
manifests.

## Installed controllers

| Controller | Role in the operating model |
| --- | --- |
| Source Controller | Acquire the declared deployment artifact and make it available for reconciliation. |
| Kustomize Controller | Compose and apply its manifests, then maintain convergence. |
| Notification Controller | Report reconciliation events to configured destinations. Its incoming webhook surface is discussed below. |

These are the three controller Deployments in the rendered installation. Their upstream APIs
remain installed even when Cur8s recommends only a narrower use of them. A recommendation here
does not imply that the package disables every other capability of an installed controller.

## OCI for released configuration

Use `OCIRepository` as the canonical source for released deployment configuration. Git holds the
authored configuration and its review history; artifact construction produces the deployment
payload. Publishing that payload to an OCI registry separates its distribution from the tools and
source repository that produced it.

An OCI artifact has a content digest and can be consumed without rebuilding its source. The same
payload can be promoted across environments, with environment inputs declared separately.
Registries also provide an established distribution surface for replication, access control,
signing, and verification. Those ecosystem capabilities do not, by themselves, mean this package
has configured each of them.

The cluster definition selects the artifact version to reconcile. Upgrades follow changes to that
declaration; the recommended model does not use a policy that discovers and selects a newer
release during reconciliation.

`GitRepository` remains useful for directly authored manifest configuration during development or
when publishing an OCI artifact is impractical. That configuration must obey the same deterministic
composition rules. Prefer `OCIRepository` once configuration is packaged as a release artifact.

## Other installed source APIs

The installation includes the following additional Source Controller APIs. Their presence reflects
the upstream controller's surface, rather than an additional Cur8s deployment model.

| API | Upstream capability | Cur8s recommendation |
| --- | --- | --- |
| `Bucket` | Acquire artifacts from object storage. | Use OCI registries for released configuration. |
| `HelmRepository`, `HelmChart` | Locate, fetch, or package Helm chart archives. | Render charts during artifact construction and publish their manifests. The package does not install Helm Controller or the `HelmRelease` API. |
| `ExternalArtifact` | Let another controller expose an artifact for Flux consumption. | Publish deployment artifacts before they reach the cluster. In-cluster artifact generation is outside the recommended model. |

In particular, [`ExternalArtifact`](https://fluxcd.io/flux/components/source/externalartifacts/)
is an interoperability API; it does not generate or combine sources by itself. Upstream
[Source Watcher](https://fluxcd.io/flux/components/source/artifactgenerators/) uses artifact
generation to compose or split sources. Source Watcher is not installed by this package.

## Reconciliation of declared manifests

Kustomize Controller applies complete manifests or deterministic composition of the artifact's
files and declared values. Explicit environment substitution is permitted within the constraints
defined in [Pre-rendered manifests](01-pre-rendered-manifests.md#permitted-composition-and-environment-values).
The package's own controller installation is already fully rendered.

Artifact construction may use Helm, Kustomize, or other build-time tools. Their choice is the
author's responsibility; the published payload must follow this reconciliation model.

## Reporting and incoming webhooks

The intended notification role is to report reconciliation events. Upstream `Alert` and `Provider`
resources configure outgoing event delivery. This gives operators information about the GitOps
engine while keeping deployment intent in external declarations.

The installed surface also includes the `Receiver` API and the internal `webhook-receiver`
Service. A configured [Receiver](https://fluxcd.io/flux/components/notification/receivers/) accepts
external events and can request reconciliation of referenced Flux resources. Reporting is therefore
not the controller's only installed capability. The package does not configure Receiver resources.

**Unresolved contract:** the intended role is informational reporting, but the incoming webhook
capability is present. Whether the package will explicitly exclude Receivers from its recommended
contract or reduce that installed surface remains an open design decision. This document records
the current surface without treating either outcome as agreed.

## Excluded controllers

| Controller | Reason for exclusion |
| --- | --- |
| Helm Controller | Renders and manages chart releases inside the cluster; Cur8s publishes the rendered manifests beforehand. |
| Image Reflector Controller and Image Automation Controller | Discover image versions and automate image-reference changes; Cur8s selects image versions during construction and release. |
| Source Watcher | Constructs deployment artifacts inside the cluster; Cur8s constructs them before publication. |

These exclusions bound the package's operating model. The
[user guide](../user-guide.md#installation-and-operation) explains how to install, operate, upgrade,
and recover this selected installation.
