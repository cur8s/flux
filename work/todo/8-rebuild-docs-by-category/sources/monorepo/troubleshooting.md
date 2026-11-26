# Troubleshooting

Common issues and solutions when working with Cur8s.

## Cluster Issues

### Cluster won't start

**Symptom:** `make cluster` fails or cluster creation hangs.

**Common causes:**
- Docker not running
- Port conflicts
- Insufficient resources

**Solutions:**

```bash
# Check Docker is running
docker ps

# Delete any existing cluster with same name
scripts/cluster delete cur8s-dev

# Try again
make cluster

# If still failing, check Docker resources:
# - Ensure Docker has at least 4GB RAM allocated
# - Ensure Docker has at least 2 CPUs allocated
```

### Port already in use

**Symptom:** Error about port already allocated during cluster creation.

**Cause:** Previous cluster using same ports, or other service conflict.

**Solution:**

```bash
# Delete the conflicting cluster
scripts/cluster delete <cluster-name>

# Or delete all k3d clusters
scripts/cluster purge

# k3d uses random ports for each cluster to avoid this issue
# If you still see port conflicts, find and stop the conflicting process:
lsof -i :<port>
```

### Can't connect to cluster

**Symptom:** `kubectl` commands fail with connection errors.

**Solutions:**

```bash
# Check cluster is running
k3d cluster list

# Verify kubectl context
kubectl config current-context
# Should be: k3d-<cluster-name>

# Switch to correct context if needed
kubectl config use-context k3d-cur8s-dev

# If cluster exists but not responding, try restart:
k3d cluster stop cur8s-dev
k3d cluster start cur8s-dev
```

## Flux Issues

### Flux controllers not ready

**Symptom:** Flux deployments stuck in `Pending` or `CrashLoopBackOff`.

**Diagnosis:**

```bash
# Check deployment status
kubectl get deployments -n flux-system

# Check pod status
kubectl get pods -n flux-system

# Check logs
kubectl logs -n flux-system deploy/source-controller
kubectl logs -n flux-system deploy/kustomize-controller
kubectl logs -n flux-system deploy/notification-controller
```

**Common fixes:**

```bash
# If image pull issues, check Docker/registry
docker ps

# If CrashLoopBackOff, check logs for specific error
kubectl logs -n flux-system <pod-name> --previous

# Nuclear option - reinstall Flux:
kubectl delete namespace flux-system
make init
```

### Platform not reconciling

**Symptom:** `flux get all -A` shows Kustomizations stuck or failing.

**Diagnosis:**

```bash
# Check overall status
flux get all -A

# Check specific Kustomization
kubectl describe kustomization platform -n flux-system

# Check Flux logs
flux logs -A

# Check source (OCIRepository)
kubectl get ocirepository -n flux-system
kubectl describe ocirepository cur8s-platform -n flux-system
```

**Common causes:**

1. **OCIRepository not ready** - Artifact not found in registry
   ```bash
   # Check registry contents
   eval "$(scripts/cluster env cur8s-dev)"
   curl http://localhost:${CLUSTER_REG_PORT}/v2/_catalog

   # Should show: {"repositories":["cur8s","cur8s-test"]}
   # If missing, re-push:
   make push
   ```

2. **Invalid manifests** - Syntax or validation errors
   ```bash
   # Check Kustomization status
   kubectl describe kustomization platform -n flux-system

   # Look for "validation failed" or similar errors
   # Fix source manifests and rebuild:
   make push
   ```

3. **Dependency issues** - Components depending on resources not yet ready
   ```bash
   # Check dependency chain
   kubectl get kustomizations -n flux-system

   # Should show: platform → cluster-config → apps
   # Wait for each level to complete before next starts
   ```

**Solutions:**

```bash
# Force reconciliation
flux reconcile source oci cur8s-platform -n flux-system
flux reconcile kustomization platform -n flux-system

# If stuck, delete and reapply GitOps config
kubectl delete -f src/test/repos-dev.yaml
kubectl delete -f src/test/kustomizations.yaml
make sync

# Nuclear option - reset cluster
scripts/cluster reset cur8s-dev
make init push sync
```

## Registry Issues

### Can't push to registry

