---
title: "Automate upstream Flux update proposals"
summary: "Detect new Flux releases and prepare reviewable update proposals without automatically selecting, merging, or publishing a version."
---

# Automate upstream Flux update proposals

`upstream:check` currently reports that a newer Flux release exists and leaves the update entirely
manual. A scheduled workflow could reduce maintenance effort by preparing the mechanical part of
an update while preserving the rule that version advancement is an explicit reviewed decision.

Explore a workflow that updates `FLUX_VERSION` in `mise.toml`, regenerates the fetched source and OCI
review surface, runs policy, drift, and end-to-end checks, and opens a proposal containing relevant
upstream release information. It must never merge, tag, or publish automatically. Determine how to
authenticate automated proposals safely, how to handle a newer release while a proposal is already
open, and whether upstream release notes provide enough compatibility information to summarize
without adding another source of truth. Whether Renovate can read the version pins depends on
the templated-pin decision in
[`standardize-mise-and-task-scripts`](../../todo/standardize-mise-and-task-scripts/overview.md).
