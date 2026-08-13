---
title: "Review thin task orchestration"
summary: "After the current task design settles, consolidate thin mise wrappers where declarative task references improve clarity without changing lifecycle semantics."
---

# Review thin task orchestration

The repository’s file-task layout keeps substantive task logic in executable scripts, but
`artifact:build` currently only invokes `artifact:clean`, `artifact:fetch`, and
`artifact:render` in sequence. `release` also mostly delegates after it derives the
package version, while `test:drift` and `test:e2e` contain meaningful assertions,
diagnostics, cleanup, or control flow and are not thin wrappers.

Defer this review until the current work has settled the task lifecycle. Then decide
whether `artifact:build` should become a declarative mise `run` list with sequential
task references, retain the equivalent safe ordering, and remain independently runnable
at each stage. Do not replace the sequence with a flat `depends` list: mise may run
independent dependencies in parallel, while `clean`, `fetch`, and `render` must remain
serial. Reassess `release` only if the version-derived arguments can stay explicit and
readable. Preserve shell tasks that own meaningful operational behavior.
