---
title: "Bump Flux to the latest 2.9.x patch"
summary: "Advance the pinned upstream Flux release from v2.9.0 to the latest stable v2.9.x patch, refresh mise.lock across all platforms, re-render, and verify."
---

# Bump Flux to the latest 2.9.x patch

`upstream:check` previously reported Flux `v2.9.6` against the tracked `v2.9.0` (on 2026-10-11).

**Scope:**

- Run `mise run upstream:check` to confirm the newest `v2.9.x` patch release.
- Update `flux2` and `UPSTREAM_VERSION` in `mise.toml` (keeping `[tools]` literal per [Mise standard](../../../docs/standards/mise-standard.md)) and refresh `mise.lock` across all four locked platforms (`linux-x64`, `linux-arm64`, `macos-x64`, `macos-arm64`).
- Run `mise run upstream:fetch` and `mise run build:render`, review the `upstream/` and `artifacts/rendered/` diffs, and run `mise run verify:run`.
- Assign the appropriate Cur8s package version bump if [adopt-capability-naming-and-semver](../adopt-capability-naming-and-semver/overview.md) has already been applied (otherwise `CUR8S_REVISION` stays `1`).
