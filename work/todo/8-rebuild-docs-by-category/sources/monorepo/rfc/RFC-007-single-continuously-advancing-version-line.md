## RFC-007: Single, Continuously Advancing Version Line

**Status:** Accepted

Cur8s adopts a **single, continuously advancing version line** for the Platform.

Cur8s is a collection of Kubernetes components that evolve continuously. 
Security fixes, dependency updates, and behavioral changes are a constant 
reality in the Kuberentes ecosystem. Rather than attempting to hold the Platform 
still, Cur8s defines clear rules for how versions advance and what users can 
expect when patch, minor, or major releases occur.

This RFC defines the **contract between Cur8s maintainers and Cur8s users** for
how the Platform evolves over time. It makes explicit which changes are 
automatic, which require user intent, how long versions are supported, and
which upstream Kubernetes versions are in scope.

## Supported Kubernetes Versions

Cur8s supports **only currently supported upstream Kubernetes versions**.

At any given time, Cur8s targets Kubernetes versions that are actively supported
by the upstream Kubernetes project. Cur8s does not attempt to maintain 
compatibility with end-of-life or deprecated Kubernetes releases.

When Kubernetes versions fall out of upstream support, they are considered 
**out of scope** for Cur8s. Users are expected to keep their clusters within the
upstream-supported Kubernetes version window in order to run supported Cur8s 
releases.

This constraint is intentional. Cur8s is not designed to extend the lifespan of
unsupported Kubernetes versions. Doing so would dilute focus, increase the 
maintenance burden, and weaken security guarantees.

## When Cur8s Releases a Patch Version

Cur8s releases a **patch version** when changes are safe, compatible, and 
require **no user action**.

Patch releases typically include security fixes (CVEs), bug fixes, and low-risk
upstream updates. Patch versions advance **automatically and continuously** 
within the currently supported minor version line. There is no decision point
for users at the patch level; clusters are expected to consume patch updates via
automation as they are released.

This rule exists because security and correctness degrade quickly when patches
are delayed. In a fast-moving ecosystem, the safest posture is to treat patching
as a **baseline, continuous operation**, not an event that requires human review.

## When Cur8s Releases a Minor Version

Cur8s releases a **minor version** when the Platform introduces new capabilities
or meaningful behavioral changes that **do not require user migration or 
reconfiguration**.

A minor release may include integrating newer upstream component versions, 
adding Platform capabilities, or adjusting behavior in ways that remain 
backward-compatible from the user’s perspective. When a new minor version is 
released, it becomes the **only supported minor version line**. The previous 
minor version immediately falls out of support, and no further patch releases 
are issued for it.

Although only one minor version line is supported at a time, advancing to a new 
minor version is an **intentional act**. The absence of further patches on an 
older minor line does not imply immediate risk; it signals that the Platform has
moved forward. Users are expected to adopt new minor versions promptly, but 
deliberately, acknowledging the Platform’s evolution rather than allowing it to
change implicitly.

This approach prevents fragmentation and avoids the false sense of safety that 
comes from maintaining multiple stagnant version lines.

## When Cur8s Releases a Major Version

Cur8s releases a **major version** only when changes require **meaningful user 
action**, migration, or a shift in how the Platform is configured, operated, or
understood.

Major releases reflect changes to the Platform’s external contract rather than 
internal churn. Upstream component major version changes do not automatically 
imply a Cur8s major version bump. Cur8s versioning is based on 
**Cur8s user impact**, not raw upstream semantics. If Cur8s absorbs upstream 
change internally and preserves user-facing behavior, a minor version is 
sufficient.

When a new Cur8s major version is released, the previous major version enters a 
**short transition period**. During this period—expected to be on the order of
**a few months**—the previous major version may receive **critical security 
fixes and severe bug fixes only**. No new features or minor enhancements are 
introduced.

Users are expected to plan and complete major version upgrades within this 
transition window. Cur8s does not provide long-term support for older major 
versions.

This model balances upgrade safety with the reality of limited maintenance 
capacity and the need to keep the Platform aligned with the evolving ecosystem.

## Maintainer and User Responsibilities

**Cur8s maintainers commit to:**
- supporting exactly one minor version line at a time  
- targeting only upstream-supported Kubernetes versions  
- issuing timely patch releases for the supported version line  
- providing a short, clearly communicated transition window for major version 
  upgrades  

**Cur8s users are expected to:**
- run supported upstream Kubernetes versions  
- enable automated patch consumption  
- remain on the currently supported minor version  
- plan and execute major version upgrades within the defined transition period  

This shared understanding keeps Cur8s sustainable for maintainers and 
predictable for users.

## Operating a Cur8s Cluster

Cur8s is designed to be operated with the expectation of 
**continuous forward movement**.

***Users of Cur8s are expected to:**
- keep their Kubernetes clusters on **currently supported upstream versions**  
- enable **automatic application of patch releases**  
- adopt new minor Cur8s versions **promptly and deliberately**  
- plan and execute major version upgrades within the defined transition window  

Cur8s does not support frozen platforms or long periods of version stasis. 
Staying current is not an exceptional maintenance task; it is the normal and 
intended mode of operation. This expectation allows Cur8s to remain secure, 
predictable, and maintainable over time.

## What the Single Version Line Refers To

The single, continuously advancing version line is the **user-facing release 
contract**. It is the version a Cur8s user installs, refers to in support
conversations, and tracks for upgrades. From the user's perspective, the
Platform is one number.

A Platform release may be **internally assembled** from multiple independently
versioned artifacts, each pinned to a specific version at release time. This
internal composition is invisible to users: they install one release, see one
version, and never need to choose compatible combinations of internal pieces.

This distinction matters because some parts of the Platform have different 
change profiles, stability properties, or audiences than others. A foundational
layer responsible for declarative control, secret distribution, and trust 
establishment may stabilize earlier and advance more slowly than the rest of 
the Platform. Allowing such a layer to carry its own internal version line — 
while the user-facing release continues to advance as a single number — lets 
Cur8s ship a stable kernel without holding the rest of the Platform still, and
without exposing operators to a compatibility matrix.

The constraint this rule preserves is the **absence of user-facing 
fragmentation**. A user must never be asked to pick a compatible combination
of Cur8s components or to reason about whether two internal versions interact.
Internal version lines are an implementation concern of the release; the 
user-facing contract remains a single advancing number.

A specific application of this principle is defined in 
[RFC-015: Cur8s Core](RFC-015-cur8s-core.md). The structural model that
organizes internal artifacts is defined in
[RFC-013: Cur8s Layer Architecture](RFC-013-cur8s-layer-architecture.md):
each layer may have its own internal version line, but the user-facing
release composes them into a single number.

## Scope

This RFC defines **how Cur8s Platform versions advance, which versions are 
supported, and how support is structured over time**.

It does not define how patch automation is implemented, how Kubernetes upgrades
are performed, or which tools enforce version transitions. Those mechanisms are 
addressed in subsequent RFCs.

## Revisions

Initial version.
