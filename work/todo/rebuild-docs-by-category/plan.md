# Plan: Rebuild the docs as product, architecture, how-to, and standards

## Context

### Outcome

`docs/` contains `README.md` (the documentation strategy) and the `product/`, `architecture/`,
`how-to/`, and `standards/` directories, each with numbered documents that open with a purpose
callout. The flat `vision.md`, `user-guide.md`, and `architecture.md` are gone, every subject they
covered has exactly one new home, and nothing outside `work/` references them. Every document was
reviewed and accepted by the owner before its commit.

### Approach

Work one document at a time. Each document step follows the same cycle:

1. Draft it from the [sources](sources/README.md) and the current repository. Sources inform the
   draft; they are not copied wholesale. Monorepo material about layers is superseded.
2. **Stop for owner review.** Revise until the owner agrees. Do not start the next document first.
3. Commit the agreed document on its own. In the same commit, delete any original in `docs/` it
   fully replaces, remove moved sections from an original it partly replaces, and repair
   references from `README.md`, `AGENTS.md`, and `docs/README.md`.

Check claims about current behavior against the repository while drafting. Distinguish agreed
statements from proposals in drafts so review can focus on them.

Phases follow the category directories. Only the phase about to start lists its steps; later
phases keep their outcome until they start, so what the product phase teaches can shape them.

## Phases

### Phase 1: Product

`docs/README.md` and `docs/product/` exist, agreed and committed, carrying the vision, the
pre-rendered-manifest philosophy, and the package's opinion.

- [ ] Write `docs/README.md`: a short documentation strategy adapted from the sales-agent model —
  the four categories, numbered reading order, purpose callouts, one home per subject, the
  `work/` reference boundary. Review, then commit.
- [ ] Write `docs/product/00-vision.md`: whom the package serves and what it is for. Replaces
  `docs/vision.md`. Review, then commit.
- [ ] With the vision agreed, confirm or revise the remaining `product/` file list below.
- [ ] Write `docs/product/01-pre-rendered-manifests.md`: the philosophy — decision time versus
  runtime, why in-cluster templating makes desired state unknowable, and what static manifests
  give operators. Draws on RFC-005, RFC-004, and the current vision. Review, then commit.
- [ ] Write `docs/product/02-the-opinion.md` (name to be decided): the Flux surface the package
  includes and excludes, and why. Takes over the controller sections of `docs/user-guide.md`;
  the operational sections stay there until the how-to phase. Review, then commit.
- [ ] Add a `docs/product/README.md` reading path if the directory benefits from one, and point
  the root `README.md` at the product documents. Review, then commit.

### Phase 2: Architecture

`docs/architecture/` explains the package boundary, the source-to-artifact pipeline, artifact
contents and metadata, and publication and self-management, replacing `docs/architecture.md`.
Steps are added when the phase starts.

### Phase 3: How-to

`docs/how-to/` holds task guides with prerequisites, actions, and observable results — at least
the operator procedures still in `docs/user-guide.md` (bootstrap, operation, upgrade, recovery),
after which `user-guide.md` is deleted. Steps are added when the phase starts.

**Known gap this phase closes:** removing `CONTRIBUTING.md` left the verification gates written
nowhere — which gates every change runs (`test:drift`, `git diff --check`), when the end-to-end
gate is required (changes to `src/`, the Flux version, or a tool pin), and refreshing `mise.lock`
for version or pin changes — along with first-run setup (`mise trust`, `mise install`, a running
Docker daemon). Write them into a local development guide, add it to the root README's reading
order, and point `AGENTS.md` at it. The removed text is in
[`sources/flux/CONTRIBUTING.md`](sources/flux/CONTRIBUTING.md).

### Phase 4: Standards

`docs/standards/` records agreed technical choices with rationale. Its first content is decided
when the phase starts.

### Phase 5: Finish

- [ ] Refine `docs/README.md` against the finished structure.
- [ ] Confirm no document outside `work/` references removed files or points into `work/`, and
  that every document opens with a purpose callout.
