# Adding Platform Components to Cur8s

This guide provides a comprehensive checklist for adding new components to the Cur8s platform. Use this as a prompt template when working with AI agents to add components similar to Prometheus Operator.

## Overview

The Cur8s platform organizes components with standardized structure, build processes, verification, and health monitoring. This guide captures all patterns, conventions, and integration points discovered when adding Prometheus Operator.

---

## Phase 1: Research & Planning

### 1.1 Investigate Platform Structure

**Goal:** Understand existing patterns before creating new components.

**Tasks:**
1. **Review existing components:**
   - Location: `src/platform/`
   - All components are at the root level: `flux/`, `cert-manager/`, `external-secrets/`, `envoy-gateway/`, `cloudnative-pg/`, `grafana/`
   - Each component is self-contained with config/, artifacts/, and Makefile

2. **Study component patterns:**
   - Pick 2-3 similar components (preferably with same complexity)
   - For operators: study `cert-manager/` and `external-secrets/`
   - Examine: directory structure, Makefile targets, overlay patterns, RBAC

3. **Understand deployment phases:**
   - **1-phase** (simple): `cloudnative-pg/` - deploy only
   - **2-phase** (common): `external-secrets/` - crds → deploy
   - **3-phase** (complex): `cert-manager/` - crds → deploy → finalize
   - **3-phase with bootstrap**: `envoy-gateway/` - crds → bootstrap (certs) → deploy
   - **Note:** The full 4-phase model (crds → bootstrap → deploy → finalize) is supported but not currently used
   - Choose appropriate pattern based on your component's needs

4. **Review build system:**
   - Platform Makefile: `src/platform/Makefile`
   - Common variables: `common.mk`
   - Artifact fetching: `scripts/lib/get-artifact.sh`
   - Understand: fetch → render → build → push workflow

**Key Files to Examine:**
```
src/platform/Makefile                    # Platform-level orchestration
common.mk                                 # Shared variables (KUBE_VERSION, etc.)
scripts/lib/get-artifact.sh              # Artifact fetching patterns
src/platform/cert-manager/   # Reference for 3-phase pattern
```

---

## Phase 2: Component Implementation

### 2.1 Directory Structure

**Create the following structure:**

```
src/platform/{component}/
├── Makefile                    # Build targets: fetch, render, clean
├── config/
│   ├── VERSION                 # Component version (e.g., v0.86.2)
│   ├── notes.md                # Documentation for this component
│   ├── sync.yaml               # Flux Kustomization resources
│   ├── helm/                   # (Optional) Helm values overrides
│   │   └── {component}-values.yaml
│   └── overlays/               # Kustomize overlays
│       ├── crds/               # Phase 1: CRDs (if applicable)
│       │   └── kustomization.yaml
│       ├── bootstrap/          # Phase 2: Prerequisites (rare - only if needed)
│       │   └── kustomization.yaml
│       ├── deploy/             # Phase 3: Controllers/Operators (required)
│       │   ├── kustomization.yaml
│       │   └── namespace.yaml
│       └── finalize/           # Phase 4: Instances/Resources (if applicable)
│           ├── kustomization.yaml
│           └── {resource}.yaml
└── artifacts/                  # tracked (vendored) - committed alongside source
    ├── FETCH.lock              # Audit trail with SHA256 digests
    ├── fetched/                # Downloaded artifacts (raw upstream)
    ├── work/                   # Intermediate processing
    └── rendered/               # Final manifests (copied to OCI)
        ├── crds/
        ├── bootstrap/
        ├── deploy/
        └── finalize/
```

**Checklist:**
- [ ] Create component directory with proper name (lowercase-with-hyphens)
- [ ] Create config/overlays structure for each phase needed
- [ ] After `make fetch`, commit the new `artifacts/` contents — Cur8s vendors fetched + rendered output so `git diff` shows the full impact of version bumps

### 2.2 Required Files

