# Plan: Restructure the repository documentation

## Context

### Outcome

The repository has a short entry-point README, a concise vision, a consumer-focused user guide,
and a current-state architecture guide. Each subject has one authoritative home, the local RFC
directory and duplicated source notes are gone, and links to applicable flagship cur8s RFCs remain
intact. A consumer can install and operate the package without reading contributor documentation,
while a contributor can understand the artifact and mise task lifecycles without reconstructing
them from shell scripts. Readers can also understand why the package is deliberately constrained:
decisions remain external and reviewable, manifests are rendered before runtime, and Flux only
reconciles immutable intent instead of interpreting templates or selecting versions in the cluster.

### Approach

Use the starter repository's durable-document responsibilities as the information-architecture
model, customized for this package. Migrate useful content before deleting its old location. Keep
the distinction strict: vision explains why, the user guide explains philosophy and use,
architecture explains how the present system works, and contributing explains how to change it.
Retire only repository-local RFCs; continue linking to flagship RFCs for org-wide law. Deliver the
work in reviewable stages so additions and removals can be assessed independently. Before drafting,
audit the original monorepo documentation and map each relevant rationale to a local explanation,
an authoritative flagship link, or an intentional out-of-scope omission. This prevents a cleaner
document structure from erasing the reasons behind the design.

## Phases

### Phase 0: Inventory and place the inherited rationale

Identify the important reasoning in the original monorepo before changing its presentation.

- [ ] Create a temporary source-to-destination inventory from
      `/Users/adib/dev/cur8s/cur8s/docs/why/`, the Flux section of
      `docs/platform-components.md`, and the relevant flagship RFCs. Include at least the rationale
      for curation, a headless Kubernetes API, declarative external control, static runtime
      manifests, constrained Flux controllers, environment-specific inputs, immutable releases,
      and component packaging.
- [ ] Map each rationale to one authoritative destination: durable local motivation in
      `docs/vision.md`, user-visible philosophy and constraints in `docs/user-guide.md`, enforcement
      mechanics in `docs/architecture.md`, or a flagship link when the rationale is org-wide law.
- [ ] Preserve the complete reasoning chain: decisions are recorded outside the cluster; rendering
      resolves choices before publication; the artifact contains reviewable static manifests; and
      Flux mechanically reconciles that intent without runtime branching, dependency resolution,
      hidden defaults, or automatic version selection.
- [ ] Record why any source material is intentionally not migrated because it is unrelated to the
      Flux component, obsolete, or already authoritative in the flagship.

### Phase 1: Establish the new authoritative documents

Add the new destinations and improve the vision while the existing RFCs remain available for
content comparison.

- [ ] Create `docs/user-guide.md` covering the philosophy behind the opinionated controller set,
      public API surface, bare-cluster properties, first-touch bootstrap, steady-state
      self-management, upgrades, rollback or recovery expectations, verification, and explicit
      limitations. Explain why dynamic in-cluster templating is rejected, why the Helm controller
      and image automation are excluded, and why build-time rendering remains acceptable.
- [ ] Create `docs/architecture.md` covering source inputs, fetch/render/validate outputs, the
      committed OCI review surface, the decision-time/runtime boundary, the mise task lifecycle,
      local k3d verification, dual-channel publication, and Flux self-management. Show where all
      choices are resolved and how the runtime is kept free of dynamic interpretation.
- [ ] Rewrite `docs/vision.md` as a quick, flowing durable-intent narrative with a clear problem,
      audience, success statement, and boundaries; do not impose a standard section outline, and
      use headings only when they naturally improve the reading flow. Move implementation
      mechanics elsewhere.
- [ ] Check the new documents against both local RFCs, the root README, and the rationale inventory
      so no important current-state contract or reason behind a deliberate constraint is lost.

### Phase 2: Simplify navigation and retire duplication

Make the new information architecture visible, then remove superseded documents.

- [ ] Shorten `README.md` to immediate orientation, a minimal consumer starting point, and links
      to the user guide, architecture, vision, and contribution guide.
- [ ] Rewrite `docs/README.md` as the durable-document map and authoring contract for the new
      required documents.
- [ ] Update `AGENTS.md`, `CONTRIBUTING.md`, workflow comments, and other references to point to
      the new authoritative locations while retaining relevant flagship RFC links.
- [ ] Remove `docs/rfc/` only after all unique current-state content has a new owner.
- [ ] Delete `src/flux/config/notes.md`, or reduce it to source-local guidance that does not repeat
      product philosophy, configuration, bootstrap, or architecture.

### Phase 3: Verify clarity and repository consistency

Prove the migration is complete and the resulting documents serve distinct audiences.

- [ ] Search for stale local RFC paths, obsolete document names, broken relative links, and
      repeated blocks of configuration or bootstrap prose.
- [ ] Confirm the user guide contains no contributor workflow, architecture does not duplicate the
      mise command reference, and vision reads as a coherent narrative without temporary plans,
      implementation details, or artificial section divisions.
- [ ] Confirm every deliberate Flux restriction says why it exists or links directly to the
      authoritative flagship rationale, especially the prohibition on dynamic in-cluster
      templating and automatic version selection.
- [ ] Run `mise run test:drift` and `git diff --check`.
- [ ] Review each phase as a focused diff and preserve any durable insight discovered during the
      migration in its single authoritative document.
