---
title: "Reduce script runtime coupling to mise"
summary: "Investigate sourceable environment configuration and root discovery so leaf scripts can run with fewer mise-specific assumptions while mise continues to manage tools and orchestration."
---

# Reduce script runtime coupling to mise

Investigate which current runtime dependencies should remain owned by mise and which repository
configuration should move to a sourceable environment file. Tool installation and activation may
remain a mise responsibility; the goal is not to replace the task runner.

The investigation should cover:

- whether `KUBE_VERSION`, `REGISTRY`, and `CLUSTER_NAME` belong in a committed environment file
  that mise loads and shell scripts can source;
- a reliable repository-root fallback for scripts that currently require `MISE_CONFIG_ROOT`;
- which leaf tasks can reasonably support direct execution and which orchestration tasks should
  continue invoking `mise run`;
- how to avoid duplicated defaults or competing configuration sources; and
- whether the sourceable [`version.env` design](../build-up-flux-versioning/overview.md) should
  establish the pattern for other non-secret repository configuration.

Any proposal should preserve the pinned toolchain and the documented `mise run` interface while
making the boundary between task orchestration and ordinary runtime configuration explicit.
