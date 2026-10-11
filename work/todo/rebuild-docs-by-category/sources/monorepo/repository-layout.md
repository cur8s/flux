# Repository Layout

Understanding the structure of the Cur8s repository.

## Top-Level Directories

```
cur8s/
├── src/            # Source components and test applications
├── oci/            # Generated artifacts (from src/)
├── scripts/        # Cluster management and build utilities
├── docs/           # Documentation
├── Makefile        # Root orchestration
├── common.mk       # Shared Makefile variables
└── VERSION         # Platform version (unused currently)
```

## Source Components (`src/`)

### Platform Components (`src/platform/`)

The curated Kubernetes platform components:

```
src/platform/
├── Makefile                    # Platform aggregator
├── VERSION                     # Platform version
├── flux/                       # GitOps engine
├── cert-manager/               # TLS certificate management
├── external-secrets/           # Secret synchronization
├── envoy-gateway/              # Ingress with Gateway API
├── cloudnative-pg/             # PostgreSQL operator
├── grafana/                    # Metrics visualization
├── docs/                       # README generation scripts
└── kustomization.yaml          # Aggregates all components
```

**Each component has:**
- `Makefile` - Fetch, render, clean targets
- `kustomization.yaml` - Kustomize overlay
- `upstream/` - Original manifests (gitignored)
- `notes.md` - Component documentation

### Test Configuration (`src/test/`)

Test applications and cluster configuration:

```
src/test/
├── Makefile                    # Test build orchestration
├── repos-ghcr.yaml             # Production OCIRepository (ghcr.io)
├── repos-dev.yaml              # Dev OCIRepository (local registry)
├── kustomizations.yaml         # Flux Kustomizations (env-agnostic)
├── kustomization.yaml          # Aggregates cluster-config + apps
├── cluster-config/             # Cluster-wide configuration
│   ├── kustomization.yaml
│   ├── gateway-class.yaml      # GatewayClass for Envoy
│   ├── gateway.yaml            # Shared Gateway
│   └── cluster-secret-store.yaml
└── apps/                       # Test applications
    ├── kustomization.yaml
    ├── hello-gateway/          # Tests Envoy Gateway
    ├── hello-secrets/          # Tests External Secrets
    └── hello-postgres/         # Tests CloudNativePG
```

**Key files:**

- **repos-ghcr.yaml** - Points to published OCI artifacts on GitHub Container Registry
  ```yaml
  url: oci://ghcr.io/cur8s/cur8s
  ref:
    tag: "1.0.0"
  ```

- **repos-dev.yaml** - Points to local k3d registry (development)
  ```yaml
  url: oci://cur8s-dev-registry:5000/cur8s
  ref:
    tag: "dev"
  insecure: true
  ```

- **kustomizations.yaml** - Defines Flux Kustomizations (works with any OCIRepository)
  ```yaml
  # platform → cluster-config → apps dependency chain
  ```

## Generated Artifacts (`oci/`)

Build output from `make render` or `make build`:

```
oci/
├── platform/                   # Platform artifacts
│   ├── flux/
│   │   ├── deploy/
│   │   │   └── flux.yaml       # Used by 'make init'
│   │   └── sync.yaml
│   ├── cert-manager/
│   │   ├── crds/
│   │   ├── deploy/
│   │   ├── finalize/
│   │   └── sync.yaml
│   ├── external-secrets/
│   │   ├── crds/
│   │   ├── deploy/
│   │   └── sync.yaml
│   ├── envoy-gateway/
│   │   ├── crds/
│   │   ├── bootstrap/
│   │   ├── deploy/
│   │   └── sync.yaml
│   ├── cloudnative-pg/
│   │   ├── deploy/
│   │   └── sync.yaml
│   ├── grafana/
│   │   ├── deploy/
│   │   ├── finalize/
│   │   └── sync.yaml
│   ├── kustomization.yaml      # Aggregates all components
│   ├── README.md               # Auto-generated
│   └── BOM.yaml                # Bill of Materials
└── test/                       # Test artifacts
    ├── cluster-config/
    ├── apps/
    └── kustomization.yaml
```

**This directory is tracked in git, not gitignored.** Cur8s vendors the rendered output deliberately: committing `oci/` makes every version bump or source change visible as a `git diff` against the manifests that will actually be deployed. That diff is the primary review surface for security audit (what bytes did the new chart introduce?) and reasoning about rendering side-effects (what did this kustomize tweak change downstream?). The same approach applies to per-component `artifacts/` directories under `src/platform/` — see below.

## Scripts (`scripts/`)

### Cluster Management

```
scripts/
├── cluster                     # Main cluster lifecycle utility
├── k3d-config.yaml            # k3d cluster template
└── lib/                       # Reusable utilities
    ├── display.sh             # Banner, colors, formatting
    ├── timing.sh              # Performance tracking
    ├── kube-query.sh          # Kubernetes query functions
    ├── get-artifact.sh        # Component artifact fetching
    ├── check-access.sh        # Upstream access preflight (github/helm-http/helm-oci/container/http)
    ├── check-version.sh       # Upstream version drift reporting
    └── utils.sh               # Miscellaneous utilities
```

