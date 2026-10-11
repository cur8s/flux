# Cur8s RFCs

This directory contains the Cur8s **Request for Comments (RFCs)**.

RFCs are a core part of the Cur8s system. They document the **architectural philosophy, constraints,
and invariants** that allow Cur8s to evolve without losing its identity. These documents are
intentionally opinionated and **selective**: they describe what must remain true, not everything
that Cur8s can do.

## What these documents are

Cur8s RFCs are **applied philosophy**.

They explain *why* Cur8s makes certain architectural commitments and *what must remain true* as the
platform evolves. RFCs are not tutorials, not usage guides, and not historical decision logs.

If the *[Why documents](../why/README.md)* describe how to **think** about the problem space, RFCs
describe how Cur8s **acts** within that space.

For a precise definition of the role and authority of RFCs, start with
**[RFC-000: The Role of RFCs in Cur8s](RFC-000-role-of-rfcs.md)**.

## How to read the RFCs

RFC numbers are **stable identifiers**, not a reading order. They exist to provide durable
references, not to imply chronology or importance.

- RFC IDs are never renumbered or reused.
- The order in which RFCs should be read is curated and may evolve.
- A newer RFC is not necessarily more important than an older one.

If you are new to Cur8s, begin with the **Foundational RFCs** below, then proceed based on the area
you are interested in.

## RFC Groups

RFCs are grouped by the architectural concerns they define. These groups are for reader orientation
only; they do not imply layering or dependency unless explicitly stated in an RFC.

### Foundational Model

These RFCs define Cur8s’ core mental model and philosophical stance.

- **[RFC-000: The Role of RFCs in Cur8s](RFC-000-role-of-rfcs.md)**
  Defines what RFCs are, how they evolve, and the authority they carry.

- **[RFC-001: Cur8s Cluster Model](RFC-001-cur8s-cluster-model.md)**
  Defines how Cur8s interprets the contents of a Kubernetes cluster.

- **[RFC-002: Curated Opinionated Platform](RFC-002-curated-opinionated-platform.md)**
  Explains why Cur8s favors curation and constraint over flexibility.

- **[RFC-003: Headless Platform](RFC-003-headless-platform.md)**
  Establishes the absence of platform-owned user interfaces and workflows.

### Declarative Control and Execution

These RFCs define how intent enters the system and how it is enforced.

- **[RFC-004: Declarative Cluster Control](RFC-004-declarative-cluster-control.md)**
  Establishes externalized, versioned intent as the only source of truth.

- **[RFC-005: Static Runtime Manifests](RFC-005-static-runtime-manifests.md)**
  Requires all runtime state to be fully rendered before reconciliation.

- **[RFC-009: Environment-Specific Inputs](RFC-009-environment-specific-inputs.md)**
  Defines the contract for env-specific inputs into platform artifacts.

- **[RFC-010: Declarative Readiness](RFC-010-declarative-readiness.md)**
  Defines how readiness and dependency ordering are enforced declaratively.

- **[RFC-008: Flux as the GitOps Engine](RFC-008-flux-as-the-gitops-engine.md)**
  Selects Flux and constrains how it is used within Cur8s.

- **[RFC-014: Cur8s Layer Configuration](RFC-014-cur8s-layer-configuration.md)**
  Defines per-layer configuration ownership, sensitivity-driven kind
  selection (ConfigMap vs Secret), naming convention, and the
  substitution chain that walks the dependency DAG.

### Composition and Layering

These RFCs define how Cur8s is structured into layers and how layers
compose into the platform.

- **[RFC-013: Cur8s Layer Architecture](RFC-013-cur8s-layer-architecture.md)**
  Defines what a layer is, how layers form a DAG, the verify model
  (component → layer → integration), and the relationship between layers
  and OCI artifacts.

- **[RFC-015: Cur8s Core](RFC-015-cur8s-core.md)**
  Defines the core layer (Flux, ESO, cert-manager) and its contract: CRD
  surface, bootstrap properties, SemVer commitment. One specific
  application of the layer pattern.

- **[RFC-016: Cur8s Routing Layer](RFC-016-cur8s-routing-layer.md)**
  Defines the routing layer: two access classes (apps, system) realized
  as well-known Gateway resources, the component obligation to classify
  HTTPRoutes by audience, and the cluster-controlled exposure mechanism
  (default LB, Tailscale, etc.).

### Change, Evolution, and Support

These RFCs define how Cur8s evolves over time.

- **[RFC-006: Semantically Versioned Platform Evolution](RFC-006-semantically-versioned-platform-evolution.md)**
  Defines how platform changes are expressed and interpreted.

- **[RFC-007: Single, Continuously Advancing Version Line](RFC-007-single-continuously-advancing-version-line.md)**
  Establishes the support and upgrade contract between Cur8s and its users.

### Identity and Secrets

These RFCs define how authentication and secret material are handled.

- **[RFC-011: Workload Identity Federation](RFC-011-workload-identity-federation.md)**
  Establishes identity-first access as the preferred model.

- **[RFC-012: External Secrets](RFC-012-external-secrets.md)**
  Defines how secrets are handled when workload identity federation is not possible.

## RFC lifecycle and evolution

RFCs are **authoritative but revisable**.

They preserve Cur8s’ design intent while allowing understanding to deepen over time.

- RFCs may be refined to improve clarity or make implicit reasoning explicit.
- Refinements are made in place and recorded in a **Revisions** section.
- Changes that alter meaning, scope, or invariants must be made via a **new RFC** that explicitly
  supersedes the old one.

In Cur8s, breaking an RFC is an architectural change.

Full details of the refinement and supersession model are defined in
**[RFC-000: The Role of RFCs in Cur8s](RFC-000-role-of-rfcs.md)**.

## File naming conventions

RFC filenames follow a strict, stable pattern:

```
RFC-<number>-<short-slug>.md
```

Examples include `RFC-000-role-of-rfcs.md`, `RFC-004-declarative-cluster-control.md`.

- The RFC number is the canonical identifier.
- Filenames are lowercase, hyphenated, and URL-safe.
- Filenames are not renamed if titles evolve.
- The full, expressive title belongs inside the document itself.

This convention ensures stable links across platforms and tooling.

## Adding or changing RFCs

Ask the following before proposing a new RFC:

- Does this introduce a **new invariant or constraint**?
- Or does it merely describe how something is implemented today?

If a change clarifies or strengthens existing reasoning, refine the relevant RFC.  
If a change violates or replaces an existing invariant, propose a new RFC that explicitly supersedes
the old one.

RFCs exist to protect the Cur8s way of thinking.  
If you find yourself working around an RFC, you are likely violating Cur8s’ design intent.

## Relationship to other documentation

The *[Why documents](../why/README.md)* explain the philosophical motivations behind Cur8s.

RFCs encode those motivations as **architectural constraints**.

Usage guides, design notes, and operational documentation live elsewhere. Each serves a different
purpose. None replace the others.

## Summary

Cur8s RFCs are not about consensus or flexibility.  
They exist to provide **clarity, constraint, and long-term coherence**.

If you align with the philosophy they express, contributions are welcome.  
If not, Cur8s is likely not the platform you are looking for.
