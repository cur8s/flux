# Local development

> [!NOTE]
> Use this guide to set up the pinned toolchain, regenerate the deployment payload, try a change
> on a disposable cluster, and verify the committed result.

## Set up the repository

Install the [software prerequisites](../../README.md#prerequisites) and start the Docker daemon.
The task scripts also use Git, Bash, curl, OpenSSL, jq, and standard shell utilities from the host.
Run the following from the repository root:

```sh
mise trust
mise install
docker info >/dev/null
mise tasks
```

Expected result: mise installs the locked toolchain, Docker responds, and mise lists the repository
tasks. [`mise.toml`](../../mise.toml) owns tool selections and environment values;
[`mise.lock`](../../mise.lock) records the tool downloads and checksums.

The repository has two local k3d clusters: `dev` (`gitops-dev`) and `verify` (`gitops-verify`). All
`dev:*` tasks target `dev`; `verify:*` tasks own `verify`. Their contexts live in the repository's
ignored `.kube/config`. Use `mise run` for tasks, or `mise exec -- kubectl ...` and
`mise exec -- flux ...` for direct inspection, so the repository's environment is loaded.

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

Create the development environment (which runs `build:render` first, then boots Flux, pushes to
the local registry, and wires up self-management):

```sh
mise run dev:create
mise run dev:status
```

Expected result: `artifacts/rendered/` is regenerated, Flux's CRDs become `Established` and its
controllers become `Available`, the payload is pushed to the new cluster's local registry, the
repo-local [`test/sync.yaml`](../../test/sync.yaml) fixture is applied, and `OCIRepository/gitops`
and `Kustomization/gitops` report Ready.

After further edits under `src/config/`, push the regenerated payload to the running `dev` cluster
and reconcile immediately:

```sh
mise run dev:update
```

To trigger reconciliation without re-rendering or pushing, run `mise run dev:reconcile` (which
targets only this component's Kustomization and its source). For continuous observation, run
`mise run dev:watch` and stop it with Ctrl-C. For direct controller inspection, use the cluster's
context through mise:

```sh
mise exec -- kubectl --context k3d-gitops-dev -n flux-system get deployments
```

When finished, remove the environment and its local registry:

```sh
mise run dev:delete
```

This workflow tests a candidate before committing. The committed-tree check below establishes
the additional guarantee that fresh capture and rendering match the recorded files.

## Verify the committed result

Check whitespace in both unstaged and staged changes (and lint bash scripts when `.mise/` changed):

```sh
git diff --check
git diff --cached --check
bash -n .mise/cluster/*.sh .mise/tasks/*/*
mise exec -- shellcheck .mise/cluster/*.sh .mise/tasks/*/*
```

Commit changed captured inputs or authored configuration together with their regenerated output
when authorized under the [agent instructions](../../AGENTS.md). Once `upstream/` and
`artifacts/rendered/` match the committed tree, run the combined verification task:

```sh
mise run verify:run
```

The task captures upstream, renders, and checks those two directories for Git changes before
creating a cluster. Staged changes count too: it stops before the cluster test if the captured
input or rendered output is uncommitted, even when that output was regenerated correctly. Use the
candidate workflow above while preparing that change for review.

After the committed-tree check, the task creates the verify cluster, boots Flux, pushes
to its local registry, and verifies self-management. Expected result: the task exits successfully
and removes its cluster and registry. It exercises fresh installation and self-management on the
selected runtime; the [verification scope](../architecture/03-publication-and-self-management.md#verification-scope-and-remaining-publication-work)
describes its limits.

If the cluster stage fails, the environment is retained for inspection. Diagnose it with the
verify context, then remove it explicitly:

```sh
mise exec -- flux --context k3d-gitops-verify get all -A
mise run verify:clean
```

A failed drift check creates no verify cluster. A verify cluster kept from an earlier failure must
be removed with `verify:clean` before retrying.

## Update an upstream version or tool pin

After changing a tool pin in `mise.toml` (including `flux2` when updating `UPSTREAM_VERSION`),
refresh all supported lockfile platforms and install the selected toolchain:

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

The development and verify tasks push to local registries. Remote publication is a separate,
explicitly authorized operation described in
[Publication and self-management](../architecture/03-publication-and-self-management.md); it is
not a setup or verification step.
