# Agent instructions — cur8s/flux

This is the package repository for the cur8s **flux** component: an
opinionated Flux configuration, rendered once and published as an
immutable OCI artifact.

- **The pipeline is the shape of the repo.** `src/flux/` (upstream
  fetch + the opinion) renders into the committed `oci/flux/` tree,
  and that tree is what gets pushed as the artifact. Never hand-edit
  `oci/` — change `src/` and re-render; the `oci/` diff is the review
  surface for every change.
- **Org-wide law lives in the flagship** ([cur8s/cur8s
  `docs/rfc/`](https://github.com/cur8s/cur8s/tree/main/docs/rfc)) —
  link to it, never copy it. This repo keeps only its own contracts
  in `docs/rfc/`: RFC-001 (the opinionated configuration + API
  surface) and RFC-002 (the bootstrap contract).
- **Versioning** follows flagship RFC-011 (component versioning): `version.env`
  is the only authored source, carrying `FLUX_VERSION` and `CUR8S_FLUX_REVISION`; the
  version is the upstream Flux version, with a `-<n>` config revision
  when the opinion changes on the same upstream (`v2.9.0`,
  `v2.9.0-2`). Published versions are immutable. No version is
  published without a green end-to-end run.
- **The opinion:** source, kustomize, and notification controllers
  only — helm-controller and the image-automation controllers are
  forbidden (flagship RFC-006). Flux comes up on a bare cluster: zero
  pre-existing secrets, no `imagePullSecrets`.
- **mise is the task runner** (`mise install`, `mise tasks`). Task
  grammar is `<object>:<action>`; the `mise.toml` header is
  authoritative. The pinned `[tools]` are the build's reproducibility
  contract — the flux pin tracks `FLUX_VERSION`, and `test:drift` proves
  the committed `oci/` tree matches what the pins produce.
- **`CONTRIBUTING.md` is the contribution contract** — setup,
  commands, verification, Conventional Commits. Durable knowledge
  lives in `docs/` (`docs/README.md` governs it), lightweight work
  notes in `work/` (`work/README.md` governs it); the README closest
  to the files you change governs.
- **Never push commits and never publish artifacts to a remote
  registry unless explicitly asked.**