#### VERSION File
```bash
# src/platform/{component}/config/VERSION
v0.86.2
```
- Single line with version number
- Used by Makefile and artifact fetching

#### Makefile

**Pattern for operators from GitHub releases:**
```makefile
# Compute repository root
REPO_ROOT := $(shell git rev-parse --show-toplevel)
include $(REPO_ROOT)/common.mk

# Component-specific variables
export PATH := $(REPO_ROOT)/scripts/lib:$(REPO_ROOT)/scripts/make:$(PATH)
VERSION := $(shell cat config/VERSION)
COMPONENT_NAME := $(shell basename $(shell pwd))

.PHONY: prereqs fetch render clean check-update

prereqs:
	@check-access.sh github "org/repo" "$(VERSION)"

fetch: prereqs
	@echo "🔽 Fetching sources..."
	@get-artifact.sh init-lock "$(VERSION)" "$(COMPONENT_NAME)"
	@get-artifact.sh github "org/repo" "$(VERSION)" "file-pattern.yaml" "artifacts/fetched/manifests"

render:
	@echo "🔨 Rendering manifests..."
	@mkdir -p artifacts/rendered/crds artifacts/rendered/deploy artifacts/rendered/finalize artifacts/work
	# CRDs: Copy CustomResourceDefinitions
	@cp artifacts/fetched/manifests/crds.yaml artifacts/rendered/crds/crds.yaml
	# Deploy: Process with kustomize (strips comments)
	@kustomize build --load-restrictor=LoadRestrictionsNone config/overlays/deploy > artifacts/rendered/deploy/deploy.yaml
	# Finalize: Copy files directly to PRESERVE COMMENTS
	@cp config/overlays/finalize/kustomization.yaml artifacts/rendered/finalize/kustomization.yaml
	@cp config/overlays/finalize/resource.yaml artifacts/rendered/finalize/resource.yaml
	@echo "   ✅ CRDs → artifacts/rendered/crds/"
	@echo "   ✅ Deploy → artifacts/rendered/deploy/"
	@echo "   ✅ Finalize → artifacts/rendered/finalize/"

clean:
	@echo "🧹 Cleaning artifacts..."
	@rm -rf artifacts
	@mkdir -p artifacts/{fetched,work,rendered}

check-update:
	@check-version.sh github "org/repo" "$(VERSION)" "$(COMPONENT_NAME)"
```

**Artifact Fetching Patterns:**
- `get-artifact.sh github "org/repo" "version" "pattern" "dest"` - GitHub releases
- `get-artifact.sh helm-oci "oci://registry/chart" "version" "dest"` - OCI Helm charts
- `get-artifact.sh helm-http "chart-name" "repo-url" "version" "dest"` - HTTP Helm repos
- `get-artifact.sh http "url" "dest-file"` - Direct HTTP downloads

**Access Probe Patterns (used in `prereqs`):**
- `check-access.sh github "org/repo" "$(VERSION)"` - verifies the GitHub release tag exists
- `check-access.sh helm-http "name" "https://repo.example.com"` - verifies the Helm HTTP repo's `index.yaml` is fetchable
- `check-access.sh helm-oci "oci://registry/chart" "$(VERSION)"` - verifies the Helm OCI chart manifest is reachable + auth works
- `check-access.sh container "registry" "image" "$(VERSION)"` - verifies the container image manifest is reachable + auth works
- `check-access.sh http "https://example.com/file.yaml"` - verifies a direct URL is reachable

Add one `check-access.sh` line per source your `fetch` body downloads from. The `prereqs` target is a prerequisite of `fetch` (`fetch: prereqs`), so the probes always run before any download is attempted — failures surface up front with a remediation hint instead of cascading into mid-fetch errors.

**CRITICAL: Comment Preservation**
- Use `cp` for files with documentation comments (finalize phase)
- Use `kustomize build` only when merging/transforming is needed
- See cert-manager pattern: preserves all comments in platform-issuer.yaml

#### sync.yaml

