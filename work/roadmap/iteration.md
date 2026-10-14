# Iteration

## Purpose

This document owns the active target and selects the current contribution toward it. It records
the current week, a provisional next week, demo constraints, and deferred questions about what
comes next. [Areas](areas.md) holds the broader work and its preferred order; detailed execution
belongs in individual todos; [Journal](journal.md) preserves completed accounts.

## Format

**Target** states the outcome we want to reach, why it matters, and how we will recognize success.
Weekly entries use ISO week numbers and readable date ranges, current week first, followed by at
most one provisional next week. **Active work** sits directly beneath the current week's heading
and is the single source of truth for what we are doing now. Each weekly entry contains
**Success**, **Plan**, **Demo**, and **Notes**. **Later / unresolved** holds deferred work and
open questions about what comes next. Horizontal rules separate the sections.

---

## Target

**Settled mise and bash conventions.** Every mechanical aspect of how the repository uses mise and
bash has an agreed convention, the repository follows it, and the conventions are published in
durable documentation.

- **Why:** each Cur8s component repository keeps its own copies of tiny task scripts; these
  conventions keep the copies consistent, and the lifecycle design is expressed in them.
- **Success:** the outcome of
  [Review and standardize the mise configuration and task scripts](../todo/standardize-mise-and-task-scripts/overview.md)
  is met, and the drift and e2e gates pass.

---

## Week 42: October 12–16, 2026

**Active work:** [Review and standardize the mise configuration and task scripts](../todo/standardize-mise-and-task-scripts/overview.md),
starting with the Phase 1 inventory.

**Success:** `working-notes.md` holds the inventory of mise features and script patterns, and the
owner has agreed the topic order for the review rounds.

**Plan:**

- Inventory mise usage and recurring script patterns; note the installed mise version (2026.10.8).
- Review the inventory and topic order with the owner.
- Begin the first review round if time allows.

**Demo:** Not set.

**Notes:**

- 2026-10-14: The owner moved the docs rebuild to last in [Areas](areas.md) and selected the mise
  and script conventions as the next work.

---

## Week 43: October 19–23, 2026 (provisional)

**Active work:** To be selected.

**Success:** To be agreed; likely further review rounds.

**Plan:**

- Continue the review rounds in the agreed topic order.

**Demo:** Not set.

**Notes:**

---

## Later / unresolved

- The remaining docs rebuild (operator how-tos, standards, finish) now comes after implementation
  planning; resume it once the conventions and lifecycle it describes are settled.