**Symptom:** `make push` fails with registry connection errors.

**Diagnosis:**

```bash
# Check registry is running
docker ps | grep registry

# Check registry port
scripts/cluster status cur8s-dev

# Test registry access
eval "$(scripts/cluster env cur8s-dev)"
curl http://localhost:${CLUSTER_REG_PORT}/v2/_catalog
```

**Solutions:**

```bash
# If registry not running, recreate cluster
scripts/cluster reset cur8s-dev

# If port mismatch, reload environment
eval "$(scripts/cluster env cur8s-dev)"
make push

# If registry exists but unreachable, restart cluster
k3d cluster stop cur8s-dev
k3d cluster start cur8s-dev
```

### OCI artifact not found

**Symptom:** Flux shows "artifact not found" or "failed to fetch artifact".

**Cause:** Artifact was never pushed or registry was reset.

**Solution:**

```bash
# Re-push artifacts
make push

# Force Flux to check again
flux reconcile source oci cur8s-platform -n flux-system
```

## Build Issues

### Build fails - validation errors

**Symptom:** `make build` fails during kubeconform validation.

**Diagnosis:**

```bash
# Run validation manually
make build 2>&1 | grep -A 5 "error"

# Check specific component
cd src/platform/<component>
make render
```

**Solutions:**

1. **Invalid Kubernetes manifests** - Fix syntax in source files
2. **Missing CRDs** - Ensure CRDs are rendered before resources that use them
3. **Version mismatches** - Update component version in Makefile

### Fetch fails - upstream unavailable

**Symptom:** `make fetch` fails to download upstream manifests.

**First diagnostic — run the preflight:**

```bash
make prereqs
```

This loops every component and probes its upstream (GitHub release / Helm repo / OCI registry / URL) using the same auth path that `fetch` will use. On failure each line carries a tagged remediation hint:

- `denied: denied` from a container registry → stale Docker credentials. Fix: `docker logout <registry>`.
- `x509: failed to verify certificate` / `OSStatus -26276` → Claude Code sandbox MITM proxy without trustd access. Fix: set `"sandbox.enableWeakerNetworkIsolation": true` in `.claude/settings.json`.
- `HTTP 403` from `api.github.com` → GitHub API rate limit. Fix: `gh auth login`.
- `HTTP 404` for a release tag → the version pinned in `config/VERSION` doesn't exist upstream.
- `connection refused` / DNS error → network or VPN issue.

`make prereqs` runs in ~5s and surfaces all reachable issues at once.

**Causes:**
- Network connectivity issues
- Upstream chart/manifest moved or deleted
- Rate limiting (GitHub)
- Stale Docker registry credentials
- Sandbox / MITM proxy interfering with TLS

**Other solutions:**

```bash
# Check network
ping github.com

# Try fetch again (may be transient)
make fetch

# If specific component failing, check upstream URL:
cd src/platform/<component>
cat Makefile
# Verify URL is correct

# If upstream moved, update Makefile and try again
```

## Verification Issues

### Verification failing

**Symptom:** `make verify` reports failures.

**Diagnosis:**

The verify script checks 4 layers:
1. Flux Controllers
2. Platform Components
3. Cluster Configuration
4. Test Applications

```bash
# Run verification with details
make verify

# Check specific layer manually:

# Layer 1: Flux
kubectl get deployments -n flux-system

# Layer 2: Platform components
kubectl get deployments -n cert-manager
kubectl get deployments -n external-secrets
kubectl get deployments -n envoy-gateway
kubectl get deployments -n cnpg-system

# Layer 3: Cluster config
kubectl get gatewayclass
kubectl get gateway shared-gateway -n default
kubectl get clustersecretstore

# Layer 4: Test apps
kubectl get deployments -n default
kubectl get externalsecret synced-db-credentials -n default
kubectl get cluster pg-test -n default
```

**Common fixes:**

```bash
# If components not ready, wait longer
watch flux get all -A

# If components failing, check logs
kubectl logs -n <namespace> deploy/<deployment>

# If stuck, force reconciliation
flux reconcile kustomization platform -n flux-system

# Nuclear option
scripts/cluster reset cur8s-dev
make init push sync verify
```

