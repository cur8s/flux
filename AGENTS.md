# Agent instructions

## Commits

- Use Conventional Commits for commit messages.
- Commit only when the user explicitly asks.
- Push commits only when the user explicitly asks.

## Generated artifacts

- Change `artifacts/rendered/` only by editing captured inputs in `upstream/`, authored
  configuration in `src/`, or render configuration, then re-rendering.
- Commit re-rendered `artifacts/rendered/` changes together with the input or configuration
  change that produced them.
- Keep hand-authored files outside `artifacts/`.
- Publish artifacts to a remote registry only when the user explicitly asks.

## Repository entry files

- When editing the root `README.md`, `AGENTS.md`, or a directory README, follow
  `docs/standards/repository-entry-files-standard.md`.

## Verification

- Follow `docs/how-to/00-local-development.md` for local setup and verification.

## Work reference boundary

- Reference files under `work/` only from other files under `work/`.
- Link from files under `work/` to any file in the repository.
