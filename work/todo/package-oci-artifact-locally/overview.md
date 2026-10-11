---
title: "Package the OCI artifact locally"
summary: "Build the OCI artifact once into a git-ignored dist/ so e2e tests, and publish ships, exactly the same bytes and digest."
---

# Package the OCI artifact locally

Today `e2e` pushes one artifact to the dev registry and the release task pushes a separately built
one to ghcr, so the published digest is never the one that was tested. Every Cur8s component must
produce an OCI artifact; producing it once, on disk, and moving those exact bytes fixes this.

The `package` phase writes the artifact to a git-ignored `dist/` (an OCI image layout or
equivalent) and records its digest. `e2e` copies it into the throwaway cluster's registry;
`publish` copies the same artifact to `ghcr.io/cur8s/<component>:<version>`. Publishing works
identically from a laptop or GitHub Actions because every tool is pinned and the tests are
self-contained.

The open questions are tooling ones and need an experiment before committing to a design:

- which pinned tool builds a local layout and copies it unchanged (`oras` is the likely
  candidate; the `flux` CLI pushes straight to a registry);
- whether the artifact keeps Flux's media types so `OCIRepository` accepts it unchanged;
- whether packaging the same `oci/` tree twice yields the same digest, and what to do about any
  timestamp or annotation that breaks that;
- where the `cur8s.io/*` and source/revision annotations attach, since `artifact:push` is
  currently the single insertion point for OCI metadata.

Builds on [`adopt-lifecycle-phases`](../adopt-lifecycle-phases/overview.md). Reshapes
[`harden-release-publication`](../harden-release-publication/overview.md), which assumes this
packaging model.
