# Documentation strategy

> [!NOTE]
> Use this document to choose where an explanation belongs, how to write it, and when to update it.

This directory holds durable knowledge about the Flux package. The
[repository README](../README.md) introduces the package and gives readers a reading order.
[Repository entry files](standards/repository-entry-files-standard.md) defines the rules for that
README, agent instructions, and directory READMEs.

## Categories and reading order

Organize documents into four categories. Introduce the package's purpose and philosophy before
explaining its mechanisms; let readers consult procedures and standards as their work requires.

| Category | Responsibility | Writing form |
| --- | --- | --- |
| [`product/`](product/README.md) | Audience, problem, intended value, pre-rendered-manifest philosophy, and the package's supported surface and boundaries. | Explain purpose and choices, with their rationale. |
| [`architecture/`](architecture/README.md) | Package boundary, source-to-artifact pipeline, artifact contents and metadata, publication, and self-management. | Explain responsibilities, mechanisms, and invariants. |
| [`how-to/`](how-to/00-local-development.md) | Local development, bootstrap, operation, upgrades, and recovery. | Give prerequisites, actions, and observable results. |
| `standards/` | Agreed technical conventions and the reasons for them. | State rules, their scope, rationale, and examples. |

Use two-digit filename prefixes to suggest reading order within each category, starting at `00`.
Entry files retain their conventional names. Keep existing published paths stable unless a move
improves the reading path, and repair references whenever a document moves. Add a directory README
when the collection needs its own orientation or reading path.

## Writing and maintenance

- Open each document with a short purpose callout saying what reading it enables someone to do.
- Give each subject one authoritative home. Other documents link to it and include only the
  context their readers need.
- Publish explanations that stand alone for their stated scope. Distinguish accepted intent and
  design from verified current behavior, proposals, and open questions; check implementation
  claims against the repository.
- Update the document that owns a subject when that subject changes. Rewrite the current account;
  Git preserves earlier wording.
- Keep investigations, experiments, execution plans, and review history in the repository's work
  material. Durable documents and code may refer to other durable documents and implementation
  evidence, but must not link or point into that work material.

## Current reading path

The existing documents remain authoritative until their replacements are reviewed and accepted.
As each subject moves into a category, replace its entry here and repair affected links in the
repository README and other documents.

| Document | Responsibility |
| --- | --- |
| [Vision](product/00-vision.md) | Why this package exists, its audience, success, and boundaries. |
| [Pre-rendered manifests](product/01-pre-rendered-manifests.md) | Why artifacts are constructed before deployment, and the constraints on runtime composition and declared values. |
| [The package's opinion](product/02-the-opinion.md) | Controller selection, source recommendations, exclusions, and the unresolved Receiver webhook contract. |
| [User guide](user-guide.md) | Bootstrap, operation, upgrades, recovery, and their verification. |
| [Local development](how-to/00-local-development.md) | Toolchain setup, rendering, candidate environments, committed-tree verification, and lockfile refresh. |
| [Architecture overview](architecture/00-overview.md) | Package and consumer responsibilities, bootstrap, and the self-management boundary. |
| [From source to artifact](architecture/01-source-to-artifact.md) | Pinned inputs, explicit upstream capture, rendering, committed output, and verification boundaries. |
| [Artifact contents and metadata](architecture/02-artifact-contents-and-metadata.md) | Applied content, descriptor fields, publication annotations, and file versus OCI identity. |
| [Publication and self-management](architecture/03-publication-and-self-management.md) | The release contract, current automation, bootstrap readiness, self-management, and verification scope. |
| [Repository entry files standard](standards/repository-entry-files-standard.md) | What belongs in the root README, agent instructions, and directory READMEs. |
| [Mise standard](standards/mise-standard.md) | Lockfile enforcement, tool pinning, `[env]` validation, file tasks, and `#MISE` headers. |
| [Bash script standard](standards/bash-script-standard.md) | Linear task scripts, executed helpers, flat statements, self-contained comments, and `shellcheck` verification. |
