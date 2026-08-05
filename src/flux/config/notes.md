# Flux — opinionated configuration

**Purpose:** GitOps continuous delivery. This is the engine every other
cur8s component depends on to reach the cluster.

**Tracked version:** see the repo-root [`version.env`](../../../version.env).
A new upstream Flux release changes `FLUX_VERSION`; an opinion-only release
increments `CUR8S_FLUX_REVISION`.

**Controllers (opinionated set):**
- `source-controller` — fetches versioned artifacts (OCI, Git).
- `kustomize-controller` — applies fully-rendered static manifests.
- `notification-controller` — emits reconciliation events (observability only).

**Deliberately excluded:**
- `helm-controller` — would perform in-cluster templating (violates "render once,
  reconcile forever").
- `image-reflector` / `image-automation` — would let Flux *select* versions;
  version advancement here is always explicit and external.
- `source-watcher` — a sample/demo controller, not a production component.

No feature gates: the install is exactly what `flux install --export`
produces for the three controllers. (An ExternalArtifact gate existed
through v2.8.8 for a since-deleted ArtifactGenerator experiment; the
platform consumes plain OCIRepositories, so it was dropped.)

**Bootstrap:** controllers come up on a bare cluster with zero pre-existing
secrets; images pulled from `ghcr.io` (no rate-limited registries, no
imagePullSecrets). See the bootstrap RFC.

**Resources:**
- https://fluxcd.io/flux/
- https://fluxcd.io/flux/components/
