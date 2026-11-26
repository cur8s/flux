# Plan: Review and standardize the mise configuration and task scripts

## Context

### Outcome

Every mechanical aspect of the repository's mise and bash usage has an agreed convention, the
repository follows it, and the conventions are published in durable documentation whose homes
were decided during the work. The drift and e2e gates still pass. Lifecycle phase
names, task naming, namespaces, and the Flux version bump are out of scope.

### Approach

Work in review rounds, one topic at a time. Each round:

1. Inventory how the repository uses the topic today and what the installed mise version offers;
   verify capabilities by experiment rather than assuming them.
2. Propose options with a recommendation. **Stop for owner discussion.**
3. Apply the agreed convention, run the drift and e2e gates, and commit only with owner
   permission.
4. Record the decision, its rationale, and rejected alternatives in `working-notes.md` in this
   todo, distinguishing owner decisions from proposals and observations.

Topics may be reordered, merged, or added as the review reveals them; the list in Phase 2 is the
starting point, not a contract. `working-notes.md` is the consolidated record that the
documentation phase publishes from. Write documentation into the structure defined by the
[docs rebuild](../rebuild-docs-by-category/overview.md); if a needed category directory does not
exist yet, create it following that todo's strategy document.

## Current baseline

The directory-layout migration is implemented, including task path references and `.mise/`
orientation. Inventory current files rather than the former `src/flux/` and `oci/flux/` layout.
The remaining rounds still settle mise and bash mechanics; this migration does not complete them.

## Phases

### Phase 1: Inventory

A shared picture of current usage and the topics to review.

- [x] Catalogue every mise feature the repository uses (settings, tools, lockfile, env directives
  and templates, task headers, usage specs, `depends`, `raw`) and every recurring script pattern.
- [x] Note the installed mise version and the mise features relevant to each topic.
- [x] Create `working-notes.md` with the inventory and the proposed topic order. Review with the
  owner before starting rounds.

### Phase 2: Review rounds

Each topic has an agreed, applied, and recorded convention.

- [x] Settings and the lockfile: `lockfile`, `locked`, locked platforms, refresh procedure.
- [x] Tool pinning: registry backends, tools outside the default registry, Flux plugins and
  container-distributed tools, host prerequisites mise does not manage (docker, git, openssl,
  curl, jq).
- [x] `[env]` design: authored versus derived values, templates and in-template validation, value
  naming, version values that drive tool pins, and the Renovate trade-off of templated pins.
- [x] Task definition: file versus TOML tasks, `#MISE` and `#USAGE` headers, argument and flag
  conventions and defaults, `depends` versus `mise run`, working directory, `raw`.
- [x] Repository layout under `.mise/`: tasks, configuration, and shared scripts.
- [x] Bash conventions: shebang and strict mode, variable naming and quoting, output and error
  messages, comments, script size, and when logic justifies a shared helper.

### Phase 3: Documentation

The conventions are published where they belong.

- [x] Decide with the owner which documents to write and their homes (standards, how-to,
  architecture, or a mix).
- [x] Write each document from `working-notes.md`; review each with the owner, then commit it
  on its own.
- [ ] Move or delete `working-notes.md` content that now lives in durable documentation.

### Phase 4: Finish

- [ ] Confirm the repository conforms to every published convention and the gates pass.
