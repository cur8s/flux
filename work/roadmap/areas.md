# Areas

## Purpose

This document groups related areas of work and explains their scope, value, and relationships.
The areas appear in the order we would naturally approach them without iteration pressure.
Their scope and order evolve as we investigate, build, and learn.

## Format

**Order and rationale** explains the sequence in a table. Each area follows with a short
introduction, **Work** bullets, and **Why / what this unlocks**. Horizontal rules separate the areas.

[Iteration](iteration.md) owns the active target, selects the weekly contribution, and records
demo constraints, including any departures from the preferred order. Detailed execution belongs
in individual todos. [Working philosophy](../working-philosophy.md) explains our approach to
depth-first and breadth-first work.

---

**Order and rationale**

| Work area | Rationale |
| --- | --- |
| Build lifecycle | Every other area uses the phase names, the fetch record, or the packaged artifact, so they come first. |
| Publication | Publishing needs the packaged artifact to exist; mirroring needs the fetch record's image list. |
| Test fidelity | Pinning the runtime is independent but makes every later e2e result meaningful; upgrade tests need published versions to move between. |
| Consumer contract | Others can only rely on the artifact once it is genuinely published; the bootstrap path documents what publication produces. |
| Maintenance | Independent of the rest and small; it can be taken whenever attention allows, and is easier once the pipeline settles. |

## Build lifecycle

Make every Cur8s component repository run the same fixed, chained phases — `fetch`, `render`,
`package`, `check`, `e2e`, `publish` — with tiny, obvious scripts behind them, so the same command
means the same thing everywhere.

**Work**

- [Adopt standard lifecycle phases](../todo/adopt-lifecycle-phases/overview.md): rename the tasks
  into chained top-level phases and settle the `--cluster` convention.
- [Record fetched sources](../todo/record-fetched-sources/overview.md): a committed provenance
  record of every upstream input and container image, by digest.
- [Package the OCI artifact locally](../todo/package-oci-artifact-locally/overview.md): build once
  into `dist/` so the tested digest is the published digest; starts with a tooling experiment.

**Why / what this unlocks**

The phase names are the cross-repository contract the cert-manager repository and later components
copy. Packaging once turns "no version is published without a green e2e" from a CI convention into
a property of the bytes.

---

## Publication

Ship the tested artifact safely and make every image it runs come from `ghcr.io/cur8s`.

**Work**

- [Harden release publication](../todo/harden-release-publication/overview.md): immutability
  preflight, partial-success recovery, digest verification, CI safety, signing decision.
- [Mirror component images to ghcr.io/cur8s](../todo/mirror-images-to-ghcr/overview.md):
  flux-mirror as the copier, render-time digest rewrite, public packages. Unsettled: which phase
  owns ghcr write access, since mirroring must precede `e2e`.

**Why / what this unlocks**

A first real release, and a bootstrap that depends on no registry outside project control.

---

## Test fidelity

Make the e2e gate test a known Kubernetes runtime and, later, the transitions users actually go
through.

**Work**

- [Pin the Kubernetes test runtime](../todo/pin-kubernetes-test-runtime/overview.md): one
  `KUBERNETES_VERSION` drives the k3s image and kubectl; decisions agreed, wiring outstanding.
- [Test upgrades and recovery](../todo/test-upgrades-and-recovery/overview.md): reapply, revision
  and upstream upgrades, and recovery; rollback policy undecided.

**Why / what this unlocks**

A passing e2e that means the same thing on every machine and over time, and confidence that
self-managed upgrades work rather than only fresh installs.

---

## Consumer contract

Make the published artifact something others can adopt: a clear bootstrap path, an accurate
description of what is installed, and explicit terms of use.

**Work**

- [Complete the production bootstrap path](../todo/complete-production-bootstrap/overview.md):
  copy-and-paste path from `install.yaml` to OCI-backed self-management.
- [Clarify the Notification Receiver contract](../todo/clarify-notification-receiver-contract/overview.md):
  reconcile the informational-only guidance with the installed `Receiver` surface.
- [Define licensing and security policy](../todo/define-licensing-and-security-policy/overview.md):
  license and vulnerability-reporting path; can move earlier whenever external use is imminent.

**Why / what this unlocks**

The repository's purpose: others can bootstrap Flux from the opinionated manifest with confidence.

---

## Maintenance

Keep the tracked upstream current.

**Work**

- [Bump Flux to the latest patch](../todo/bump-flux-to-latest-patch/overview.md): v2.9.0 to the
  newest 2.9.x.
- Idea: [Automate upstream Flux update proposals](../ideas/automate-upstream-update-proposals/overview.md).

**Why / what this unlocks**

Security and bug fixes reach the artifact without the update itself becoming a project.
