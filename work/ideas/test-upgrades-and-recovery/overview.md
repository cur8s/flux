---
title: "Test upgrades and recovery"
summary: "Extend end-to-end coverage from fresh bootstrap to self-managed upgrades, repeat application, and defined recovery behavior."
---

# Test upgrades and recovery

The current end-to-end test proves a fresh cluster can bootstrap Flux and hand control to the OCI
artifact, but it does not exercise an already self-managed installation moving between component
versions. That transition is where controller, CRD, and reconciliation compatibility problems are
most likely to appear.

Investigate tests for a cur8s revision upgrade, an upstream Flux upgrade, reapplying the same
version, and recovery from a candidate that cannot become Ready. First define whether rollback is
a supported operation or whether recovery means advancing to a corrected artifact. Also decide
whether the baseline should be a published release or a second locally built fixture, and how much
of this lifecycle belongs in the required CI gate rather than a slower scheduled test.
