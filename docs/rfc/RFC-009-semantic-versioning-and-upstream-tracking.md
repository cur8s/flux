# RFC-009: Semantic Versioning & Upstream Tracking

**Status:** Accepted

A foundation built on a fast-moving ecosystem derives most of its day-2 cost not
from installation but from *keeping current*. Kubernetes and the controllers
around it release continuously; security fixes arrive without warning. This RFC
defines how a component repository relates to time and change: how its artifacts
are versioned, and how it tracks the upstream it packages.

This RFC governs a **single component repository tracking a single upstream**
(here: this repo tracks Flux). Composing several independently-versioned
component artifacts into one user-facing "platform version" is a separate
concern that belongs to a composition/umbrella repository, not the foundation
— see [RFC-010](RFC-010-component-repositories-and-oci-distribution.md).

## Core Rule

**Each component publishes immutable, semantically versioned OCI artifacts.
A published version always refers to the same bytes and the same behavior, and
is never re-tagged or modified in place. New behavior is a new version.**

Immutability is what gives a version number meaning rather than making it
advisory. It is also what makes [RFC-006](RFC-006-static-runtime-manifests.md)
("render once, reconcile forever") enforceable across time: a cluster pinned to
`flux:2.8.8` reconciles the same manifests today and a year from now.

## Versioning Scheme

A component artifact's version is derived from the upstream it packages, plus a
revision for opinion-only changes:

```
<upstream-version>[-<config-revision>]
```

- `2.8.8` — packages upstream Flux v2.8.8 with this repo's opinionated config.
- `2.8.8-2` — same upstream, but the opinionated configuration changed (a patch
  added, a feature gate flipped) without an upstream bump. The suffix increments;
  the upstream component is unchanged.

This keeps the relationship to upstream legible at a glance and avoids inventing
a parallel version line that operators would have to map back to Flux.

## Upstream Tracking

The opinionated configuration is the **stable** part of a component repository;
the upstream version **advances underneath it**.

- A new upstream release SHOULD produce a new artifact **promptly and
  automatically**. Tracking upstream is the normal, continuous mode of
  operation, not an event — delayed patching is how security and correctness
  decay.
- Each candidate version is qualified by the repository's own end-to-end test
  (build → cluster → bootstrap → reconcile → verify) before publication. A
  version that does not pass e2e is not published.
- The mechanism (a CI job that watches the upstream release feed, bumps
  `VERSION`, rebuilds, runs e2e, and publishes) is an implementation concern.
  The invariant is that advancement is **tested and recorded in git**, never
  silent.

## Apply, Never Select

The platform may **apply** an explicitly declared version; it may never
**select** one. Version advancement is an authoring-time act — a human or a CI
job changes the declared version and records it in version control. Nothing
inside the cluster discovers, chooses, or rolls forward to a new version on its
own. This is why image-automation controllers are forbidden
([RFC-015](RFC-015-flux-as-the-gitops-engine.md)): they would let the cluster
cross a version boundary that was never declared.

## Forbidden Patterns

- Re-tagging or mutating an already-published version.
- Publishing a version that has not passed the repository's e2e.
- Runtime discovery or auto-selection of new versions inside the cluster.
- Inventing a version line unrelated to the upstream it packages.

## Scope

This RFC defines how a component repository versions its artifacts and tracks
its upstream. It does not define artifact coordinates or how clusters compose
multiple components (that is
[RFC-010](RFC-010-component-repositories-and-oci-distribution.md)), nor the CI
implementation.

## Revisions

Initial version.
