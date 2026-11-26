# Publication and self-management

> [!NOTE]
> Read this document to understand the release contract, how Flux takes over its installation,
> and which parts of publication and verification the current implementation provides.

The [overview](00-overview.md) defines package and consumer responsibilities.
[From source to artifact](01-source-to-artifact.md) explains rendering, and
[Artifact contents and metadata](02-artifact-contents-and-metadata.md) identifies the payload and
its publication metadata. This document connects that payload to a release and a running cluster.

## Release contract and current publication path

A release has two matching distribution forms:

| Form | Contract | Current repository implementation |
| --- | --- | --- |
| OCI artifact | The versioned payload at `oci://ghcr.io/cur8s/gitops:<version>`, consumed during normal reconciliation. | The publication task pushes the existing rendered tree to `RELEASE_REGISTRY` under `CUR8S_COMPONENT` (`gitops`) at `CUR8S_TAG`. |
| `install.yaml` release asset | Static controller installation for bootstrap or recovery before Flux can reconcile itself. | The rendered installation is available locally as `artifacts/rendered/deploy/flux.yaml`; the publication task does not attach it to a GitHub release. |

Both forms must use the same generated controller installation bytes. Publication must not render
a separate installation for each channel. Their packaging differs, but the resources that bootstrap
installs must be the resources Flux subsequently reconciles.

[`release:publish`](../../.mise/tasks/release/publish) requires a clean working tree and publishes
the existing rendered tree to `RELEASE_REGISTRY` at `CUR8S_TAG` (with no tag override). It does
not fetch or render inputs, run `verify:run`, or check whether that version already
exists in either distribution channel. There is currently no live GitHub Actions workflow in the
repository; the verification gates run locally.

A green end-to-end run remains a release acceptance requirement. Publication is an explicit owner
action, rather than a consequence of rendering or a successful test. The current script's lack of
automatic enforcement does not remove the acceptance requirement.

## Version identity and immutable publication

Cur8s distributes each capability as an independently versioned OCI package under
`ghcr.io/cur8s/<name>`, using short capability names rather than upstream product names so Cur8s
package tags are not confused with upstream versions. The eight agreed Cur8s capability package
names are:

| Package (`ghcr.io/cur8s/<name>`) | Capability area |
| --- | --- |
| `gitops` | GitOps reconciliation engine (this package, backed by Flux) |
| `certificates` | Certificate management |
| `secrets` | Secrets management |
| `gateway` | Cluster ingress and gateway |
| `postgres` | PostgreSQL database |
| `metrics` | Metrics collection and storage |
| `logging` | Log collection and storage |
| `grafana` | Dashboards and visualization |

Each capability package carries its own independent `MAJOR.MINOR.PATCH` Semantic Version authored
as `CUR8S_VERSION` in [`mise.toml`](../../mise.toml) and validated by `CUR8S_TAG`. Upstream
software versions remain separate provenance metadata (`UPSTREAM_VERSION` / `UPSTREAM_TAG`,
`cur8s.yaml`, and `cur8s.io/upstream-version` OCI annotations). A Cur8s platform release versions a
tested combination of exact capability versions independently through a bill of materials (BOM).

Apply SemVer increments to the Cur8s package's compatibility contract across both upstream and
Cur8s-owned changes:

- **MAJOR:** An incompatible change to the package's documented behavior or interfaces.
- **MINOR:** Backward-compatible new functionality or capabilities.
- **PATCH:** Backward-compatible fixes, packaging corrections, or dependency updates that do not
  introduce new functionality or incompatibility.

