---
title: "Clarify the Notification Receiver contract"
summary: "Resolve the mismatch between informational-only notification guidance in the docs and the installed Receiver CRD and webhook-receiver Service."
---

# Clarify the Notification Receiver contract

The user guide states that Notification Controller reports events without influencing reconciliation, but the rendered Flux installation includes the `Receiver` CRD and the `webhook-receiver` Service (which accept external webhook events and can request reconciliation).

**Scope:**

- Decide whether `Receiver` remains installed as part of the upstream controller surface while explicitly documented as outside the package's recommended contract, or whether the `Receiver` CRD, `webhook-receiver` Service, and related behavior should be removed or disabled.
- Prefer a narrow documentation correction if the upstream controller surface cannot be safely reduced.
- Update durable product/architecture/user-guide docs to match the decision, and update verification checks if the rendered manifest surface changes.
