---
title: Bash script standard
scope: Executable task and helper scripts under .mise/
version: 1
---

# Bash script standard

> [!NOTE]
> Use this standard when writing, modifying, or reviewing bash scripts under `.mise/`.

## Required Conventions

Apply every applicable convention in this section.

### BASH-001: Keep task scripts strictly linear

**Applies to:** Every task script under `.mise/tasks/`.

**Rule:**

- Write task scripts top-to-bottom with no shell functions, `case` dispatchers, or `trap` handlers.
- Handle cleanup or failure reporting inline with `if ... else ... fi` rather than `trap`.
- Reserve multi-action dispatch (`case` and functions) for dedicated helper scripts outside
  `.mise/tasks/`.

---

### BASH-002: Execute shared helpers, guard required env vars, and never source them

**Applies to:** Helper scripts outside `.mise/tasks/`.

**Rule:**

- Invoke helpers as standalone executables by path; never `source` them into callers.
- Name multi-action dispatch helpers `<noun>.sh` and single-action linear helpers
  `<verb>-<noun>.sh`.
- Guard every required `mise.toml [env]` variable immediately after `set -euo pipefail` with
  `: "${VAR:?must be set (mise.toml [env]); run through mise}"` so running a helper outside mise
  fails fast before touching external state.

---

### BASH-003: Keep statements flat and guard truncating pipes under `pipefail`

**Applies to:** Every script under `.mise/`.

**Rule:**

- Use `[[ ... ]]` rather than `[ ... ]`, and place one statement per line (no semicolon-packed
  commands or inline `{ ...; exit 1; }` blocks).
- Append `|| true` after pipes that intentionally truncate output under `pipefail` (such as
  `git diff | head -n 100 || true`) so `SIGPIPE` does not abort error reporting.

**Exception:** One-line arms inside a helper's `case` dispatcher are permitted.

---

### BASH-004: Keep script comments self-contained and contract-first

**Applies to:** Comments across `.mise/`.

**Rule:**

- Open helper scripts with purpose, callers, and usage syntax; open task scripts with a short
  contract or precondition comment after `set -euo pipefail`.
- Keep comments plain English and self-contained; avoid agent-instruction references, internal
  architecture jargon, and claims about other repositories.

---

### BASH-005: Verify scripts with `bash -n` and pinned `shellcheck`

**Applies to:** Any edit to scripts under `.mise/`.

**Rule:** Before committing script changes, run syntax checking and static analysis with zero
warnings:

```sh
bash -n .mise/cluster/*.sh .mise/tasks/*/*
mise exec -- shellcheck .mise/cluster/*.sh .mise/tasks/*/*
```
