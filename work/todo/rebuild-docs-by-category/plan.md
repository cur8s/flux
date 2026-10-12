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

### Phase 1: How-to

`docs/how-to/` holds task guides with prerequisites, actions, and observable results — at least
the operator procedures still in `docs/user-guide.md` (bootstrap, operation, upgrade, recovery),
after which `user-guide.md` is deleted. Steps are added when the phase starts.

**Known gap this phase closes:** removing `CONTRIBUTING.md` left setup and verification procedures
without a home. The concurrent task migration now combines drift and cluster verification in
`test:run`; write the current workflow from the live scripts rather than copying the old split
gate names. Include `git diff --check`, refreshing `mise.lock` for version or pin changes, and
first-run setup (`mise trust`, `mise install`, a running Docker daemon). Add the local development
guide to the root README's reading order and point `AGENTS.md` at it. Earlier verification and
setup guidance is preserved in
[`sources/flux/CONTRIBUTING.md`](sources/flux/CONTRIBUTING.md).

The directory layout is now implemented and the current architecture explanations and reading
links reflect it. The how-to phase must use `upstream/flux.yaml`, `src/config/`, and
`artifacts/rendered/`; explain whole-tree cleanup of `artifacts/` and the current committed-tree
restriction in `test:run`. Local packaging under ignored `artifacts/oci/` is future work. Keep
preserved source documents and their old path examples as provenance rather than live contracts.

### Phase 2: Standards

`docs/standards/` records agreed technical choices with rationale. Its first standard already
exists: [repository entry files](../../../docs/standards/repository-entry-files-standard.md), written
ahead of this phase. Further content is decided when the phase starts; consider bringing over the
sales-agent standards authoring guide as a how-to so standards keep one format.

### Phase 3: Finish

- [ ] Refine `docs/README.md` against the finished structure.
- [ ] Confirm no document outside `work/` references removed files or points into `work/`, and
  that every document opens with a purpose callout.
