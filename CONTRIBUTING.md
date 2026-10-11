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
mise install   # pinned toolchain: flux, kustomize, kubectl, k3d
mise tasks     # list every task
```

## Commands

Tasks follow the `<object>:<action>` grammar; the
[`mise.toml`](mise.toml) header is the authoritative description of
the objects, the grammar, and the pinned toolchain.

| Command | Intent |
| --- | --- |
| `mise run artifact:build` | Fetch upstream → render the artifact tree. |
| `mise run test:drift` | Prove the committed `oci/` tree matches a fresh build. |
| `mise run test:e2e` | Prove the full bootstrap → self-manage loop on an ephemeral k3d cluster. |
| `mise run cluster:<action>` | Create, inspect, or delete a k3d dev cluster and its registry. |
| `mise run flux:<action>` | Bootstrap or inspect Flux on a dev cluster. |
| `mise run artifact:deploy` / `artifact:verify` | Point a dev cluster's Flux at the pushed artifact, then wait for it to be Ready. |
| `mise run upstream:check` | Report whether upstream Flux has a newer release than the tracked version. |
| `mise run release` | Build and publish the versioned OCI artifact — only when explicitly asked. |

A release has two channels: the OCI artifact that `mise run release`
publishes, and the rendered `oci/flux/deploy/flux.yaml` attached to a GitHub
release as `install.yaml`. Run the end-to-end gate before publishing either.
The repository has no CI workflows yet; contributors run the gates locally.

## Testing

There is no unit-test suite; the product is a rendered tree, so the
tests are the pipeline itself:

- `test:drift` is the review-surface gate: what is committed under
  `oci/` and `src/flux/artifacts/` must be byte-for-byte what the
  pinned pipeline produces from `src/`.
- `test:e2e` is the product contract and Kubernetes compatibility gate:
  build → push → bootstrap → self-manage → verify on an ephemeral k3d
  cluster. Its API server accepts the generated Flux manifest and the
  readiness checks prove the controllers and self-management resources
  converge. It requires the docker daemon. No version is published without
  a green run.

## Repository Conventions

- Never hand-edit `oci/` — change `src/` and re-render with
  `mise run artifact:build`; the `oci/` diff is the review surface
  for every change.
- Keep agent guidance tool-neutral: edit `AGENTS.md` and
  `.agents/skills/`, and preserve `.claude/skills` as a symlink to the
  skills rather than maintaining copies.
- Store durable current-state knowledge in `docs/`
  ([`docs/README.md`](docs/README.md) governs it); keep temporary
  reasoning and intended work under `work/`, managed with the
  `manage-work-notes` skill. Nothing outside `work/` links into it.
- Rewrite current-state documents instead of appending historical
  logs; git history is the changelog.
- The documents listed in `docs/README.md` are authoritative for this
  package. Update the document that owns a subject when its behavior
  changes; do not depend on an external RFC for the package contract.

## Verification

Before considering a change complete, run:

```sh
mise run test:drift
git diff --check
```

For a change that alters the rendered artifact or bootstrap behavior
(`src/`, the `mise.toml` version or tool pins), also run:

```sh
mise run test:e2e
```

A change to `FLUX_VERSION` or any tool pin must also refresh the committed
`mise.lock`, which holds each tool's download checksums:

```sh
mise lock --platform linux-x64,linux-arm64,macos-x64,macos-arm64
```

A change is not done while either gate is red.

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
