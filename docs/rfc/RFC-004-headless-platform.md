# RFC-004: Headless Platform

**Status:** Accepted

The platform is a **headless platform**. It does not provide, depend on, or
curate a built-in user interface. It exposes only the canonical Kubernetes APIs
and declarative state, and deliberately delegates interaction, visualization,
and workflow to external tools chosen by the user. This is a strategic decision
enabled by the maturity and universality of the Kubernetes API.

## Why Headless Works

The Kubernetes API is the interaction contract. It provides a single,
authoritative view of the desired and actual state and is designed to be driven
directly by external clients. Because this API is sufficient, the platform does
not provide or maintain a graphical user experience. Interaction happens
entirely through the API, making humans, automation, and AI agents equal
participants that operate on the same contract and observe the same state.

The platform is designed for solo builders and small teams playing the long
game. In that context, investing in durable foundations matters more than
short-term convenience. The Kubernetes API and its standard interfaces are
primitives that remain relevant across providers, environments, and years of
evolution. By remaining headless, the platform intentionally biases users
toward skills and tools that compound over time.

## Canonical Interface and Ecosystem Alignment

The platform assumes **kubectl** as the canonical, baseline interface to the
Kubernetes API. kubectl is the reference client and defines what it means to
interact with Kubernetes in a direct, scriptable, and observable way. Mastery of
kubectl and the underlying resource model is treated as the primary interaction
skill for working with the platform.

The Kubernetes ecosystem reinforces this model through established extension
patterns, such as kubectl plugins and project-specific CLIs that speak the same
API vocabulary rather than introducing new control planes. The platform aligns
with this approach and does not invent a separate interaction abstraction.

## Layered Interaction Tools

On top of the canonical CLI, the ecosystem provides richer interaction layers
that remain API-faithful and do not require changes to the platform.
For example:

**[k9s](https://k9scli.io)**
A terminal-based user interface that provides real-time visibility into cluster
state and resource management. It accelerates interactive exploration while
remaining a thin layer over the Kubernetes API.

**[Headlamp](https://headlamp.dev)**
A CNCF project offering a graphical interface that runs in the browser or as a
desktop application. It connects directly to the Kubernetes API and provides an
extensible, API-faithful view of cluster resources. Headlamp includes a
pluggable extension model that enables package- or project-specific user
interfaces—such as tailored views for cert-manager or Flux—without changing the
underlying platform.

These tools are illustrative, not required. Any tool that speaks the Kubernetes
API can be layered on top without changing the platform.

## Scope

This RFC defines the **interaction posture** and **assumed usage model** of the
platform. It does not prescribe which tools users should adopt, nor does it
document how specific CLIs, TUIs, or GUIs work. Those choices are deliberately
left to users and to the broader Kubernetes ecosystem.

## Revisions

Initial version.
