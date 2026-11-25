# Task tooling

[mise](https://mise.jdx.dev/getting-started.html) runs the executable tasks under `tasks/` with the
pinned toolchain in [`mise.toml`](../mise.toml). Use `mise tasks` for command discovery; keep supporting
configuration outside `tasks/` so it is not discovered as a task. [`cluster.sh`](cluster.sh) and
[`k3d-config.yaml`](k3d-config.yaml) manage the repository's `dev` and `verify` k3d clusters,
[`push-artifact.sh`](push-artifact.sh) pushes `artifacts/rendered/` with `cur8s.io/*` annotations
to local or remote registries, and [`install-component.sh`](install-component.sh) installs Flux and
this component into an existing cluster using `FLUX_BOOTSTRAP_MANIFEST` and `FLUX_SYNC_MANIFESTS`
from `mise.toml`. All of those helpers are identical across component repositories.

[From source to artifact](../docs/architecture/01-source-to-artifact.md) explains the pipeline;
[Publication and self-management](../docs/architecture/03-publication-and-self-management.md)
explains the local verification and publication boundaries.
