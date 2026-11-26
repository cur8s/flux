---
title: "Mirror runtime images to ghcr.io/cur8s"
summary: "Discover upstream container image digests, mirror them byte-for-byte into ghcr.io/cur8s, and rewrite rendered manifests to pull from the mirror by digest; parked until prioritized."
---

# Mirror runtime images to ghcr.io/cur8s

**Pick up** when owned container images are prioritized (either as a 1.0 hardening pass or post-1.0). Today rendered manifests reference upstream `ghcr.io/fluxcd/*` images directly.

**Goal:** Every container image a component runs is pulled from `ghcr.io/cur8s` **by digest**, removing exposure to upstream tag mutation, deletion, and rate limits while preserving zero-secrets bootstrap (no `imagePullSecrets`) when the mirrored packages are public.

**Candidate approach (not yet tested):**

1. **Discover:** resolve every container image referenced by the rendered manifests to its upstream digest (candidate tool: `crane digest`, pinned via mise) and record the list alongside upstream provenance.
2. **Copy:** generate declarative config for [flux-mirror](https://fluxcd.io/flux/cli-plugins/flux-mirror/) (`v0.9.0`, `mirror.plugin.fluxcd.io/v1beta1`) to copy multi-arch image indexes byte-for-byte into `ghcr.io/cur8s` (with optional signature/SBOM referrers via `includeReferrers` and cosign verification).
3. **Rewrite:** rewrite image references at render time (for example via Kustomize `images:`) to `ghcr.io/cur8s/...@sha256:...` so `artifacts/rendered/` stays static and diffs show exact digests.

*Alternative compared:* Carvel `imgpkg` copies a bundle plus locked images in one step, but does not rewrite manifests, places all images in one repository by digest only, and its bundle format is not a Flux OCI artifact.

**Open questions / experiments:**

- **Lifecycle timing:** because rendered manifests reference the mirror, mirroring must happen before `verify:run` (or `verify:run` must test against a local mirror rewrite); decide which step owns remote registry write access without accidentally publishing unreleased versions.
- **Tool pinning:** how to pin `flux-mirror` within [Mise standard](../../../docs/standards/mise-standard.md) (`flux plugin install` sits outside `mise.lock`; a release binary via `github:` or digest-pinned container image may be pinnable).
- **Registry details:** destination naming scheme under `ghcr.io/cur8s`, ensuring new packages are public (and having `verify:run` fail on private ones), and whether Helm charts should be mirrored for later components. Experiment against a local k3d registry first; mirror to `ghcr.io` only when explicitly requested.
