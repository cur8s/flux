---
title: "Add upgrade and recovery verification"
summary: "Extend end-to-end verification beyond fresh bootstrap to test self-managed version upgrades, repeat application, and recovery from failed reconciliations."
---

# Add upgrade and recovery verification

Today `verify:run` proves that a fresh cluster can bootstrap Flux and hand control to the OCI artifact, but it does not exercise an already self-managed installation moving between component versions. That transition is where controller, CRD, and reconciliation compatibility problems are most likely to appear. (The [Flux bootstrap proposal](../move-self-management-to-consumer/flux-bootstrap-proposal.md) also calls for fresh-cluster coverage through phase 1, readiness, phase 2, first reconciliation, and a subsequent version update.)

**Scope:**

- Add end-to-end coverage for:
  - reapplying the same version,
  - upgrading across a Cur8s configuration-only version bump,
  - upgrading across an upstream Flux version bump, and
  - recovering from a candidate that cannot become Ready.
- Decide whether rollback to an earlier immutable artifact is supported or whether recovery requires advancing to a corrected version.
- Decide whether the baseline version comes from a published release or a second locally built fixture, and which cases run in default `verify:run` vs. a slower scheduled check once CI is restored.
