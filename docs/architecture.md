# Architecture

## From upstream release to immutable intent

`version.env` is the only authored version source. It records the upstream Flux version and a Cur8s configuration revision; the `mise.toml` Flux pin follows it. `artifact:fetch` runs that pinned Flux CLI with the three permitted controllers and stores both the upstream manifest and its digest in `src/flux/artifacts/`. That tree is an audit trail, not an authored install.

The authored opinion is deliberately small:

- `src/flux/config/overlays/deploy/` composes the fetched manifest with metadata-only Cur8s marks.
- `src/flux/config/sync.yaml` defines the self-management `Kustomization`.

`artifact:render` uses Kustomize to produce `oci/flux/deploy/flux.yaml`, copies `sync.yaml`, and writes the inert `cur8s.yaml` release descriptor. `artifact:validate` checks the rendered manifest with kubeconform. The complete tree under `oci/flux/` is committed intentionally: it is the review surface and the exact content later pushed as an OCI artifact.

```text
version.env + pinned Flux CLI + source configuration
                    │
                    ▼
      fetch → render → validate → committed oci/flux/
                                      │
                         ┌────────────┴────────────┐
                         ▼                         ▼
            versioned OCI artifact       GitHub release install.yaml
                  (steady state)              (first touch)
```

The pipeline resolves all choices before publication. Kustomize is used only as deterministic, build-time structural composition; it cannot vary output with cluster state. At runtime source-controller fetches the declared artifact and kustomize-controller applies its static manifests. This preserves the decision-time/runtime boundary required by the flagship's [RFC-005: Static Runtime Manifests](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-005-static-runtime-manifests.md): the cluster executes recorded decisions rather than making new ones.

## Task graph and verification

[mise](https://mise.jdx.dev) is the task runner. Its `mise.toml` header is the authoritative command reference and defines the `<object>:<action>` grammar. The important lifecycle is:

```text
artifact:clean → artifact:fetch → artifact:render → artifact:validate
                                      │
                                      ▼
                              artifact:build
                              ├─ test:drift
                              └─ artifact:push
                                      │
        cluster:create → cluster:init → cluster:sync → cluster:verify
                                      ▲
                                   test:e2e
```

`test:drift` rebuilds and proves that the committed `oci/` tree and fetched audit trail still match the pins. `test:e2e` creates an ephemeral k3d cluster, builds and pushes a local artifact, bootstraps the controllers, hands them the self-management resources, and waits for the resulting source and Kustomization to become Ready. The end-to-end run qualifies every published version.

## Bootstrap, publication, and self-management

The production release has two deliberately paired outputs. `release` builds and pushes `oci://ghcr.io/cur8s/flux:<version>`; the tag-triggered workflow runs the end-to-end gate and publishes the exact rendered install manifest as the GitHub release asset `install.yaml`. First touch applies that asset. Once the controllers are running, the cluster's external composition supplies the `OCIRepository` for the chosen tag and applies `sync.yaml`. Flux then fetches the artifact and reconciles its own `deploy/` directory.

The OCI source is environment-specific: development points at k3d's local registry, while production points at `ghcr.io`. That source remains outside the package because choosing an environment and artifact version is a decision-time concern. The self-management resource is inside the artifact so the artifact fully describes the relationship once a source is declared.

Artifacts are immutable. An upstream release changes `FLUX_VERSION`; an opinion-only change increments `CUR8S_FLUX_REVISION`. A version is never retagged, and Flux only applies the tag declared by the cluster. The version rule itself is owned by the flagship's [RFC-011: Component Versioning](https://github.com/cur8s/cur8s/blob/main/docs/rfc/RFC-011-component-versioning.md).
