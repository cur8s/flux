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

**Settled mise and bash conventions (completed 2026-11-26 — awaiting next target).** Every
mechanical aspect of how the repository uses mise and bash has an agreed convention, the repository
follows it, and the conventions are published in durable documentation.

- **Why:** each Cur8s component repository keeps its own copies of tiny task scripts; these
  conventions keep the copies consistent, and the lifecycle design is expressed in them.
- **Success:** met — [Mise standard](../../docs/standards/mise-standard.md) and
  [Bash script standard](../../docs/standards/bash-script-standard.md) are published, the repository
  conforms, and `bash -n`, `shellcheck`, and `mise run verify:run` pass. See
  [Journal](journal.md).

---

## Week 42: October 12–16, 2026

**Active work:** None — the mise and bash conventions todo is complete and removed; awaiting owner
selection of the next target and weekly contribution.

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
- 2026-11-26: Completed the mise and task-scripts review, applied all conventions, published
  [Mise standard](../../docs/standards/mise-standard.md) and
  [Bash script standard](../../docs/standards/bash-script-standard.md), drafted the closeout account
  in [Journal](journal.md), and removed `work/todo/standardize-mise-and-task-scripts/`.
- 2026-11-26: Completed capability naming (`gitops`), independent SemVer (`0.1.0`), GitHub repo
  rename (`cur8s/flux` → `cur8s/gitops`), and durable docs updates (including independent SemVer
  rationale in [Publication and self-management](../../docs/architecture/03-publication-and-self-management.md)),
  drafted the closeout account in [Journal](journal.md), and removed
  `work/todo/1-adopt-capability-naming-and-semver/`.
- 2026-11-26: Moved the self-management `Kustomization` out of `src/config/` and
  `artifacts/rendered/` into repo-local [`test/sync.yaml`](../../test/sync.yaml), added the
  explicit Flux CRD `Established` wait to `.mise/cluster/install-component.sh`, documented the
  copy-and-paste production bootstrap path in [User guide](../../docs/user-guide.md) and updated
  the architecture docs (`ce5a6c7`), drafted the closeout account in [Journal](journal.md), and
  removed `work/todo/2-move-self-management-to-consumer/`.
- 2026-11-26: Clarified the Notification Receiver contract in
  [The package's opinion](../../docs/product/02-the-opinion.md) and linked docs (`62b51b4`)—keeping
  the upstream `notification-controller` surface unmodified and contrasting opt-in webhook
  reconciliation of already-declared state with the excluded Image Reflector / Image Automation
  controllers—drafted the closeout account in [Journal](journal.md), and removed
  `work/todo/3-clarify-notification-receiver-contract/`.
- 2026-11-26: Pinned the local `dev`/`verify` Kubernetes runtime to `1.36.6` (current GA N-1,
  within Flux `v2.9.0`'s `1.34`–`1.36` range) via `KUBERNETES_VERSION` / `K3S_IMAGE` (`9999769`),
  added client/server version assertions in `.mise/cluster/cluster.sh` and `flux check --pre` in
  `.mise/cluster/install-component.sh`, simplified `mise.toml` (`UPSTREAM_SOURCE`, `COMPONENT_*`,
  `CUR8S_REGISTRY`, `FLUX_SYNC_PATH`, plain derived templates, single-sourced `[tools]` pins in
  `8932ce6`..`9f6bf53`), documented the compatibility contract and advance procedure (`8fed67b`),
  drafted the closeout account in [Journal](journal.md), and removed
  `work/todo/4-pin-kubernetes-test-runtime/`.

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

- The remaining docs rebuild (operator how-tos, standards, finish) comes last in [Areas](areas.md);
  resume it once the package contract, verification, and release procedures settle.
