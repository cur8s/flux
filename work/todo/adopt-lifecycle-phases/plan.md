# Plan: Adopt standard lifecycle phases

## Context

### Outcome

`mise tasks` lists the six top-level phases — `fetch`, `render`, `package`, `check`, `e2e`,
`publish` — each depending on the one before it, plus the namespaced supporting tasks
(`cluster:*`, `flux:*`, `artifact:push|deploy|verify`, `upstream:check`). Every script stays a
small, obvious bash file. CI and the release workflow call phases only, documentation describes
the lifecycle as the repository's command contract, and `check` and `e2e` pass.

### Approach

Rename in place rather than rebuild: the existing scripts already do the work of `fetch`,
`render`, `check` (drift), `e2e`, and `publish` (release). Express ordering with each phase's
`#MISE depends=["<previous phase>"]`; a single dependency per phase keeps mise serial, so no
`run` lists or nested `mise run` chains are needed for the main path.

`package` is introduced as the seam the local-packaging todo fills. Until that lands, `package`
may do nothing beyond confirming `oci/<component>/` exists, and `publish` keeps today's push from
`oci/`; do not invent a packaging format here.

`e2e` keeps its success-cleanup and failure-preservation behavior and its own cluster name. With
`publish` depending on `e2e`, the release workflow no longer needs a separate e2e step.

Apply the cluster-argument convention in the same change, since it touches the same headers:
positional `[name]` on `cluster:*`, `--cluster <name>` (defaulting to `CLUSTER_NAME`) on every
other task that targets a cluster.

## Phases

### Phase 1: Rename and chain the phases

The six phases exist as top-level tasks with single-predecessor dependencies.

- [ ] Move `artifact/fetch` → `fetch`, `artifact/render` → `render` (depends `fetch`), add
  `package` (depends `render`), `test/drift` → `check` (depends `package`), `test/e2e` → `e2e`
  (depends `check`), `release` → `publish` (depends `e2e`); remove `artifact/build`.
- [ ] Keep `fetch` responsible for clearing its own generated inputs so a phase run is always
  fresh.
- [ ] Switch `flux:bootstrap`, `flux:status`, and `e2e` to `--cluster <name>`; leave
  `cluster:*` positional.

### Phase 2: Update callers and contract documentation

Nothing references the old task names.

- [ ] Point CI at `mise run check` and `mise run e2e`, and the release workflow at
  `mise run publish` (dropping its separate e2e step).
- [ ] Rewrite the `mise.toml` header, the `docs/architecture.md` task graph, the CONTRIBUTING
  command table and verification section, the README quickstart, and the AGENTS.md references to
  describe phases and supporting namespaces.
- [ ] Update other work notes that name old tasks.

### Phase 3: Verify

- [ ] `mise tasks` shows exactly the phases and supporting tasks; every phase's `--help` is
  correct.
- [ ] `mise run check` and `mise run e2e` pass; `bash -n` passes for every script;
  `git diff --check` is clean.