**cluster commands:**
- `create` - Create k3d cluster with registry
- `delete` - Delete cluster and registry
- `reset` - Destroy and recreate
- `status` - Show cluster info
- `env` - Print environment variables
- `exists` - Check if cluster exists
- `purge` - Delete all k3d clusters

### Build and Test Scripts

```
scripts/make/
├── e2e                        # End-to-end test orchestration
├── init                       # Install Flux controllers
├── push                       # Push OCI artifacts to registry
├── sync                       # Apply GitOps configuration
└── verify                     # 4-layer verification
```

These are called by root Makefile targets.

## Makefile Hierarchy

```
Makefile (root)                 # Orchestrates everything
├── common.mk                   # Shared variables
├── src/platform/Makefile       # Platform aggregator
│   ├── flux/Makefile
│   ├── cert-manager/Makefile
│   ├── external-secrets/Makefile
│   ├── envoy-gateway/Makefile
│   ├── cloudnative-pg/Makefile
│   └── grafana/Makefile
└── src/test/Makefile           # Test build
```

**Variable flow:**
- `common.mk` defines: `PLATFORM_VERSION`, `REGISTRY`, `CLUSTER_NAME`
- Root Makefile exports to sub-makes
- Component Makefiles use these variables

## Documentation (`docs/`)

```
docs/
├── getting-started.md          # Prerequisites and initial setup
├── development.md              # Daily workflows and iteration
├── repository-layout.md        # This file
├── troubleshooting.md          # Common issues and solutions
└── adr/                        # Architecture Decision Records (future)
```

Single source of truth - each topic lives in ONE file.

## Configuration Files

### Root Level

- **Makefile** - Main orchestration
- **common.mk** - Shared variables
- **VERSION** - Platform version (currently unused)
- **README.md** - Navigation and overview

### GitOps Configuration

Test configurations live in `src/test/`:

- **repos-ghcr.yaml** - Production OCIRepository
- **repos-dev.yaml** - Development OCIRepository
- **kustomizations.yaml** - Flux Kustomizations (environment-agnostic)

These are applied with `make sync` or `kubectl apply`.

## How Components Are Organized

Each platform component follows this pattern:

```
src/platform/{component}/
├── Makefile
├── config/
│   ├── VERSION
│   ├── sync.yaml
│   ├── notes.md
│   ├── helm/              # Optional: Helm values files
│   └── overlays/
│       ├── crds/          # Phase 1 (if needed): CRDs
│       ├── bootstrap/     # Phase 2 (rare): Prerequisites like certificates
│       ├── deploy/        # Phase 3 (always): Controllers
│       └── finalize/      # Phase 4 (if needed): Instances
└── artifacts/             # tracked (vendored)
    ├── FETCH.lock          # SHA256 digests of every fetched source
    ├── fetched/            # raw upstream (helm charts, release YAML, etc.)
    ├── work/               # intermediate processing
    └── rendered/           # final manifests (copied to oci/ during build)
```

**Standard Makefile targets:**
- `fetch` - Download upstream manifests to `upstream/`
- `render` - Process with Kustomize, output to `oci/platform/{component}/`
- `clean` - Remove `upstream/` and generated files

**Kustomize overlay structure:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - upstream/manifest.yaml

# Optional transformations:
# - patches
# - configMapGenerator
# - namespace changes
```

## Build Flow

```
make build
  ├── make clean                # Remove oci/
  ├── make fetch                # Download to upstream/
  ├── make render               # Process to oci/
  └── validate                  # kubeconform validation
```

**Output:**
- Rendered manifests in `oci/platform/` and `oci/test/`
- Auto-generated `oci/platform/README.md` from component `notes.md` files
- Bill of Materials in `oci/platform/BOM.md`

## Development Workflow Paths

### Local Development
```
src/platform/           →  oci/platform/  →  k3d registry  →  Flux reconciles
src/test/               →  oci/test/      →  k3d registry  →  Flux reconciles
```

### Publishing
```
src/platform/           →  oci/platform/  →  ghcr.io/cur8s/cur8s
src/test/               →  oci/test/      →  ghcr.io/cur8s/cur8s-test
```

## Dynamic vs Static Configuration

**Dynamic (per cluster):**
- Registry ports (random, from k3d)
- LoadBalancer ports (can be random or fixed)
- Retrieved via `scripts/cluster env <name>`

**Static:**
- Internal registry DNS: `{cluster-name}-registry:5000` (always)
- Cluster context: `k3d-{cluster-name}` (always)
- Dev cluster gateway ports (by convention):
  - Apps gateway (port 80): `localhost:19080`
  - System gateway (port 8080): `localhost:18080`
  - Can be customized via: `scripts/cluster create <name> [apps_port] [system_port]`

This is why `repos-dev.yaml` uses `cur8s-dev-registry:5000` (internal DNS) while `make push` uses `localhost:$CLUSTER_REG_PORT` (external access).

## See Also

- [Getting Started](getting-started.md) - How to build and run
- [Development Guide](development.md) - Iteration workflows
- [Troubleshooting](troubleshooting.md) - Common issues
