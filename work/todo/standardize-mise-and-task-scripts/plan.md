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

## Phases

### Phase 1: Inventory

A shared picture of current usage and the topics to review.

- [ ] Catalogue every mise feature the repository uses (settings, tools, lockfile, env directives
  and templates, task headers, usage specs, `depends`, `raw`) and every recurring script pattern.
- [ ] Note the installed mise version and the mise features relevant to each topic.
- [ ] Create `working-notes.md` with the inventory and the proposed topic order. Review with the
  owner before starting rounds.

### Phase 2: Review rounds

Each topic has an agreed, applied, and recorded convention.

- [ ] Settings and the lockfile: `lockfile`, `locked`, locked platforms, refresh procedure.
- [ ] Tool pinning: registry backends, tools outside the default registry, Flux plugins and
  container-distributed tools, host prerequisites mise does not manage (docker, git, openssl,
  curl, jq).
- [ ] `[env]` design: authored versus derived values, templates and in-template validation, value
  naming, version values that drive tool pins, and the Renovate trade-off of templated pins.
- [ ] Task definition: file versus TOML tasks, `#MISE` and `#USAGE` headers, argument and flag
  conventions and defaults, `depends` versus `mise run`, working directory, `raw`.
- [ ] Repository layout under `.mise/`: tasks, configuration, and shared scripts.
- [ ] Bash conventions: shebang and strict mode, variable naming and quoting, output and error
  messages, comments, script size, and when logic justifies a shared helper.
- [ ] CI usage: how GitHub Actions installs and runs mise, action pinning, caching, and locked
  installs.

### Phase 3: Documentation

The conventions are published where they belong.

- [ ] Decide with the owner which documents to write and their homes (standards, how-to,
  architecture, or a mix).
- [ ] Write each document from `working-notes.md`; review each with the owner, then commit it
  on its own.
- [ ] Move or delete `working-notes.md` content that now lives in durable documentation.

### Phase 4: Finish

- [ ] Confirm the repository conforms to every published convention and the gates pass.
