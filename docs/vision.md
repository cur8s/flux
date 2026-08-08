# Vision

The Cur8s Flux package provides a deliberately curated configuration of Flux. It installs only the
Source, Kustomize, and Notification Controllers and configures them to continuously reconcile
static manifests. This restricted surface is part of the package's contract, not a default that
clusters are expected to expand. In-cluster templating, including the Flux Helm Controller, is
deliberately excluded because it constructs the desired state inside the cluster rather than before
it reaches the cluster.

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

The package is headless: its interfaces are declarative resources and the Kubernetes API. It does
not add a user interface, deployment workflow, or secondary control plane that can diverge from
the state visible in the cluster and its declared inputs. Humans and automation operate through the
same API surface.

All choices owned by the package are resolved before publication. A cluster definition selects an
immutable package version and supplies its explicit environment values; Flux fetches and applies
that declared intent. Flux never discovers or selects a newer package or workload version on the
cluster's behalf.

This package serves Cur8s cluster definitions and the operators who need a predictable bootstrap
GitOps engine. It is not a general-purpose Flux distribution.
