# Platform Components

This document explains why Cur8s includes each platform component. These are **curated choices**, not architectural constraints. The constraints live in [RFCs](rfc/README.md); this document captures the reasoning behind specific tool selections.

Components can be replaced if something better emerges. What matters is that replacements satisfy the same RFCs—declarative control, static manifests, identity-first security, and so on. The architecture stays the same; only implementations change.

For the philosophy behind curation, see [RFC-002: Curated Opinionated Platform](rfc/RFC-002-curated-opinionated-platform.md).

---

## GitOps

### FluxCD

Flux is the reconciliation engine that enforces declared state. Cur8s uses three controllers: source-controller (fetches artifacts), kustomize-controller (applies manifests), and notification-controller (observability). Helm-controller and image-automation are explicitly excluded.

**Why Flux over Argo CD**: Argo CD is UI-centric and encourages interaction through its dashboard. Cur8s is headless by design ([RFC-003](rfc/RFC-003-headless-platform.md)). Flux operates entirely through declarative resources and the Kubernetes API—no separate operational surface.

**Why Flux over Carvel**: Carvel aligns philosophically with Cur8s (build-time rendering, small composable tools), but Flux has broader adoption, a larger contributor base, and stronger community momentum. For a platform designed to last, ecosystem stability matters.

The constraints Flux must satisfy are defined in [RFC-008: Flux as the GitOps Engine](rfc/RFC-008-flux-as-the-gitops-engine.md).

---

## Secrets

### External Secrets Operator

ESO synchronizes secrets from external stores (1Password, Vault, AWS Secrets Manager, etc.) into Kubernetes. Git declares *which* secrets should exist; secret values remain authoritative outside the cluster.

**Why ESO over Sealed Secrets**: Sealed Secrets encrypt values into Git. This puts secret material—even encrypted—into version control, complicating rotation and audit. ESO keeps values external, making rotation a vault operation rather than a Git commit.

**Why ESO over SOPS**: SOPS also encrypts secrets in Git. Same problem: secret material lives in the repository. ESO's model—declare references, sync values—keeps the boundary clean.

**Why not just mount secrets manually**: Manual `kubectl create secret` introduces hidden state that can't be recovered from Git. ESO makes secrets declarative and reproducible.

The constraints ESO must satisfy are defined in [RFC-012: External Secrets](rfc/RFC-012-external-secrets.md).

---

## Certificates

### cert-manager

