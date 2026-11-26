# Development Guide

Daily workflows and iteration patterns for developing the Cur8s platform.

## Development Workflow

### Fast Iteration Loop

Once your environment is set up (see [Getting Started](getting-started.md)), the typical iteration cycle is:

```bash
# 1. Edit component source
vim src/platform/cert-manager/...

# 2. Build and push (rebuilds → pushes to registry)
make push

# 3. Watch Flux reconcile (in separate terminal)
watch flux get all -A
```

Flux automatically detects the new artifact and reconciles within ~30 seconds. No manual intervention needed.

### Review Changes Before Pushing

Since `make push` rebuilds everything, you can review what changed:

```bash
# Build locally first
make build

# Review rendered manifests
git diff oci/

# Push when satisfied
make push
```

## Makefile Targets

### Development Targets (Filesystem Only)

These targets work with local files only, no cluster required:

#### `make prereqs`
Verify every component's upstream is reachable before any fetch work runs.

```bash
make prereqs
```

Loops every platform component and probes whatever it would actually pull during `fetch` — GitHub releases, Helm HTTP repos, Helm OCI charts, container registries, raw URLs. Each line is tagged with the check type:

| Tag | Probe | Verifies |
|---|---|---|
| `[github]` | HTTP GET to `api.github.com` | network + release tag exists |
| `[helm-http]` | HTTP GET to `repo/index.yaml` | network + TLS |
| `[helm-oci]` | `docker manifest inspect` | network + TLS + registry auth |
| `[container]` | `docker manifest inspect` | network + TLS + registry auth |
| `[http]` | HTTP HEAD to URL | network + TLS |

On failure the script prints a remediation hint for the recognizable cases (stale Docker credentials, sandbox MITM cert issues, missing tag, GitHub rate limit). Runs in ~5s — useful as a fast preflight before the longer `make build`.

`fetch` and `build` also invoke `prereqs` automatically via the per-component `fetch: prereqs` dependency — running `make prereqs` standalone is purely a diagnostic shortcut.

#### `make clean`
Remove all generated artifacts.

```bash
make clean
```

Deletes the `oci/` directory and all rendered manifests.

#### `make fetch`
Fetch upstream manifests for all components.

```bash
make fetch
```

Downloads Helm charts, CRDs, and manifests from upstream sources (cert-manager, Flux, etc.). Each component runs its `prereqs` check first (via `fetch: prereqs`), so unreachable upstreams fail fast with a clear diagnostic instead of cascading into mid-fetch errors.

#### `make render`
Render manifests to `oci/` for all components.

```bash
make render
```

Processes Kustomize overlays and generates final manifests in `oci/platform/` and `oci/test/`.

#### `make build`
Build and validate everything.

```bash
make build
```

Runs: `clean` → `fetch` → `render` → `validate`

This is the complete build pipeline. Use this for clean builds or before publishing.

### Test Targets (Needs Cluster)

These targets interact with a k3d cluster:

#### `make cluster`
Create k3d cluster with registry.

```bash
make cluster
```

Creates cluster named `cur8s-dev` by default (override with `CLUSTER_NAME=<name>`).

#### `make init`
Install Flux controllers.

```bash
make init
```

Installs Flux from `oci/platform/flux/deploy/flux.yaml`. Cluster must exist first.

#### `make push`
Build and push to local registry.

```bash
make push
```

Runs `make build` then pushes artifacts to the cluster's local registry. Flux auto-reconciles.

#### `make sync`
Apply GitOps configuration.

```bash
make sync
```

Applies OCIRepository and Kustomization resources. This tells Flux what to reconcile.

#### `make verify`
Verify cluster installation.

```bash
make verify
```

Runs 4-layer validation:
1. Flux Controllers
2. Platform Components
3. Cluster Configuration
4. Test Applications

Exit code `0` = success, `1` = failure.

#### `make e2e`
Run automated end-to-end tests.

```bash
make e2e
```

Full validation workflow using an ephemeral cluster:

1. Creates fresh k3d cluster (`e2e-test`)
2. Builds and pushes artifacts
3. Installs Flux and applies GitOps configuration
4. Waits for complete reconciliation (10min timeout)
5. Runs 4-layer verification
6. **On success:** Deletes cluster automatically
7. **On failure:** Preserves cluster with debug commands

**Duration:** ~4-5 minutes

**Use this before publishing** to ensure everything works from scratch.

### Publish Targets (Needs GitHub Access)

#### `make release`
Run E2E tests and publish to ghcr.io.

```bash
# Update version first
vim src/platform/VERSION

# Run E2E and publish
make release
```

Publishes:
- `oci://ghcr.io/cur8s/cur8s:<version>`
- `oci://ghcr.io/cur8s/cur8s-test:<version>`

## Cluster Management Commands

The `scripts/cluster` utility manages k3d cluster lifecycle. Available commands:

### `cluster create <name>`
Create a new cluster with local registry.

```bash
scripts/cluster create cur8s-dev
```

**State:** `missing` → `empty`

### `cluster delete <name>`
Delete a cluster and its registry.

```bash
scripts/cluster delete cur8s-dev
```

### `cluster reset <name>`
Destroy and recreate cluster (fresh start).

```bash
scripts/cluster reset cur8s-dev
```

**State:** `*` → `empty`

Useful when you need a completely clean slate.

### `cluster status <name>`
Show cluster information.

```bash
scripts/cluster status cur8s-dev
```

