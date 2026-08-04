# Durable Project Knowledge

This directory contains durable, current-state knowledge about the
flux package. Its documents explain what is true now and are rewritten
when that truth changes; git history preserves previous versions, so
none of them becomes a chronological log.

The README closest to a directory governs how that directory is used;
this file governs `docs/`. Temporary investigation and planning belong
in a work note under [`work/`](../work/README.md). Org-wide law lives
in the flagship
([cur8s/cur8s `docs/rfc/`](https://github.com/cur8s/cur8s/tree/main/docs/rfc))
and is linked, never copied.

## Documents

| Document | Required | Responsibility |
| --- | --- | --- |
| [`vision.md`](vision.md) | Yes | Why this package exists, who it serves, what success means, and what is outside its scope. |
| [`rfc/`](rfc/README.md) | Yes | This package's own normative contracts; [`rfc/README.md`](rfc/README.md) governs the directory. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Yes | How contributors and coding agents develop, verify, and change the repository. |

RFCs are this repository's normative genre: a contract another party
can depend on — the opinionated configuration, the bootstrap contract
— becomes an RFC under `rfc/`. Material that merely orients a reader
belongs in the README or an optional document, never in an RFC.

## Optional Documents

Add these only after a concrete need is demonstrated, and rewrite
them when the truth they record changes:

- `architecture.md` — how the current system works: components,
  responsibilities, data flows, constraints. Add it when the pipeline
  grows past what the root README's layout section explains clearly.
- `principles.md` — enduring principles used to choose between design
  alternatives. Normally introduced together with `architecture.md`.
- `user-guide.md` — how consumers use the published artifact, when
  that outgrows the README and the RFCs. It must not explain how to
  contribute changes.
- `glossary.md` — normative definitions, added when a domain term
  needs one precise meaning across docs, discussion, and code.

`vision.md` records durable intent in roughly 200–300 words: the
problem, the audience, what success means, and the boundaries. It
contains no implementation plans, task lists, or progress updates.
