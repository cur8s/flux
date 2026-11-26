## RFC-013: Cur8s Layer Architecture

**Status:** Accepted

Cur8s is composed of named **layers**, not a flat collection of components.
Each layer has a defined responsibility, declared dependencies on other
layers, and a contract describing what it provides upward. This RFC
defines what a layer is, how layers compose, how they are tested, and how
they relate to the user-facing platform release.

## The Problem

A platform with a meaningful number of components has a meaningful number
of *kinds* of component. Some components establish foundational mechanisms
(GitOps reconciliation, secret distribution, certificate issuance). Others
get traffic in and out (gateways, mesh ingress). Others observe what's
happening (metrics, logs, traces). Others provide stateful storage. These
groups have different stability profiles, different change cadences,
different blast radii, and often different audiences.

Treating them as a flat set of components works at small sizes but loses
architectural meaning as the system grows. The questions *"what does
component X depend on?"*, *"can I update component Y safely?"*, *"what
must be running before component Z can come up?"* become answerable only
by reading every component and tracing references. Reasoning becomes
implicit when it should be explicit.

A layer model solves this by making the groups first-class. Each
component belongs to exactly one layer; each layer's responsibility is
named; the dependencies between layers are declared and machine-readable.
Architectural reasoning becomes structural rather than archaeological.

## Core Rule

**Cur8s is composed of named layers. Each layer has a single named
responsibility, declares its dependencies on other layers explicitly,
and provides a documented contract to the layers above it. Layers form
a directed acyclic graph; cycles are forbidden.**

This rule is the structural commitment behind every other rule in this
RFC.

## What Constitutes a Layer

A layer is **not** an arbitrary grouping. A subset of components forms a
layer when:

- It has a coherent, nameable responsibility — *"this layer brings up
  declarative control"*, *"this layer routes traffic"*, *"this layer
  observes the cluster"*.
- The components within it interact more tightly with each other than
  with components outside it.
- Removing or replacing the layer is a deliberate architectural change,
  not a routine update.
- The layer's contract to the layers above it can be stated in a few
  sentences.

Groupings that fail these tests are not layers. *"Things that ship
together"* is not a layer. *"The big one"* is not a layer. *"Everything
else"* is not a layer.

## Layers Today

Cur8s currently defines four layers:

- **core** — establishes declarative control, secret distribution, and
  certificate issuance. Composed of Flux, External Secrets Operator, and
  cert-manager. Defined in detail by [RFC-015](RFC-015-cur8s-core.md).
- **routing** — establishes ingress and egress paths for the cluster.
  Composed of envoy-gateway today; will include Tailscale and similar in
  the future.
- **observability** — establishes metrics, logs, and traces collection
  and visualization. Composed of VictoriaMetrics, fluent-bit, and
  Grafana.
- **postgres** — establishes managed PostgreSQL. Composed of
  CloudNativePG.

Adding a new layer is a structural change to Cur8s and requires its own
RFC defining the layer's responsibility, contract, and CRD surface.
Removing a layer is similarly significant. Renaming a layer is a major
version event for the layered structure.

## Dependencies Form a DAG

Layers declare their dependencies on other layers explicitly. The
dependency graph is acyclic.

Today's graph:

```
core
├── routing                (depends on core)
│       └── observability  (depends on core, routing)
└── postgres               (depends on core)
```

Each layer can reach upstream resources, contracts, and configuration
freely; it cannot reach downstream. observability may consume routing's
gateways; routing may not assume observability is present.

A layer's dependencies must include every layer whose contract it
relies on. Implicit or "convenient" cross-layer references are
forbidden — every consumed dependency is named.

## What a Layer Provides

A layer's **contract** is the named set of things layers above it can
rely on. A contract typically includes:

- **CRDs the layer installs** that downstream layers may create custom
  resources of (e.g., routing installs Gateway API CRDs; observability
  installs VictoriaMetrics CRDs).
- **Named resources** the layer creates that downstream layers may
  reference (e.g., core's `platform-issuer` ClusterIssuer, routing's
  `cur8s-apps-gateway` and `cur8s-system-gateway` Gateways).
- **Configuration keys** the layer introduces that downstream layers may
  consume (defined in [RFC-014](RFC-014-cur8s-layer-configuration.md)).

The contract is what makes a layer a stable unit. When the contract
changes, downstream layers may need to adapt — that change is a major
version event for the layer.

### Layer-Installed, Cluster-Parameterized Resources

A common case for the *named resources* bullet above deserves explicit
treatment: a layer commits to installing a resource by a well-known name,
but the resource's values are parameterized by cluster-supplied
configuration.

The split is:

