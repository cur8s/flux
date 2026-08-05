---
title: "Restructure the repository documentation"
summary: "Replace local RFCs with focused user and architecture guides, tighten the vision, and simplify navigation so each topic has one authoritative home."
---

# Restructure the repository documentation

Retire this repository's local RFC genre. The existing RFCs describe current package behavior more
than they record decisions, and their content overlaps the root README, vision, contribution guide,
and source-local notes. Org-wide cur8s RFCs remain authoritative and should continue to be linked
where platform law matters.

Treat this as a content-preservation migration from the original cur8s monorepo, not only a
formatting cleanup. Audit `/Users/adib/dev/cur8s/cur8s/docs/why/`, the Flux section of
`docs/platform-components.md`, and the relevant flagship RFCs before rewriting or deleting
anything. Preserve the reasoning that connects an opinionated platform, externally versioned
intent, build-time decisions, static runtime manifests, and constrained reconciliation. In
particular, the new docs must explain why Cur8s rejects dynamic in-cluster templating: the same
declared input must not produce different output based on live cluster state, and the cluster
should execute recorded decisions rather than make new ones.

Do not copy org-wide law into this component repository. Keep its detailed rationale authoritative
in the flagship and link to it, while explaining the Flux-specific consequences locally: why the
Helm controller and image automation are excluded, why build-time Helm remains acceptable, why
deterministic structural composition is different from runtime interpretation, and how the
rendered OCI artifact makes the final desired state reviewable and reproducible.

Adopt the following document ownership:

| Document | Responsibility |
| --- | --- |
| `README.md` | Brief orientation and clear routes for consumers and contributors. |
| `docs/vision.md` | A concise, flowing narrative about the problem, audience, durable meaning of success, and boundaries. |
| `docs/user-guide.md` | The package philosophy, reasons behind its user-visible constraints, supported Flux surface, bootstrap, steady-state use, upgrades, verification, and limitations. |
| `docs/architecture.md` | The fetch-to-render-to-publish lifecycle, decision-time/runtime boundary, mise task graph, source and generated trees, release channels, and self-management flow. |
| `CONTRIBUTING.md` | Setup, authoring commands, repository conventions, and change verification. |

The user guide should absorb the consumer-facing configuration and bootstrap contracts from the
current RFCs. The architecture guide should absorb pipeline, publication, and self-management
mechanics without duplicating the command reference maintained by mise. Rewrite `vision.md` for a
faster read by removing implementation detail and fixing the fragmented scope discussion. Do not
force it into standardized section titles: let the ideas form a coherent narrative and introduce
headings only where they naturally make that narrative easier to scan.

After the new documents carry all useful current-state knowledge, remove `docs/rfc/`, shorten the
root README, update the documentation index and agent guidance, and delete or reduce
`src/flux/config/notes.md` so it does not become another copy of the same material.
