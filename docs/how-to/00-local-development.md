# Local development

> [!NOTE]
> Use this guide to set up the pinned toolchain, regenerate the deployment payload, try a change
> on a disposable cluster, and verify the committed result.

## Set up the repository

Install the [software prerequisites](../../README.md#prerequisites) and start the Docker daemon.
The task scripts also use Git, Bash, curl, OpenSSL, and standard shell utilities from the host.
Run the following from the repository root:

```sh
mise trust
mise install
docker info >/dev/null
mise tasks
```

Expected result: mise installs the locked toolchain, Docker responds, and mise lists the repository
tasks. [`mise.toml`](../../mise.toml) owns tool selections, environment values, and task conventions;
[`mise.lock`](../../mise.lock) records the tool downloads and checksums. Use
`mise run <task> --help` for a task's arguments and flags.

Local cluster tasks use the repository's ignored `.kube/config` and target the named k3d context.
Use `mise run` for those tasks, or `mise exec -- kubectl ...` for direct inspection, so the
repository's environment is loaded. Default development and test names are declared in `mise.toml`.
Explicit cluster names must start with `flux-`; choose an unused name for each new environment.

## Regenerate the deployment payload

Edit authored installation configuration under [`src/config/`](../../src/README.md). The captured
upstream manifest lives in [`upstream/flux.yaml`](../../upstream/flux.yaml); refresh it explicitly
when changing the selected upstream release, as described below.

```sh
mise run build:render
git diff -- upstream src artifacts/rendered mise.toml mise.lock
```

Expected result: `artifacts/rendered/` is regenerated from the captured input and authored
configuration. Inspect its diff alongside the producing changes. Keep authored changes in their
source files and regenerate their output; do not hand-edit the rendered files.

`build:render` first removes the whole `artifacts/` tree, then regenerates the rendered payload.
Captured upstream input and authored configuration survive cleanup. Keep all hand-authored files
outside `artifacts/`; `artifacts/oci/` is reserved for future generated packaging output and is
also removed by cleanup. If the captured manifest is missing, run `mise run upstream:fetch`, then
render again. Rendering itself does not fetch upstream or require a cluster.

[From source to artifact](../architecture/01-source-to-artifact.md) explains the input boundary
and committed review surface. [Artifact contents and metadata](../architecture/02-artifact-contents-and-metadata.md)
identifies the generated files.

## Try an uncommitted candidate locally

Render the candidate first. Then create a disposable environment from those rendered files:

```sh
mise run dev:create flux-preview
mise run dev:status flux-preview
mise run flux:reconcile flux-preview
```

Expected result: Flux's controllers become available, the payload is published to the new cluster's
local registry, and `OCIRepository/flux` and `Kustomization/flux` report Ready. Reconciliation targets
this component's Kustomization and its source. The development task does not fetch or render; it
consumes the output already on disk, including uncommitted candidate changes.

For continuous observation, run `mise run flux:watch flux-preview` and stop it with Ctrl-C. For
direct controller inspection, use the same named context through mise:

```sh
mise exec -- kubectl --context k3d-flux-preview -n flux-system get deployments
```

When finished, remove the environment and its local registry:

```sh
mise run dev:delete flux-preview
```

This workflow tests a candidate before committing. The committed-tree check below establishes
the additional guarantee that fresh capture and rendering match the recorded files.

## Verify the committed result

Check whitespace in both unstaged and staged changes:

```sh
git diff --check
git diff --cached --check
```

Commit changed captured inputs or authored configuration together with their regenerated output
when authorized under the [agent instructions](../../AGENTS.md). Once `upstream/` and
`artifacts/rendered/` match the committed tree, run the combined verification task using an unused
test name:

```sh
mise run test:run flux-check
```

The task captures upstream, renders, and checks those two directories for Git changes before
creating a cluster. Staged changes count too: it stops before the cluster test if the captured
input or rendered output is uncommitted, even when that output was regenerated correctly. Use the
candidate workflow above while preparing that change for review.

After the committed-tree check, the task creates a disposable environment, boots Flux, publishes
to its local registry, and verifies self-management. Expected result: the task exits successfully
and removes its cluster and registry. It exercises fresh installation and self-management on the
selected runtime; the [verification scope](../architecture/03-publication-and-self-management.md#verification-scope-and-remaining-publication-work)
describes its limits.

If the cluster stage fails, the environment is retained for inspection. Diagnose it, then remove
it explicitly:

```sh
mise run dev:status flux-check
mise run test:destroy flux-check
```

A failed drift check creates no test cluster. An existing cluster with the chosen name must be
removed or a different test name selected before retrying creation.

## Update an upstream version or tool pin

After changing `FLUX_VERSION` or a tool pin in `mise.toml`, refresh all supported lockfile platforms
and install the selected toolchain:

```sh
mise lock --platform linux-x64,linux-arm64,macos-x64,macos-arm64
mise install
```

If the Flux release changed, capture its installation explicitly:

```sh
mise run upstream:fetch
```

Render, inspect the source and output diffs, and use the candidate and committed-result workflows
above. Review the lockfile with the pin change. A green run on the selected runtime is required
before treating a changed installation as verified.

The development and test tasks publish to local registries. Remote publication is a separate,
explicitly authorized operation described in
[Publication and self-management](../architecture/03-publication-and-self-management.md); it is
not a setup or verification step.
