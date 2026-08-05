---
title: "Harden release publication"
summary: "Protect immutable versions and make OCI and GitHub release publication safe to verify, retry, and recover when only one channel succeeds."
---

# Harden release publication

The release workflow currently pushes the OCI artifact before it creates the GitHub release. It
does not preflight both destinations for an existing version, so a repeated or recreated tag could
attempt to mutate a published OCI tag or leave the two release channels partially published.

Explore preflight checks that reject an already-published component version, a publication order
that minimizes partial releases, and post-publish verification of artifact contents, annotations,
digest, and release asset. Define idempotent retry behavior and an explicit recovery procedure for
the case where one channel succeeds and the other fails. This design should follow the build-up
versioning work so every check uses the final component-version source of truth.
