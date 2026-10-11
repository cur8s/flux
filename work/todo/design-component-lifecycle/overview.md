---
title: "Design the component lifecycle"
summary: "Identify the goals and invariants of a Cur8s component's build-to-publish lifecycle, try candidate designs in disposable experiments, and document the chosen design."
---

# Design the component lifecycle

**Agreed with the owner:**

- This is an interactive design session focused on the problem: consider different approaches,
  try them out to see how they work, then choose.
- The first step is to identify clearly the lifecycle's goals and its invariants, before any
  approach is chosen.
- The todo is **document only**. It ends with agreed goals and invariants, the chosen design with
  the alternatives considered, evidence from the experiments, and durable documentation.
  Implementation is planned afterwards by [Plan the lifecycle implementation](../plan-lifecycle-implementation/overview.md).
- The monorepo at `~/dev/cur8s/monorepo-cur8s` is a reference for what the needs are — its Make
  targets and scripts show what a component build actually did. Its files are referenced, not
  copied here.
- Requirements already identified are folded into this todo rather than kept as separate todos:
  traceable fetching, a locally packaged artifact that is the one tested and published, safe
  publication, and owned images. They are preserved in [requirements](requirements.md).
- The owner has since advanced the design into a [proposal](proposal.md), recorded unedited. It
  is the current direction: architectural invariants, the namespaces `upstream`, `build`,
  `cluster`, and `flux` with per-task contracts and status, installation stages `crds`, `deploy`,
  and `post-install`, the intended local lifecycle, and the open decisions it says must not be
  resolved silently. Continue from those open decisions.
- The earlier six-phase proposal, top-level Maven-style phases rather than namespaces, is kept as
  an alternative considered in [candidate: six chained phases](candidate-six-phases.md).

**Differences to reconcile** between the proposal, the other todos, and the repository today —
to resolve with the owner, not by assumption:

- Section 9 (migration sequence and acceptance criteria) is implementation guidance; this todo is
  document only, so it belongs with
  [Plan the lifecycle implementation](../plan-lifecycle-implementation/overview.md).
- The migration steps and acceptance criteria update CI workflows, but CI is parked in
  [`finalize-ci-workflows`](../../parked/finalize-ci-workflows/overview.md) and `.github/` was
  moved out of the repository.
- Section 8's script style and task composition guidance (about 15 lines, compose with mise
  dependencies) overlaps the mise conventions todo, which owns all aspects of mise and the task
  scripts.
- Section 8 assumes `curl` and `jq` "per documented prerequisites", but the root `README.md`
  lists only mise and Docker; decide whether such tools are mise-managed or assumed.

**Goals and invariants the owner stated while planning** — inputs to the first step, to confirm
or revise there:

- Task names are consistent across component repositories while each repository keeps freedom in
  how it implements a step, in the spirit of the Maven lifecycle.
- What was downloaded from upstream is captured in the repository so it is clear what it is.
- The OCI artifact can be built and kept locally — not committed, not published — and tested
  there; publishing is a separate later step.
- Every component produces an OCI artifact.
- Publishing works the same from a laptop or GitHub Actions, because the tooling is pinned and the
  tests are self-contained.
- Scripts stay tiny and obvious.
- The directory layout is part of the design: each lifecycle step defines the directories it reads
  and writes, the layout is consistent across component repositories, and each directory's purpose
  is obvious. Each major directory explains itself in its own README rather than through a central
  layout description.

The mise mechanics any design uses follow
[`standardize-mise-and-task-scripts`](../standardize-mise-and-task-scripts/overview.md), which
comes first.
