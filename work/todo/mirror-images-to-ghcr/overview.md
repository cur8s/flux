---
title: "Mirror component images to ghcr.io/cur8s"
summary: "Copy every container image a component runs into the cur8s GitHub org and pin the rendered manifests to those copies by digest."
---

# Mirror component images to ghcr.io/cur8s

Goal: every image a Cur8s component runs is pulled from `ghcr.io/cur8s`, by digest. One registry
under project control removes exposure to upstream tag mutation, deletion, and rate limits, and
keeps the zero-secrets bootstrap contract (no `imagePullSecrets`) if the mirrored packages are
public.

The [flux-mirror](https://fluxcd.io/flux/cli-plugins/flux-mirror/) plugin (v0.9.0, config
`mirror.plugin.fluxcd.io/v1beta1`) is the candidate copier: declarative config, byte-for-byte
copies including multi-arch indexes, idempotent digest comparison with drift exit codes, optional
copying of signatures and SBOMs (`includeReferrers`), and optional cosign verification before
mirroring. It does not discover the images inside charts or manifests and does not rewrite
references, so the work splits in three:

1. **Discover** — the image list with digests comes from
   [`record-fetched-sources`](../record-fetched-sources/overview.md).
2. **Copy** — generate the flux-mirror config from that list and mirror exactly those versions.
3. **Rewrite** — at render time, point each image reference at its `ghcr.io/cur8s/...@sha256:`
   copy (for example with kustomize `images:`), keeping manifests static per the render-once
   rule. The committed `oci/` diff then shows which images, by digest, each version runs.

Because the rendered manifests reference the mirror, mirroring must happen before `e2e`, not at
`publish`; mirroring by digest early publishes nothing whose meaning can change. That makes the
phase needing ghcr write access earlier than `publish` — decide which phase owns it.

Open questions: how to pin flux-mirror itself (the `flux plugin install` path is outside
`mise.lock`; the container image or a release binary may be pinnable); the destination naming
scheme under `ghcr.io/cur8s`; making each new package public and having `e2e` fail on a private
one; and whether to mirror Helm charts too (not needed for Flux). Experiment against a local k3d
registry first; mirror to ghcr only when explicitly requested.
