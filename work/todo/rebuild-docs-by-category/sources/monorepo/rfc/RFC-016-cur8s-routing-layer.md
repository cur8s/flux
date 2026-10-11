## RFC-016: Cur8s Routing Layer

**Status:** Accepted

The routing layer establishes the cluster's ingress contract: how HTTP
traffic enters the cluster, how cur8s components expose themselves to
their audiences, and how cluster operators control what's actually
reachable from where. This RFC defines the routing layer's composition,
its access-class contract, and the responsibility split between layer
and cluster.

Routing is one specific application of the layer pattern defined in
[RFC-013](RFC-013-cur8s-layer-architecture.md). Like core
([RFC-015](RFC-015-cur8s-core.md)), it makes a stable contract that
layers above can rely on; its specifics live here.

## The Problem

Every cur8s cluster has components that expose HTTP surfaces. Some are
**user-facing applications** — workloads the operator deploys for their
end users to consume. Others are **operator-facing tools** — grafana,
metrics UIs, log explorers, future cluster-management interfaces — that
serve the people running the cluster, not its users.

These two audiences have fundamentally different exposure requirements:

- Applications typically need to be reachable from the public internet
  (or whatever audience the operator has chosen to expose to). Their
  hostnames are publicly resolvable; their endpoints face untrusted
  clients.
- Operator-facing tools must NOT be publicly reachable in production.
  They expose privileged interfaces to the cluster's internals; their
  hostnames may be private; their endpoints are reachable only from
  trusted networks (VPNs, mesh networks, or operator workstations).

Without an explicit contract, every cur8s component would have to make
its own decisions about how to expose itself, the operator would have to
configure exposure per component, and components would inevitably leak
exposure assumptions into their manifests (*"my UI is reachable at
https://X"*, baked in). The platform would become unmaintainable.

The routing layer solves this by providing **two well-known access
classes** that components classify themselves into. Components don't
own their exposure; they declare their audience. The cluster decides
how each audience is reached.

## Core Rule

**The routing layer provides exactly two access classes via well-known
Gateway resources. Cur8s components MUST attach their HTTPRoutes to one
of these Gateways based on the route's audience. The routing layer
guarantees the access-class semantics; the exposure mechanism for each
class is cluster-configurable through routing's per-layer configuration.**

This rule is the structural commitment behind every other rule in this
RFC.

## The Two Access Classes

Cur8s defines exactly two access classes, named after Cloud Foundry's
long-established system-domain / apps-domain split:

- **apps class** — for end-user applications. Realized as the Gateway
  resource named `cur8s-apps-gateway`, listening on the apps domain
  hostname pattern. Cluster operators expose this for their target
  audience (typically the public internet, but configurable).
- **system class** — for cur8s administrative and operational
  interfaces. Realized as the Gateway resource named
  `cur8s-system-gateway`, listening on the system domain hostname
  pattern. Cluster operators expose this restricted to administrators
  (typical: a private network, a Tailscale tailnet, a VPN, or operator
  workstations only).

A cur8s cluster always has both. Components above routing rely on these
names existing.

## Layer Contract

Per [RFC-013](RFC-013-cur8s-layer-architecture.md), the routing layer
provides a contract that downstream layers and components consume:

**Named resources installed by the layer** (Layer-Installed,
Cluster-Parameterized Resources per RFC-013):

- `standard-gateway-class` — a `GatewayClass` referencing the
  envoy-gateway controller. Installed by the envoy-gateway component.
- `cur8s-apps-gateway` — a `Gateway` for the apps class. Installed by
  the gateways component.
- `cur8s-system-gateway` — a `Gateway` for the system class. Installed
  by the gateways component.

**Configuration keys introduced** (consumed via the substitution chain
defined in [RFC-014](RFC-014-cur8s-layer-configuration.md)):

- `ROUTING_APPS_DOMAIN` — the apps class hostname suffix (e.g.,
  `apps.example.com`). Used in the apps Gateway listener and in
  HTTPRoutes attaching to it.
- `ROUTING_SYSTEM_DOMAIN` — the system class hostname suffix (e.g.,
  `sys.example.com`). Used in the system Gateway listener and in
  HTTPRoutes attaching to it.

Additional configuration keys may be introduced as exposure mechanisms
expand (see *Exposure Mechanism* below).

## Component Obligation

Every cur8s component that exposes an HTTP surface MUST attach its
HTTPRoute to one of the two well-known Gateways:

- Components serving end users → `cur8s-apps-gateway` (apps class).
- Components serving operators → `cur8s-system-gateway` (system class).

This classification is part of each component's contract. Where a
component lands is declared in the component's own RFC (when written)
or in its source comments. A component MUST NOT create its own Gateway
resource; the platform contract is that the routing layer's two
Gateways are the only attachment points for cur8s-native components.

Application workloads deployed by operators on top of cur8s also use
this contract: their HTTPRoutes attach to `cur8s-apps-gateway`. The
classification is mechanical: if it's a tool the cluster operator runs,
it's system; if it's an application the operator hosts, it's apps.

## Exposure Mechanism

How each access class is *reached from the outside world* is a cluster
concern, not a layer concern. The routing layer creates the Gateway
resources and the underlying envoy-gateway controllers serve them; the
cluster controls how each Gateway's traffic flow is exposed.

The mechanism today is the `Service` of `type: LoadBalancer` that
envoy-gateway creates per Gateway. Customizing it (for example, setting
`loadBalancerClass`) is done through an `EnvoyProxy` resource referenced
by the Gateway's `spec.infrastructure.parametersRef`. Cluster
configuration drives which `loadBalancerClass` each access class uses.

Concretely (illustrative; actual configuration keys to be locked when
the Tailscale and EnvoyProxy work lands):

- Default — no `loadBalancerClass`: the cluster's default LB (k3d's
  built-in for development, or a cloud LB in production) handles the
  Service. Both access classes reachable via that mechanism.
