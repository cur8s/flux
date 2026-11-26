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
| Component lifecycle design | Decides what every component repository does and guarantees; it builds on the published docs structure and mise/bash standards. |
| Implementation planning | Implementation can only be planned against a documented lifecycle; it gathers all remaining known work into the new sequence. |
| Documentation structure | The category directories, strategy, product and architecture documents, local development guide, and mise/bash standards already exist for earlier work to write into. The owner chose to finish the rest last: the remaining operator how-tos and standards describe procedures that the lifecycle design and implementation planning are likely to change. |

## Component lifecycle design

Identify the goals and invariants of a component's lifecycle, try candidate designs in disposable
experiments, and document the chosen design. Traceable fetching, tested-equals-published
packaging, safe publication, and owned images are folded in as requirements.

**Work**

- [Design the component lifecycle](../todo/design-component-lifecycle/overview.md)

**Why / what this unlocks**

The cross-repository contract that the cert-manager repository and later components follow.

---

## Implementation planning

Turn the documented lifecycle, its requirements, and every other piece of known work into a new
ordered sequence of implementation todos.

**Work**

- [Plan the lifecycle implementation](../todo/plan-lifecycle-implementation/overview.md): folds in
  Kubernetes test-runtime pinning, the Flux patch bump, the production bootstrap path, the
  Notification Receiver contract, upgrade and recovery testing, licensing and security policy, and
  the automated upstream-update-proposals idea.

**Why / what this unlocks**

The path to 1.0, planned from settled conventions and design rather than from older notes.

---

## Documentation structure

Rebuild `docs/` as product, architecture, how-to, and standards directories, one reviewed document
at a time, capturing the pre-rendered-manifest philosophy in the product section.

**Work**

- [Rebuild the docs as product, architecture, how-to, and standards](../todo/rebuild-docs-by-category/overview.md)

**Why / what this unlocks**

Operator guides and standards that describe the settled conventions and lifecycle rather than
procedures about to change. The existing structure and strategy already give the earlier areas a
home for their documentation.
