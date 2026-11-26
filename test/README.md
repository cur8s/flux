# Test and development fixtures

Keep repository-local manifests used to exercise the package in disposable `dev` and `verify`
clusters here, outside `src/` and `artifacts/rendered/` so they are never packaged into the
published OCI artifact.

- [`sync.yaml`](sync.yaml): the local self-management `Kustomization` referenced by
  `FLUX_SYNC_PATH` in [`mise.toml`](../mise.toml) and applied by
  [`.mise/cluster/install-component.sh`](../.mise/cluster/install-component.sh) and
  [`dev:update`](../.mise/tasks/dev/update).

[Local development](../docs/how-to/00-local-development.md) explains the disposable cluster
workflows; the [user guide](../docs/user-guide.md) shows the production bootstrap manifests that
consuming clusters own.
