# Requirements folded into the lifecycle design

These were separate todos (`record-fetched-sources`, `package-oci-artifact-locally`,
`harden-release-publication`, `mirror-images-to-ghcr`) until they were recognized as requirements
the lifecycle must satisfy. Each section keeps the requirement, its open design questions
(candidate experiments), and the implementation detail that follow-up todos will need. Their
original notes are in Git history before the commit that folded them in.

The [layout decision](working-notes.md) is implemented: captured input is outside disposable
output, renders are committed under `artifacts/rendered/`, and `artifacts/oci/` is the reserved
ignored destination for future local packaging. These lifecycle requirements remain unfinished;
reserving a path does not implement packaging, provenance records, or tested-digest promotion.

## Traceable fetching

**Requirement:** for any version it must be clear exactly what was downloaded from upstream.

- The previous `FETCH.lock` was removed in `2575527` because, for Flux alone, its fields repeated
  the tool pin and Git. As a cross-repository convention a record earns its place anyway:
  cert-manager and later components download Helm charts and release files from remote
  registries, where a digest is the only evidence an input did not change.
- One small, uniform record, written when fetching, listing each input's source, version, and
  digest (name and format open; `upstream/FETCH.lock` is a candidate alongside the captured inputs).
  For Flux: the pinned CLI version and the generated manifest's digest.
- Include the container images the rendered manifests reference, each with its upstream digest.
  This answers "what will this version run?" and is the input list for owned images.
- A check fails if the committed record differs from a fresh fetch.
- Keep the release descriptor (`cur8s.yaml`) and the record distinct: the descriptor states
  identity, the record states provenance.

**Open questions / experiments:** which tool resolves image digests (for example `crane digest`)
and how it is pinned.

## Tested artifact is the published artifact

**Requirement:** the OCI artifact is built once, locally, and those exact bytes are tested and
published. Today e2e pushes one artifact to the dev registry and release pushes a separately
built one, so the published digest is never the tested one.

- Write the artifact to a git-ignored `artifacts/oci/` (an OCI image layout or equivalent) and record its
  digest. E2e copies it into the throwaway cluster's registry; publishing copies the same artifact
  to `ghcr.io/cur8s/<component>:<version>`.
- Keep OCI metadata in one place: whatever builds the artifact owns the annotations
  `oci:publish` attaches today (`cur8s.io/*`, source, revision).

**Open questions / experiments** (local registries only):

- Which pinned tool builds an on-disk layout and copies it to a registry without re-encoding
  (`oras` is the likely candidate; the `flux` CLI pushes straight to a registry).
- Whether the artifact keeps the media types `flux push artifact` produces, so `OCIRepository`
  accepts it without a `layerSelector`. Inspect today's pushed manifest, config, and layer media
  types and annotations first.
- Whether packaging the same `artifacts/rendered/` tree twice yields the same digest; fix inputs (fixed
  timestamps, sorted tar) rather than accept a changing digest.
- Copy a packaged layout into a k3d registry and confirm Flux fetches it and self-management
  becomes Ready.

## Safe publication

**Requirement:** publishing never overwrites an immutable version, verifies what it published,
and recovers cleanly when only one channel succeeds. A release has two channels: the OCI artifact
at `ghcr.io/cur8s/flux:<version>` and the rendered manifest as the GitHub release asset
`install.yaml`. Publication stays an explicit, reviewed action: never merge, retag, or advance
versions automatically.

Implementation detail for follow-up:

- **Immutability preflight:** refuse to publish if the version exists in either channel, before
  writing anything.
- **Partial success:** publication order, idempotent retry, and an explicit recovery procedure
  when one channel succeeds and the other fails, without retagging.
- **Post-publish verification:** the published OCI digest equals the tested local `artifacts/oci/` digest, the
  annotations are present, and `install.yaml` matches `artifacts/rendered/deploy/flux.yaml`.
- **CI safety:** per-version concurrency that never cancels an in-progress publication;
  third-party actions pinned to immutable revisions; the tag check in `release.yml` keeps matching
  the version mise derives.
- **Signing and provenance:** decide whether cosign signing and attestations belong in the first
  hardened release or a follow-up.

## Owned images

**Requirement:** every image a component runs is pulled from `ghcr.io/cur8s`, by digest. One
registry under project control removes exposure to upstream tag mutation, deletion, and rate
limits, and keeps the zero-secrets bootstrap contract (no `imagePullSecrets`) if the mirrored
packages are public.

- [flux-mirror](https://fluxcd.io/flux/cli-plugins/flux-mirror/) (v0.9.0, config
  `mirror.plugin.fluxcd.io/v1beta1`) is the candidate copier: declarative config, byte-for-byte
  copies including multi-arch indexes, idempotent digest comparison with drift exit codes,
  optional copying of signatures and SBOMs (`includeReferrers`), and optional cosign verification
  before mirroring. It does not discover images inside charts or manifests and does not rewrite
  references.
- So the work splits in three: **discover** (the image list from traceable fetching), **copy**
  (generate the flux-mirror config from that list and mirror exactly those versions), and
  **rewrite** (at render time, point each image reference at its `ghcr.io/cur8s/...@sha256:` copy,
  for example with kustomize `images:`, keeping manifests static). The committed `artifacts/rendered/` diff then
  shows which images, by digest, each version runs.
- **Lifecycle consequence:** because rendered manifests reference the mirror, mirroring must
  happen before e2e, not at publish; mirroring by digest early publishes nothing whose meaning can
  change. The design must decide which step owns registry write access.
- imgpkg (Carvel) was compared: it copies a bundle plus its locked images in one step and writes a
  relocated lock, but also does not rewrite manifests, lands all images in one repository by
  digest only, and its bundles are not a Flux artifact format.

**Open questions / experiments:** how to pin flux-mirror (the `flux plugin install` path is
outside `mise.lock`; its container image or a release binary may be pinnable); the destination
naming scheme under `ghcr.io/cur8s`; making each new package public and having e2e fail on a
private one; whether to mirror Helm charts too (not needed for Flux). Experiment against a local
k3d registry first; mirror to ghcr only when explicitly requested.
