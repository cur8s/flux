---
title: "Finalize the CI workflows"
summary: "Settle the GitHub Actions workflows that gate pull requests and publish releases; parked as a work in progress until the other work toward 1.0 is done."
---

# Finalize the CI workflows

**Pick up** after the focused implementation todos toward 1.0 are complete. The owner intends this
to be one of the last things done before 1.0, and parked it because working on CI now is a
distraction.

The workflows were a work in progress, not a finished design. They were moved out of the live
`.github/` directory into [sources](sources/.github/workflows/) so they do not distract coding
agents or the owner, which means the repository currently has no CI and the gates run locally.
Restoring them is part of this work:

- `ci.yml` runs the drift and e2e gates (`mise run verify:run`) on pushes to `main` and on pull
  requests.
- `release.yml` runs on a release tag: checks the tag matches `CUR8S_VERSION`, runs verification,
  logs in to `ghcr.io`, publishes the OCI artifact, and creates the GitHub release with
  `install.yaml`.

The preserved workflow sources retain historical task and path examples. On resumption, adapt
callers to the current task interface (`upstream:*`, `build:*`, `dev:*`, `verify:*`, `release:*`)
and implemented layout: captured `upstream/flux.yaml`, authored `src/config/`, and committed
`artifacts/rendered/`.

When picking this up, also incorporate the CI concerns recorded elsewhere:

- **CI release safety:** per-version concurrency that never cancels an in-progress publication;
  third-party GitHub Actions pinned to immutable commit SHAs; tag check in `release.yml` matching
  `CUR8S_VERSION` in `mise.toml`; and alignment with whatever publication safeguards land in
  [Harden OCI packaging and release publication](../../todo/harden-release-publication/overview.md)
  (immutability preflight, partial-success recovery, post-publish verification, and signing).
- **Mise in GitHub Actions:** action pinning, caching, and locked installs following
  [Mise standard](../../../docs/standards/mise-standard.md).
- **CI runner architecture:** running the pinned Kubernetes test runtime from
  [Pin the Kubernetes test runtime](../../todo/pin-kubernetes-test-runtime/overview.md) on CI's
  `linux/amd64` runners.
