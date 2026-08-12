---
title: "Complete the production bootstrap path"
summary: "Give standalone operators a complete, reproducible path from install.yaml to OCI-backed Flux self-management."
---

# Complete the production bootstrap path

The user guide provides the initial `install.yaml` command, then tells operators to create an
`OCIRepository` and apply the package's `sync.yaml`. The complete production resources and a direct
way to obtain the sync manifest are not provided; the only executable example is embedded in the
local k3d task and targets an insecure development registry.

Provide a production-safe, copy-and-paste path for the versioned `OCIRepository` and self-management
`Kustomization`. Decide whether the source of truth should remain a documented example or become a
version-specific release asset generated from authored configuration. Document package tag syntax,
public and authenticated registry behavior, ordering after controller bootstrap, readiness checks,
upgrade selection, and recovery without duplicating manifests that can drift.
