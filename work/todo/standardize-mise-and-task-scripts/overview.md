---
title: "Review and standardize the mise configuration and task scripts"
summary: "Systematically review every mechanical aspect of how this repository uses mise and bash, settle each convention interactively, apply it, and publish the results as docs the remaining work to 1.0 builds on."
---

# Review and standardize the mise configuration and task scripts

**Agreed with the owner:**

- This is a todo, not an exploration: the intent is settled, the decisions are not. They emerge
  from an interactive review, applied to the repository as they are agreed.
- Scope is every mechanical aspect of mise and the bash scripts: `mise.toml` structure (settings,
  `[tools]`, `[env]`, templates and derived values), tool pinning and `mise.lock`, how tasks are
  defined and invoked (file versus TOML tasks, `#MISE` and `#USAGE` headers, arguments,
  `depends` versus `mise run`, supporting files under `.mise/`), and bash script conventions.
- Out of scope: lifecycle phase names, task naming, and namespaces, which the next todo
  defines; the versioning scheme, which the lifecycle design todo settles; bumping the tracked
  Flux version, an input to the implementation planning todo; and how CI runs mise, which
  moved to the parked [CI workflows note](../../parked/finalize-ci-workflows/overview.md). Documenting *how* a pin
  is bumped and re-locked is in scope; performing a bump is not.
- Where the resulting documentation lands — architecture, how-to, standards, or a mix — is decided
  within this todo.
- When it is finished, written standards, how-to, and architecture documents exist that the
  remaining todos toward 1.0 follow.

**Context for the review:** each Cur8s component repository keeps its own copies of tiny, obvious
task scripts, so the conventions decided here are what keep those copies consistent. Later todos
depend on the general rules settled here, notably how to pin a tool that is not in mise's default
registry or ships as a Flux plugin (flux-mirror, crane, oras) and whether tool versions may be
derived from `[env]` templates (which affects whether Renovate can read the pins).

**Implemented baseline for the review:** the owner separately agreed the repository layout and
its task path migration. Captured input is in `upstream/`, authored config in `src/config/`, and
rendered output in `artifacts/rendered/`; `build:clean` deletes all of `artifacts/`. `.mise/README.md`
orients task tooling. The reserved ignored `artifacts/oci/` path adds no packaging task or settled
mise convention. Review mechanics from the current scripts; the systematic review remains open.
