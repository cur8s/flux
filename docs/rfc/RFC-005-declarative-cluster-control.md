# RFC-005: Declarative Cluster Control

**Status:** Accepted

The platform requires **declarative cluster control**.

Kubernetes is a declarative system built around reconciliation loops. However,
it is still possible to operate a cluster through ad-hoc commands issued
directly with **kubectl**. While these commands apply declarative resources,
the sequence of decisions that produced the current state is not preserved,
making it difficult to understand, reproduce, or reason about the cluster over
time.

The desired state is authoritative only when it is declared **outside the
cluster and versioned**. Ad-hoc interaction with the cluster is limited to
**inspection** in all environments and to **temporary mutation only during
local development**. In production, ad-hoc mutation is never authoritative and
is not an accepted mode of control.

This establishes a clear separation between **decision-making** and **execution**.
Decisions are made externally and recorded durably; the cluster's role is to
converge toward those decisions through reconciliation.

Declarative cluster control requires an external representation of intent that
is **versioned, reviewable, reproducible, and independent of the live cluster**.
Git repositories and immutable OCI images are well-understood formats that
satisfy these requirements.

## Behavioral Consequences

Given declarative cluster control, the platform acts as a
**convergent executor**, not an operational target for ad-hoc commands.

The platform is composed of **independently published component artifacts**,
each representing some part of the **Platform layer** defined in
[RFC-002: Platform vs Applications](RFC-002-platform-vs-applications.md). Each
artifact is built, versioned, and released independently of any specific
cluster.

Cluster-specific intent is declared separately from these artifacts. A cluster
is described by external declarations that select specific component artifact
versions and compose them with application-level intent and minimal
environment-specific configuration. For example, a cluster may declare that it
runs a particular set of component versions, is configured for the domain
**myapp.com**, and deploys a set of applications on top. The declaration does
not modify the artifacts themselves; it records how a particular cluster
combines approved releases with its applications and environment-specific
settings, forming the authoritative description of what that cluster should run.

Humans, automation, and AI agents express change by modifying these external
declarations rather than operating the live cluster directly. There is no
separate operational interface: all actors follow the same path—change intent,
then rely on reconciliation for execution. This keeps behavior mechanical,
predictable, and safe to drive programmatically.

## Scope

This RFC defines **how authoritative cluster intent is controlled and applied**.

It does not define how intent is rendered, how reconciliation is implemented,
or which specific tools are used. Those details are addressed in subsequent RFCs.

## Revisions

Initial version.
