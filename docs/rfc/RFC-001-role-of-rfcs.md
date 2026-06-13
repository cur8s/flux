# RFC-001: The Role of RFCs

**Status:** Accepted

This repository is the **foundation** that independent component repositories build on. Its
RFCs capture the architectural reasoning that constrains how the foundation — and everything
layered on it — evolves. They are part of the system itself: the models, boundaries, and
invariants that preserve coherence across many repositories and across years of upstream change.

RFCs are **normative**. They prescribe what is allowed and disallowed as the system evolves,
not merely what is true today. Any change that violates an RFC is an architectural change and
must be justified by a new RFC that supersedes the old one.

RFCs are authoritative but not frozen. Clarifications that improve readability or make implicit
reasoning explicit may be made in place and recorded under a **Revisions** note. Changes that
alter meaning, scope, or invariants are introduced through a new RFC; existing RFCs are never
rewritten to erase prior understanding.

RFCs are intentionally free-form. There is no required section structure or template; authors
use whatever form communicates the idea most clearly. Readability takes precedence over
formality.

RFC numbers are **stable identifiers**, not a reading order. Once assigned, a number is never
reused or renumbered, even if the title changes or the document is later superseded. The
recommended reading order is curated separately in [README.md](README.md).

Because this repository is a foundation, its RFCs serve a second role: they are a **template**.
A component repository that builds on this foundation adopts the same RFC discipline and may add
its own component-specific RFCs, but it may not contradict a foundation RFC. Where a component
must diverge, that divergence is itself an architectural change requiring an RFC.

If you find yourself working around an RFC, you are most likely violating the design intent it
protects.

**Revisions:** Initial version.
