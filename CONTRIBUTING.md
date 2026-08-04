# Contributing

This document explains how to develop, verify, and contribute changes
to this repository. It defines the expected tools, commands,
conventions, and quality checks so that humans and coding agents can
work on the repository consistently.

## Setup

Requires `docker` and [mise](https://mise.jdx.dev/). Clone the
repository, enter its directory, and run:

```sh
mise trust
mise install   # pinned toolchain: flux, kustomize, kubeconform, kubectl, k3d, jq
mise tasks     # list every task
```

## Commands

Tasks follow the `<object>:<action>` grammar; the
[`mise.toml`](mise.toml) header is the authoritative description of
the objects, the grammar, and the pinned toolchain.

| Command | Intent |
| --- | --- |
| `mise run artifact:build` | Fetch upstream → render → validate the artifact tree. |
| `mise run test:drift` | Prove the committed `oci/` tree matches a fresh build. |
| `mise run test:e2e` | Prove the full bootstrap → self-manage loop on an ephemeral k3d cluster. |
| `mise run cluster:<action>` | Drive a persistent k3d dev cluster (see the README quickstart). |
| `mise run upstream:check` | Report whether upstream Flux has a newer release than `VERSION`. |
| `mise run release` | Build and publish the versioned artifact — only when explicitly asked. |

## Testing

There is no unit-test suite; the product is a rendered tree, so the
tests are the pipeline itself:

- `test:drift` is the review-surface gate: what is committed under
  `oci/` and `src/flux/artifacts/` must be byte-for-byte what the
  pinned pipeline produces from `src/`.
- `test:e2e` is the product contract: build → push → bootstrap →
  self-manage → verify on an ephemeral k3d cluster. It requires the
  docker daemon. No version is published without a green run.

## Repository Conventions

- Never hand-edit `oci/` — change `src/` and re-render with
  `mise run artifact:build`; the `oci/` diff is the review surface
  for every change.
- Keep agent guidance tool-neutral: edit `AGENTS.md` and
  `.agents/skills/`, and preserve `CLAUDE.md` and `.claude/skills` as
  symlinks to them rather than maintaining copies.
- Store durable current-state knowledge in `docs/`
  ([`docs/README.md`](docs/README.md) governs it); store temporary
  reasoning and intended work in a work note under `work/`
  ([`work/README.md`](work/README.md) governs it).
- Rewrite current-state documents instead of appending historical
  logs; git history is the changelog.
- Org-wide law lives in the flagship
  ([cur8s/cur8s `docs/rfc/`](https://github.com/cur8s/cur8s/tree/main/docs/rfc))
  — link to it, never copy it.

## Verification

Before considering a change complete, run:

```sh
mise run test:drift
git diff --check
```

For a change that alters the rendered artifact or bootstrap behavior
(`src/`, `VERSION`, the `mise.toml` tool pins), also run:

```sh
mise run test:e2e
```

CI runs both gates on every push; a change is not done while either
is red.

## Commit Messages

Use [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
for every commit:

```text
<type>[optional scope][!]: <description>
```

Use a lowercase type and add a scope only when it provides stable,
useful context. Write the description as a concise imperative
statement without a trailing period. Mark breaking changes with `!`
and explain them in a `BREAKING CHANGE:` footer. Before committing,
verify that the message describes everything staged and nothing
unstaged.

Never push commits and never publish artifacts to a remote registry
unless explicitly asked.
