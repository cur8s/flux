# Vision

The Cur8s Flux package provides an opinionated configuration of Flux. It configures Flux to
continuously reconcile static manifests only. In-cluster templating, including the Flux Helm
Controller, is deliberately excluded because it constructs the desired state inside the cluster
rather than before it reaches the cluster.

In-cluster templating makes the final desired state impossible to determine from the declared
inputs alone. A Helm chart rendered inside the cluster may produce different manifests depending on
the Kubernetes version, installed APIs, or existing cluster state. The same chart and values can
therefore produce different results across clusters or over time, making failures and differences
harder to understand, reproduce, and recover from.

By limiting reconciliation to static manifests, deterministic structural composition, and explicit
declared values, the complete desired state remains derivable and inspectable. Operators can
determine exactly what Flux will reconcile, compare intended state across environments, reproduce
installations from immutable artifacts, and recover the GitOps engine without relying on hidden
runtime decisions.

This package serves Cur8s cluster definitions and the operators who need a predictable bootstrap
GitOps engine. It is not a general-purpose Flux distribution.
