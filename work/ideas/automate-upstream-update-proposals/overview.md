---
title: "Automate upstream update proposals"
summary: "Detect newer upstream releases on a schedule and open reviewable pull requests with refreshed pins, lockfiles, and rendered diffs without ever auto-merging or publishing."
---

# Automate upstream update proposals

`upstream:check` currently reports newer upstream Flux releases and leaves updates manual. A scheduled workflow or Renovate configuration could prepare the mechanical part of an upstream bump while preserving the rule that version advancement and publication remain explicit, reviewed human decisions.

**Context and constraints:**

- Tool pins in `mise.toml` are literal strings per [Mise standard](../../../docs/standards/mise-standard.md) (`MISE-003`), so Renovate or similar tools can parse them directly.
- Wait to pursue until live CI workflows ([finalize-ci-workflows](../../parked/finalize-ci-workflows/overview.md)) are restored.
- Questions to resolve if pursued: updating both tool pins and `UPSTREAM_VERSION`, regenerating `mise.lock`, `upstream/`, and `artifacts/rendered/`, running drift and e2e checks, safely authenticating automated PRs, handling superseded open PRs when a newer release arrives, and summarizing upstream release notes without introducing a second source of truth.
