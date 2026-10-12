# Pre-rendered manifests

> [!NOTE]
> Read this document to understand why Cur8s constructs deployment artifacts before they reach
> the cluster, and what remains permissible during reconciliation.

The [vision](00-vision.md) calls for a GitOps engine that operators can understand, reproduce,
and recover. That requires an inspectable deployment payload and an explicit account of every
input that affects it. Versioning a template does not, by itself, preserve the manifests it will
produce.

## Resolve choices before deployment

Cur8s separates constructing a deployment artifact from reconciling it. Build-time tools resolve
templates, dependencies, component versions, and choices about which resources to include. The
result is published as an immutable artifact that operators can inspect before deployment.

The cluster definition selects that artifact and declares any environment-specific inputs.
Reconciliation applies the resulting manifests and corrects drift. It must not choose newer
versions, render Helm charts, or decide which resources to create by discovering the cluster's
capabilities or existing objects.

| Stage | Responsibility | Recorded result |
| --- | --- | --- |
| Artifact construction | Resolve templates, dependencies, versions, and resource structure. | An inspectable, immutable deployment artifact. |
| Cluster declaration | Select the artifact version and declare environment values. | Versioned intent outside the cluster. |
| Reconciliation | Compose declared inputs and converge toward their manifests. | Applied resources and observable reconciliation status. |

This is the meaning of **render once, reconcile forever**: publication preserves the result of
the construction process, and reconciliation repeatedly applies the declared payload.

## Why in-cluster rendering obscures intent

A chart can branch on the APIs available in a cluster or query existing objects. Helm provides
these capabilities through
[cluster capability checks and resource lookups](https://docs.helm.sh/docs/chart_template_guide/function_list/#kubernetes-and-chart-functions).
When rendering depends on those observations, the chart version and values alone do not determine
the resulting manifests. Two clusters with the same declared chart inputs can produce different
resources, and a later render can differ after the cluster changes.

An operator investigating that difference must recover both the declared inputs and the relevant
cluster state at the time of rendering. Recovery can then depend on recreating the conditions that
produced the original installation. Cur8s resolves those choices before publication so the
deployment artifact preserves the result directly.

Helm and other rendering tools remain useful during artifact construction. Their output, rather
than their unresolved templates, becomes the deployment payload.

## Permitted composition and environment values

A deployment artifact may contain complete manifests or Kustomize composition whose output is
determined by the artifact's files and explicitly declared values. Structural composition is
permitted when it introduces no discovery of dependencies or choices based on live cluster state.

The operating model also permits Flux's
[`postBuild.substituteFrom`](https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution)
to supply environment values from explicitly referenced ConfigMaps and Secrets. Those resources
form part of the cluster's declared state. For example, a declared domain value can fill a field
in an existing resource while its resource structure remains fixed.

This is a constraint on how Cur8s uses substitution: values must not introduce new resource
structure or select undeclared dependencies. Inspecting the artifact alone is insufficient when
it uses substitution; the referenced declarations are part of its inputs too. A change to those
inputs changes the intended state even when the artifact version stays the same.

The Flux package's own controller installation is fully rendered before publication. Its
self-management resource applies those manifests without environment substitution; the consuming
cluster separately declares the artifact source and version. The
[architecture overview](../architecture/00-overview.md) explains that package boundary and handoff.

## What operators gain

- **Review:** Inspect the deployment payload before it reaches a cluster, including the declared
  values needed to derive the applied manifests.
- **Comparison:** Explain differences between environments through their selected artifacts and
  explicit inputs.
- **Reproduction:** Derive the same desired manifests from the same artifact and declared values
  without reconstructing historical cluster observations.
- **Recovery:** Reapply recorded intent, including the GitOps engine's installation, rather than
  rerunning a construction process against a damaged cluster.

These guarantees concern declared manifests. Kubernetes still validates them against its APIs,
and controllers respond to observed conditions. Identical desired manifests do not imply identical
runtime behavior or make an incompatible Kubernetes version compatible. Verification must still
establish that the selected installation works on its target runtime.
