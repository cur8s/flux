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
Start from the owner's [lifecycle proposal](proposal.md),
[versioning proposal](versioning-proposal.md), and
[Flux bootstrap proposal](flux-bootstrap-proposal.md): they are the current direction, and their open
decisions are the design work that remains.
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
- [ ] Draft goals and invariants from the owner-stated list in the overview, the architectural
  invariants in the [lifecycle proposal](proposal.md), the publication invariants in the
  [versioning proposal](versioning-proposal.md), the
  [requirements](requirements.md), and the monorepo review.
- [ ] **Stop for owner discussion**; revise until agreed.

### Phase 2: Complete the design

The namespaced design completed and assessed against the agreed goals and invariants, with the
six-phase alternative compared.

- [ ] Continue the namespaced design from the [lifecycle proposal](proposal.md): settle its open
  decisions (`flux:reconcile` targeting, `test`, local packaging, and `publish`), and resolve the
  differences listed in the overview.
- [ ] Settle versioning from the [versioning proposal](versioning-proposal.md): its open
  implementation details (upstream metadata schema, tag and OCI repository layout, reproducibility
  test, signing and provenance, upgrade and rollback), and how the repository's current
  upstream-derived version moves to it.
- [ ] Settle bootstrap from the [Flux bootstrap proposal](flux-bootstrap-proposal.md): which
  controllers the package installs, how `flux:boot` and the end-to-end test supply consumer-owned
  self-management resources, and the readiness check between the two applies. Keep the [six chained phases](candidate-six-phases.md) as the alternative
  it is compared against. The design states its directory layout:
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
  move [requirements](requirements.md), the [lifecycle proposal](proposal.md)'s implementation guidance
  (section 9: migration sequence and acceptance criteria), and any working notes still needed for
  implementation, into that todo, then remove this todo.
