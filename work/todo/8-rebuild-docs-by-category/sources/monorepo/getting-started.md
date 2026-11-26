# Getting Started

Get up and running with Cur8s in your local development environment.

## Prerequisites

Before you begin, ensure you have these tools installed:

- **Docker** - For running k3d clusters
- **kubectl** - Kubernetes CLI
- **flux** - Flux CLI for GitOps
- **k3d** - Lightweight Kubernetes in Docker
- **kustomize** - Kubernetes manifest customization
- **kbld** - Image building and resolution
- **kubeconform** - Kubernetes manifest validation
- **helm** - Package manager (used by some components)
- **Git** - Version control

## First Time Setup

### 1. Build the Platform

Fetch upstream manifests and render them to the `oci/` directory:

```bash
make build
```

This runs: `clean` → `fetch` → `render` → `validate`

**Tip:** if you suspect network or credential issues, run `make prereqs` first (~5s). It probes every upstream the build will pull from and prints a clear diagnostic with remediation hints (stale Docker creds, sandbox MITM cert, GitHub rate limit, etc.) before any fetch work begins. See [Development Guide → make prereqs](development.md#make-prereqs) for details.

**What it does:**
- Cleans any previous builds
- Fetches upstream manifests (Flux, cert-manager, etc.)
- Renders all components to `oci/platform/` and `oci/test/`
- Validates manifests with kubeconform
- Generates BOM and documentation

### 2. Create a Cluster

Create a k3d cluster with a local OCI registry:

```bash
make cluster
```

**What it does:**
- Creates k3d cluster named `cur8s-dev` (configurable via `CLUSTER_NAME`)
- Creates local OCI registry with random port
- Waits for cluster to be ready
- Validates registry accessibility

**Cluster state:** `missing` → `empty`

### 3. Install Flux Controllers

Install Flux into the cluster:

```bash
make init
```

**What it does:**
- Installs Flux from `oci/platform/flux/deploy/flux.yaml`
- Waits for all Flux deployments to be ready
- Does NOT apply any Flux custom resources yet

**Cluster state:** `empty` → `bootstrapped`

### 4. Push Artifacts to Registry

Build and push platform artifacts to your local registry:

```bash
make push
```

**What it does:**
- Builds platform (if needed)
- Pushes `oci://localhost:<port>/cur8s:dev`
- Pushes `oci://localhost:<port>/cur8s-test:dev`

### 5. Apply GitOps Configuration

Tell Flux about the artifacts:

```bash
make sync
```

**What it does:**
- Applies OCIRepository resources (tells Flux where to pull artifacts)
- Applies Kustomization resources (tells Flux what to deploy)
- Flux begins reconciling the platform automatically

**Cluster state:** `bootstrapped` → `managed`

### 6. Verify Installation

Wait for reconciliation to complete, then verify:

```bash
make verify
```

**What it validates:**
1. Flux Controllers (source-controller, kustomize-controller, etc.)
2. Platform Components (cert-manager, external-secrets, envoy-gateway, cloudnative-pg)
3. Cluster Configuration (GatewayClass, Gateway, ClusterSecretStore)
4. Test Applications (hello-gateway, hello-secrets, hello-postgres)

**Exit codes:**
- `0` - All checks passed
- `1` - One or more checks failed

### 7. Access Applications

The dev cluster uses well-known ports for easy access:

**Apps Gateway** (port 80 → 19080):
```bash
# Test hello-backend application
curl http://hello.apps.cur8s.localhost:19080/

# Open in browser
open http://hello.apps.cur8s.localhost:19080/
```

**System Gateway** (port 8080 → 18080):
```bash
# Access Grafana dashboard
open http://grafana.sys.cur8s.localhost:18080/

# Default credentials: admin / admin (change on first login)
```

**RFC 6761 .localhost domain:**
All `*.localhost` domains automatically resolve to `127.0.0.1` on macOS, Windows, and Linux - no `/etc/hosts` configuration needed!

## What's Running?

After successful setup, you have:

- **Flux** managing GitOps reconciliation
- **cert-manager** for TLS certificate management
- **external-secrets** syncing secrets from Kubernetes Secret Store
- **envoy-gateway** providing ingress with Gateway API
- **cloudnative-pg** managing PostgreSQL clusters
- **Test applications** validating the platform works

## Next Steps

Now that your environment is set up:

1. Read the [Development Guide](development.md) to learn the iteration workflow
2. Read the [Repository Layout](repository-layout.md) to understand the codebase
3. Keep [Troubleshooting](troubleshooting.md) handy when issues arise

## Quick Reference

```bash
# Complete setup (all steps above)
make build cluster init push sync verify

# Check what's running
flux get all -A

# Watch reconciliation
watch flux get all -A

# Delete cluster when done
scripts/cluster delete cur8s-dev
```
