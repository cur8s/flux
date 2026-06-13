# RFC-002: Platform vs Applications

**Status:** Accepted

Given a Kubernetes cluster, the platform interprets its contents as belonging to
**two distinct layers**:

- **Platform**
- **Applications**

Every Kubernetes resource and change is classified according to this model.
The distinction is based on **intent**—what a workload exists to do and who
it exists to serve. This model is how the platform reasons about responsibility,
ownership, and architectural change.

## Platform

The platform consists of workloads that define the **shape and behavior of the
cluster itself**. Platform workloads exist to support other workloads rather
than to deliver application-specific functionality.

The platform establishes cluster-wide capabilities and invariants that all
applications rely on. Because platform behavior affects everything in the
cluster, it is intentionally small and slow to change.

The platform does not adapt itself to individual applications. When a platform
component begins to answer questions about how a specific application should be
deployed or configured, the boundary has been crossed.

## Applications

Applications are workloads that deliver **application-specific or
business-specific behavior**. They consume platform capabilities but do not
define them.

Applications are expected to vary widely and evolve independently. The platform
does not manage application lifecycles directly; instead, applications adapt to
the platform.

## Classifying Changes

If a workload defines or enforces cluster-wide behavior, it belongs to the
platform. If a change modifies platform-owned resources, it is a platform change.
If a workload exists to serve a single application or team, it belongs to the
application layer. Proposals that require exceptions in the platform to satisfy
a specific workload are rejected by default.

## Scope

This RFC defines **how the platform interprets the contents of a Kubernetes
cluster**. It does not describe tools, workflows, or operational procedures.

## Revisions

Initial version.
