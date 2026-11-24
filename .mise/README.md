# Task tooling

[mise](https://mise.jdx.dev/getting-started.html) runs the executable tasks under `tasks/` with the
pinned toolchain in [`mise.toml`](../mise.toml). Use `mise tasks` for command discovery; keep supporting
configuration outside `tasks/` so it is not discovered as a task. [`cluster.sh`](cluster.sh), run by
the tasks rather than directly, manages the repository's `dev` and `test` k3d clusters with
[`k3d-config.yaml`](k3d-config.yaml); both are identical across component repositories.
[`env.sh`](env.sh) holds the component-specific cluster bootstrap and self-management setup shared
by `dev:create` and `test:run`.

[From source to artifact](../docs/architecture/01-source-to-artifact.md) explains the pipeline;
[Publication and self-management](../docs/architecture/03-publication-and-self-management.md)
explains the local verification and publication boundaries.
