---
title: "Adopt capability naming and independent SemVer"
summary: "Switch package identity to the short capability name gitops, replace upstream-derived versions in mise.toml with independent SemVer, and record the eight agreed Cur8s capability names."
---

# Adopt capability naming and independent SemVer

**Owner decisions:**

- **Independent SemVer per package:** each Cur8s capability package carries its own `MAJOR.MINOR.PATCH` semantic version reflecting the Cur8s compatibility contract; upstream versions remain provenance metadata (`UPSTREAM_VERSION`, `cur8s.yaml`, OCI annotations). This supersedes the current upstream-derived `CUR8S_REVISION` scheme (`v2.9.0`, `v2.9.0-2`, where `-2` sorts before `v2.9.0` in SemVer). See [versioning-proposal.md](versioning-proposal.md).
- **Short capability names under `ghcr.io/cur8s/<name>`:** use capability names rather than upstream product names so version tags are not confused with upstream versions. The eight agreed package names are:
  - `gitops`
  - `certificates`
  - `secrets`
  - `gateway`
  - `postgres`
  - `metrics`
  - `logging`
  - `grafana`

**Scope:**

- Update `mise.toml`: replace `CUR8S_REVISION` and the upstream-derived `CUR8S_VERSION` formula with an explicitly authored SemVer `CUR8S_VERSION` (with template validation), and switch `CUR8S_COMPONENT` from `flux` to `gitops`.
- Re-render `artifacts/rendered/cur8s.yaml` and update OCI annotations, deploy overlay labels, and cluster/sync naming as needed.
- Check whether any version has already been published to `ghcr.io/cur8s/flux`; if so, decide how old tags relate to the new `ghcr.io/cur8s/gitops` package.
- Update durable documentation (`docs/architecture/`, `docs/product/`, `docs/how-to/00-local-development.md`, `README.md`) to describe independent SemVer and record the eight capability names.

**Open details to confirm when starting:**

- Starting SemVer value for `gitops` (for example `0.1.0` vs `1.0.0`) and whether OCI/git tags are bare (`1.0.0`) or `v`-prefixed (`v1.0.0`).
- Whether the GitHub repository (`cur8s/flux`) keeps its current name for now or is renamed separately to match `gitops`.
- Whether `cur8s.yaml` needs any schema or field changes for the future platform bill of materials (BOM).
