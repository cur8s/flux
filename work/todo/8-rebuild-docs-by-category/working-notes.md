# Documentation rebuild working notes

## Selected scope

The owner accepted [Local development](../../../docs/how-to/00-local-development.md) and explicitly
requested its commit, including the README and agent navigation. The tested guide and its work
record are committed together. Subsequent operator guides, standards, and final consistency checks
remain in the [plan](plan.md).

## Agreed direction

The [overview](overview.md) establishes four categories, two-digit reading order, purpose
callouts, one authoritative home per subject, and one reviewed document at a time. The
[repository entry files standard](../../../docs/standards/repository-entry-files-standard.md)
governs the directory README. References into work material stay within work material.

## Sources and observations

- Adapted the documentation strategy from
  `/Users/adib/dev/asaikali/sales-agent/docs/README.md`, retaining the category responsibilities,
  reading progression, writing forms, and maintenance principles relevant to this package.
- The product and architecture collections are committed; the flat user guide retains operator
  procedures. Preserve their reading path while the remaining guides are rebuilt.
- The [source index](sources/README.md) identifies the preserved Flux and monorepo documents for
  later drafts. The monorepo layer model is superseded.

## Strategy choices accepted by advancing

- Keep the strategy concise, with category responsibilities and writing forms in one table.
- Apply numeric prefixes to new category documents; retain entry-file names and published paths
  unless a move improves navigation. This preserves the existing entry-files standard's path.
- Keep a temporary current reading path with valid links until reviewed replacements take over.

## Vision sources and choices accepted by advancing

- Start from the [preserved vision](sources/flux/vision.md), [user guide](../../../docs/user-guide.md),
  and the [preserved architecture](sources/flux/architecture.md). The collected
  [curation rationale](sources/monorepo/rfc/RFC-002-curated-opinionated-platform.md),
  [static-manifest rationale](sources/monorepo/rfc/RFC-005-static-runtime-manifests.md), and
  [Flux rationale](sources/monorepo/rfc/RFC-008-flux-as-the-gitops-engine.md) inform the problem
  and approach, without adopting the superseded platform-layer architecture.
- Keep the audience scoped to Cur8s cluster operators. Use limited attention as context rather
  than extending this component's audience to every platform user.
- Keep rendering philosophy and controller details brief; their full explanations belong in
  later product documents. Preserve explicit environment values as part of the operating model.
- Carry bare-cluster bootstrap without pre-existing secrets or image pull secrets into the
  success conditions, as required by the overview and already described by the live user guide.
- State a green end-to-end run as a publication requirement. Code observation: the release task
  documents that precondition but does not run the end-to-end task automatically.
- Inspected the bootstrap and publication scripts. Do not claim this documentation work freshly
  verified end-to-end behavior or remote registry access.

## Pre-rendered manifests sources and choices accepted by advancing

- Consolidate the vision's rendering rationale with
  [declarative cluster control](sources/monorepo/rfc/RFC-004-declarative-cluster-control.md),
  [static runtime manifests](sources/monorepo/rfc/RFC-005-static-runtime-manifests.md), and the
  live user guide's deterministic composition and explicit substitution model. The live model
  permits declared environment values; do not import the older RFC's blanket prohibition on
  unresolved variables.
- Checked Helm's [capability and lookup documentation](https://docs.helm.sh/docs/chart_template_guide/function_list/#kubernetes-and-chart-functions)
  and Flux's [post-build substitution documentation](https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution).
  Describe cluster-dependent rendering conditionally, and distinguish Cur8s usage constraints
  from what the upstream tools can technically do.
- Code observation: the deploy overlay structurally composes the fetched installation, and the
  self-management Kustomization has no post-build substitution. This package's installation is
  fully rendered even though the broader operating model permits explicit environment values.
- Explain reproducibility of desired manifests without implying identical observed behavior or
  compatibility with every Kubernetes version.
- The user guide's duplicated static-manifest and substitution sections now link to the accepted
  explanation. Controller choices are now owned by the accepted package opinion.

## Package opinion sources and choices accepted by advancing

- Consolidate the live user guide's controller and source choices. Retain OCI as the canonical
  released-configuration source and Git as a direct-source option, with the accepted rendering
  document owning composition rules. Do not imply that CI or OCI signing is already configured.