**3-Phase Pattern (CRDs → Deploy → Finalize):**
```yaml
# {component}-crds
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: {component}-crds
  namespace: flux-system
spec:
  interval: 10m
  path: ./{component}/crds
  prune: true
  wait: true
  sourceRef:
    kind: OCIRepository
    name: cur8s-platform
---
# {component}-deploy
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: {component}-deploy
  namespace: flux-system
spec:
  interval: 10m
  dependsOn:
    - name: {component}-crds
  path: ./{component}/deploy
  prune: true
  wait: true
  sourceRef:
    kind: OCIRepository
    name: cur8s-platform
---
# {component}-finalize
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: {component}-finalize
  namespace: flux-system
spec:
  interval: 10m
  dependsOn:
    - name: {component}-deploy
  path: ./{component}/finalize
  prune: true
  wait: true
  healthChecks:
    - apiVersion: {custom-resource-api}
      kind: {CustomResourceKind}
      name: {instance-name}
      namespace: {namespace}
  sourceRef:
    kind: OCIRepository
    name: cur8s-platform
```

**Naming Convention:** `{component}-{phase}`

**Health Checks:**
- Add `healthChecks` to finalize phase for custom resources
- Flux will wait for these resources to be healthy before marking kustomization as ready
- Example: Prometheus CR, Alertmanager CR

#### notes.md

```markdown
**Purpose:** Brief description of what this component does

**Configuration:**
- Key configuration decisions
- Dependencies on other components
- Deployment phases explained

**CRDs Provided:** (if applicable)
- List of CRDs this component installs

**Resources Deployed:**
- Controllers, operators, instances

**Platform Integration:**
- How other components can use this
- Next steps or future enhancements

**Resources:**
- [Documentation](https://...)
- [GitHub](https://...)
```

### 2.3 Overlay Configuration

#### CRDs Overlay

**Purpose:** Install Custom Resource Definitions before the operator

```yaml
# config/overlays/crds/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../artifacts/rendered/crds/crds.yaml
```

**Pattern:**
- Reference the rendered CRDs from artifacts/
- Keep it simple - just reference the file
- CRDs should be in a single file

#### Deploy Overlay (Operator/Controller)

**Purpose:** Deploy the main controller/operator

```yaml
# config/overlays/deploy/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: {component-namespace}

resources:
  - namespace.yaml
  - ../../../artifacts/work/{processed-manifests}.yaml  # Or fetched/manifests/
```

**For operators fetching from GitHub:**
- Filter out CRDs if bundle includes them
- Use `yq eval 'select(.kind != "CustomResourceDefinition")' bundle.yaml > bundle-without-crds.yaml`
- Set namespace via kustomize `namespace:` field

**namespace.yaml:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: {component-namespace}
```

#### Finalize Overlay (Instances/Resources)

**Purpose:** Deploy instances of custom resources or post-deployment resources

**CRITICAL: Preserve Comments!**

Create resource files with **extensive comments** explaining:
- Why each resource exists
- Why specific permissions/configurations are needed
- Design decisions and trade-offs
- Future considerations

**Example Structure:**
```yaml
# config/overlays/finalize/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: {namespace}

resources:
  - serviceaccount.yaml  # Or consolidated resource files
  - clusterrole.yaml
  - clusterrolebinding.yaml
  - instance.yaml
```

**For Operators with CRDs:**

Create **consolidated, well-documented files**:

```yaml
# prometheus.yaml - All Prometheus resources with RBAC
# ==============================================================================
# Prometheus Instance with RBAC
# ==============================================================================
# This file contains all resources needed...
#
# Why RBAC is required:
# - Explain cluster-wide discovery needs
# - Explain API permissions
# - Explain why ClusterRole vs Role
#
# Resource order matters:
# 1. ServiceAccount - identity
# 2. ClusterRole - permissions
# 3. ClusterRoleBinding - grants
# 4. Custom Resource - instance
# ==============================================================================

