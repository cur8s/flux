# RFCs

This repository is the **foundation** that independent component repositories build on. These
RFCs are the foundation's **applied philosophy**: the architectural invariants that keep the
foundation — and every layer built on top of it — coherent as it spreads across many
repositories and tracks a fast-moving upstream ecosystem.

If you want to understand not just *how* this repo works but *why it is shaped the way it is*,
start here. The narrative motivation behind these constraints lives in
[../why/](../why/README.md); the RFCs encode that motivation as normative rules.

For the authority, lifecycle, and supersession model of RFCs, read
**[RFC-001](RFC-001-role-of-rfcs.md)** first.

## How to read

RFC numbers are stable identifiers, not a reading order (see [RFC-001](RFC-001-role-of-rfcs.md)).
The groups below are a curated reading path. A higher number is not "more important" than a
lower one.

## The RFCs

### Foundations — the mental model and posture

| RFC | Title | What it fixes |
|-----|-------|---------------|
| 001 | The Role of RFCs | What an RFC is, the authority it carries, and how it evolves. |
| 002 | Platform vs Applications | Every resource is either *platform* (defines the cluster) or *application* (runs on it). |
| 003 | Curated, Opinionated Platform | Flexibility is a cost; the platform decides so users don't have to. |
| 004 | Headless Platform | No platform-owned UI. The Kubernetes API is the only interface. |

### Declarative control — how intent enters and converges

| RFC | Title | What it fixes |
|-----|-------|---------------|
| 005 | Declarative Cluster Control | Authoritative intent lives outside the cluster, versioned. |
| 006 | Static Runtime Manifests | Render once, reconcile forever. No runtime templating. |
| 007 | Environment-Specific Inputs | Per-cluster values enter by pure substitution, never interpretation. |
| 008 | Declarative Readiness | Ordering and dependencies are declared, never scripted. |

### Versioning & distribution — the multi-repo heart

| RFC | Title | What it fixes |
|-----|-------|---------------|
| 009 | Semantic Versioning & Upstream Tracking | Immutable, semver'd artifacts; a new upstream release produces a new artifact. |
| 010 | Component Repositories & OCI Distribution | How an independent repo publishes its artifact and how a cluster composes many. **(new)** |
| 011 | Bootstrap Contract | Comes up on a bare cluster with zero pre-existing secrets; how the artifact is applied. **(new)** |

### Composition — how independent repos form one platform

| RFC | Title | What it fixes |
|-----|-------|---------------|
| 012 | Layer Architecture | A *layer* is a repo; layers form a cross-repo DAG via OCI references. |
| 013 | Layer Configuration | Each config key has exactly one owning layer; sensitivity picks ConfigMap vs Secret. |

### Security posture

| RFC | Title | What it fixes |
|-----|-------|---------------|
| 014 | Workload Identity Federation | Prove *identity*; don't ship static credentials. |

### The GitOps engine — this repository's component

| RFC | Title | What it fixes |
|-----|-------|---------------|
| 015 | Flux as the GitOps Engine | Which Flux controllers are permitted/forbidden, and the opinionated config this repo ships. |

## What is intentionally not here

This foundation defines *cross-cutting* invariants plus the GitOps engine. Component-specific
contracts live in the repository that owns the component:

- routing (Gateways, access classes) → the routing repo
- external secrets (ESO mechanics) → the secrets repo
- managed Postgres, observability, and so on → their own repos

A single, user-facing "platform version" that composes many component artifacts into one
release is a **composition** concern and belongs to a future umbrella/release repo, not the
foundation.

## Status

All 15 RFCs (001–015) are written. RFCs 002–008 and 014 adapt well-settled prior art; 009–013
and 015 are written fresh for the independent multi-repo model and are where the real design
work lives.
