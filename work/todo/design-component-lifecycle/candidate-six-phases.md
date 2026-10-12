# Candidate: six chained phases

> Historical design input: local directory examples below predate the
> [decided and implemented layout](working-notes.md). Preserve the proposal body as provenance;
> follow the later layout decision for current paths. Broader lifecycle questions remain open.

A candidate design proposed while planning, formerly the `adopt-lifecycle-phases` todo. It is one
option to evaluate against the agreed goals and invariants, not a decision.

## Shape

Model the lifecycle on Maven: a few phases with fixed names and order, top-level tasks, where
running a phase runs the phases before it and each repository implements a phase however its
component needs.

| Phase | Produces | Committed |
| --- | --- | --- |
| `fetch` | Pinned upstream inputs under `src/<component>/artifacts/` plus a record of what was downloaded | yes |
| `render` | The final manifests in `oci/<component>/` (the review surface) | yes |
| `package` | The OCI artifact on disk under a git-ignored `dist/` | no |
| `check` | Static checks on the result; drift today, anything else a repository needs | — |
| `e2e` | Proof on a throwaway cluster, using the packaged artifact | — |
| `publish` | The same packaged artifact copied to `ghcr.io/cur8s` | — |

Supporting tasks stay namespaced and single-purpose: `cluster:*` is pure k3d lifecycle, `flux:*`
is Flux on a cluster, `artifact:push|deploy|verify` put a built artifact on a dev cluster, and
`upstream:check` reports newer upstream releases. Today's `artifact:fetch`, `artifact:render`,
`artifact:build`, `test:drift`, `test:e2e`, and `release` map onto the phases.

A cluster-argument convention accompanied it: positional name only where the cluster is the
object (`cluster:create <name>`), `--cluster <name>` everywhere else.

## Claimed properties

- Chaining makes `publish` structurally unable to skip `e2e`, so "no version is published without
  a green end-to-end run" is enforced by the task graph rather than CI step order. CI and the
  release workflow would call phases only.
- `package` is the seam where local packaging lands; until then it can only confirm
  `oci/<component>/` exists.

## Known costs and questions

- A phase cannot run alone: `render` always fetches first, which is a network download for
  components that fetch remotely. A supporting fast re-render task may be needed.
- Owned images require mirroring before `e2e`, so registry writes would happen before `publish`;
  the phase that owns them is unresolved.
- Whether `check` belongs after `package`, and whether e2e should depend on `check`, were not
  examined.
