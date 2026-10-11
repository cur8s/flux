---
title: "Design the component lifecycle"
summary: "Identify the goals and invariants of a Cur8s component's build-to-publish lifecycle, try candidate designs in disposable experiments, and document the chosen design for follow-up implementation."
---

# Design the component lifecycle

**Agreed with the owner:**

- This is an interactive design session focused on the problem: consider different approaches,
  try them out to see how they work, then choose.
- The first step is to identify clearly the lifecycle's goals and its invariants, before any
  approach is chosen.
- The todo is **document only**. It ends with agreed goals and invariants, the chosen design with
  the alternatives considered, evidence from the experiments, and durable documentation.
  Implementation happens in follow-up todos written from the design.
- The monorepo at `~/dev/cur8s/monorepo-cur8s` is a reference for what the needs are — its Make
  targets and scripts show what a component build actually did. Its files are referenced, not
  copied here.
- Requirements already identified are folded into this todo rather than kept as separate todos:
  traceable fetching, a locally packaged artifact that is the one tested and published, safe
  publication, and owned images. They are preserved in [requirements](requirements.md).
- The earlier six-phase proposal is one candidate design, preserved in
  [candidate: six chained phases](candidate-six-phases.md).

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

The mise mechanics any design uses follow
[`standardize-mise-and-task-scripts`](../standardize-mise-and-task-scripts/overview.md), which
comes first.