An upstream major, minor, or patch designation is a useful signal, not a mechanical rule: the actual
effect on the Cur8s package's compatibility contract determines the bump, and a Cur8s-only change
can trigger any appropriate increment. See [Why independent SemVer](#why-independent-semver) for the
rejected alternatives and trade-offs behind this model.

Once a production version is published, it must keep identifying the same content. Development
tags such as `dev` and `verify` serve local workflows via `.mise/cluster/push-artifact.sh`; `release:publish` only
targets `RELEASE_REGISTRY` at `CUR8S_TAG`, though it does not yet refuse an existing production
version.

The intended publication path also requires one packaged OCI artifact to be tested and promoted
unchanged. Local OCI packaging under the reserved, ignored `artifacts/oci/` directory is still
unfinished. Today test and production publication invoke the publisher separately, packaging only
at push time. A green local test therefore establishes that its payload reconciles; it does not establish that the
production OCI manifest digest is the tested digest. The
[metadata explanation](02-artifact-contents-and-metadata.md#file-identity-and-oci-identity)
describes why identical rendered files alone do not establish that identity.

## Bootstrap before self-management

Bootstrap establishes Flux without depending on Flux already running. The static installation
contains the namespace, CRDs, permissions, Services, and selected controller Deployments. Once
those controllers and APIs are available, a separate apply attaches the installation to its
declared OCI source.

| Stage | Required state | Current local operation |
| --- | --- | --- |
| Install controllers | The selected Flux installation resources exist in the cluster. | [`.mise/cluster/install-component.sh`](../../.mise/cluster/install-component.sh) (called by [`dev:create`](../../.mise/tasks/dev/create) and [`verify:run`](../../.mise/tasks/verify/run) after `.mise/cluster/cluster.sh create`) applies the locally rendered installation with server-side apply. |
| Establish readiness | Required CRDs and controllers are usable before Flux custom resources are applied. | `.mise/cluster/install-component.sh` waits for Flux CRDs (`app.kubernetes.io/part-of=flux`) to be `Established` and controller Deployments to be `Available`. |
| Declare self-management | A source selects the artifact and a Kustomization selects its installation content. | `.mise/cluster/install-component.sh` creates the local OCI source and applies the repo-local [`test/sync.yaml`](../../test/sync.yaml) fixture (`FLUX_SYNC_MANIFESTS`) after CRD and controller readiness and local publication. |
| Verify convergence | The declared artifact is acquired and its installation is healthy. | The development task waits for the source and Kustomization to report Ready. |

The local source uses the disposable cluster's registry and selected test tag. Production source
coordinates, credentials, and the selected release version belong to the consuming cluster
definition. Neither endpoint selection nor registry credentials are embedded in the reusable
controller installation.

Consuming repositories own both the `OCIRepository` and the self-management `Kustomization`
selecting `path: ./deploy` with pruning and health waiting enabled, as explained in the
[overview](00-overview.md#self-management-boundary) and documented in the
[user guide](../user-guide.md). This package does not ship a self-management manifest; its own
[`test/sync.yaml`](../../test/sync.yaml) fixture is used only by disposable `dev` and `verify`
clusters.

## Operation and recovery after the handoff

After self-management is established, Flux fetches the declared OCI artifact and reconciles its
controller installation. Upgrades change the selected version in the external cluster definition.
Bootstrap YAML is not the normal upgrade mechanism.

If Flux cannot reconcile itself, recovery reapplies the matching static installation and restores
the declared source and self-management configuration. Keeping bootstrap and OCI installation
content aligned prevents the handoff from introducing a separately constructed controller
installation. The [user guide](../user-guide.md) contains the current operator procedures.

## Verification scope and remaining publication work

[`verify:run`](../../.mise/tasks/verify/run) captures upstream, renders, and checks agreement with the
committed files before creating a disposable cluster with `.mise/cluster/cluster.sh` and installing into it
with `.mise/cluster/install-component.sh`. That flow creates
the cluster and registry, boots Flux, publishes locally, declares self-management, and waits for
Ready conditions. A successful run deletes the cluster; a failed cluster run preserves it for investigation.
The test establishes fresh installation and self-management on its selected Kubernetes runtime.
It does not exercise version upgrades, rollback, or recovery from a failed GitOps engine.

The current verification path checks Flux CRD `Established` status and controller availability
during bootstrap, and source and Kustomization readiness after the handoff. Package verification
does not cover every consuming repository's composition or integration with other components.

The publication contract still requires implementation and verification of:

- Refusing an existing production version before writing either distribution channel.
- Testing one packaged OCI artifact and promoting those exact bytes unchanged.
- Publishing matching installation YAML and verifying the published digest and metadata.
- Recovering from partial publication without changing an already published version.

Signing and provenance policy remain unsettled. These are requirements and open decisions for the
publication design; the current scripts do not provide them merely by attaching origin annotations.

## Why independent SemVer

Upstream software and Cur8s-maintained manifests, defaults, and integration choices evolve on
different schedules. A Cur8s-only manifest correction needs a new immutable release even when the
bundled upstream version has not changed, and capabilities must evolve independently without forcing
a shared repository-wide version number. Upstream-derived version schemes were evaluated and
rejected:

| Rejected scheme | Example | Why it fails |
| --- | --- | --- |
| Reuse upstream version | `2.7.0` | A Cur8s-only fix has no distinct version without overwriting an immutable release. |
| Fourth numeric component | `2.7.0.1` | Does not conform to SemVer's `MAJOR.MINOR.PATCH` structure. |
| SemVer build metadata | `2.7.0+r.1` | Build metadata does not affect SemVer precedence, and `+` is invalid in OCI tags. |
| Prerelease-style packaging suffix | `2.7.0-r.1`, `v2.9.0-2` | SemVer treats suffixes as prereleases sorting *before* the base version, and subordinates Cur8s' compatibility history to upstream's version. |

The trade-off is that a package version alone no longer reveals the bundled upstream version.
Cur8s accepts that cost by surfacing upstream provenance explicitly in `cur8s.yaml` and OCI
annotations, maintaining a compatibility contract per capability, and pinning exact tested
combinations in a separate platform BOM (whose canonical schema and repository location remain open
design work).
