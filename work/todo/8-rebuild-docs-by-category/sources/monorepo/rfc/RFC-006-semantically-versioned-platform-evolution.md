## RFC-006: Semantically Versioned Platform Evolution

**Status:** Accepted

Cur8s treats **platform evolution as a first-class architectural concern**.

A useful Kubernetes platform derives much of its value from the ecosystem it 
builds on: Kubernetes itself, controllers, operators, and supporting services. 
That same ecosystem evolves rapidly. Kubernetes releases multiple times per 
year, and the surrounding projects tend to follow. In addition, security 
patches and CVEs arrive continuously.

In practice, this means that even a modest platform composed of a small set of
core components is subject to constant change pressure. For a small team or solo
developer, the real cost is not installing the platform on Day-1, but keeping it
correct, secure, and understandable on Day-2 and beyond. Without a disciplined
approach to versioning and upgrades, clusters drift, fixes accumulate, and 
operational knowledge decays faster than it can be rebuilt.

Cur8s is designed for this reality. It assumes that change is continuous and 
unavoidable, and that the only sustainable strategy is to make change 
**explicit, mechanical, and repeatable**.

## Immutable, Semantically Versioned Platform

Cur8s evolves the Platform using **semantic versioning**, treating version 
numbers as a precise statement of compatibility, safety, and intent. A given 
Platform version uniquely defines a specific composition and its expected 
behavior, and operators and automation can rely on that meaning remaining stable.

Platform versions are **immutable once released**. A published version always 
refers to the same content and behavior and is never modified in place, 
re-tagged, or retroactively changed. If behavior must change, a new version is 
published. Immutability is what gives version numbers real meaning rather than 
making them advisory.

Semantic versioning defines the scope of change:

- **Patch versions** represent safe, compatible changes and are expected to be
  applied **automatically and continuously**.
- **Minor versions** introduce new capabilities without breaking existing 
  assumptions and require deliberate adoption but are designed to require
  minimal effort or planning
- **Major versions** introduce breaking changes and require explicit migration 
   and planning.

Because versions are immutable and semantically defined, advancing a cluster is 
always an intentional act. A cluster evolves by declaring a new Platform version
as part of its external, versioned intent and allowing reconciliation to 
converge to that version.

## Scope

This RFC defines **how the Cur8s Platform relates to time and change** through 
semantic versioning.

It does not define how long versions are supported, how patch streams are 
maintained, how upgrades are automated, or which tools enforce version 
transitions. Those concerns are addressed in subsequent RFCs.

## Revisions

Initial version.
