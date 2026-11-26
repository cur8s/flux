---
title: "Design cross-repo patterns for non-Flux components"
summary: "Settle and document the cross-repository lifecycle patterns needed for Helm-based, multi-stage components such as certificates and gateway; parked until building the next component repository."
---

# Design cross-repo patterns for non-Flux components

**Pick up** when starting the next Cur8s component repository (such as `certificates` / cert-manager), where Helm charts, multi-stage Kustomizations, and consuming a published `gitops` release become concrete.

The mechanical conventions and single-component workflow are already settled and implemented in this repository:
- Directory layout (`upstream/`, `src/config/`, committed `artifacts/rendered/`, reserved `artifacts/oci/`): [From source to artifact](../../../docs/architecture/01-source-to-artifact.md).
- Five zero-argument mise namespaces (`upstream:`, `build:`, `dev:`, `verify:`, `release:`) and standalone `.mise/cluster/` helpers: [Local development](../../../docs/how-to/00-local-development.md), [Mise standard](../../../docs/standards/mise-standard.md), and [Bash script standard](../../../docs/standards/bash-script-standard.md).
- Independent SemVer and eight agreed capability package names (`gitops`, `certificates`, `secrets`, `gateway`, `postgres`, `metrics`, `logging`, `grafana`): [Adopt capability naming and independent SemVer](../../todo/adopt-capability-naming-and-semver/overview.md).

**Remaining cross-repo design work to settle when resuming:**

- **Monorepo reference review:** inspect `~/dev/cur8s/monorepo-cur8s` (Make targets, `scripts/`, component Makefiles such as cert-manager) for requirements of Helm-based components without porting its superseded layer model.
- **Traceable fetching (`FETCH.lock`):** define a uniform provenance record written by `upstream:fetch` for components that download Helm charts and remote YAML from external registries (listing each source, version, and digest, plus a check that fails if a fresh fetch differs). Keep it distinct from the identity descriptor `cur8s.yaml`.
- **Multi-stage deployment layout (`crds`, `deploy`, `post-install`):** confirm the stage directory/Kustomization convention, define how `dev:reconcile` targets a component with multiple Kustomizations (and whether source reconciliation is included), and decide whether a component-ready synchronization Kustomization is needed.
- **Downstream bootstrap and dependency staging:** define how non-`gitops` component repositories bootstrap a pinned published `gitops` release into their local k3d cluster and stage pinned published OCI artifacts for prerequisite capabilities (for example `gateway` depending on `certificates`).
- **Platform bill of materials (BOM):** confirm what each component publishes for the future platform repository's BOM to reference, and define the BOM schema when that repository begins.
- **Cross-repo lifecycle contract doc:** reconcile the historical proposals preserved here ([proposal.md](proposal.md), [task-namespaces-proposal.md](task-namespaces-proposal.md), [candidate-six-phases.md](candidate-six-phases.md)) with the repo's settled five-namespace layout and publish a durable cross-repository lifecycle guide.
