---
title: "Bump Flux to the latest patch"
summary: "Advance the tracked upstream from v2.9.0 to the newest v2.9.x release (v2.9.6 when last checked)."
---

# Bump Flux to the latest patch

`upstream:check` reported Flux `v2.9.6` against the tracked `v2.9.0` on 2026-10-11. Re-check the
latest 2.9.x patch when starting, then update `FLUX_VERSION` in `mise.toml`, refresh `mise.lock`
for all four platforms, re-render, review the `oci/` diff, and run the drift and e2e gates.
`CUR8S_FLUX_REVISION` stays `1`. Independent of the lifecycle work.
