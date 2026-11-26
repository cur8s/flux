## RFC-010: Declarative Readiness

**Status:** Accepted

Cur8s operates in a domain where **readiness**, not just existence, determines
whether a system can function correctly.

Many platform dependencies involve **real-world systems outside Kubernetes**. 
Security and identity are common examples. Issuing a public TLS certificate via 
ACME using a DNS-01 challenge introduces unavoidable latency: DNS records must 
propagate, external validation must complete, and rate limits may apply. The 
certificate resource can exist immediately, but it may take minutes before it 
becomes ready. During that time, any resource that depends on the 
certificate—such as network-facing infrastructure that requires TLS—cannot 
function correctly yet.

If such dependencies are not modeled explicitly, reconciliation degrades into 
**race conditions**. Resources are applied before prerequisites are ready,
controllers repeatedly retry, and error logs accumulate until readiness 
eventually arrives. When multiple long-running dependencies exist, 
reconciliation becomes noisy and opaque: it is difficult to tell whether the 
system is progressing normally, blocked on an external dependency, or genuinely 
misconfigured.

The cost is operational clarity. It becomes hard to answer basic questions: 
*What is the system waiting on? Which dependency is the bottleneck? Is this 
expected latency or a real error?* Without an explicit readiness model, 
debugging turns into log archaeology and progress depends on timing rather than
intent.

This RFC defines how Cur8s addresses that problem by expressing readiness 
**declaratively**, so that reconciliation remains understandable, failures are
localized, and progress is observable—without introducing imperative 
installation steps or procedural orchestration.

## Core Rule

**Readiness is expressed declaratively.  
Reconciliation must respect readiness boundaries.  
No imperative install sequence is authoritative.**

## Readiness as a Declarative Property

Cur8s treats readiness as part of the **desired state**, not as an execution 
detail.

A resource is not considered usable merely because it exists. It becomes usable 
only when it has reached a state that downstream resources can safely depend on.
Readiness therefore defines *when* a dependency may be consumed, not just
*whether* it is present.

In a declarative system, this distinction is critical. Without it, 
reconciliation cannot distinguish between “not yet ready” and “misconfigured,” 
and operators cannot reason about whether the system is converging or failing.

## How Cur8s Expresses Readiness

Cur8s expresses readiness using **Flux Kustomizations as reconciliation boundaries**.

Rather than reconciling the entire system as a single unit, Cur8s partitions the
desired state into multiple reconciliation units. Each unit declares:

- the resources it is responsible for
- the readiness conditions it depends on
- the other reconciliation units that must reach readiness first

These relationships are expressed declaratively. Reconciliation proceeds 
automatically when readiness conditions are satisfied and pauses naturally when
they are not.

If a reconciliation unit cannot apply because a dependency has not yet reached
readiness, it remains pending. Once readiness is achieved, reconciliation 
resumes without manual intervention. No explicit “wait” logic, sleeps, or 
procedural control flow is required.

### Illustrative Example (Non-Normative)

The following simplified example illustrates how readiness dependencies may be
expressed declaratively using Flux Kustomizations. It is provided for clarity 
only and does not prescribe a specific layout or configuration.

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: platform
spec:
  dependsOn:
    - name: init
```

In this example, the `platform` reconciliation unit will not proceed until the
`init` unit has reached readiness. If `init` is waiting on an external 
dependency, reconciliation pauses cleanly rather than failing repeatedly.

##  Why Declarative Readiness Works

By encoding readiness relationships declaratively:

- race conditions are reduced rather than masked
- failures are localized to specific dependencies
- progress is observable and explainable
- reconciliation remains resilient

The system converges based on readiness signals, not timing assumptions.

## Forbidden Patterns

Cur8s explicitly forbids:

- imperative installation scripts
- ordered `kubectl apply` workflows as the authoritative control path
- embedding “wait for X” logic in automation
- treating existence as equivalent to readiness
- hidden sequencing encoded in procedural tooling

Any approach that requires a human or script to manage readiness sequencing 
violates this RFC.

## Scope

This RFC defines **how readiness is modeled and enforced declaratively in Cur8s**.

It does not prescribe directory layouts, file structures, or complete YAML 
specifications. Those details are implementation concerns that may evolve 
without changing the architectural contract defined here.

## Revisions

Initial version.
