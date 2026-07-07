# flux — foundation + GitOps engine

This repository plays two roles:

1. **The foundation.** It holds the cross-cutting architectural philosophy —
   the [RFCs](docs/rfc/README.md) — that every other component repository built
   on top of it inherits.
2. **One component: an opinionated Flux.** It packages a specific, constrained
   configuration of [Flux](https://fluxcd.io) and publishes it as an OCI
   artifact. A new upstream Flux release becomes a new published artifact.

It is an independent, single-purpose repository. Other layers (routing,
external-secrets, cert-manager, postgres, observability, …) live in their own
repositories and build on the contracts defined here.

## The opinionated Flux

- **Three controllers only:** source, kustomize, notification.
- **Forbidden:** helm-controller (in-cluster templating) and the
  image-automation controllers (would let Flux *select* versions).
- **No feature gates** — the install is exactly what `flux install --export`
  produces for the three controllers.
- Comes up on a **bare cluster with zero pre-existing secrets**; images from
  `ghcr.io`; no `imagePullSecrets`.

The *why* behind each of these is in the RFCs — start with
[RFC-015: Flux as the GitOps Engine](docs/rfc/RFC-015-flux-as-the-gitops-engine.md).

## How it is distributed (dual-publish)

The same rendered manifest is published two ways
([RFC-011](docs/rfc/RFC-011-bootstrap-contract.md)):

- **OCI artifact** `oci://<registry>/flux:<version>` — the steady-state channel.
  Once Flux runs, an `OCIRepository` + `Kustomization` make it **self-manage**
  from this artifact; bumping the tag is how Flux upgrades itself.
- **HTTP-addressable install manifest** — for first-touch bootstrap, since
  `kubectl` cannot apply an `oci://` reference directly:

  ```bash
  kubectl apply --server-side -f https://<host>/flux/releases/download/<version>/install.yaml
  ```

## Quickstart (local)

Requires: `docker` and [mise](https://mise.jdx.dev) — `mise install`
fetches the rest of the toolchain at pinned versions (flux, kustomize,
kubeconform, kubectl, k3d, jq).

```bash
mise install              # pinned toolchain (one-time)
mise run artifact:build   # fetch (flux install --export) → render → validate
mise run test:e2e         # ephemeral k3d cluster: build → push → bootstrap → self-manage → verify
```

Or step by step against a persistent dev cluster:

```bash
mise run cluster:create   # create k3d cluster + local registry
mise run artifact:build   # build the artifact tree
mise run artifact:push    # push the OCI artifact to the cluster's local registry
mise run cluster:init     # bootstrap Flux (kubectl apply of the rendered manifest)
mise run cluster:sync     # apply OCIRepository + Kustomization → Flux self-manages
mise run cluster:verify   # controllers + self-management Ready?
```

`mise tasks` lists every task; the task grammar is documented in the
[`mise.toml`](mise.toml) header.

## Tracking upstream Flux

```bash
mise run upstream:check   # is there a newer upstream Flux release than VERSION?
```

The opinionated configuration is the stable part; the Flux version in
[`VERSION`](VERSION) advances under it (the `mise.toml` flux pin tracks it).
Each version is qualified by `mise run test:e2e` before publication
([RFC-009](docs/rfc/RFC-009-semantic-versioning-and-upstream-tracking.md)).

## Layout

```
VERSION                     # the upstream Flux version this repo tracks
mise.toml                   # pinned toolchain + task grammar (see its header)
mise-tasks/
  artifact/                 # clean, fetch, render, validate, build, push
  cluster/                  # create, delete, status, init, sync, verify, watch (+ k3d lib/config)
  test/                     # e2e (ephemeral full loop), drift (committed tree == fresh build)
  upstream/                 # check (newer upstream release?)
  release                   # build + publish the versioned artifact
docs/
  rfc/                      # the foundation's RFCs (001–015) — see docs/rfc/README.md
  why/                      # the philosophy the RFCs encode
scripts/
  lib/display.sh            # shared display vocabulary for all tasks
src/flux/
  config/                   # VERSION, sync.yaml, notes.md, overlays/deploy (the opinion)
  artifacts/                # FETCH.lock + fetched upstream (vendored, audit trail)
oci/flux/                   # rendered artifact tree (committed — git diff = review surface)
  cur8s.yaml                #   release descriptor (inert — the artifact's identity)
  deploy/flux.yaml          #   install manifest (what bootstrap applies)
  sync.yaml                 #   self-management Kustomization
```

The rendered output under `oci/` is committed deliberately: every version bump
or config change shows up as a reviewable `git diff` of the exact bytes that
will be deployed ([RFC-006](docs/rfc/RFC-006-static-runtime-manifests.md)).

## Status

Built and validated end-to-end on a live k3d cluster: the opinionated config
for the tracked [`VERSION`](VERSION) renders and validates, publishes as an
OCI artifact, bootstraps, self-manages, and self-upgrades (re-push → Flux
reconciles the change into its own install).