cert-manager automates certificate issuance and renewal via ACME (Let's Encrypt). You declare a Certificate resource; cert-manager handles challenges, issuance, and rotation. No manual downloads, no calendar reminders, no expired certificates breaking production.

**Why cert-manager**: It's the de facto standard for Kubernetes certificate automation. Broad ecosystem support, extensive documentation, and integration with every major ingress controller and service mesh. Choosing something else would mean fighting the ecosystem.

**Why not Traefik's built-in ACME**: Traefik handles its own certificates well, but Cur8s uses Envoy Gateway. cert-manager provides a consistent certificate model regardless of which ingress solution is in use.

**Why not manual certificates**: Manual certificate management doesn't scale and inevitably leads to expiration incidents. Automation is the only sustainable path.

---

## Ingress

### Envoy Gateway

Envoy Gateway provides the external entry point for HTTP/HTTPS traffic. It implements the Kubernetes Gateway API standard, backed by the battle-tested Envoy proxy.

**Why Envoy Gateway over Traefik**: Traefik is excellent and would work fine. Envoy Gateway was chosen because Envoy is the proxy behind most service meshes and cloud load balancers—learning Envoy's model transfers broadly. Gateway API is also the future of Kubernetes ingress, and Envoy Gateway implements it cleanly.

**Why Envoy Gateway over nginx-ingress**: nginx-ingress uses the older Ingress API and relies heavily on annotations for configuration. Gateway API is more expressive and structured. Envoy Gateway embraces the new model fully.

**Why not a service mesh**: Service meshes (Istio, Linkerd) add significant complexity for capabilities most bootstrappers don't need. Envoy Gateway provides ingress without the mesh overhead. If mesh capabilities become necessary later, Envoy familiarity transfers directly.

---

## DNS

### ExternalDNS

ExternalDNS watches Kubernetes resources (Services, Ingresses, Gateway routes) and automatically creates DNS records in external providers (Cloudflare, Route53, Google Cloud DNS, etc.). DNS becomes declarative: change a resource, DNS updates automatically.

**Why ExternalDNS**: It's the only mature option for declarative DNS in Kubernetes. Broad provider support, active maintenance, and a simple model: annotate resources with desired hostnames, ExternalDNS handles the rest.

**Why not manual DNS**: Manual DNS management doesn't scale and introduces drift between what the cluster expects and what DNS provides. Declarative DNS eliminates an entire class of "why isn't this working" debugging sessions.

---

## Databases

### CloudNativePG

CloudNativePG is a Kubernetes operator for PostgreSQL. It handles provisioning, configuration, automated backups to object storage, point-in-time recovery, replication, and rolling upgrades.

**Why PostgreSQL**: Postgres is the most capable open-source relational database and the default choice for most web applications. Learning Postgres deeply is a durable investment—the skills transfer everywhere.

**Why CloudNativePG over Zalando Postgres Operator**: Both are solid. CloudNativePG has cleaner documentation, more active development, and a simpler operational model. It also handles backups to S3-compatible storage natively, which aligns with Cur8s' emphasis on object storage for durability.

**Why CloudNativePG over managed databases (RDS, Cloud SQL)**: Managed databases work well but create provider lock-in and ongoing costs that scale with usage. CloudNativePG runs on your own infrastructure, keeping costs predictable and skills portable.

**Why an operator at all**: Running Postgres without an operator means manual backup scripts, manual failover procedures, and manual upgrade processes. Operators encode operational knowledge into software. CloudNativePG handles the hard parts so you can focus on your application.

---

## Observability

### VictoriaMetrics

VictoriaMetrics collects and stores metrics. It's Prometheus-compatible (same scrape configs, same PromQL queries) but significantly more resource-efficient. A single-node deployment handles what would require a clustered Prometheus setup.

**Why VictoriaMetrics over Prometheus**: Prometheus is the standard, but it's resource-hungry. VictoriaMetrics provides the same interface with lower memory and CPU requirements—important for bootstrappers running everything on modest hardware. If you know Prometheus, you already know how to use VictoriaMetrics.

**Why not Thanos or Cortex**: These are distributed systems designed for massive scale and long-term storage across multiple Prometheus instances. Overkill for a single-cluster, single-operator setup. VictoriaMetrics handles long-term retention natively without the operational complexity.

### VictoriaLogs

VictoriaLogs provides log aggregation. Fluent Bit collects logs from all pods and ships them to VictoriaLogs for storage and querying.

**Why VictoriaLogs over Loki**: Loki is widely used but can be resource-intensive and operationally complex at scale. VictoriaLogs is newer but designed from the ground up to be lean. It fits the same "do more with less" philosophy as VictoriaMetrics.

**Why VictoriaLogs over Elasticsearch**: Elasticsearch is powerful but notoriously resource-hungry and complex to operate. It's designed for search workloads far beyond what log aggregation requires. VictoriaLogs is purpose-built for logs and runs comfortably on minimal resources.

### Grafana

Grafana provides dashboards and visualization for both metrics (from VictoriaMetrics) and logs (from VictoriaLogs). It's the industry standard for observability visualization.

**Why Grafana**: There's no serious alternative with comparable ecosystem support. Grafana has pre-built dashboards for nearly every Kubernetes component, extensive documentation, and a query interface that works with both Prometheus-compatible metrics and multiple log backends.

**Why include visualization at all**: Cur8s is headless—no platform-owned UI for operations. But observability is different. Understanding system behavior requires visualization. Grafana provides insight without creating an operational control surface.

---

## Summary

Every component exists because it solves a permanent problem in a way that fits Cur8s' constraints: declarative, automatable, resource-efficient, and aligned with durable skills. None are sacred. If better tools emerge that satisfy the same RFCs, components can be replaced.

The goal is a coherent platform where everything follows the same operational model—declare intent, let controllers reconcile—so you can focus on building your product instead of managing infrastructure.
