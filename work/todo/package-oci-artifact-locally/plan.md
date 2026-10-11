# Plan: Package the OCI artifact locally

## Context

### Outcome

`mise run package` writes the Flux OCI artifact to git-ignored `dist/` with a recorded digest;
packaging an unchanged `oci/flux/` tree twice produces the same digest. `e2e` deploys that exact
artifact from the dev registry and Flux self-manages from it, and `publish` copies the same
digest to the production registry. The published digest equals the tested digest.

### Approach

Prove the mechanism with an experiment before changing phases. The experiment uses only local
registries (the k3d dev registry); nothing goes to ghcr until publication is explicitly requested.

Prefer a tool that can both build an on-disk OCI layout and copy it to a registry without
re-encoding (`oras` first); pin whichever tool wins in `mise.toml` and refresh `mise.lock`. Match
the media types `flux push artifact` produces today so `OCIRepository` needs no `layerSelector`.
If digests are not reproducible because of a timestamp or annotation, fix the input (fixed
timestamps, sorted tar) rather than accepting a changing digest.

Keep OCI metadata in one place: whatever builds the artifact owns the annotations that
`artifact:push` attaches today.

## Phases

### Phase 1: Experiment

Know whether a reproducible, Flux-compatible local artifact is possible and with which tool.

- [ ] Inspect the manifest, config, and layer media types and annotations of an artifact pushed
  by today's `artifact:push` to a k3d registry.
- [ ] Build an equivalent artifact from `oci/flux/` into an on-disk OCI layout with the candidate
  tool; package twice and compare digests.
- [ ] Copy the layout into a k3d registry, point an `OCIRepository` at it, and confirm Flux
  fetches it and the self-management Kustomization becomes Ready.
- [ ] Record the chosen tool, media types, and any reproducibility fixes in this plan.

### Phase 2: Wire package, e2e, and publish

- [ ] Implement `package` to write `dist/` and its digest; add `dist/` to `.gitignore`.
- [ ] Make `e2e` copy the packaged artifact into its cluster's registry instead of pushing from
  `oci/`, and `publish` copy the same artifact to `REGISTRY`.
- [ ] Move OCI annotation responsibility into `package`; retire or narrow `artifact:push`
  accordingly.

### Phase 3: Verify and document

- [ ] Run `check` and `e2e`; confirm the digest `e2e` deployed equals the digest in `dist/`.
- [ ] Update `docs/architecture.md` (artifact lifecycle and metadata) and CONTRIBUTING.