- Checked the rendered installation: exactly three controller Deployments; Source Controller
  installs OCIRepository, GitRepository, Bucket, HelmRepository, HelmChart, and ExternalArtifact
  CRDs; Notification Controller installs Alert, Provider, Receiver, and the internal webhook Service.
  No Receiver resource is configured by the package.
- Upstream [ExternalArtifact documentation](https://fluxcd.io/flux/components/source/externalartifacts/)
  identifies a generic interoperability API; [ArtifactGenerator documentation](https://fluxcd.io/flux/components/source/artifactgenerators/)
  identifies Source Watcher's composition role. Avoid attributing generation to ExternalArtifact
  itself, as the old user guide does.
- The [Receiver documentation](https://fluxcd.io/flux/components/notification/receivers/) confirms
  that incoming webhooks request reconciliation. The known
  [Notification Receiver contract todo](../3-clarify-notification-receiver-contract/overview.md)
  defers deciding whether to exclude that use from the recommended contract or reduce the installed
  surface. The accepted document preserves this as an unresolved boundary; neither outcome is chosen.
- Treat the current three-controller selection as implementation evidence. The lifecycle design
  may later revise it; the draft does not silently adopt that proposal as current behavior.
- The user guide's controller and source sections now link to this primary home. Its installation
  and operation text remains unchanged until the how-to phase replaces it.

## Product reading path accepted by advancing

- Add a short directory README linking the three accepted explanations in their numbered order;
  route readers onward to the existing architecture and operational guide.
- Keep the root README's direct reading links to the accepted product documents, including the
  package opinion. Update the documentation index to reflect the user guide's narrower scope.
- The product's explanations and reading path are accepted, but commits remain pending explicit
  authorization. The documentation strategy now links to the product reading path.

## Architecture overview sources and choices accepted by advancing

- Use the [preserved architecture](sources/flux/architecture.md) and current configuration and scripts. Propose
  an overview, source-to-artifact explanation, metadata explanation, and publication/self-management
  explanation rather than porting the monorepo layer structure.
- Describe the actual artifact: controller installation, inert descriptor, and shipped sync file.
  The consuming cluster owns its OCIRepository; the package currently owns the sync Kustomization.
- The owner's [Flux bootstrap proposal](../2-move-self-management-to-consumer/flux-bootstrap-proposal.md)
  explicitly selects consumer ownership of both self-management resources. Preserve that as the
  intended boundary while stating that the current package still ships sync.yaml. Documentation
  must not claim the ownership transition has been implemented.
- The same proposal requires matching static YAML and OCI installation content. Code observation:
  the release script currently pushes OCI only; it does not attach a GitHub release YAML asset.
  Avoid the preserved architecture's unsupported claim that a tag-triggered workflow does so.
- Concurrent implementation changes appeared while this step was underway: staged task renames
  moved upstream capture to upstream:fetch, rendering to build:render, and local bootstrap to
  flux:boot; artifact:build was removed and build:clean added. Preserve those changes and their
  index state. The overview avoids hard-coding task names; later pipeline documentation must read
  the current scripts again before drafting.
- At initial inspection, test:drift, test:e2e, and release still referenced removed task names.
  Those scripts were updated concurrently before verification. The drift gate now fetches and
  renders successfully, but fails against the committed tree because the generated cur8s.yaml
  comment changed from artifact:render to build:render. Preserve the re-rendered change produced
  by that script rename; do not hand-edit the descriptor or alter the concurrent staging.
- Draft links, local anchors, purpose callouts, the work-reference boundary, and whitespace checks
  passed. The drift result above remains unsuccessful; earlier successful results do not cover
  this changed pipeline. No end-to-end run or commit was performed for this documentation step.

## Source-to-artifact sources and choices accepted by advancing

- Read the current upstream:fetch, build:clean, build:render, test:drift, test:e2e, and release
  scripts after the concurrent rename. The then-current flat architecture also included that
  implementation work's task-name updates; check those details against current scripts.
- Explain Flux capture precisely: the pinned CLI exports an installation manifest locally. Do not
  imply it downloads a separate upstream YAML release asset. Capture replaces its own fetched area;
  clean removes only the generated artifact tree.
- Rendering consumes captured input without fetching. Its clean dependency executes before its
  missing-input check. Keep this ordering clear without adding a new procedure or changing scripts.
- Drift captures and renders sequentially and checks Git status, including staged output changes.
  E2e and release render the already captured input. Do not repeat the flat document's inaccurate
  implication that E2e performs fresh capture.
- Separate reproducible rendered files from reproducible OCI packaging and runtime compatibility.
  Keep descriptor schema and publication annotation details with their upcoming explanation.
- The accepted overview now owns the package-boundary section of the flat architecture. That
  section now links to the overview; other subjects remain until their category drafts are accepted.
- Source-to-artifact draft links, local anchors, purpose callouts, reference boundary, and whitespace
  checks passed. Drift was rerun and still fails only on the descriptor generator-name comment
  from the concurrent task rename. No end-to-end run or commit was performed for this step.

## Artifact contents and metadata accepted by advancing

- Read current build:render, artifact:push, artifact:deploy, artifact:verify, descriptor, and sync
  content. Verified the descriptor's upstream.digest against SHA-256 of the captured manifest and
  confirmed that the rendered sync file is a byte-identical copy of its authored source.
- Use a field table for the existing schema and an annotation table for custom publication keys.
  The digest identifies captured YAML, not upstream image bytes, transformed installation bytes,
  or the OCI manifest. Keep those identities distinct.
- Descriptor source comes from CUR8S_SOURCE; publication source comes from the local Git origin.
  Publication revision is current branch and HEAD, not a clean-worktree attestation. The current
  push task does not verify that its payload is the content of that commit.
- Checked the installed Flux CLI's push help and the official
  [push reference](https://fluxcd.io/flux/cmd/flux_push_artifact/) and
  [OCI metadata explanation](https://fluxcd.io/flux/cheatsheets/oci-artifacts/). The CLI has a
  reproducible-timestamp option, but artifact:push does not use it. Do not claim reproducible OCI
  digests from reproducible rendered files. No push or registry inspection is part of this draft.
- Use the [OCI descriptor specification](https://github.com/opencontainers/image-spec/blob/main/descriptor.md)
  for the meaning of object digests. Avoid treating metadata as signatures or verified provenance.
- The flat architecture's metadata section now links to the accepted replacement. Its runtime-test
  explanation remains until the publication/self-management draft is accepted.
- Metadata draft links, local anchors, purpose callouts, reference boundary, whitespace checks,
  upstream digest, and sync-file comparison passed. The drift gate now passes: the concurrent
  task changes and regenerated descriptor have been committed by the separate implementation work.
  No documentation commit or registry push was performed for this step.

## Publication and self-management accepted by advancing

- Read the current release, boot, deploy, verify, end-to-end, and cluster-creation scripts, plus
  sync configuration and the operator guide. The
  [parked CI overview](../../parked/finalize-ci-workflows/overview.md) confirms no live CI workflow
  is configured; preserved workflows are unfinished sources, not executable release automation.
- Keep the two matching distribution forms as the publication contract. The current release task
  renders captured input and pushes OCI; it does not publish the YAML asset, run e2e, check clean
  Git state, or reject an existing version. No registry state or release asset was inspected.
- The owner's versioning proposal (now settled in
  [Publication and self-management](../../../docs/architecture/03-publication-and-self-management.md#why-independent-semver);
  original unedited proposal preserved in Git at `fd7572b`) selects
  independent package SemVer. State that intended identity separately from the current upstream
  version plus configuration revision scheme; do not claim the migration has happened.
- Consolidate the selected [publication requirements](../7-harden-release-publication/overview.md):
  immutable versions, one tested and promoted packaged artifact, matching installation bytes,
  post-publication verification, and partial-success recovery. Avoid choosing packaging tools,
  signing policy, workflow timing, or other unresolved implementation details.
- Boot currently waits for Deployment availability but does not issue an explicit CRD Established
  wait. Describe the readiness precondition and actual check separately. Deploy uses a local OCI
  source plus shipped sync; the accepted overview owns the intended consumer ownership change.
- E2e covers fresh installation and self-management, not upgrade, rollback, or failed-engine
  recovery. Do not present desired recovery procedures as fresh test evidence.
- The accepted publication document now owns runtime and publication explanations. The flat
  architecture has been retired and its remaining references repaired.
- Publication draft links, local anchors, purpose callouts, reference boundary, whitespace checks,
  and the drift gate passed. No end-to-end run, documentation commit, or remote publication was
  performed for this step. Concurrent lifecycle-note edits were preserved.

## Architecture reading path accepted for commit

- Add a short directory README linking the four accepted explanations in order, with routes to
  the product collection, operational guide, and documentation strategy.
- Retire the flat architecture after checking every subject has an accepted replacement. Repair
  its incoming references in docs, mise configuration comments, task comments, lifecycle notes,
  and the parked release-workflow comment. Preserve original rebuild source snapshots.
- A second concurrent task migration moved publication to oci:publish, consolidated testing into
  test:run, and placed source creation, self-management application, and readiness checks in
  dev:create. Update the accepted explanations' implementation observations and local links to
  match the current scripts. Publication now consumes rendered output without fetching/rendering;
  test:run now performs fresh capture, rendering, and drift comparison before its cluster test.
- Document/configuration changes made by this step preserve task behavior. Preserve concurrent
  lifecycle-note changes, kubeconfig isolation, and the unrelated task-namespaces proposal.
- Reading-path links, local anchors, purpose callouts, reference boundary, whitespace checks, and
  syntax checks on the two task scripts whose comments were repaired passed. Explicit fresh
  capture and rendering leave the recorded upstream and OCI trees clean, matching the drift
  portion of test:run. The full cluster test was not rerun during this documentation step.
- Update the upcoming how-to phase's context for the combined test:run interface. No documentation
  commit or remote publication was performed.

## Documentation commits

The owner authorized these local commits. Each reviewed document has its own Conventional Commit.
The consolidation commit also retires the old documents, repairs links, and records the remaining
plan. Concurrent implementation changes and their staging are preserved; no push is authorized.

| Document | Commit |
| --- | --- |
| `docs/product/00-vision.md` | `2b4e985` |
| `docs/product/01-pre-rendered-manifests.md` | `fc978dd` |
| `docs/product/02-the-opinion.md` | `50c3063` |
| `docs/product/README.md` | `9efea7d` |
| `docs/architecture/00-overview.md` | `a5a7216` |
| `docs/architecture/01-source-to-artifact.md` | `7cda8fd` |
| `docs/architecture/02-artifact-contents-and-metadata.md` | `b28efd4` |
| `docs/architecture/03-publication-and-self-management.md` | `20716a9` |
| `docs/architecture/README.md` | `de4bc79` |
| `docs/README.md` | `d699fc4` |

## Local development guide accepted for commit

- Read the current scripts and architecture after layout commit `0a73317`. Use upstream/flux.yaml,
  src/config/, and artifacts/rendered/. Whole-tree artifacts cleanup preserves captured and authored
  inputs; local packaging remains future work.
- Adapt setup and lock refresh from the [preserved contribution guide](sources/flux/CONTRIBUTING.md),
  replacing its old split verification tasks with the current combined test:run workflow.
- Distinguish uncommitted candidate testing with dev:create from the committed-tree prerequisite in
  test:run. The latter checks staged changes as well and stops before cluster creation on drift.
- The current tasks load the repository-local kubeconfig and target explicit named contexts. Use
  mise exec for direct kubectl inspection; show flux-prefixed, disposable names in examples.
- Verified available task names and the dev:create, test:run, test:destroy, and oci:publish help.
  Verified the installed mise lock help accepts comma-separated platforms. Docker is available;
  the initial cluster inventory contained only cur8s-dev, which this task must preserve.
- Validated `mise run test:run flux-check`: fresh capture and render matched Git, the disposable
  cluster booted Flux, local OCI publication succeeded, and the source and self-management
  Kustomization reached Ready. The task exited successfully and removed its cluster and registry.
  Verified cur8s-dev remained present and the recorded upstream/rendered trees were unchanged.
- Guide links, local anchors, task names, shell-example syntax, reference boundary, and whitespace
  checks passed. Setup and lock-refresh syntax was checked against the installed CLI; no tool pin
  was changed and the lockfile was not rewritten. Candidate inspection/reconciliation examples
  were checked against their scripts and help, rather than exercised on a second cluster.
- The owner accepted the guide by explicitly requesting its commit. Its navigation and work record
  are included with the guide; no push or remote publication was requested or performed.
