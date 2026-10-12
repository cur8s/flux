# Architecture

> [!NOTE]
> Follow this reading path to understand the package boundary, rendering pipeline, artifact
> identity, and handoff to Flux self-management.

Read the overview first, then consult the explanation that owns the mechanism you are considering.

| Order | Document | What it explains |
| --- | --- | --- |
| 1 | [Overview](00-overview.md) | Package and consumer responsibilities, bootstrap, and current versus intended self-management ownership. |
| 2 | [From source to artifact](01-source-to-artifact.md) | Pinned inputs, explicit upstream capture, rendering, committed output, and verification boundaries. |
| 3 | [Artifact contents and metadata](02-artifact-contents-and-metadata.md) | Installation content, descriptor fields, publication annotations, and file versus OCI identity. |
| 4 | [Publication and self-management](03-publication-and-self-management.md) | The release contract, current automation, bootstrap readiness, normal operation, and remaining publication work. |

The [product documents](../product/README.md) explain the purpose and choices this architecture
supports. Use the [user guide](../user-guide.md) for current installation and operation procedures,
and the [documentation strategy](../README.md) when maintaining these explanations.
