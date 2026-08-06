# flux — the Cur8s GitOps engine package

This repository renders Cur8s' constrained [Flux](https://fluxcd.io) installation once and publishes it as an immutable OCI artifact. It installs only source, kustomize, and notification controllers, so a cluster reconciles explicit, static intent rather than interpreting templates or selecting versions at runtime.

Start with the [user guide](docs/user-guide.md) to bootstrap and operate the package, [architecture](docs/architecture.md) to understand the artifact lifecycle, and [vision](docs/vision.md) for the durable intent. Contributors should follow [CONTRIBUTING.md](CONTRIBUTING.md).

For a local build and full verification:

```sh
mise install
mise run artifact:build
mise run test:e2e
```

The rendered `oci/flux/` tree is committed deliberately: its diff is the reviewable deployment result. Run `mise run test:drift` to prove it matches a fresh render. Org-wide architecture and versioning rules remain authoritative in the [cur8s flagship RFCs](https://github.com/cur8s/cur8s/tree/main/docs/rfc).
