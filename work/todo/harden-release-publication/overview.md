---
title: "Harden release publication"
summary: "Make the publish phase safe to run from a laptop or GitHub: never overwrite an immutable version, verify what was published, and recover cleanly when only one release channel succeeds."
---

# Harden release publication

Nothing has been published yet. A release has two channels: the OCI artifact at
`ghcr.io/cur8s/flux:<version>` and the rendered manifest as the GitHub release asset
`install.yaml`. Under the lifecycle model, `publish` copies the already packaged and e2e-tested
artifact rather than rebuilding it (see
[`package-oci-artifact-locally`](../package-oci-artifact-locally/overview.md)), and it must work
the same from a maintainer's laptop or GitHub Actions.

What remains to harden:

- **Immutability preflight:** refuse to publish if the version already exists in either
  channel, before writing anything.
- **Partial success:** define publication order, idempotent retry, and an explicit recovery
  procedure when one channel succeeds and the other fails, without retagging.
- **Post-publish verification:** confirm the published OCI digest equals the tested `dist/`
  digest, the annotations are present, and `install.yaml` matches `oci/flux/deploy/flux.yaml`.
- **CI safety:** per-version concurrency that never cancels an in-progress publication, and
  third-party actions pinned to immutable revisions. The tag check in `release.yml` must keep
  matching the version mise derives.
- **Signing and provenance:** decide whether cosign signing (and attestations) belongs in the
  first hardened release or a follow-up.

Publication stays an explicit, reviewed action: never merge, retag, or advance versions
automatically.
