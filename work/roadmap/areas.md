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
| Verification and upstream currency | Pins the Kubernetes test runtime, advances upstream Flux to the latest patch, and extends e2e verification beyond fresh install on top of the settled package contract and identity. |
| Release readiness | Hardens OCI packaging and publication before cutting 1.0 releases. |
| Documentation structure | The category directories, strategy, product and architecture documents, local development guide, and mise/bash standards already exist for earlier work to write into. The owner chose to finish the remaining operator how-tos and standards last, after verification and release procedures settle. |

## Verification and upstream currency

Make end-to-end verification deterministic on an explicit Kubernetes runtime, advance to the latest
Flux patch release, and cover self-managed upgrades and recovery.

**Work**

- [Pin the Kubernetes test runtime](../todo/4-pin-kubernetes-test-runtime/overview.md)
- [Bump Flux to the latest 2.9.x patch](../todo/5-bump-flux-to-latest-patch/overview.md)
- [Add upgrade and recovery verification](../todo/6-test-upgrades-and-recovery/overview.md)

**Why / what this unlocks**

Dependable verification coverage against a known Kubernetes N-1 runtime and proven upgrade/recovery
behavior before cutting 1.0 releases.

---

## Release readiness

Harden how releases are packaged, checked, and published. CI workflows
([finalize-ci-workflows](../parked/finalize-ci-workflows/overview.md)), mirrored runtime images
([mirror-images-to-ghcr](../parked/mirror-images-to-ghcr/overview.md)), and cross-repo patterns for
non-Flux components ([design-cross-repo-component-lifecycle](../parked/design-cross-repo-component-lifecycle/overview.md))
remain parked until prioritized.

**Work**

- [Harden OCI packaging and release publication](../todo/7-harden-release-publication/overview.md)

**Why / what this unlocks**

Immutable, reproducible, verified 1.0 releases.

---

## Documentation structure

Rebuild `docs/` as product, architecture, how-to, and standards directories, one reviewed document
at a time, capturing the pre-rendered-manifest philosophy in the product section.

**Work**

- [Rebuild the docs as product, architecture, how-to, and standards](../todo/8-rebuild-docs-by-category/overview.md)

**Why / what this unlocks**

Operator guides and standards that describe the settled conventions, package contract, and release
procedures rather than details about to change. The existing structure and strategy already give the
earlier areas a home for their documentation.
