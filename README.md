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
- **ExternalArtifact feature gate** enabled on kustomize-controller (qualified
  per Flux version).
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

Requires: `docker`, `k3d`, `kubectl`, `flux`, `kustomize`, `kubeconform`.

```bash
make build      # fetch (flux install --export) → render → validate
make e2e        # ephemeral k3d cluster: build → push → bootstrap → self-manage → verify
```

Or step by step against a persistent dev cluster:

```bash
make cluster    # create k3d cluster + local registry
make push       # build + push the OCI artifact to the local registry
make init       # bootstrap Flux (kubectl apply of the rendered manifest)
make sync       # apply OCIRepository + Kustomization → Flux self-manages
make verify     # controllers + self-management Ready?
```

`make help` lists every target.

## Tracking upstream Flux

```bash
make check-update   # is there a newer upstream Flux release than VERSION?
```

The opinionated configuration is the stable part; the Flux version in
[`VERSION`](VERSION) advances under it. Each version is qualified by `make e2e`
before publication ([RFC-009](docs/rfc/RFC-009-semantic-versioning-and-upstream-tracking.md)).

## Layout

```
VERSION                     # the upstream Flux version this repo tracks
Makefile                    # fetch → render → validate → cluster/init/push/sync/verify/e2e
docs/
  rfc/                      # the foundation's RFCs (001–015) — see docs/rfc/README.md
  why/                      # the philosophy the RFCs encode
scripts/
  cluster                   # k3d lifecycle (create/delete/env/status)
  lib/                      # display + verify helpers
  make/                     # init, push, sync, verify, validate, e2e, check-update
src/flux/
  config/                   # VERSION, sync.yaml, notes.md, overlays/deploy (the opinion)
  artifacts/                # FETCH.lock + fetched upstream (vendored, audit trail)
oci/flux/                   # rendered artifact tree (committed — git diff = review surface)
  deploy/flux.yaml          #   install manifest (what bootstrap applies)
  sync.yaml                 #   self-management Kustomization
```

The rendered output under `oci/` is committed deliberately: every version bump
or config change shows up as a reviewable `git diff` of the exact bytes that
will be deployed ([RFC-006](docs/rfc/RFC-006-static-runtime-manifests.md)).

## Status

Built and validated end-to-end on a live k3d cluster: opinionated v2.8.8 config
renders and validates, publishes as an OCI artifact, bootstraps, self-manages,
and self-upgrades (re-push → Flux reconciles the change into its own install).
