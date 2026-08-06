# Durable Project Knowledge

This directory records durable, current-state knowledge about the Flux package. Rewrite a document when its subject changes; Git history preserves the old state. Temporary investigation and planning belong in a work note under [`work/`](../work/README.md). Platform-wide law belongs in the [cur8s flagship RFCs](https://github.com/cur8s/cur8s/tree/main/docs/rfc) and is linked here rather than copied.

| Document | Responsibility |
| --- | --- |
| [`vision.md`](vision.md) | Why this package exists, its audience, success, and boundaries. |
| [`user-guide.md`](user-guide.md) | Consumer-facing philosophy, supported surface, bootstrap, operation, upgrades, verification, and limits. |
| [`architecture.md`](architecture.md) | How the source-to-artifact pipeline, decision boundary, task lifecycle, publication, and self-management work. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | How contributors set up, author, verify, and change the repository. |

Keep one authoritative home for each subject. The root README is only the orientation and route map; `mise.toml` remains the command reference. Do not create local RFCs for current behavior: explain component-specific consequences in the guide or architecture and link to a flagship RFC whenever the rule is organization-wide.