- The **layer** owns the resource's *existence*, *kind*, *name*, and
  *structural shape* (the fields that don't vary across clusters).
  The layer installs the resource as part of its reconciliation; cluster
  operators do not author the resource themselves.
- The **cluster** owns the *parameter values* that the layer's resource
  references. These flow in through the substitution chain defined in
  [RFC-014](RFC-014-cur8s-layer-configuration.md).
- **Components above** reference the resource by its well-known name
  without knowing the parameter values. Their attachment is stable across
  clusters because the name is stable.

This pattern lets the platform offer a strong contract — *"every cur8s
cluster has resource X with name Y"* — while preserving environment
freedom over the values that genuinely vary. Examples include named
ClusterIssuers from a certificates layer or named Gateways from a routing
layer. Adding a new such resource is a layer responsibility; renaming or
removing one is a major version event for the layer.

## The Verify Model

Each layer's installation is verifiable at three tiers, mirroring the
layered structure:

- **Component verify** — checks the resources that a single component
  owns and is responsible for. *"Is grafana's deployment ready and is
  its HTTPRoute attached?"*
- **Layer verify** — assumes every component in this layer and every
  layer this layer depends on has been verified. Checks that the
  components in this layer compose correctly into the layer's contract.
  *"Given metrics + logs + traces components are healthy, can a query
  to grafana resolve a metric from VictoriaMetrics?"*
- **Integration verify** — assumes every layer is verified. Checks
  cross-layer flows that no single layer owns. *"Does an HTTP request
  to a public app produce a log entry that fluent-bit ships to
  VictoriaLogs and is queryable from grafana?"*

Component verifies live with the component. Layer verifies live with
the layer. Integration verifies live in the cluster artifact (today
`src/test/`).

A failure at any tier short-circuits the tiers above it: layer verify
is not informative if components are broken; integration verify is
not informative if layers are broken.

## Layering Discipline

A layer may only create custom resources whose Custom Resource
Definitions (CRDs) are installed by itself or by a layer it declares as
a dependency.

Kubernetes rejects creation of a custom resource whose CRD is not
present. A layer that creates such a resource therefore cannot
reconcile, and a layer below it cannot install the missing CRD without
violating the dependency direction. The reconciliation graph cannot
start. This is the bootstrap-deadlock failure mode.

This rule generalizes the layering discipline introduced for core in
[RFC-015](RFC-015-cur8s-core.md): downstream layers see everything
upstream, but an upstream layer cannot see downstream. Cross-layer
interactions therefore live in the layer that installs the relevant
CRD — for example, monitoring scrapes for routing's controllers are
defined in observability and use cross-namespace selection.

## Relationship to OCI Artifacts

Layer organization and OCI packaging are **separable concerns**.

A layer is a source/runtime organization concept: it defines where
components live, how dependencies flow, how testing is structured.
OCI packaging is a release-engineering concern: how the platform is
published, versioned, and consumed by Flux.

Some layers earn their own OCI artifact because they have a stable
contract worth versioning independently. core does today
([RFC-015](RFC-015-cur8s-core.md)). Other layers may earn their own
artifact in the future when their contracts stabilize. Layers that
do not have an artifact-worthy contract are bundled into the
user-facing release artifact (`cur8s`), still organized by layer
internally.

This relationship is governed by [RFC-007](RFC-007-single-continuously-advancing-version-line.md):
the user-facing release is a single advancing version. The internal
artifact composition — how many artifacts, which layers each artifact
contains — is invisible to users.

## Naming Convention

Source organization mirrors the layer structure:

```
src/<layer>/<component>/
```

For example: `src/core/cert-manager/`, `src/routing/envoy-gateway/`,
`src/observability/victoria-metrics/`.

Per-layer aggregator paths follow:

- `src/<layer>/Makefile`
- `src/<layer>/kustomization.yaml`
- `src/<layer>/verify`

The Flux Kustomization graph mirrors the dependency DAG: each layer's
outer Kustomization in the cluster artifact declares `dependsOn` for
every layer it depends on.

## Forbidden Patterns

Cur8s explicitly forbids:

- cycles in the layer dependency graph
- a layer creating custom resources whose CRDs are not installed by
  itself or a declared dependency
- a layer reading a contract or resource from a layer it has not
  declared as a dependency
- merging two layers without architectural justification ("they happen
  to be small" is not justification)
- reorganizing components into layers in a way that does not pass the
  test for what constitutes a layer

## Scope

This RFC defines **what a layer is, how layers compose into the platform,
how they are tested, and their relationship to the user-facing release**.

It does not enumerate the contracts of specific layers — those are
defined in per-layer RFCs (e.g., [RFC-015](RFC-015-cur8s-core.md) for
core, future RFCs for routing, observability, postgres). It does not
prescribe the configuration mechanism — that is defined in
[RFC-014](RFC-014-cur8s-layer-configuration.md). It does not define
build pipeline, OCI artifact naming, or directory layout beyond the
naming convention; those are implementation concerns.

## Revisions

Initial version.