- `loadBalancerClass: tailscale`: a Tailscale operator running in the
  routing layer picks up the Service and exposes it on the cluster's
  tailnet. Typical for the system class in production deployments where
  operators want admin tools reachable only from tailnet members.
- Cloud-specific LB classes for the apps class (e.g., AWS NLB, GCP LB)
  when those features are required.

The Gateway resources themselves DO NOT change as exposure mechanisms
vary. Components attached to them remain unchanged. Operators
reconfigure exposure by changing routing's per-layer configuration; the
contract above is preserved.

### Illustrative Example (Non-Normative)

A future routing-config Secret might look like:

```
ROUTING_APPS_LB_CLASS:    ""              # default LB for apps
ROUTING_SYSTEM_LB_CLASS:  "tailscale"     # system reachable only on tailnet
ROUTING_TAILSCALE_AUTH_KEY: <secret>      # Tailscale operator credential
```

In this configuration, end users reach apps over the public LB; cluster
operators reach grafana and other system-class UIs only after joining
the cluster's tailnet. Components attached to either Gateway are
unaffected by this configuration; their HTTPRoutes work identically.

This example is illustrative; specific configuration keys, the
EnvoyProxy resources used to apply them, and the Tailscale operator's
integration are to be locked in subsequent revisions of this RFC when
the supporting work lands.

## Composition

The routing layer today contains:

- **envoy-gateway** — the Gateway API controller, plus the
  `standard-gateway-class` GatewayClass it provides via its finalize
  phase.
- **gateways** — the two access-class Gateway resources installed by
  the layer as its named-resource contract.

Future components in routing:

- A Tailscale operator providing tailnet-based exposure for Services
  with `loadBalancerClass: tailscale`. Lands when the tailnet exposure
  configuration is wired through routing-config.
- Per-Gateway `EnvoyProxy` resources customizing the Service template
  (carrying `loadBalancerClass` and similar exposure parameters).

These additions extend the layer's exposure-mechanism flexibility
without changing the access-class contract above.

## Layering Discipline

Per [RFC-013](RFC-013-cur8s-layer-architecture.md), routing depends on
core (Flux for reconciliation, ESO for any sensitive layer config,
cert-manager for TLS material on the Gateways' future HTTPS listeners).
Routing may not depend on observability, postgres, or any layer above
it.

Routing's CRD use is restricted to the Gateway API surface
(`gateway.networking.k8s.io` v1 kinds: `GatewayClass`, `Gateway`,
`HTTPRoute`) and the envoy-gateway-specific extensions
(`EnvoyProxy`) only when needed for exposure customization. Adopting
additional Gateway API kinds (TLSRoute, GRPCRoute, etc.) is a routing
contract extension and a minor version event for the layer.

## Forbidden Patterns

Cur8s explicitly forbids:

- cur8s components creating their own Gateway resources
- cur8s components attaching HTTPRoutes to Gateways other than
  `cur8s-apps-gateway` or `cur8s-system-gateway`
- introducing a third access class without an architectural review
  (a third named class is a structural change requiring an amendment to
  this RFC)
- baking exposure assumptions into component manifests (e.g., "this
  component is reachable via Tailscale at hostname X")
- moving the Gateway resources out of the routing layer into the
  cluster artifact (the Gateways are platform-named convention, not
  cluster definition)
- defining the GatewayClass anywhere except inside the controller
  component that fulfills it (per RFC-013's Layer-Installed,
  Cluster-Parameterized Resources pattern)

## Scope

This RFC defines **what the routing layer is, the contract it commits
to, and the responsibility split between routing's components and the
cluster operator**.

It does not define:

- HTTPS / TLS configuration on the Gateways. When wired, will be a
  refinement of this RFC.
- The specific Tailscale operator integration or its full configuration
  schema. The illustrative example above sketches the direction; the
  locked design lands with the implementing PR.
- Per-component classification rules (which components belong to apps
  vs system class). Each component's own RFC declares its classification.
- Cloud-specific exposure mechanisms or their configuration. These
  extend routing's exposure mechanism without changing the contract.

## Revisions

Initial version.
