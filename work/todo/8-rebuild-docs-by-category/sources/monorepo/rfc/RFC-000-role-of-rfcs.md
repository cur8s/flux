# RFC-000: The Role of RFCs in Cur8s

**Status:** Accepted

Cur8s RFCs capture the architectural reasoning that constrains how Cur8s evolves.
They are part of the system itself, defining the models, boundaries, and
constraints that preserve coherence over time. RFCs are **normative**: they
prescribe what is allowed and disallowed as Cur8s evolves, defining constraints
that future designs must respect rather than merely describing current behavior. 
Any change that violates an RFC is considered an architectural change and
must be justified by a new RFC that supersedes the old one.

RFCs are authoritative but not frozen. Clarifications that improve
readability or make implicit reasoning explicit may be made in place and
recorded as revisions. Changes that alter meaning or constraints must be
introduced via a new RFC; RFCs are not rewritten to erase prior understanding.

Cur8s RFCs are intentionally free-form. There is no required section structure
or template; authors should use whatever form best communicates the idea
clearly and directly. Readability and clarity take precedence over formality.

RFC numbers are stable identifiers, not a reading order. IDs are never
renumbered or reused, and the recommended reading order is curated
separately in [docs/rfcs/README.md](README.md).

**Revisions:** Initial version.
