# Architecture

## Package boundary

This repository owns one release unit: an opinionated Flux installation published as an immutable
OCI artifact. It owns the upstream version pin, controller selection, source configuration,
rendering, bootstrap manifest, and the resource that lets Flux reconcile its own
installation.

A consuming cluster owns the `OCIRepository` because the registry endpoint, credentials, and
artifact version are deployment-specific intent. It also owns any higher-level composition and
integration with other cluster components. The package ships its self-management `Kustomization`
because that resource describes how the artifact reconciles its own `deploy/` directory once a
source has been declared.

## From upstream release to immutable intent

`FLUX_VERSION` and `CUR8S_FLUX_REVISION` in the `mise.toml` `[env]` section are the only authored
version source: the upstream Flux version and a Cur8s configuration revision. The Flux tool pin
follows `FLUX_VERSION`. `upstream:fetch` runs that pinned Flux CLI with the three permitted
controllers and stores the upstream manifest in `src/flux/artifacts/`. That tree is generated
upstream input, not an authored install.

The authored opinion is deliberately small:

- `src/flux/config/overlays/deploy/` composes the fetched manifest with metadata-only Cur8s marks.
- `src/flux/config/sync.yaml` defines the self-management `Kustomization`.

`build:render` clears the generated tree with `build:clean`, then uses Kustomize to produce
`oci/flux/deploy/flux.yaml`, copies `sync.yaml`, and writes the inert `cur8s.yaml` release
descriptor. The complete `oci/flux/` tree is committed intentionally: it is the review surface and
the exact content later pushed as an OCI artifact.

```text
mise.toml version + pinned Flux CLI + source configuration
                    │
                    ▼
             fetch → render → committed oci/flux/
                                      │
                         ┌────────────┴────────────┐
                         ▼                         ▼
            versioned OCI artifact       GitHub release install.yaml
                  (steady state)              (first touch)
```

All choices owned by this package resolve before publication. Kustomize is used only for
deterministic, build-time structural composition; it cannot vary output with cluster state. The
cluster definition later supplies the environment-specific source endpoint and immutable version
pin, but does not reinterpret or mutate the package. At runtime source-controller fetches that
declared artifact and kustomize-controller applies its static manifests. The cluster executes
recorded package decisions rather than making new ones.

## Artifact contents and metadata

The rendered artifact contains three files:

```text
oci/flux/
├── cur8s.yaml
├── deploy/
│   └── flux.yaml
└── sync.yaml
```

`deploy/flux.yaml` is the complete controller installation. `sync.yaml` is the self-management
`Kustomization`. `cur8s.yaml` is an inert release descriptor for humans and tooling; Kubernetes
does not apply it.

The descriptor contains only facts known at render time: component identity, package version,
upstream project, upstream version and digest, source, and documentation location. It deliberately
omits a timestamp and Git revision so a fresh render remains byte-for-byte reproducible. The push
task adds source revision and other registry-facing facts as OCI manifest annotations. Both forms
of metadata obtain their shared component facts from the `[env]` section of `mise.toml`.

## Task graph and verification

[mise](https://mise.jdx.dev) is the task runner. Its `mise.toml` header is the authoritative
command reference and defines the `<object>:<action>` grammar. The important lifecycle is:

```text
upstream:fetch → build:render ─┬─ test:drift
                               │
cluster:create → flux:boot → artifact:push → artifact:deploy → artifact:verify
                               ▲
                            test:e2e
```

`upstream:fetch` is the only step that reaches for upstream; `build:render` works from the captured
inputs alone, so outputs can be regenerated and diffed without re-fetching. `cluster` is pure k3d
lifecycle: a cluster and its local registry with nothing installed. `flux:boot` installs Flux from
the locally rendered manifest. `artifact:deploy` supplies the `OCIRepository` and applies the
artifact's `sync.yaml`, and `artifact:verify` waits for that `Kustomization` to become Ready;
because `sync.yaml` sets `wait: true`, Ready means Flux has health-checked every resource the
artifact applied. Only `upstream:fetch`, `build:render`, and `flux:boot` are specific to this
component, so other Cur8s component repositories can share the remaining tasks.

`test:drift` re-fetches and re-renders, and proves that the committed `oci/` tree and fetched
upstream manifest match the pins. `test:e2e` runs that whole sequence on an ephemeral k3d cluster:
Flux installs from this repository's render and then takes over managing itself from the pushed
artifact. This is both the package's release gate and its semantic compatibility check for the
generated manifest: the repository does not hand-author the Flux controller installation and
therefore cannot repair a static schema failure independently of changing the Flux or Kubernetes
version. Deployments that combine this artifact with other components own their broader integration
verification.

## Bootstrap, publication, and self-management

The production release has two deliberately paired outputs. `release` builds and pushes
`oci://ghcr.io/cur8s/flux:<version>`, after the end-to-end gate has passed, and the exact rendered
install manifest is published as the GitHub release asset `install.yaml`. First
touch applies that asset. Once the controllers are running, the cluster definition supplies the
`OCIRepository` for the chosen tag and applies `sync.yaml`. Flux then fetches the artifact and
reconciles its own `deploy/` directory.

The OCI source is environment-specific: development points at k3d's local registry, while
production points at `ghcr.io`. That source remains outside the package because choosing an
environment and artifact version is a decision-time concern. The self-management resource is
inside the artifact so the artifact fully describes its side of the relationship once a source is
declared.

Artifacts are immutable. An upstream release changes `FLUX_VERSION`; an opinion-only change
increments `CUR8S_FLUX_REVISION`. A version is never retagged, and Flux only applies the tag
declared by the cluster.
