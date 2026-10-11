## RFC-012: External Secrets

**Status:** Accepted

Not all secrets can be eliminated through workload identity federation.

As established in [RFC-011: Workload Identity Federation](RFC-011-workload-identity-federation.md)
, Cur8s prefers identity-based access to external systems. However, some 
integrations still require static credentials such as API tokens, passwords, or 
shared keys. When this is the case, Cur8s must still provide a way to make those
secrets available to workloads **without violating the platform’s core 
architectural constraints**.

This RFC defines how Cur8s handles secret material when workload identity 
federation is not available.

## The Problem

Consider a workload that requires a secret value that cannot be obtained via
workload identity federation—for example, an external API that requires a static
token.

The most obvious approaches all fail:

- **Committing the secret to Git** makes sensitive material part of the 
  declarative source of truth.
- **Creating the secret imperatively** introduces hidden state. For example:
  ```bash
  kubectl create secret generic api-token \
    --from-literal=token=abcd1234
  ```
  This command (or a variation of it) must now live somewhere—run manually, 
  embedded in a script, or executed by a CI pipeline. Regardless of where it 
  runs, the secret exists in the cluster without a declarative, reviewable, or 
  reproducible representation in Git.
- **Relying on scripts or pipelines** only moves the problem. It formalizes the
  same imperative behavior in a different place, creating an alternate control
  path outside the GitOps reconciliation loop.

Each of these approaches violates one or more foundational Cur8s principles: 
externalized intent, reproducibility, declarative control, or recoverability.

The core problem is therefore **not how to store secrets securely at rest**,
but how to introduce secret material into the cluster in a way that remains
declarative, observable, and recoverable over time—without creating hidden 
state or side channels of control.

## Core Rule

**Secret values are external inputs.  
Secret values are never committed to Git.  
Secrets are synchronized into the cluster from an external secrets store.**

An *external secrets store* is a system designed specifically for securely 
storing, rotating, and controlling access to sensitive material, such as a 
password manager or a cloud-managed secrets service.

Kubernetes `Secret` objects are treated as **derived runtime state**. They 
exist only to make externally managed values available to running workloads. 
Deleting and recreating a cluster must never imply losing a secret.

## External Secrets Operator (ESO)

Cur8s uses the **External Secrets Operator (ESO)** to synchronize secret values
from an external secrets store into the Kubernetes cluster.

ESO provides the architectural shape required by Cur8s: Git declares *which* 
secrets should exist, while secret values remain authoritative outside the 
cluster. ESO materializes Kubernetes `Secret` objects declaratively and keeps 
them synchronized over time. Missing or invalid secrets block readiness visibly,
in alignment with [RFC-010: Declarative Readiness](RFC-010-declarative-readiness.md).

ESO is not a convenience feature. It is the mechanism that allows Cur8s to 
support secrets **without violating declarative control, reproducibility, or 
recoverability**.

### Illustrative Example (Non-Normative)

Suppose you are using an **external secrets management service**, such as 
**1Password**, as the authoritative place where secret values are stored.

An API token required by an application is created and stored in the external
secrets store. That value never appears in Git and is never embedded in 
platform manifests.

Cur8s configures **ESO** to reference that secret and project it into the 
cluster as a Kubernetes `Secret`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-token
spec:
  secretStoreRef:
    name: onepassword
    kind: ClusterSecretStore
  target:
    name: api-token
  data:
    - secretKey: token
      remoteRef:
        key: my-api-token
```

In this model, the secret value lives only in the external secrets store. 
Git declares that a Kubernetes `Secret` named `api-token` must exist. ESO 
retrieves the value, materializes it into the cluster, and keeps it 
synchronized. If the cluster is destroyed and recreated, the secret can be 
re-materialized without loss of information.

This example illustrates how Cur8s uses ESO to enforce its secret-handling
contract, not a required provider or vault choice.

## Bootstrapping the Secret System

An external secrets store cannot synchronize itself without initial access.

Cur8s explicitly acknowledges that **one bootstrap secret is unavoidable**. 
To establish secret synchronization, a minimal credential must be introduced 
manually, outside the GitOps workflow. This bootstrap step is performed once, 
is not stored in Git, and is limited strictly to enabling ESO to access the
external secrets store.

This one-time imperative action is explicit and constrained. Once 
synchronization is established, all other secret material flows 
declaratively and continuously.

## Forbidden Patterns

Cur8s explicitly forbids:

- committing plaintext secrets to Git
- embedding secret values in platform artifacts or static manifests
- using ad-hoc `kubectl create secret` commands as a steady-state mechanism
- allowing workloads to start with missing or placeholder secrets
- treating Kubernetes `Secret` objects as authoritative state

Any approach that obscures where secret values originate or how they enter the
cluster violates this RFC.

## Scope

This RFC defines **how Cur8s handles secret material when workload identity 
federation is not available**.

It does not mandate a specific external secrets store beyond the requirement
for secure external storage, nor does it prescribe detailed ESO configuration. 
Those concerns are addressed in follow-up RFCs and implementation documentation.

## Revisions

Initial draft.
