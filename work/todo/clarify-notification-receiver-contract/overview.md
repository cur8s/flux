---
title: "Clarify the Notification Receiver contract"
summary: "Resolve the mismatch between informational-only notification guidance and the installed Receiver webhook surface."
---

# Clarify the Notification Receiver contract

The user guide says Notification Controller reports events without influencing reconciliation, but
the rendered installation includes the `Receiver` CRD and the `webhook-receiver` Service. A Receiver
accepts external events and can request reconciliation, so the installed surface is broader than the
documented informational-only model.

Decide whether `Receiver` should remain installed but explicitly outside the package's recommended
contract, or whether the receiver CRD, Service, and related controller behavior should be removed or
disabled. Prefer a narrow documentation correction if the upstream controller surface cannot be
safely reduced. If the rendered surface changes, update component verification to enforce the
chosen contract.
