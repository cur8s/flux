# Journal

## Purpose

This document records accomplishments, decisions, and learning over time, explaining what
changed and why it mattered. It preserves the story of progress as [Areas](areas.md) and
[Iteration](iteration.md) evolve. Design and research outcomes count alongside implemented features.

## Format

Months use H2 headings. Each entry uses an H3 heading with a date and short descriptive title,
followed by concise bullets about accomplishments, decisions, and learning. Include commits,
work notes, or other evidence when useful. Horizontal rules separate months. Draft entries retain
"Draft" in the heading until reviewed.

An iteration closeout entry summarizes the week's results and learning, followed by a shell
code block that retrieves its final committed account. Use the commit containing that account,
before the completed weekly section was removed from the rolling document:

```shell
git show <commit-id>:work/roadmap/iteration.md
```

---

## November 2026

### 2026-11-26 — Standardize mise configuration and task scripts (Draft)

- **Accomplishments:** Reviewed and standardized every mechanical aspect of `mise.toml`,
  `mise.lock`, and the bash scripts under `.mise/`, applied the conventions across the repository
  (commits `2988bdd` through `7640762`), and published durable standards in
  [Mise standard](../../docs/standards/mise-standard.md) and
  [Bash script standard](../../docs/standards/bash-script-standard.md). Wired both standards into
  [docs/README.md](../../docs/README.md) and [AGENTS.md](../../AGENTS.md), and aligned
  [Local development](../../docs/how-to/00-local-development.md).
- **Key decisions:**
  - Consolidated tasks into five zero-argument namespaces (`upstream:`, `build:`, `dev:`,
    `verify:`, `release:`) with file tasks under `.mise/tasks/` and standalone executed helpers
    under `.mise/cluster/` (`cluster.sh`, `install-component.sh`, `push-artifact.sh`,
    `k3d-config.yaml`).
  - Kept task scripts strictly linear (no functions, `case`, or `trap`); drove component-specific
    cluster wiring through `FLUX_BOOTSTRAP_MANIFEST` and `FLUX_SYNC_MANIFESTS` in `mise.toml`.
  - Pinned Kubernetes/pipeline tools plus `shellcheck` with literal versions locked across four
    platforms in `mise.lock` (backend priority: default registry → `github:` → digest-pinned
    `docker run`); left host utilities (`docker`, `git`, `bash`, `curl`, `openssl`, `jq`) on the
    host.
  - Disambiguated registry and URL naming (`RELEASE_REGISTRY`, `registry_container`,
    `registry-host-address` / `registry-cluster-address`, `oci_repository_url` vs. `artifact_url`,
    `UPSTREAM_PROJECT`) and simplified `install-component.sh` to a single `dev|verify` argument.
  - Kept local k3d cluster names deterministic (`<component>-dev`, `<component>-verify`) under the
    single-checkout assumption, with `switchCurrentContext: false` and no host-specific registry
    mirrors.
- **Learning:** Keeping `mise-standard.md` and `bash-script-standard.md` free of both Bash 101
  boilerplate and Cur8s-specific lifecycle/k3d architecture keeps them short, non-obvious, and
  reusable across repositories.
- **Verification:** `bash -n .mise/cluster/*.sh .mise/tasks/*/*`,
  `mise exec -- shellcheck .mise/cluster/*.sh .mise/tasks/*/*` (0 warnings), `mise run dev:update`
  against `flux-dev`, `mise run verify:run` (fresh drift check, `flux-verify` bootstrap,
  reconciliation to Ready on `verify@sha256:...`, and cluster cleanup), and `git diff --check` all
  passed.
- **Handoff:** Lifecycle proposal docs under
  [Design the component lifecycle](../todo/design-component-lifecycle/overview.md) still need
  reconciling with the settled five-namespace task layout when that todo runs.
