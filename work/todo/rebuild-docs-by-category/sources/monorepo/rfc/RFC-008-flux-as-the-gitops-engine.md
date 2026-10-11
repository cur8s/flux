## RFC-008: Flux as the GitOps Engine

**Status:** Accepted

Cur8s uses **Flux** as the GitOps engine for the Platform.

Cur8s requires a system that continuously reconciles declared intent without 
introducing new sources of authority, runtime interpretation, or hidden state.
Given the constraints already established by: externalized intent 
([RFC-004](RFC-004-declarative-cluster-control.md)), static runtime manifests 
([RFC-005](RFC-005-static-runtime-manifests.md)), semantically versioned platform
evolution ([RFC-006](RFC-006-semantically-versioned-platform-evolution.md)), and 
a single, continuously advancing version line 
([RFC-007](RFC-007-single-continuously-advancing-version-line.md)), 
a continuously running reconciler is mandatory.

Flux fits these constraints directly. Its modular, controller-based design
allows Cur8s to include only the reconciliation capabilities it requires while
forbidding others. Flux is headless by design: it introduces no platform-owned
user interface or workflow layer, and all interaction occurs through declarative
Kubernetes resources and the Kubernetes API itself, aligning with Cur8s’ 
headless platform model ([RFC-003](RFC-003-headless-platform.md)).
Flux is also pull-based and declarative, reconciling cluster state mechanically
and repeatably toward declared intent. Its small, understandable control surface
keeps the platform predictable and sustainable over time.

## Permitted Flux Controllers

Cur8s uses Flux in a **restricted, opinionated configuration**. Each permitted
Flux controller exists to enforce a specific architectural rule and nothing more.

### Source Controller

The Flux Source Controller materializes declared intent into the cluster. In
Cur8s, sources represent versioned, externalized artifacts that define platform
or application state, directly enforcing 
[RFC-004: Declarative Cluster Control](RFC-004-declarative-cluster-control.md). 
The Source Controller’s role is limited to fetching that intent and making it 
available for reconciliation; it does not generate, transform, or interpret intent.

### Kustomize Controller

The Flux Kustomize Controller applies fully rendered, static manifests and 
maintains convergence. It operates on already-resolved Kubernetes manifests and
applies them declaratively, enforcing 
[RFC-005: Static Runtime Manifests](RFC-005-static-runtime-manifests.md).

Kustomize overlays are permitted because they perform **structural composition**,
not runtime interpretation. They do not evaluate conditions, fetch dependencies,
or vary output based on cluster state. Given the same inputs, the rendered 
result is deterministic and identical across environments. This allows 
environment-specific composition without reintroducing runtime templating or 
hidden decision logic.

### Notification Controller

Where notifications are used, the Flux Notification Controller provides
observability into reconciliation events without affecting control flow. 
Notifications are informational only; they do not trigger actions, perform
orchestration, or influence platform behavior. This preserves Cur8s’ headless
model while allowing operators to observe system behavior.

## Forbidden Flux Controllers

Cur8s explicitly **forbids** the use of certain Flux controllers because they
violate Cur8s’ architectural constraints.

### Helm Controller

Cur8s **forbids** the Flux Helm Controller. The Helm Controller performs runtime
chart rendering, dependency resolution, and release state tracking inside the
cluster, introducing runtime interpretation, mutable state, and ordering 
concerns that directly conflict with 
[RFC-005: Static Runtime Manifests](RFC-005-static-runtime-manifests.md) and
[RFC-004: Declarative Cluster Control](RFC-004-declarative-cluster-control.md).
In Cur8s, Helm charts may be used only at build time to produce static YAML; 
Flux reconciles the rendered output and never `HelmRelease` resources.

### Image Automation Controllers

Cur8s **forbids** Flux from automatically advancing versions. Image automation 
would allow Flux to cross version boundaries without explicit declaration, 
violating [RFC-006: Semantically Versioned Platform Evolution](RFC-006-semantically-versioned-platform-evolution.md) 
and [RFC-007: Single, Continuously Advancing Version Line](RFC-007-single-continuously-advancing-version-line.md). 
Version advancement in Cur8s is always intentional and external; 
Flux may apply a new version, but it may never select one.

## Alternatives Considered

### [Argo CD](https://argo-cd.readthedocs.io/en/stable/)  

Argo CD provides a rich, UI-driven operational experience and encourages direct
interaction with application-state through that interface. While effective for 
many teams, this model introduces an additional operational surface and workflow
layer that Cur8s intentionally avoids. Cur8s requires a headless reconciler that
operates solely through declarative state and the Kubernetes API, without 
embedding a user interface or promoting UI-centric workflows as part of the 
platform.

### [Carvel](https://carvel.dev)  

Carvel aligns closely with Cur8s’ preference for build-time rendering,
deterministic artifacts, and small composable tools. However, Cur8s also 
optimizes for long-term ecosystem stability and adoption. Flux has a larger and
more diverse contributor base, broader industry usage, and stronger community
momentum independent of any single vendor. Given Cur8s’ long-horizon goals, 
Flux is considered the more stable foundation despite Carvel’s strong
philosophical fit.

## Scope

This RFC defines **how Flux is used and constrained within Cur8s**.

It does not describe Flux installation steps, controller configuration, build 
pipelines, or repository layout. The contract governing how cluster-specific 
inputs interact with the platform is defined in a follow-up RFC.

## Revisions

Initial version.
