---
title: "Harden release publication"
summary: "Protect immutable versions and make OCI and GitHub release publication safe to verify, retry, and recover when only one channel succeeds."
---

# Harden release publication

The repository has not published a version yet. Its release workflow currently pushes the OCI
artifact before creating the GitHub release and does not preflight either destination for an
existing version. A repeated or recreated tag could therefore attempt to replace an immutable OCI
tag or leave only one release channel published.

Add preflight checks for both destinations, per-version concurrency that never cancels an active
publication, and post-publish verification of the OCI digest, annotations, and `install.yaml`
contents. Define publication order, idempotent retry behavior, and an explicit recovery procedure
for partial success without weakening tag immutability.

Run `mise run test:version` in CI and pin third-party workflow actions to immutable revisions.
Decide whether signing and provenance belong in the first hardened release or in separately scoped
follow-up work. Publication must remain an explicit reviewed action and must never merge, retag, or
advance versions automatically.