Shows: cluster state, LoadBalancer URL, registry URL, API port, kubectl context.

### `cluster env <name>`
Print environment variables for the cluster.

```bash
eval "$(scripts/cluster env cur8s-dev)"
echo $CLUSTER_REG_PORT  # e.g., 52023
echo $CLUSTER_LB_PORT   # e.g., 55008
```

Useful for scripts that need dynamic port numbers.

### `cluster exists <name>`
Check if cluster exists (for scripts).

```bash
scripts/cluster exists cur8s-dev && echo "yes" || echo "no"
```

Exit code `0` = exists, `1` = does not exist.

### `cluster purge`
Delete ALL k3d clusters (with confirmation).

```bash
scripts/cluster purge
```

Useful for cleaning up after multiple test runs.

## Cluster States

Cur8s uses explicit state management for clarity:

| State | Description |
|-------|-------------|
| `missing` | No cluster exists |
| `empty` | Cluster exists with registry, no Flux |
| `bootstrapped` | Flux controllers installed, not managing resources |
| `managed` | Flux actively managing platform and applications |

## Adding or Modifying Components

### Adding a New Platform Component

1. Create component directory:
   ```bash
   mkdir -p src/platform/my-component
   ```

2. Add Makefile with standard targets:
   - `fetch` - Download upstream manifests
   - `render` - Process with Kustomize
   - `clean` - Remove generated files

3. Add to platform aggregator:
   ```bash
   vim src/platform/Makefile
   # Add to fetch-all, render-all targets
   ```

4. Build and test:
   ```bash
   make push
   make verify
   ```

### Modifying an Existing Component

1. Edit component configuration:
   ```bash
   vim src/platform/cert-manager/kustomization.yaml
   ```

2. Rebuild and push:
   ```bash
   make push
   ```

3. Watch reconciliation:
   ```bash
   watch flux get all -A
   ```

4. Verify changes:
   ```bash
   make verify
   ```

## Watching Progress

### Monitor Flux Reconciliation

```bash
# One-time check
flux get all -A

# Continuous monitoring
watch flux get all -A

# Watch specific namespace
watch flux -n flux-system get all

# Stream logs
flux logs -A --follow
```

### Monitor Kubernetes Resources

```bash
# All resources in all namespaces
kubectl get all -A

# Specific resource type
kubectl get gateways -A
kubectl get externalsecrets -A
kubectl get clusters -A  # PostgreSQL clusters

# Watch pod status
watch kubectl get pods -A
```

## Manual Testing

### Test Envoy Gateway

```bash
# Dev cluster uses well-known ports:
# - Apps gateway (port 80): localhost:19080
# - System gateway (port 8080): localhost:18080

# Quick test with dev defaults:
curl http://hello.apps.cur8s.localhost:19080/

# Or get dynamic port (for custom cluster configurations):
CLUSTER_APPS_PORT=$(scripts/cluster env cur8s-dev | grep CLUSTER_APPS_PORT | cut -d= -f2 | tr -d '"')
curl http://hello.apps.cur8s.localhost:${CLUSTER_APPS_PORT}/

# Check Gateway status
kubectl get gateway cur8s-apps-gateway -n envoy-gateway
kubectl get httproute hello-backend -n default
```

Expected: Echo response from hello-backend service.

### Test External Secrets

```bash
# Check ExternalSecret status
kubectl get externalsecret synced-db-credentials -n default

# Verify secret was synced
kubectl get secret synced-db-credentials -n default

# Compare source and synced secrets (should match)
kubectl get secret source-db-credentials -n default -o jsonpath='{.data.password}' | base64 -d
kubectl get secret synced-db-credentials -n default -o jsonpath='{.data.password}' | base64 -d
```

Expected: Both passwords match.

### Test CloudNativePG

```bash
# Check PostgreSQL cluster status
kubectl get cluster pg-test -n default

# Check pods
kubectl get pods -l postgresql=pg-test -n default

# Check test job logs
kubectl logs job/pg-test-job -n default
```

Expected: Job logs show successful connection and query.

## When You Get Stuck

### Reset to Clean State

```bash
# Destroy and recreate cluster (keeps Makefile state)
scripts/cluster reset cur8s-dev

# Then re-bootstrap
make init
make push
make sync
```

### Complete Fresh Start

```bash
# Delete everything
scripts/cluster delete cur8s-dev
make clean

# Start from scratch
make build
make cluster
make init
make push
make sync
make verify
```

## Publishing Workflow

Before publishing a new release:

1. **Update version:**
   ```bash
   vim src/platform/VERSION
   ```

2. **Run E2E validation:**
   ```bash
   make e2e
   ```

3. **Publish to ghcr.io:**
   ```bash
   make release
   ```

This publishes synchronized artifacts for both platform and test.

## Common Workflows Summary

| Workflow | Command | Time | Use Case |
|----------|---------|------|----------|
| **Preflight check** | `make prereqs` | ~5s | Confirm every upstream is reachable before a longer build |
| **Fast iteration** | `make push` | ~30s | Edit → push → Flux reconciles |
| **Clean build** | `make build` | ~1min | Validate everything renders |
| **Fresh cluster** | `scripts/cluster reset` | ~1min | When stuck or testing from scratch |
| **E2E validation** | `make e2e` | ~4.5min | Pre-publish validation |
| **Publish release** | `make release` | ~5min | E2E + publish to ghcr.io |
