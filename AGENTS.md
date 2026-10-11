# Agent instructions

## Commits

- Use Conventional Commits for commit messages.
- Commit only when the user explicitly asks.
- Push commits only when the user explicitly asks.

## OCI artifact

- Change `oci/` only by editing `src/` and re-rendering.
- Commit the re-rendered `oci/` changes together with the `src/` change that produced them.
- Publish artifacts to a remote registry only when the user explicitly asks.

## Repository entry files

- When editing the root `README.md`, `AGENTS.md`, or a directory README, follow
  `docs/standards/repository-entry-files-standard.md`.

## Work reference boundary

- Reference files under `work/` only from other files under `work/`.
- Link from files under `work/` to any file in the repository.