### Gateway not programmed

**Symptom:** Gateway shows `Programmed=False` or HTTPRoute not working.

**Diagnosis:**

```bash
# Check Gateway status
kubectl describe gateway cur8s-apps-gateway -n envoy-gateway
kubectl describe gateway cur8s-system-gateway -n envoy-gateway

# Check Envoy Gateway controller
kubectl logs -n envoy-gateway deploy/envoy-gateway

# Check if envoy-gateway namespace exists
kubectl get ns envoy-gateway

# Check envoy proxy deployments
kubectl get deploy -n envoy-gateway
```

**Solutions:**

```bash
# Wait for gateway to reconcile (can take 1-2 minutes)
watch kubectl get gateway shared-gateway -n default

# If stuck, check events
kubectl get events -n default | grep -i gateway

# Force reconciliation
flux reconcile kustomization cluster-config -n flux-system

# Test endpoint manually
# Dev cluster default: localhost:19080 (apps), localhost:18080 (system)
curl http://hello.apps.cur8s.localhost:19080/

# Or use dynamic port:
eval "$(scripts/cluster env cur8s-dev)"
curl http://hello.apps.cur8s.localhost:${CLUSTER_APPS_PORT}/
```

## E2E Test Issues

### E2E test timeout

**Symptom:** `make e2e` fails with timeout waiting for reconciliation.

**Cause:** Platform taking longer than 10 minutes to reconcile.

**Diagnosis:**

The e2e test preserves the cluster on failure with debug commands.

```bash
# Use the provided debug commands:
kubectl --context k3d-e2e-test get all -A
flux --context k3d-e2e-test get all -A
flux --context k3d-e2e-test logs -A

# Check what's stuck
flux --context k3d-e2e-test get kustomizations -A
```

**Solutions:**

1. **Fix the issue** based on logs, then clean up:
   ```bash
   scripts/cluster delete e2e-test
   ```

2. **Re-run e2e** after fixing source issue:
   ```bash
   make e2e
   ```

### E2E cluster not deleted

**Symptom:** `e2e-test` cluster still exists after test run.

**Cause:** Test failed, cluster preserved for debugging.

**Solution:**

```bash
# Debug first (see above), then delete manually:
scripts/cluster delete e2e-test
```

## General Debugging Tips

### Check everything

```bash
# Cluster and Docker
docker ps
k3d cluster list

# Kubernetes basics
kubectl get nodes
kubectl get ns
kubectl get all -A

# Flux status
flux get all -A
flux logs -A --follow

# Events (often very helpful)
kubectl get events -A --sort-by='.lastTimestamp'
```

### Clean slate

When all else fails, start completely fresh:

```bash
# Delete cluster
scripts/cluster delete cur8s-dev

# Clean build artifacts
make clean

# Start from scratch
make build
make cluster
make init
make push
make sync

# Wait for reconciliation
watch flux get all -A

# Verify
make verify
```

### Get help

If you're still stuck:

1. Check recent changes: `git log --oneline -10`
2. Check what's modified: `git status`
3. Review cluster state: `scripts/cluster status cur8s-dev`
4. Collect logs: `flux logs -A > flux-logs.txt`
5. Check GitHub issues for similar problems

## Common Error Messages

### "context deadline exceeded"

**Meaning:** Operation timed out (usually kubectl or k3d).

**Fix:** Cluster may be slow or unresponsive. Try restart:
```bash
k3d cluster stop cur8s-dev
k3d cluster start cur8s-dev
```

### "connection refused"

**Meaning:** Can't connect to Kubernetes API or registry.

**Fix:** Check cluster is running:
```bash
k3d cluster list
docker ps
```

### "no matches for kind"

**Meaning:** CRD not installed for a resource type.

**Fix:** Ensure CRDs are applied before resources:
```bash
# Check if CRDs exist
kubectl get crds | grep <resource-type>

# Force platform reconciliation (installs CRDs)
flux reconcile kustomization platform -n flux-system
```

### "failed to fetch artifact"

**Meaning:** Flux can't pull OCI artifact from registry.

**Fix:** Ensure artifact was pushed:
```bash
make push
flux reconcile source oci cur8s-platform -n flux-system
```
