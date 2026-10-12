---
title: "Finalize the CI workflows"
summary: "Settle the GitHub Actions workflows that gate pull requests and publish releases; parked as a work in progress until the other work toward 1.0 is done."
---

# Finalize the CI workflows

**Pick up** after the current todo sequence is complete — the docs rebuild, the mise and
task-script conventions, the lifecycle design, and its implementation. The owner intends this to be
one of the last things done before 1.0, and parked it because working on CI now is a distraction.

The workflows were a work in progress, not a finished design. They were moved out of the live
`.github/` directory into [sources](sources/.github/workflows/) so they do not distract coding
agents or the owner, which means the repository currently has no CI and the gates run locally.
Restoring them is part of this work:

- `ci.yml` runs the drift and e2e gates on pushes to `main` and on pull requests.
- `release.yml` runs on a `v*` tag: checks the tag matches the package version, runs e2e, logs in
  to ghcr, publishes the OCI artifact, and creates the GitHub release with `install.yaml`.

The preserved workflow sources retain historical task and path examples. On resumption, adapt
callers to the current task interface and implemented layout: captured `upstream/flux.yaml`,
authored `src/config/`, and committed `artifacts/rendered/`, with ignored `artifacts/oci/` reserved
for future packaging. `build:clean` removes the whole output tree. Local packaging and tested-digest
promotion remain unfinished; restoring CI must not assume they are already implemented.

When picking this up, also gather the CI concerns recorded elsewhere so far:

- the publication safety items — immutability preflight, partial-success recovery, digest
  verification, per-version concurrency, pinned third-party actions, and the signing decision —
  in the lifecycle work's requirements;
- how GitHub Actions installs and runs mise (action pinning, caching, locked installs), moved here
  from the mise and task-script conventions todo, building on the conventions it settles;
- running the Kubernetes runtime pin on CI's AMD64 runners, from the implementation planning
  inputs.
