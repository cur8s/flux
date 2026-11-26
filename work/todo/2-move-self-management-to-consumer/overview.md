---
title: "Move self-management Kustomization out of the package"
summary: "Stop shipping sync.yaml inside artifacts/rendered/, relocate this repository's local dev/verify sync manifest, add explicit CRD readiness checking, and document a copy-and-paste production bootstrap path."
---

# Move self-management Kustomization out of the package

**Owner decisions:**

- Self-management resources (`OCIRepository` and `Kustomization`) belong to the consuming repository, not the reusable Cur8s package. Bootstrap stays two separate apply steps: static controller installation first, then consumer-owned self-management after CRDs and controllers are ready. See [flux-bootstrap-proposal.md](flux-bootstrap-proposal.md) and [architecture overview](../../../docs/architecture/00-overview.md#intended-self-management-boundary).

**Scope:**

- Remove `sync.yaml` from `src/config/` and stop copying it into `artifacts/rendered/sync.yaml` in `.mise/tasks/build/render`.
- Move this repository's own local dev/verify self-management `Kustomization` to a repo-local path (for example `.mise/cluster/sync.yaml` or `test/sync.yaml`) and update `FLUX_SYNC_MANIFESTS` in `mise.toml` (`.mise/cluster/install-component.sh` and `dev:update` are already data-driven via `FLUX_SYNC_MANIFESTS`).
- Add an explicit CRD `Established` readiness check in `.mise/cluster/install-component.sh` between applying `FLUX_BOOTSTRAP_MANIFEST` and applying `FLUX_SYNC_MANIFESTS` (currently it waits only for controller Deployments to be Available).
- Document a complete, copy-and-paste production bootstrap path (`OCIRepository` + self-management `Kustomization`) covering package tag syntax, public and authenticated registries, ordering after controller bootstrap, readiness checks, upgrade selection, and recovery without duplicating manifests that can drift.
- Update durable architecture and user-guide documentation to reflect that `sync.yaml` no longer ships in the artifact.

**Open details to confirm when starting:**

- Where this repository's local dev/verify `sync.yaml` lives (`.mise/cluster/sync.yaml` vs `test/sync.yaml`).
- Whether the production self-management manifest stays a documented copy-and-paste example in the user guide or also becomes a version-specific release asset.
