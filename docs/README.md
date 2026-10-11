# Durable Project Knowledge

This directory records durable, current-state knowledge about the Flux package. Rewrite a document
when its subject changes; Git history preserves the old state. Temporary investigation and planning
belong in the repository's work material, not here. The documents in this repository are the
authoritative source for the package's behavior and architecture.

| Document | Responsibility |
| --- | --- |
| [`vision.md`](vision.md) | Why this package exists, its audience, success, and boundaries. |
| [`user-guide.md`](user-guide.md) | Consumer-facing philosophy, supported surface, bootstrap, operation, upgrades, verification, and limits. |
| [`architecture.md`](architecture.md) | How the source-to-artifact pipeline, decision boundary, task lifecycle, publication, and self-management work. |
| [`standards/repository-entry-files-standard.md`](standards/repository-entry-files-standard.md) | What belongs in the root `README.md`, `AGENTS.md`, and directory READMEs. |

Keep one authoritative home for each subject. The root README is only the orientation and route
map; `mise tasks` lists the available commands. Do not create a separate RFC catalog for current
behavior: document durable intent in the vision, consumer-facing behavior in the user guide, and
implementation structure in the architecture.
