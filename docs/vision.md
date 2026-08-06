# Vision

The Cur8s Flux package provides an opinionated configuration of Flux. It configures Flux to
continuously reconcile static manifests only. In-cluster templating, including the Flux Helm
Controller, is deliberately excluded because it constructs the desired state inside the cluster
rather than before it reaches the cluster.

In-cluster templating makes the final desired state impossible to determine from the source
artifacts alone. A Helm chart rendered inside the cluster may produce different manifests depending
on the Kubernetes version, installed APIs, or existing cluster state. The same chart and values can
therefore produce different results across clusters or over time, making failures and differences
harder to understand, reproduce, and recover from.

By reconciling only static manifests, the complete desired state is explicit and inspectable before
it reaches the cluster. Operators can determine exactly what Flux will reconcile, compare the
intended state across environments, reproduce installations from immutable artifacts, and recover
the GitOps engine without relying on hidden runtime decisions.
