# Sources

Unedited copies of the documentation this todo rebuilds from. They are input material, not
accepted content: drafts draw on them selectively, and anything about the monorepo's layer
architecture is superseded by the one-component-per-repository direction.

| Directory | Origin | Taken at |
| --- | --- | --- |
| [`flux/`](flux/) | `cur8s/flux` repository, `docs/` | commit `06c800d`, 2026-10-11 |
| [`monorepo/`](monorepo/) | `~/dev/cur8s/monorepo-cur8s`, `docs/` | commit `a4eb317`, 2026-10-11 |
| [`flux/CONTRIBUTING.md`](flux/CONTRIBUTING.md) | `cur8s/flux` repository, root `CONTRIBUTING.md`, removed in `639c197` | commit `22ba4ba`, 2026-10-11 |

The `flux/` files are preserved copies. The accepted
[product vision](../../../../docs/product/00-vision.md) replaces the original flat vision document.
The accepted [rendering philosophy](../../../../docs/product/01-pre-rendered-manifests.md) and
[package opinion](../../../../docs/product/02-the-opinion.md) now own the corresponding user-guide
subjects. The live user guide retains installation and operation. The accepted
[architecture overview](../../../../docs/architecture/00-overview.md) owns the package boundary,
and [From source to artifact](../../../../docs/architecture/01-source-to-artifact.md) owns capture,
rendering, and drift verification. The accepted
[metadata explanation](../../../../docs/architecture/02-artifact-contents-and-metadata.md) owns
artifact content and identity. The accepted
[publication explanation](../../../../docs/architecture/03-publication-and-self-management.md)
owns runtime and publication details; the flat architecture has been retired.

Most relevant monorepo material for the product phase:

- [`rfc/RFC-002-curated-opinionated-platform.md`](monorepo/rfc/RFC-002-curated-opinionated-platform.md)
- [`rfc/RFC-004-declarative-cluster-control.md`](monorepo/rfc/RFC-004-declarative-cluster-control.md)
- [`rfc/RFC-005-static-runtime-manifests.md`](monorepo/rfc/RFC-005-static-runtime-manifests.md)
- [`rfc/RFC-008-flux-as-the-gitops-engine.md`](monorepo/rfc/RFC-008-flux-as-the-gitops-engine.md)
- [`why/`](monorepo/why/README.md) essays for the broader philosophy
