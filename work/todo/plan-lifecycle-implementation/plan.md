# Plan: Plan the lifecycle implementation

## Context

### Outcome

A new, ordered sequence of implementation todos exists, agreed with the owner, that implements the
documented lifecycle and carries every input from [inputs](inputs.md) and the design todo's
[requirements](../design-component-lifecycle/requirements.md) — each either placed in a todo,
deliberately deferred to an idea or parked note, or explicitly dropped. The roadmap's Areas
reflect the new sequence. This todo and its supporting files are then removed.

### Approach

Start only after the lifecycle documentation from
[Design the component lifecycle](../design-component-lifecycle/overview.md) is committed; that
documentation, not this todo's inputs, is the authority on how the lifecycle works. Plan
interactively with the owner, stopping at each step. Keep decisions in a `working-notes.md` in this
todo. Write each new todo following the work README's naming and template rules; do not begin
implementation.

## Current baseline

The owner separately authorized and implemented the repository layout. Inventory remaining
work from `upstream/`, `src/config/`, and `artifacts/rendered/`; do not plan the old path migration
again. Ignored `artifacts/oci/` reserves the future packaging destination only. Include packaging,
reproducibility, digest promotion, sync ownership, and versioning as unfinished lifecycle work.

## Phases

### Phase 1: Inventory

- [ ] Read the committed lifecycle documentation, [inputs](inputs.md), and the design todo's
  [requirements](../design-component-lifecycle/requirements.md); list every distinct piece of
  work they imply, noting dependencies and decisions already made.
- [ ] **Stop for owner discussion** of the list.

### Phase 2: Shape and order the work

- [ ] With the owner, group the work into implementation todos, decide each one's scope, and
  agree their order and the reasoning behind it.
- [ ] Decide the fate of anything not scheduled: an idea, a parked note, or dropped.

### Phase 3: Write the sequence

- [ ] Create each implementation todo, carrying over the relevant input material and plans
  (including the preserved Kubernetes pinning plan), and review the set with the owner.
- [ ] Rewrite the roadmap's Areas around the new sequence.
- [ ] Remove this todo once every input has a home, repairing references to it.
