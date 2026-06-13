# Flux — opinionated configuration

**Purpose:** GitOps continuous delivery. This is the foundation's only runtime
component and the engine every other layer depends on.

**Tracked version:** see [`VERSION`](VERSION) (mirrors the repo-root `VERSION`).
A new upstream Flux release becomes a new value here and a new published artifact.

**Controllers (opinionated set):**
- `source-controller` — fetches versioned artifacts (OCI, Git).
- `kustomize-controller` — applies fully-rendered static manifests.
- `notification-controller` — emits reconciliation events (observability only).

**Deliberately excluded:**
- `helm-controller` — would perform in-cluster templating (violates "render once,
  reconcile forever").
- `image-reflector` / `image-automation` — would let Flux *select* versions;
  version advancement here is always explicit and external.
- `source-watcher` — a sample/demo controller, not a production component. The
  ExternalArtifact *capability* is enabled via feature gate (below) without it.

**ExternalArtifact feature gate:** enabled on `kustomize-controller` via an
overlay patch (`--feature-gates=ExternalArtifact=true`). Per-version
qualification status:

- **v2.8.8 — qualified ✓** — kustomize-controller accepts the flag (pod healthy,
  0 restarts); `externalartifacts.source.toolkit.fluxcd.io` CRD is present;
  full e2e green (bootstrap → self-manage → self-upgrade).

**Bootstrap:** controllers come up on a bare cluster with zero pre-existing
secrets; images pulled from `ghcr.io` (no rate-limited registries, no
imagePullSecrets). See the bootstrap RFC.

**Resources:**
- https://fluxcd.io/flux/
- https://fluxcd.io/flux/components/
