# Artifact contents and metadata

> [!NOTE]
> Read this document to distinguish the installation payload, release descriptor, and OCI
> publication metadata, including what each identity refers to.

[From source to artifact](01-source-to-artifact.md) explains how rendering produces the committed
tree. This document describes that tree and the metadata added when it is published.

## Applied content and inert metadata

The rendered tree contains two files. Publication packages their paths relative to
`artifacts/rendered/`, so the local prefix is absent inside the OCI artifact:

```text
artifacts/rendered/
├── cur8s.yaml
└── deploy/
    └── flux.yaml
```

| File | Purpose | How it is used |
| --- | --- | --- |
| [`deploy/flux.yaml`](../../artifacts/rendered/deploy/flux.yaml) | Complete controller installation: namespace, CRDs, permissions, Services, and Deployments. | Applied directly for bootstrap and reconciled from the artifact's `deploy/` directory. |
| [`cur8s.yaml`](../../artifacts/rendered/cur8s.yaml) | Release identity for readers and tooling. | Read as metadata; it is not a Kubernetes resource and is not applied. |

Consuming clusters supply both the `OCIRepository` and the self-management `Kustomization`
selecting `path: ./deploy`, leaving `cur8s.yaml` outside the manifests Flux applies. The
[overview](00-overview.md#self-management-boundary) defines that ownership boundary; the
[user guide](../user-guide.md) shows the production manifests.

## Render-time release descriptor

[`build:render`](../../.mise/tasks/build/render) generates `cur8s.yaml` from capability identity,
the independent package version, and the captured upstream file. The current schema is
`cur8s.io/release-descriptor/v1`.

| Field | Render-time source | Meaning |
| --- | --- | --- |
| `schema` | Literal schema identifier in the render script. | Format of this descriptor. |
| `component` | `COMPONENT_NAME` (`gitops`). | Cur8s capability package identity. |
| `version` | `COMPONENT_VERSION`. | Independent component package Semantic Version. |
| `upstream.source` | `UPSTREAM_SOURCE`. | Upstream repository URL. |
| `upstream.version` | `UPSTREAM_TAG`. | Selected upstream release. |
| `upstream.digest` | SHA-256 of the captured `upstream/flux.yaml` bytes. | Identity of the captured installation input before the authored overlay is applied. |
| `source` | `COMPONENT_SOURCE`. | Declared package source location. |
| `docs` | `COMPONENT_DOCS`. | Declared package documentation location. |

The authored identity values live in [`mise.toml`](../../mise.toml). The descriptor omits a render
timestamp and Git revision so it can be regenerated from the same recorded inputs without those
publication-time facts changing the rendered files.

`upstream.digest` identifies the captured YAML file. It is neither a controller image digest nor
the digest of the rendered controller installation or published OCI artifact. It also does not
record every tool or authored transformation used to produce the payload; those remain in the
repository and its lockfile.

## Publication annotations

[`.mise/cluster/push-artifact.sh`](../../.mise/cluster/push-artifact.sh) (used by
[`release:publish`](../../.mise/tasks/release/publish), [`dev:update`](../../.mise/tasks/dev/update),
and [`.mise/cluster/install-component.sh`](../../.mise/cluster/install-component.sh)) packages `artifacts/rendered/` with
`flux push artifact`. It adds these custom OCI manifest annotations from the same configuration
values used by the descriptor:

| Annotation | Value source |
| --- | --- |
| `cur8s.io/component` | `COMPONENT_NAME`. |
| `cur8s.io/version` | `COMPONENT_VERSION`. |
| `cur8s.io/upstream-source` | `UPSTREAM_SOURCE`. |
| `cur8s.io/upstream-version` | `UPSTREAM_TAG`. |
| `cur8s.io/docs` | `COMPONENT_DOCS`. |

The script also supplies the Git origin URL through `--source` and the current branch and HEAD
commit through `--revision`. Flux stores them as `org.opencontainers.image.source` and
`org.opencontainers.image.revision`, respectively, as described in the
[Flux OCI metadata documentation](https://fluxcd.io/flux/cheatsheets/oci-artifacts/).

These values are obtained at push time. The descriptor's `source` comes from the authored
`COMPONENT_SOURCE`, while the OCI source annotation comes from the local Git remote; they need not be
identical. `.mise/cluster/push-artifact.sh` records HEAD without requiring a clean working tree so local `dev`
pushes can test uncommitted changes, whereas `release:publish` refuses to run on a dirty working
tree so remote releases match the recorded commit.

The destination tag is passed explicitly to `.mise/cluster/push-artifact.sh`. Local `dev` and `verify` pushes
use `dev` and `verify` while the descriptor still records the configured package version.
`release:publish` always tags with `COMPONENT_TAG` (validated from `COMPONENT_VERSION`) and exposes no tag override.

## Cluster-side identification

The deploy overlay adds `cur8s.io/component: gitops` to installation resources. Consuming
repositories may also place `cur8s.io/docs` and `cur8s.io/upstream-source` annotations on their
self-management `Kustomization` (as shown in the [user guide](../user-guide.md) and used by this
repository's local [`test/sync.yaml`](../../test/sync.yaml)). These are stable component markers,
rather than version-bearing records.

Upstream `app.kubernetes.io/*` labels remain on the generated installation. The package does not
use those labels as a substitute for its descriptor or registry metadata. Rendered resources,
the descriptor, and OCI annotations answer different questions: what is installed, which package
the payload declares itself to be, and which publication supplied it.

## File identity and OCI identity

An [OCI descriptor digest](https://github.com/opencontainers/image-spec/blob/main/descriptor.md)
identifies the bytes of the referenced OCI object. The published artifact includes packaging and
manifest metadata in addition to the rendered files. Keeping those files identical is therefore
only part of reproducing the same OCI identity.

Flux exposes a [`--reproducible` option](https://fluxcd.io/flux/cmd/flux_push_artifact/) to normalize
its created timestamp. The current push script does not use that option. Rendered-file
reproducibility is a requirement of the build, but reproducible OCI manifest digests have not been
established by the current publication path. Likewise, metadata annotations describe origin and
identity; they are not signatures or verified provenance.
