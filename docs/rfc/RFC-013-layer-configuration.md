# RFC-013: Layer Configuration

**Status:** Accepted

Each layer needs its own environment-specific configuration: a routing layer
needs domain names, an observability layer needs admin credentials, the
foundation needs cluster identity. A single cluster-wide configuration blob does
not fit the layered, multi-repository model: ownership becomes unclear, the same
value drifts across places, and *"what does this layer require?"* has no compact
answer. Configuration must be partitioned by **ownership** (which layer
introduces a value) and **sensitivity** (public vs secret).

## Core Rule

**Each configuration key has exactly one owning layer. A layer may consume keys
from itself or from any layer it declares as a dependency. Public values live in
ConfigMaps committed to git in the cluster artifact; sensitive values live in
Secrets materialized from an external secrets store. The kind follows the
sensitivity, not uniformity.**

This preserves single-source-of-truth, clear ownership, externalized intent
([RFC-005](RFC-005-declarative-cluster-control.md)), and the layered
architecture ([RFC-012](RFC-012-layer-architecture.md)).

## Ownership and Naming

A key is **introduced** by exactly one layer — the one that requires it to
fulfill its contract. Every key is prefixed with the introducing layer's name,
upper-cased:

```
<LAYER>_<KEY>      e.g. CORE_CLUSTER_NAME, ROUTING_SYSTEM_DOMAIN, OBS_ADMIN_PASS
```

The convention is enforced, not stylistic: a reader sees `${ROUTING_SYSTEM_DOMAIN}`
and instantly knows which layer owns it; ownership is greppable; and a layer
cannot accidentally redefine a key introduced upstream. A key whose prefix does
not match its owning layer is a bug. Layers above may **consume** an upstream
key by including the owner's config in their substitution chain; they never
redeclare it, so there is exactly one definition of each value.

## Sensitivity Drives the Kind

Each layer's configuration splits into two optional resources:

- **`<layer>-config`** — a `ConfigMap`, committed to git in the cluster
  artifact, holding non-sensitive values (operator-authored, reviewable, openly
  inspectable).
- **`<layer>-secret`** — a `Secret`, materialized by an external-secrets layer
  from an external store, holding sensitive values (authored in the store, never
  in git).

A layer declares only what it needs; a layer with no secrets has no
`<layer>-secret`. Both are valid sources for Flux post-build substitution
([RFC-007](RFC-007-environment-specific-inputs.md)); the kind is chosen by the
value's sensitivity, never for uniformity.

## The Substitution Chain Is Assembled in the Cluster

Each layer's Flux `Kustomization` declares a `postBuild.substituteFrom` list
that walks the dependency DAG ([RFC-012](RFC-012-layer-architecture.md)): for
the layer itself and each transitive dependency, it includes whichever of
`<layer>-config` / `<layer>-secret` that layer declares. Because layers are
separate repositories, this chain is assembled in the **cluster artifact** that
composes them ([RFC-010](RFC-010-component-repositories-and-oci-distribution.md)),
not by a shared build. A layer never substitutes from a layer it has not
declared as a dependency.

## Configuration as Contract

A layer's set of introduced keys is part of its versioned contract
([RFC-009](RFC-009-semantic-versioning-and-upstream-tracking.md)):

- adding a new **optional** key — minor;
- adding a new **required** key with no sensible default — major (it changes the
  operator's bootstrap obligations);
- renaming or removing a key — major.

## Bootstrap Exceptions

Two minimal, load-bearing exceptions:

- The credential an external-secrets layer uses to reach its store is the one
  secret applied outside the GitOps loop ([RFC-011](RFC-011-bootstrap-contract.md)).
  It is not part of any layer's `<layer>-config`/`<layer>-secret`.
- The foundation's own identity configuration (e.g. cluster/environment name) is
  **git-authored**, not flowed through the external-secrets mechanism — because
  the foundation is the layer that *brings those mechanisms up*, so its own
  inputs cannot depend on them. It therefore holds only non-sensitive identity
  values, in a `ConfigMap`, authored at cluster setup.

## Forbidden Patterns

- A key defined in more than one layer.
- A layer reading configuration from a layer it has not declared as a
  dependency.
- A key whose `<LAYER>_` prefix does not match its introducing layer.
- Storing public values in `Secret`s for uniformity, or sensitive values in
  `ConfigMap`s / git.
- A single cluster-wide configuration source spanning multiple layers' keys.

## Scope

This RFC defines how configuration is partitioned per layer, what mechanism each
sensitivity uses, and how layers consume each other's configuration. It does not
enumerate any specific layer's keys (those live in each layer's repository), nor
choose an external secrets store.

## Revisions

Initial version.
