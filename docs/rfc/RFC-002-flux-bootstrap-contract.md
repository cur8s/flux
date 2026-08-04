# RFC-002: The Flux Bootstrap Contract

**Status:** Accepted

Flux is the chicken-and-egg component: every other artifact is
reconciled *by* the engine this package installs, so this one cannot
rely on that engine for its own first install — and it must come up on
a cluster where nothing exists yet. The properties that make that
possible are easy to erode accidentally, and once eroded they fail
exactly when recovery matters most: on a fresh or rebuilt cluster.

## Core Rule

**Flux comes up on a bare cluster with zero pre-existing secrets. Its
images pull anonymously from registries with no practical rate limit,
no ServiceAccount references an imagePullSecret, and missing inputs
fail closed. First touch is one `kubectl apply` of an HTTP-addressable
manifest; from then on Flux self-manages from the OCI artifact.**

## Bootstrap Properties

- **No rate-limited registries.** Images pull from `ghcr.io` only —
  never `docker.io` or any registry that throttles anonymous pulls. A
  bare cluster with public internet access installs the engine without
  authenticating.
- **No imagePullSecrets.** Pulling the engine cannot depend on a secret
  that itself would have to be bootstrapped.
- **Zero secrets, full stop.** The engine requires no secret to
  install or to run. The platform's one permitted bootstrap secret
  belongs to the secrets layer
  ([cur8s RFC-010](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-010-external-secrets.md)),
  not to the engine.
- **Fail closed.** A missing required input blocks reconciliation
  visibly; it is an operator-visible stall, never a silent default.

## The Dual-Publish Mechanism

A release publishes one rendered artifact through two channels:

1. **OCI artifact** — `oci://ghcr.io/cur8s/flux:<version>`, the
   steady-state channel. Once the engine runs, an `OCIRepository` +
   the artifact's own `sync.yaml` Kustomization make it continuously
   **self-manage** from this artifact; advancing the tag is how Flux
   upgrades itself.
2. **GitHub release asset** — an exact copy of
   `oci/flux/deploy/flux.yaml` attached to the versioned GitHub release
   as `install.yaml`, so first-touch bootstrap is a single command:

   ```bash
   kubectl apply --server-side -f \
     https://github.com/cur8s/flux/releases/download/<version>/install.yaml
   ```

   A release asset is immutable with its release and needs no branch
   to maintain — `kubectl` cannot apply `oci://`, and this is the one
   blessed HTTP path.

The tag-triggered release workflow builds and pushes the full OCI artifact,
then copies that build's `deploy/flux.yaml` to the GitHub release unchanged as
`install.yaml`.

The bootstrap sequence: **apply the release asset once** (controllers
come up idle), **then apply the `OCIRepository` + `sync.yaml`** (the
engine begins self-managing from the OCI artifact). From that point on,
all change flows through declared, versioned intent.

## Forbidden Patterns

- Images from rate-limited registries; `imagePullSecrets` on any
  ServiceAccount; any secret required before the engine can install.
- Publishing a version's OCI artifact without its release asset, or
  the reverse — the two channels are one release.
- Silent defaulting when a required input is absent.

## Scope

This RFC defines how this component bootstraps and self-manages. What
the package installs is [RFC-001](RFC-001-opinionated-flux-configuration.md);
the org-wide packaging contract every component follows lives in the
flagship RFC set.

## Revisions

Initial version — descends from the pre-alignment RFC-011, reduced to
the flux side; first-touch mechanism fixed as the GitHub release asset
(2026-07-07).
