# flux — the Cur8s GitOps engine package

This repository renders Cur8s' constrained [Flux](https://fluxcd.io) installation once and
publishes it as an immutable OCI artifact. The installation includes only the source, kustomize,
and notification controllers, so clusters reconcile static manifests instead of templates resolved
at runtime.

## Prerequisites

| Concept | Why it matters here |
| --- | --- |
| [GitOps](https://opengitops.dev/) | Desired state is declared outside the cluster, versioned, and continuously reconciled into it; this package installs [Flux](https://fluxcd.io/flux/concepts/), the engine that does the reconciling. |
| [OCI artifacts](https://oras.land/docs/concepts/artifact) | Non-image content, such as Kubernetes manifests, stored and distributed through OCI registries; this package ships as one. |

| Software | What it gives us |
| --- | --- |
| [mise](https://mise.jdx.dev/installing-mise.html) | The same toolchain and commands on every machine: exact, checksum-verified tool versions from [`mise.toml`](mise.toml), and every command as a task. |
| [Docker](https://docs.docker.com/get-started/get-docker/) | The full end-to-end test on your own machine: k3d runs disposable Kubernetes clusters and registries in Docker, with no shared cluster or cloud account. |

## Read next

1. [Vision](docs/vision.md): why the package exists and what it deliberately excludes.
2. [User guide](docs/user-guide.md): the supported surface, bootstrap, operation, and upgrades.
3. [Architecture](docs/architecture.md): how the source becomes the published artifact.
