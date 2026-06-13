# RFC-011: Bootstrap Contract

**Status:** Accepted

The foundation has to come up on a cluster where *nothing exists yet* — no
GitOps engine, no secrets, no registry credentials. The properties that make
that possible are easy to erode accidentally (a controller that pulls from a
rate-limited registry, a ServiceAccount that wants a pull secret), and once
eroded they fail exactly when recovery matters most: on a fresh or rebuilt
cluster. This RFC fixes the bootstrap contract the foundation commits to.

## Core Rule

**The foundation comes up from a bare cluster with zero pre-existing secrets.
Its images pull from registries with no practical anonymous rate limit, no
ServiceAccount requires an imagePullSecret, and missing inputs fail closed
rather than defaulting.**

This is load-bearing: it is what lets everything *above* the foundation receive
its secrets and credentials *through* the foundation (via GitOps and, later, an
external-secrets layer), instead of requiring those secrets to be in place
before the foundation can install.

## Bootstrap Properties

- **No rate-limited registries.** Foundation images pull from `ghcr.io` or
  `quay.io` only — never `docker.io` or any registry that throttles anonymous
  pulls. A bare cluster with public internet access must be able to pull the
  foundation without authenticating.
- **No imagePullSecrets.** No foundation ServiceAccount references a pull
  secret. Pulling the foundation cannot depend on a secret that itself has to
  be bootstrapped.
- **Fail closed.** If a required input (a config value, a referenced source) is
  missing, reconciliation blocks visibly rather than guessing or silently
  defaulting. A missing input is an operator-visible stall, not a latent
  misconfiguration.

## The Dual-Publish Bootstrap Mechanism

A foundation component is reconciled *by* the engine it installs, so it cannot
rely on that engine for its own first install. It is therefore published through
**two channels from the same rendered bytes**:

1. **OCI artifact** —
   `oci://<registry>/<component>:<version>`
   ([RFC-010](RFC-010-component-repositories-and-oci-distribution.md)). This is
   the steady-state channel: once the engine is running, an `OCIRepository` +
   `Kustomization` make it continuously **self-manage** from this artifact.
   Advancing the version is how it upgrades itself.
2. **HTTP-addressable install manifest** — the same rendered manifest attached
   to a versioned release (e.g. a GitHub Release asset), so first-touch
   bootstrap is a single command:

   ```
   kubectl apply --server-side -f https://<host>/<component>/releases/download/<version>/install.yaml
   ```

`kubectl` cannot apply an `oci://` reference directly — hence the second
channel. Both channels render from the same build, so they never diverge.

The bootstrap sequence is therefore: **apply the HTTP manifest once** (engine
comes up), **then apply the `OCIRepository` + `Kustomization`** (engine begins
self-managing from the OCI artifact). From that point on, all change flows
through declared, versioned intent.

## The One Permitted Secret (Not Here)

Exactly one secret is unavoidable in the larger platform: the credential an
external-secrets layer uses to reach its secret store. That is the single secret
an operator introduces manually, and it belongs to that future layer — **not to
this foundation**. The GitOps engine itself requires no secret to bootstrap.

## Forbidden Patterns

- Foundation images pulled from rate-limited registries.
- `imagePullSecrets` on any foundation ServiceAccount.
- Requiring any secret to exist before the engine can install.
- Distributing the bootstrap manifest *only* as an OCI artifact (nothing could
  apply it on a bare cluster) or *only* as a loose file (no immutable,
  self-managing artifact).
- Silent defaulting when a required input is absent.

## Scope

This RFC defines the bootstrap contract and the dual-publish mechanism. It does
not define artifact coordinates
([RFC-010](RFC-010-component-repositories-and-oci-distribution.md)), the engine's
controller set ([RFC-015](RFC-015-flux-as-the-gitops-engine.md)), or the
external-secrets layer that owns the one permitted bootstrap secret.

## Revisions

Initial version.
