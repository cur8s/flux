## RFC-014: Cur8s Layer Configuration

**Status:** Accepted

Cur8s layers each have their own environment-specific configuration. A
single cluster-wide configuration blob does not match the layered
architecture defined in [RFC-013](RFC-013-cur8s-layer-architecture.md).
This RFC defines how configuration is partitioned per layer, how
sensitivity drives the kind of resource used, how layers consume each
other's configuration, and how configuration becomes part of a layer's
versioned contract.

## The Problem

Configuration ownership is a structural concern. When configuration is
shared cluster-wide, it is unclear which layer is responsible for any
given key, drift becomes possible (the same value written in multiple
places, updated inconsistently), and the question *"what configuration
does this layer require?"* has no compact answer.

The shared-configuration model also conflates two different sensitivity
profiles. A cluster's primary domain name is public — it is announced in
DNS, visible in URLs, used in certificate Common Names. An admin
password for a metrics dashboard is sensitive. Treating both with the
same mechanism either over-protects public values (forcing them through
a secret store unnecessarily) or under-protects sensitive values
(committing them to Git). Neither is appropriate.

Configuration must therefore be partitioned along two axes:
**ownership** (which layer introduces a value) and **sensitivity**
(public vs sensitive). The mechanism follows from the partition.

## Core Rule

**Each configuration key has exactly one owning layer. A layer may
consume keys from itself or from any layer it declares as a dependency.
Public values live in ConfigMaps committed to Git in the cluster
artifact. Sensitive values live in Secrets materialized via External
Secrets from an external secrets store.**

This rule preserves Cur8s' principles of single source of truth, clear
layer ownership, externalized intent
([RFC-004](RFC-004-declarative-cluster-control.md)), declarative
secret handling ([RFC-012](RFC-012-external-secrets.md)), and the
layered architecture itself
([RFC-013](RFC-013-cur8s-layer-architecture.md)).

## Ownership

A configuration key is **introduced** by exactly one layer — the layer
that requires the value to fulfill its contract. Examples:

- `CORE_ENV_NAME` is introduced by core (used to construct paths to
  other layers' secrets in the external store).
- `ROUTING_SYSTEM_DOMAIN` is introduced by routing (used for gateway
  listener hostnames).
- `OBS_BASIC_AUTH_PASS` is introduced by observability (used to gate
  access to observability UIs).

Layers above a key's owning layer may consume that key by including
the owner's config in their substitution chain. They do not redeclare
the key. Drift is impossible because there is exactly one place each
value is defined.

## Naming Convention

Every configuration key is prefixed with the introducing layer's name
in upper-case, separated by an underscore:

```
<LAYER>_<KEY>
```

For example: `CORE_CLUSTER_NAME`, `ROUTING_SYSTEM_DOMAIN`,
`OBS_BASIC_AUTH_PASS`, `POSTGRES_BACKUP_BUCKET`.

This convention is **enforced**, not stylistic. It serves three
purposes:

- A reader of any manifest sees `${ROUTING_SYSTEM_DOMAIN}` and knows
  immediately which layer owns the value.
- Greppability: searching for a key's owner is mechanical.
- Collision-free: a layer cannot accidentally define a value already
  introduced upstream.

A key whose prefix does not match its owning layer is a bug.

## Sensitivity Drives the Kind

Each layer's configuration is split into two optional resources:

- **`<layer>-config`** — a `ConfigMap`, committed to Git in the
  cluster artifact, holding non-sensitive values. Operator-authored,
  reviewable in code review, openly inspectable in the cluster.
- **`<layer>-secret`** — a `Secret`, materialized by an
  `ExternalSecret` pulling from the external secrets store, holding
  sensitive values. Operator-authored in the external store, never in
  Git, materialized into the cluster declaratively per
  [RFC-012](RFC-012-external-secrets.md).

A layer declares only the resources it actually needs. A layer with no
sensitive values has no `<layer>-secret`. A layer with no public
configuration has no `<layer>-config`.

Both kinds are equally valid sources for Flux post-build substitution;
the kind is determined by the value's sensitivity, not by uniformity.

## The Substitution Chain

Each layer's outer Flux `Kustomization` declares a `postBuild.substituteFrom`
list that walks the dependency DAG defined in
[RFC-013](RFC-013-cur8s-layer-architecture.md). The list includes,
for each layer in the chain (the layer itself and every transitive
dependency), whichever of `<layer>-config` and `<layer>-secret` that
layer has declared.

For example, observability (depends on core and routing) substitutes
from:

```yaml
postBuild:
  substituteFrom:
    - kind: ConfigMap
      name: core-config
    - kind: ConfigMap
      name: routing-config
    - kind: ConfigMap
      name: observability-config        # if it has non-secret values
    - kind: Secret
      name: observability-secret        # for BasicAuth, admin creds
```

A layer's chain is mechanically derivable from its declared
dependencies. No layer reads from a layer it has not declared a
dependency on.

## The Cluster Artifact Provides Configuration

The platform OCI artifacts (e.g., `cur8s-core`, `cur8s`) are
environment-agnostic. Per [RFC-009](RFC-009-environment-specific-inputs.md)
and [RFC-013](RFC-013-cur8s-layer-architecture.md), env-specific
inputs live in the cluster artifact — the per-deployment configuration
applied on top of the platform.

The cluster artifact contains one config resource declaration per layer
that requires configuration:

```
<cluster-artifact>/
└── config/
    ├── core-config.yaml             # ConfigMap with literal values
    ├── routing-config.yaml          # ConfigMap with literal values
    ├── observability-secret.yaml    # ExternalSecret reference
    └── postgres-secret.yaml         # ExternalSecret reference (when needed)
```

Each environment (dev, staging, prod) maintains its own cluster
artifact with its own config values. Adding a new environment is
adding a new cluster artifact directory.

## Layer Configuration as Contract

A layer's set of introduced configuration keys is part of its
versioned contract:

- **Adding a new configuration key** the layer optionally consumes
  is a minor version increment for the layer.
- **Adding a new required key** with no sensible default is a major
  version increment (it changes the operator's bootstrap obligations).
- **Renaming or removing a key** is a major version increment.

This applies the same SemVer commitment defined for core in
[RFC-015](RFC-015-cur8s-core.md) to layer configuration generally.
Per-layer RFCs (one per layer) declare the layer's specific config
schema and any subsequent changes to it.

## The Bootstrap Exception

The credential the External Secrets Operator uses to reach the
external secrets store is the one secret applied outside the GitOps
loop, per [RFC-012](RFC-012-external-secrets.md). That secret is
applied at cluster bootstrap and is not part of any layer's
configuration.

`core-config` is a second exception: it is **Git-authored**, not
ESO-flowed, even though some of its values (like `CORE_ENV_NAME`)
could in principle be sensitive. The reason is structural: ESO uses
`CORE_ENV_NAME` to construct paths into the external secrets store
when materializing every other layer's secrets. If `core-config`
itself flowed through ESO, ESO could not start. core-config therefore
contains only non-sensitive identity values, lives in a `ConfigMap`,
and is part of the bootstrap input authored at cluster setup.

These two exceptions — the ESO bootstrap secret and `core-config` —
are minimal and load-bearing. Every other piece of Cur8s configuration
flows declaratively from one of the two mechanisms defined above.

## Forbidden Patterns

Cur8s explicitly forbids:

- a configuration key being defined in more than one layer
- a layer reading configuration from a layer it has not declared as a
  dependency
- a key whose `<LAYER>_` prefix does not match the layer that
  introduces it
- storing public, non-sensitive values in `Secret` resources for
  uniformity rather than for protection
- storing sensitive values in `ConfigMap` resources or in Git
- using a single cluster-wide configuration source for keys that
  belong to multiple layers
- creating a `<layer>-config` or `<layer>-secret` for a layer that
  does not actually need configuration of that kind

## Scope

This RFC defines **how configuration is partitioned per layer, what
mechanism each kind uses, and how layers consume each other's
configuration**.

It does not enumerate specific configuration keys per layer — those
are defined in per-layer RFCs. It does not define the choice of
external secrets store provider or the cluster artifact build
pipeline; those are implementation concerns.

## Revisions

Initial version.