# ------------------------------------------------------------------------------
# ServiceAccount
# ------------------------------------------------------------------------------
# Purpose: ...
# Why needed: ...
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {name}
  namespace: {namespace}
---
# ... more resources with detailed comments
```

**Makefile render target:**
```makefile
# Finalize: Copy files directly to PRESERVE COMMENTS
@cp config/overlays/finalize/kustomization.yaml artifacts/rendered/finalize/kustomization.yaml
@cp config/overlays/finalize/prometheus.yaml artifacts/rendered/finalize/prometheus.yaml
```

**DON'T:**
- Don't use `kustomize build` for finalize if you have documentation comments
- Don't create separate files for each RBAC resource (consolidate with comments)

**DO:**
- Use direct `cp` to preserve comments
- Consolidate related resources into well-documented multi-resource YAML files
- Include extensive header blocks and inline comments
- Follow cert-manager's finalize pattern (preserves all comments)

---

## Phase 3: Platform Integration

### 3.1 Update Platform Files

#### Platform Kustomization

**Update:** `src/platform/kustomization.yaml`

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - {component}/sync.yaml
  # Add new component here
```

#### Root Kustomization

**Update:** `src/platform/kustomization.yaml`

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - flux/sync.yaml
  - cert-manager/sync.yaml
  - external-secrets/sync.yaml
  - envoy-gateway/sync.yaml
  - cloudnative-pg/sync.yaml
  - grafana/sync.yaml
  - {new-component}/sync.yaml  # Add your new component here
