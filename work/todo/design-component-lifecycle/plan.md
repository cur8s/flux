# Plan: Design the component lifecycle

## Context

### Outcome

The owner has agreed the lifecycle's goals and invariants and chosen a design after comparing
candidates and trying them in disposable experiments. The design, the alternatives considered,
and the experiment evidence are recorded, and durable documentation describing the lifecycle is
committed. The todo ends with that documentation; implementation is planned by
[Plan the lifecycle implementation](../plan-lifecycle-implementation/overview.md), which also takes [requirements](requirements.md) as input. Nothing in the repository's
tasks, CI, or artifacts changes as part of this todo.

### Approach

Interactive design with the owner, one step at a time, stopping for discussion at each step.
Record decisions, rejected alternatives, and evidence in a `working-notes.md` in this todo,
distinguishing owner decisions from proposals and observations.

Use the monorepo at `~/dev/cur8s/monorepo-cur8s` as a reference for needs, not as a design to
port: its layer model is superseded by one independent repository per component, and a platform
repository composing them. Account for components unlike Flux — cert-manager fetches a Helm chart
and remote files, renders several Kustomizations, and depends on a published Flux.

Experiments are disposable: scratch directories, throwaway k3d clusters, and local registries
only. Nothing is pushed to `ghcr.io` unless the owner explicitly requests it. Any mise mechanics
follow the conventions settled by
[`standardize-mise-and-task-scripts`](../standardize-mise-and-task-scripts/overview.md).

## Phases

### Phase 1: Goals and invariants

An agreed, written statement of what the lifecycle must achieve and what must always hold.

- [ ] Review the monorepo's lifecycle (Make targets, `scripts/`, component Makefiles) and the needs
  of a Helm-based component such as cert-manager; summarize the needs in `working-notes.md`.
- [ ] Draft goals and invariants from the owner-stated list in the overview, the
  [requirements](requirements.md), and the monorepo review.
- [ ] **Stop for owner discussion**; revise until agreed.

### Phase 2: Candidate designs

Several candidate lifecycles, each assessed against the agreed goals and invariants.

- [ ] Describe candidate designs, including the [six chained phases](candidate-six-phases.md) and
  at least one structurally different alternative. Each candidate states its directory layout:
  which step reads and writes which directory (today `src/<component>/`, `oci/<component>/`,
  `.mise/`; candidates may add `dist/`), and what is committed versus ignored.
- [ ] Identify which questions only an experiment can answer.
- [ ] **Stop for owner discussion**; agree which candidates and experiments to pursue.

### Phase 3: Experiments

Evidence for the questions that decide between candidates.

- [ ] Run the agreed experiments; candidates include local packaging (tool, reproducible digest,
  Flux media types), owned images (flux-mirror plus render-time rewrite against a local registry),
  and image-digest resolution for traceable fetching.
- [ ] Record results and their effect on each candidate in `working-notes.md`.
- [ ] **Stop for owner review** of the evidence.

### Phase 4: Decide and document

- [ ] Agree the design, including its directory layout, with the owner, recording the
  alternatives considered and why they lost.
- [ ] Decide with the owner which durable documents describe the lifecycle and where they live;
  write each, review it with the owner, and commit it on its own.
- [ ] Hand off to [Plan the lifecycle implementation](../plan-lifecycle-implementation/overview.md):
  move [requirements](requirements.md), and any working notes still needed for implementation,
  into that todo, then remove this todo.
