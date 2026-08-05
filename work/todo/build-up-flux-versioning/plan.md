# Plan: Build up Flux package versions

## Context

### Outcome

`version.env` is the only hand-edited source for the upstream Flux version and cur8s Flux
revision. The toolchain, fetched upstream manifest, release descriptor, OCI annotations, OCI tag,
GitHub release tag, and upstream check all use values constructed from that source. Revision 1
produces `v2.9.0`; revision 2 produces `v2.9.0-2`. The old root `VERSION`, literal Flux tool pin,
and combined-version parsing are gone, and the repository's drift and end-to-end gates pass.

### Approach

Keep the two independent inputs explicit as `FLUX_VERSION` and `CUR8S_FLUX_REVISION`. Load them
into mise with its dotenv-file directive and use `FLUX_VERSION` directly for the Flux CLI pin.
Add shared shell logic that validates the inputs and constructs `FLUX_TAG` and
`CUR8S_FLUX_VERSION`; consumers source that logic instead of reading or splitting version strings.
Keep generated copies in `FETCH.lock`, `cur8s.yaml`, and OCI annotations as verified projections,
not authoring points. Direct execution of every mise file task is outside this change, but the
version source and construction logic must not depend on mise-specific parsing.

## Phases

### Phase 1: Establish the version source and builder

Create the single authored source and one reusable implementation of its validation and
construction rules.

- [ ] Add root `version.env` with `FLUX_VERSION=2.9.0` and `CUR8S_FLUX_REVISION=1`.
- [ ] Add shared version logic that loads an explicit `version.env`, validates stable Flux SemVer
      and a positive numeric cur8s revision, and constructs `FLUX_TAG` and
      `CUR8S_FLUX_VERSION` without decomposing a combined version.
- [ ] Configure `mise.toml` to load `version.env` and derive the `flux2` tool pin directly from
      `FLUX_VERSION`.
- [ ] Add `test:version` coverage for revision 1, revision 2, and invalid input cases.

### Phase 2: Migrate every version consumer

Make build, publication, and release automation consume the constructed facts, then remove the
superseded source.

- [ ] Update artifact fetch, facts, render, push, release, and upstream-check tasks to use
      `FLUX_VERSION`, `FLUX_TAG`, and `CUR8S_FLUX_VERSION` according to their responsibilities.
- [ ] Update the tag-triggered release workflow to compare its Git tag with
      `CUR8S_FLUX_VERSION` through the shared version logic.
- [ ] Remove root `VERSION` and all reads of it after consumers have migrated.
- [ ] Re-render and confirm revision 1 leaves `FETCH.lock` and the committed `oci/` product
      unchanged apart from intentionally generated identity changes, if any.

### Phase 3: Align documentation and verify

Document the new authoring operations and prove the complete pipeline still satisfies its
contracts.

- [ ] Update `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `mise.toml` comments, and source-local
      notes to describe `version.env`, upstream bumps, and cur8s-only revision increments.
- [ ] Search for stale `VERSION`, `CUR8S_VERSION`, `CUR8S_UPSTREAM_VERSION`, and config-revision
      references and either migrate or remove each one.
- [ ] Run `mise run test:version`, `mise run test:drift`, `mise run test:e2e`, and
      `git diff --check`.
