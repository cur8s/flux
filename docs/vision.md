# Vision

Cur8s gives independent builders a durable way to operate the software they put on the internet. DNS, certificates, secrets, data, routing, observability, and recovery are permanent responsibilities: outsourcing them can be useful, but cannot make them disappear. The platform gives those responsibilities one Kubernetes-based operating model, so the skills and decisions behind a product compound as it grows.

This package supplies the GitOps engine that keeps that model external to the cluster. A cluster should not be an operational surface where people, scripts, or controllers decide what to do next. Its desired state is recorded outside the cluster, reviewed, versioned, and then mechanically reconciled. Flux is deliberately a small, headless executor of that intent: it gives operators the Kubernetes API rather than a separate dashboard or workflow.

Success is a bare cluster becoming a predictable, self-managing Flux installation from one immutable artifact. An operator can inspect the exact manifests the cluster will reconcile, reproduce them with the pinned tools, and recover the engine without hidden prerequisites. Advancing it is an explicit, versioned decision, never an in-cluster discovery.

The package is not a general-purpose Flux distribution, a deployment UI, or a place to decide what applications and platform components a cluster should run. It owns one constrained engine configuration; the broader platform architecture and its laws remain authoritative in the [cur8s flagship RFCs](https://github.com/cur8s/cur8s/tree/main/docs/rfc).
