# RFC-006: Static Runtime Manifests

**Status:** Accepted

The platform requires **static runtime manifests**.

Kubernetes is a declarative system, and the platform already requires that
cluster intent be externalized and versioned (as defined in
[RFC-005: Declarative Cluster Control](RFC-005-declarative-cluster-control.md)).
However, even with versioned, external intent, it is still common for that
intent to be **interpreted at runtime**—through templating, parameter
substitution, or environment-dependent logic executed inside the cluster.

A common example is in-cluster templating using Helm controllers, where charts
render different resources depending on the cluster state. For instance, a chart
may conditionally create resources based on the presence of certain CRDs, API
versions, or existing controllers. In these cases, the same chart version and
values can produce different manifests across clusters or over time, even though
the versioned source has not changed. The final runtime state cannot be inferred
from Git alone.

This form of runtime interpretation undermines predictability. It becomes
difficult to reason about behavior, reproduce identical clusters, or explain why
environments diverge despite sharing the same declared intent. The cluster is no
longer just executing decisions; it is making them.

The platform does not permit this ambiguity. All decisions that affect cluster
behavior must be resolved **before** manifests reach the cluster. At runtime,
the cluster only ever reconciles fully rendered, static manifests. This
constraint is often summarized as **render once, reconcile forever**.

## Decision Time vs. Runtime

**Decision time** occurs outside the cluster. This is where composition,
configuration selection, variable resolution, and environment-specific choices
are made. The result is a complete, unambiguous set of manifests.

At **runtime**, the cluster does not evaluate conditions, select between
alternatives, or interpret configuration. It compares observed state to the
declared manifests and converges mechanically. The cluster executes; it does
not decide.

Static runtime manifests therefore have the following properties:

- they are fully rendered before being applied
- they contain no unresolved variables or conditionals
- they describe a complete desired state
- they can be applied repeatedly with the same result

Once declared, these manifests are treated as immutable intent. Any change
requires producing a new set of manifests rather than modifying behavior at
runtime.

Reconciliation then enforces this intent continuously. It detects divergence,
converges the system toward the declared state, corrects drift automatically,
and repeats indefinitely. Reconciliation does not reinterpret intent or
introduce new information; it enforces what has already been decided.

## Why This Constraint Exists

This constraint reflects the needs described in the
[why essays](../why/README.md) and the realities of a solo developer or small
team playing the long game. Static runtime manifests favor systems that are easy
to reason about, reproduce, and recover, even after long periods of time. By
removing runtime interpretation, the platform prioritizes clarity and
predictability over short-term convenience, allowing limited time and attention
to compound rather than being spent rediscovering how a system behaves.

## Scope

This RFC defines **the semantic constraint placed on runtime behavior**.

It does not define how manifests are rendered, which tools perform rendering,
or how reconciliation is implemented. Those concerns are addressed in
subsequent RFCs.

## Revisions

Initial version.
