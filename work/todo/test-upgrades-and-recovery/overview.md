---
title: "Test upgrades and recovery"
summary: "Extend end-to-end coverage from fresh bootstrap to self-managed upgrades, repeat application, and defined recovery behavior."
---

# Test upgrades and recovery

The current end-to-end test proves a fresh cluster can bootstrap Flux and hand control to the OCI
artifact, but it does not exercise an already self-managed installation moving between component
versions. That transition is where controller, CRD, and reconciliation compatibility problems are
most likely to appear.

Add coverage for reapplying the same version, a Cur8s configuration-revision upgrade, an upstream
Flux upgrade, and recovery from a candidate that cannot become Ready. First decide whether rollback
to an earlier immutable artifact is supported or whether recovery requires advancing to a corrected
version. Also decide whether the baseline should be a published release or a second locally built
fixture, and which lifecycle cases belong in required CI versus a slower scheduled test.
