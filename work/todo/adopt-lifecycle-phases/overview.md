---
title: "Adopt standard lifecycle phases"
summary: "Replace the artifact/test task split with fixed, chained top-level phases — fetch, render, package, check, e2e, publish — named identically in every Cur8s component repository."
---

# Adopt standard lifecycle phases

Every Cur8s component repository keeps its own small task scripts, so consistency comes from the
task names, not shared code. The model is the Maven build lifecycle: a few well-defined phases with
fixed names and order, where running a phase runs the phases before it, and each repository is
free to implement a phase however its component needs.

The phases, as top-level tasks:

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

Chaining phases through mise `depends` makes `publish` structurally unable to skip `e2e`, so "no
version is published without a green end-to-end run" is enforced by the task graph rather than
by CI step order. The cost is that a phase cannot run alone; `render` always fetches first. Keep a
supporting task for a fast re-render only if that cost proves real.

Also settle the cluster-argument convention while renaming: positional name only where the
cluster is the object (`cluster:create <name>`), `--cluster <name>` everywhere else.

`package` and `publish` depend on
[`package-oci-artifact-locally`](../package-oci-artifact-locally/overview.md); until it lands,
`package` can stay a thin placeholder and `publish` can keep pushing from `oci/`.
