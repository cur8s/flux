## RFC-009: Environment-Specific Inputs

**Status:** Accepted

Cur8s enforces a strict separation between immutable platform artifacts and 
environment-specific cluster configuration.

The Cur8s Platform is delivered as a versioned artifact composed of multiple 
Kubernetes resources installed together to establish shared infrastructure and 
behavior. These resources may have structural dependencies on one another and,
in some cases, require environment-specific values to be valid at installation 
time. For example, a public DNS domain used by shared ingress resources, 
identifiers for externally managed DNS zones, or references to secrets 
provisioned outside the platform. Platform artifacts are built once, released 
as a unit, and reused across clusters. They are intentionally generic and do 
not embed environment-specific details.

A cluster exists in a specific environment and role—such as development, 
staging, or production—and must be configured accordingly to operate correctly.
That role determines concrete external bindings: domain names, external 
endpoints, certificate references, and integrations with systems that exist 
outside the cluster itself. These values cannot be known or fixed at platform
build time, yet some platform resources must reference them when installed.

Without an explicit contract, this requirement can appear to create a circular
dependency: the platform is immutable and environment-agnostic, yet some of its
resources must reference environment-specific values at installation time. 
This RFC establishes the contract that resolves that tension while preserving 
immutability, determinism, and declarative control.

## Core Rule

**Platform artifacts are immutable.  
Clusters may supply a limited set of environment-specific inputs.  
Those inputs may affect composition, but never interpretation.**

This rule preserves Cur8s’ core invariants:

- Authoritative intent remains external ([RFC-004: Declarative Cluster Control](RFC-004-declarative-cluster-control.md)).
- Runtime manifests remain static ([RFC-005: Static Runtime Manifests](RFC-005-static-runtime-manifests.md)).
- Platform releases remain immutable and versioned ([RFC-006: Semantically Versioned Platform Evolution](RFC-006-semantically-versioned-platform-evolution.md)).
- Reconciliation remains mechanical and deterministic ([RFC-008: Flux as the GitOps Engine](RFC-008-flux-as-the-gitops-engine.md)).

## Allowed Environment-Specific Inputs

Cur8s permits a **small, explicit class of environment-specific inputs** that 
describe **cluster identity**, not platform behavior.

Examples include:

- primary DNS domain
- externally managed DNS zone identifiers
- environment name (e.g., `prod`, `staging`)
- cluster name or identifier
- references to externally managed secrets

These inputs describe *where* the platform is running. They do not control 
*how the platform behaves*. They do not enable or disable features, alter 
control flow, or introduce conditional logic.

## Where Environment-Specific Inputs Live

Environment-specific inputs are declared **outside the platform artifact**.

Platform artifacts are built once and reused unchanged. Cluster configuration 
supplies identity inputs explicitly and declaratively. All such inputs are
visible, reviewable, and versioned alongside cluster configuration.

## How Inputs Are Applied

Environment-specific inputs may be applied only through 
**structural composition**, not runtime interpretation.

Cur8s permits composition mechanisms that:

- operate on already-rendered YAML
- do not evaluate conditions
- do not fetch dependencies
- do not vary output based on cluster state
- produce deterministic results given the same inputs

The result is a **fully resolved, static set of manifests**. At runtime, the 
cluster only reconciles those manifests; no interpretation or decision-making 
occurs.

### Illustrative Example (Non-Normative)

Cur8s applies environment-specific inputs using **Kustomize post-build 
substitution** as part of declarative reconciliation.

Post-build substitution is permitted because it is **pure value substitution**,
not templating. It does not evaluate conditions, inspect cluster state, fetch 
external data, or perform computation. It operates only on the fully rendered 
YAML provided to it, replacing explicit placeholders with explicit values. In
this sense, it is equivalent to deterministic search-and-replace, not 
interpretation.

In Cur8s, environment-specific values are supplied **explicitly and 
externally**, typically via a ConfigMap that represents cluster configuration. 
Post-build substitution consumes only what is declared; if a required value is
missing, reconciliation fails rather than guessing or defaulting. This failure
is intentional and makes the missing environment configuration visible 
immediately.

For illustration, a reconciliation unit may declare that environment-specific 
values are sourced from a ConfigMap and substituted into platform manifests at 
composition time:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: platform
spec:
  postBuild:
    substituteFrom:
      - kind: ConfigMap
        name: cluster-config
```

The referenced ConfigMap might contain environment identity such as:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-config
# Environment-specific identity for this cluster.
# These values are supplied by the cluster configuration,
# not embedded in the platform artifact.
data:
  CLUSTER_DOMAIN: example.com
```

In this model, the platform artifact remains immutable. The cluster supplies its
environment identity explicitly. If the ConfigMap or required keys are missing,
reconciliation does not proceed. When present, the final manifests are produced
deterministically before reconciliation.

At runtime, the cluster only applies static YAML. No interpretation, branching,
or decision-making occurs.

This example is illustrative only and does not prescribe a specific layout, 
schema, or configuration.

## Forbidden Patterns

Cur8s explicitly forbids using environment-specific inputs for:

- feature flags or conditional platform behavior
- per-cluster enablement or disablement of platform capabilities
- branching logic based on environment
- runtime evaluation based on cluster state
- arbitrary configuration injection into platform components

Any mechanism that turns cluster configuration into a general-purpose templating
or feature system violates this RFC.

## Per-Layer Partitioning

Environment-specific inputs **are partitioned per layer**.

[RFC-013](RFC-013-cur8s-layer-architecture.md) defines Cur8s as a composition
of named layers, each with its own responsibility and contract. Some layers 
require their own environment-specific inputs (routing requires domain names; 
observability requires admin credentials). Other layers require none. There 
is no single cluster-wide configuration source; each input has exactly one 
owning layer.

[RFC-014](RFC-014-cur8s-layer-configuration.md) defines how this partitioning
works mechanically: each layer that requires inputs declares its own
`<layer>-config` (ConfigMap, for non-sensitive values) and/or `<layer>-secret`
(Secret, for sensitive values). A layer's Flux Kustomization composes these
sources in dependency order.

The principles in this RFC are unchanged by per-layer partitioning: inputs
are external to platform artifacts, declared explicitly in cluster
configuration, applied through pure substitution, and produce fully resolved
manifests at composition time. Per-layer partitioning does not introduce
templating, branching, or interpretation — it organizes the same substitution
mechanism around the architectural unit defined in
[RFC-013](RFC-013-cur8s-layer-architecture.md).

## Scope

This RFC defines **the contract governing how environment-specific inputs 
interact with Cur8s platform artifacts**.

It does not define how platform or cluster resources are ordered, phased, or 
sequenced during reconciliation; that contract is defined in a separate RFC. 
It also does not enumerate specific parameters, define schemas, or describe
implementation details. Those concerns are addressed in platform-specific RFCs
and implementation documentation. Per-layer partitioning of inputs is defined
in [RFC-014](RFC-014-cur8s-layer-configuration.md).

## Revisions

Initial version.
