---
title: Mise standard
scope: mise.toml, mise.lock, and task layout under .mise/
version: 1
---

# Mise standard

> [!NOTE]
> Use this standard when editing `mise.toml`, refreshing `mise.lock`, or organizing tasks under
> `.mise/`. For setup and lockfile refresh commands, see
> [Local development](../how-to/00-local-development.md).

## Required Conventions

Apply every applicable convention in this section.

### MISE-001: Enforce a verified multi-platform lockfile

**Applies to:** `[settings]` in `mise.toml` and `mise.lock`.

**Rule:**

- Set `lockfile = true` and `locked = true` under `[settings]` so missing tools or checksum
  mismatches fail installs immediately.
- Whenever `[tools]` changes, refresh `mise.lock` for all four supported platforms (`linux-x64`,
  `linux-arm64`, `macos-x64`, `macos-arm64`) and commit `mise.lock` with `mise.toml`.

---

### MISE-002: Pin project toolchain and lint tools; leave host utilities unmanaged

**Applies to:** `[tools]` in `mise.toml`.

**Rule:**

- Pin tools that control builds, pipelines, runtime operations, or script linting.
- Leave standard host utilities (`docker`, `git`, `bash`, `curl`, `openssl`, `jq`) unmanaged by
  mise and list them as host prerequisites in documentation.

---

### MISE-003: Keep tool pins literal and choose backends by priority

**Applies to:** `[tools]` in `mise.toml`.

**Rule:**

- Write every tool version as a literal string (for example, `flux2 = "2.9.0"`), never a template
  such as `"{{env.UPSTREAM_VERSION}}"`, so humans and automated updaters such as Renovate can parse
  pins directly.
- Select tool backends in this order:
  1. Mise's default registry (`aqua:` or `core:`).
  2. Mise's `github:<owner>/<repo>` backend locked in `mise.lock`, for GitHub-released binaries
     outside the default registry.
  3. An image pinned by SHA-256 digest via `docker run`, for container-only tools.

---

### MISE-004: Keep derived `[env]` templates simple and grouped at the bottom

**Applies to:** `[env]` in `mise.toml`.

**Rule:**

- Group authored raw inputs linearly at the top of `[env]` and derived variables at the bottom
  under a clear comment separator.
- Use plain `{{ ... }}` interpolation in derived `[env]` variables (for example,
  `"v{{ env.UPSTREAM_VERSION }}"`) rather than inline Tera `throw(...)` conditionals.

---

### MISE-005: Separate file tasks from supporting helpers under `.mise/`

**Applies to:** Directory layout under `.mise/`.

**Rule:**

- Define tasks as executable files under `.mise/tasks/<namespace>/<action>` rather than inline
  `[tasks.*]` tables in `mise.toml`.
- Place supporting helper scripts and configuration outside `.mise/tasks/` so mise never discovers
  them as tasks.

---

### MISE-006: Keep `#MISE description` short and scannable

**Applies to:** `#MISE description="..."` headers in `.mise/tasks/*/*`.

**Rule:**

- Give each task a single plain-English imperative phrase of 60 characters or fewer so `mise tasks`
  renders without wrapping in an 80-column terminal.
- Omit parenthetical caveats, semicolons, and raw environment variable names.

---

### MISE-007: Use `#MISE depends` for unconditional prerequisites and `mise run` for ordered checks

**Applies to:** Task composition in `.mise/tasks/*/*`.

**Rule:**

- Use `#MISE depends=[...]` when a task always requires a prerequisite.
- Use explicit `mise run` calls inside the script when execution depends on preconditions or
  intermediate checks.