```

**Checklist:**
- [ ] Platform kustomization.yaml includes your new component sync.yaml

### 3.2 Verification Functions

**Update:** `scripts/lib/kube-query.sh`

**For Custom Resources:**

Add health check functions following this pattern:

```bash
# Check if CustomResource is ready
# Sets KUBE_QUERY_MSG to status or "not found"
# Returns: 0 if ready, 1 otherwise
is_{resource}_ready() {
  local name=$1
  local namespace=$2

  if kubectl_cmd -n "$namespace" get {resource} "$name" &>/dev/null; then
    local available=$(kubectl_cmd -n "$namespace" get {resource} "$name" -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
    local reconciled=$(kubectl_cmd -n "$namespace" get {resource} "$name" -o jsonpath='{.status.conditions[?(@.type=="Reconciled")].status}')
    local available_replicas=$(kubectl_cmd -n "$namespace" get {resource} "$name" -o jsonpath='{.status.availableReplicas}')
    local desired_replicas=$(kubectl_cmd -n "$namespace" get {resource} "$name" -o jsonpath='{.spec.replicas}')

    KUBE_QUERY_MSG="${available_replicas:-0}/$desired_replicas replicas (Available: ${available:-Unknown}, Reconciled: ${reconciled:-Unknown})"

    [ "$available" = "True" ] && [ "${available_replicas:-0}" -gt 0 ]
  else
    KUBE_QUERY_MSG="not found"
    return 1
  fi
}
```

**Function Naming Convention:**
- `is_{resource}_ready()` - Checks if resource is healthy
- `does_{resource}_exist()` - Checks if resource exists (less common)

**Pattern:**
- Use `kubectl_cmd` helper (handles context)
- Set `KUBE_QUERY_MSG` global variable
- Return 0 for ready, 1 for not ready
- Check both conditions and replica status

### 3.3 Verification Script

**Update:** `scripts/make/verify`

Add section after similar components:

```bash
# ============================================================
# {component}
# ============================================================

# Check all Flux Kustomizations
for phase in crds deploy finalize; do
  check_kustomization "{component}-$phase" flux-system
done

# Check deployments
check_deployment {operator-deployment} {namespace}

# Check custom resources exist
check_namespaced_resource {cr-name} {namespace} {cr-kind}

# Check custom resources are healthy
if is_{resource}_ready {name} {namespace}; then
  print_pass "{Resource} {namespace}/{name} is Ready: $KUBE_QUERY_MSG"
else
  print_fail "{Resource} {namespace}/{name} not Ready: $KUBE_QUERY_MSG"
  FAILED_COUNT=$((FAILED_COUNT + 1))
fi
```

**Helper Functions Available:**
- `check_kustomization` - Flux Kustomization readiness
- `check_deployment` - Deployment readiness
- `check_namespaced_resource` - Resource existence
- `check_cluster_resource` - Cluster-scoped resource existence
- `print_pass`, `print_fail`, `print_warn` - Output formatting

### 3.4 Capacity Tracking

**Update:** `scripts/make/capacity`

Add namespace to PLATFORM_NAMESPACES array (around line 60):

```bash
PLATFORM_NAMESPACES=(
  "flux-system:Flux Controllers:"
  "cert-manager:cert-manager:"
  "{namespace}:{Description}:"  # Add new component
)
```

**Optional:** Add label filter for specific pods:
```bash
"{namespace}:{Description}:app.kubernetes.io/name={component}"
```

**Format:** `"namespace:description:label-filter"`
- namespace: Where component runs
- description: Human-readable name (shows in output)
- label-filter: Optional pod label selector (empty = all pods)

---

## Phase 4: Common Patterns & Best Practices

### 4.1 RBAC for Operators

**Pattern for Operators that need cluster-wide discovery:**

1. **ServiceAccount** - Identity for operator pods
   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: {operator-name}
     namespace: {namespace}
   ```

2. **ClusterRole** - Permissions for discovery
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRole
   metadata:
     name: {operator-name}
   rules:
   - apiGroups: [""]
     resources: [nodes, services, endpoints, pods]
     verbs: ["get", "list", "watch"]
   ```

3. **ClusterRoleBinding** - Grant permissions
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: {operator-name}
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: {operator-name}
   subjects:
   - kind: ServiceAccount
     name: {operator-name}
     namespace: {namespace}
   ```

**Why ClusterRole vs Role:**
- ClusterRole: When operator needs cluster-wide access (service discovery, CRDs in any namespace)
- Role: When operator only needs access within its own namespace

**ServiceAccount in Custom Resources:**
- Operators create StatefulSets/Deployments that REQUIRE ServiceAccount to exist
- If ServiceAccount missing: StatefulSet created but pods never start (replicas=0)
- Always create ServiceAccount BEFORE the CR that references it

### 4.2 Resource Configuration Best Practices

**Always specify both requests AND limits:**

```yaml
resources:
  requests:
    cpu: 200m      # Minimum guaranteed
    memory: 400Mi
  limits:
    cpu: 1000m     # Maximum allowed (allows bursting)
    memory: 2Gi
```

**Common Mistake:**
- Setting only memory limits without CPU limits
- This causes Kubernetes to assign arbitrary low CPU limits
- Result: CPU limits < CPU requests (violates QoS)

**For operators with sidecars:**
- Main container resources: Your configuration
- Sidecar resources: Operator-injected (usually 10m CPU, 50Mi memory)
- Total pod resources: Sum of all containers

### 4.3 Multi-Phase Deployment Dependencies

**Use `dependsOn` in Flux Kustomizations:**

```yaml
spec:
  dependsOn:
    - name: {component}-crds  # CRDs first
    # or
    - name: cert-manager-finalize  # When needing platform-issuer
```

**Common Dependency Patterns:**
- **Deploy depends on Bootstrap:** Wait for CRDs before deploying operator
- **Finalize depends on Deploy:** Wait for operator before creating instances
- **Cross-component:** Depend on cert-manager when needing ClusterIssuers

### 4.4 Namespace Management

**Pattern:**
- Create namespace in deploy phase
- Set `namespace:` field in kustomization.yaml (applies to all resources)
- Don't hardcode namespace in fetched artifacts (let kustomize set it)

```yaml
# deploy/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: {component-namespace}
resources:
  - namespace.yaml
  - artifacts-without-hardcoded-namespace.yaml
```

### 4.5 CRD Filtering

**When fetching bundles that include CRDs:**

Use `yq` to filter:
```makefile
@yq eval 'select(.kind != "CustomResourceDefinition")' \
    artifacts/fetched/manifests/bundle.yaml \
    > artifacts/work/bundle-without-crds.yaml
```

**Why:**
- Bundle contains both CRDs and operator resources
- CRDs go to crds phase (separate)
- Operator resources go to deploy phase
- Prevents CRD duplication

### 4.6 Health Checks

**Always add health checks for custom resources in finalize phase:**

```yaml
spec:
  healthChecks:
    - apiVersion: {api-version}
      kind: {Kind}
      name: {instance-name}
      namespace: {namespace}
```

**Benefit:**
- Flux waits for resources to be healthy
- Clear visibility in `flux get kustomizations`
- Automatic retries if instances fail

**Without health checks:**
- Flux marks kustomization as "Ready" even if pods never start
- Hidden failures (StatefulSet exists but replicas=0)

---

## Phase 5: Testing & Validation

### 5.1 Build Verification

```bash
cd src/platform
make build
```

**Expected:**
- All components fetch artifacts
- All components render manifests
- Manifests validate with kubeconform
- BOM.yaml generated with artifact checksums
- README.md generated with component table
- Output directory: `oci/platform/`

### 5.2 Component Structure Verification

```bash
tree oci/platform/{component}/
```

**Expected structure:**
```
{component}/
├── crds/
│   └── crds.yaml (or similar)
├── deploy/
│   └── deploy.yaml
├── finalize/ (if applicable)
│   ├── kustomization.yaml
│   └── {resources}.yaml (WITH comments preserved)
└── sync.yaml
```

### 5.3 Comment Preservation Check

```bash
# Check finalize files have comments
head -20 oci/platform/{component}/finalize/{resource}.yaml
```

**Expected:**
- Header comment blocks
- Inline comments explaining configuration
- NOT just raw YAML

### 5.4 Deployment Testing

```bash
# Push to registry
make push

# Watch Flux reconcile
flux get kustomizations --watch

# Check Flux status
flux get kustomizations | grep {component}

# Check pods
kubectl get pods -n {namespace}

# Check custom resources
kubectl get {cr-kind} -n {namespace}
```

### 5.5 Verification Script

```bash
make verify
```

**Expected:**
- All kustomizations ready
- All deployments ready
- All custom resources exist and healthy
- No failures in output

### 5.6 Capacity Check

```bash
make capacity
```

**Expected:**
- New namespace section appears
- Shows resource requests/limits for all containers
- Container-level breakdown with `--containers` flag

---

## Phase 6: Documentation

### 6.1 Component Documentation

Ensure `config/notes.md` is complete:
- Purpose clearly stated
- Configuration decisions explained
- Dependencies documented
- Integration guidance provided
- Links to external docs

### 6.2 Commit Message

Follow conventional commits:

```
feat(platform): add {Component} for {purpose}

Brief description of what this component does and why it's needed.

- Add {component} component with {N}-phase deployment
- Key feature 1
- Key feature 2
- Integration point 1
- Integration point 2
```

---

## Troubleshooting Patterns

### Issue: StatefulSet has 0 replicas, pods never start

**Root Cause:** Missing ServiceAccount

**Solution:**
1. Check StatefulSet spec for `serviceAccountName`
2. Verify ServiceAccount exists in same namespace
3. Create ServiceAccount BEFORE the CR that triggers StatefulSet creation
4. In finalize phase: ServiceAccount → CR (order matters)

### Issue: Flux Kustomization stuck in "Not Ready"

**Root Cause:** Missing health checks or resource not reconciling

**Solution:**
1. Check Flux logs: `flux logs`
2. Check if resources were created: `kubectl get {kind} -n {namespace}`
3. Check resource status: `kubectl describe {kind} {name} -n {namespace}`
4. Add health checks to sync.yaml
5. Verify operator logs for reconciliation errors

### Issue: Comments stripped from rendered manifests

**Root Cause:** Using `kustomize build` which strips comments

**Solution:**
1. Use `cp` instead of `kustomize build` for finalize phase
2. Copy files directly to artifacts/rendered/finalize/
3. Follow cert-manager pattern

### Issue: CPU limits lower than requests

**Root Cause:** Missing CPU limits in resource spec

**Solution:**
1. Always specify both CPU and memory limits
2. CPU limit should be ≥ CPU request
3. Account for sidecar containers in total pod resources

### Issue: CRDs included in deploy phase

**Root Cause:** Bundle contains both CRDs and operator

**Solution:**
1. Use `yq eval 'select(.kind != "CustomResourceDefinition")'` to filter
2. Put CRDs in crds phase
3. Put operator in deploy phase

---

## AI Agent Prompt Template

When asking an AI agent to add a component, use this prompt structure:

```
I need to add {COMPONENT_NAME} to the Cur8s platform following established patterns.

Component Details:
- Purpose: {what it does}
- Source: {GitHub releases / Helm chart / etc.}
- Version: {version}
- Deployment complexity: {1-phase / 2-phase / 3-phase}
- Namespace: {namespace}
- Custom Resources: {list CRs if applicable}

Tasks:
1. Research existing platform patterns (examine cert-manager, external-secrets)
2. Create component structure following platform conventions
3. Implement Makefile with fetch/render/clean targets
4. Create overlay configurations (crds/deploy/finalize as needed)
5. Add comprehensive RBAC with detailed comments explaining WHY
6. Preserve documentation comments in finalize phase
7. Integrate with platform (update kustomization.yaml, Makefile)
8. Add Flux health checks for custom resources
9. Add verification functions (is_{resource}_ready)
10. Update verify script
11. Add namespace to capacity tracking
12. Test build and validate structure

Reference Guide: docs/adding-platform-components.md
```

---

## Checklist Summary

Use this checklist when adding components:

**Planning:**
- [ ] Researched similar components
- [ ] Identified appropriate deployment phases
- [ ] Understood artifact sources
- [ ] Reviewed existing component patterns

**Implementation:**
- [ ] Created directory structure
- [ ] Written VERSION file
- [ ] Written Makefile (fetch/render/clean)
- [ ] Created overlay configurations
- [ ] Added comprehensive comments to finalize resources
- [ ] Written sync.yaml with health checks
- [ ] Written notes.md documentation

**Integration:**
- [ ] Updated platform kustomization.yaml
- [ ] Updated platform Makefile
- [ ] Added verification functions to kube-query.sh
- [ ] Updated verify script
- [ ] Added namespace to capacity script

**Testing:**
- [ ] Build succeeds (make build)
- [ ] Comments preserved in finalize phase
- [ ] Verification passes (make verify)
- [ ] Capacity reporting includes component
- [ ] Deployment works in cluster
- [ ] Health checks function correctly

**Documentation:**
- [ ] notes.md complete
- [ ] Inline comments comprehensive
- [ ] Commit message follows conventions

---

## Key Learnings from Prometheus Operator

1. **Comment preservation is critical** - Use `cp` not `kustomize build` for finalize
2. **RBAC documentation matters** - Future maintainers need to understand WHY permissions exist
3. **Health checks catch issues early** - Don't rely on `wait: true` alone
4. **ServiceAccount must exist first** - Operators create StatefulSets that require it
5. **Always specify CPU limits** - Prevents QoS violations with sidecar containers
6. **CRD filtering is necessary** - Bundles often mix CRDs with operator resources
7. **Container-level capacity view** - Use `--containers` flag for multi-container pods
8. **Consolidate related resources** - Group RBAC + CR in well-documented files
9. **Health checks for CRs** - Flux needs help knowing when custom resources are ready
10. **Follow naming conventions** - `{component}-{phase}` for all Kustomization resources

---

This guide represents the complete pattern for adding platform components. Use it as a comprehensive reference when working with AI agents or manually adding new components to the Cur8s platform.
