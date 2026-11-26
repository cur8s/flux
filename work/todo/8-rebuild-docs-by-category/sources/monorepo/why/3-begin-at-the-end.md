# Begin at the End

By now the shape of the journey is clear. **Stop Renting Your Knowledge** argued that self-hosting
is one of the highest-leverage investments a bootstrapper can make: even if the product fails, the
skills compound. **The Eternal Problems of Self-Hosting** mapped the universal responsibilities
every internet-facing system must confront. **Order Over Chaos** showed why Kubernetes is the most
durable model for bringing order to those responsibilities over the long arc of a project.

Taken together, these ideas point toward a natural destination: a Kubernetes-based platform where
DNS, certificates, routing, state, secrets, identity, observability, and automation are all
first-class, declarative concerns. But understanding that destination is not the same as building
the road to reach it. You don’t learn programming by writing a compiler, and you don’t learn web
development by inventing a framework. In the same way, you don’t need to design an entire
infrastructure platform from scratch in order to benefit from the long-term model the trilogy
describes.

The most effective way to grow is to start *inside* a system that already embodies solid, long-lived
principles—coherent enough to trust, open enough to inspect, and structured enough to evolve with.
That is the role Cur8s is meant to play: it turns the destination into a starting point.

## Cur8s: A Platform Shaped by the Trilogy

Cur8s is a self-hosted platform shaped directly by the philosophy of the trilogy: durable skills
over disposable convenience, open protocols over vendor-specific abstractions, Kubernetes as the
stable substrate, and automation through controllers instead of ad-hoc scripts. It gives you a
production-ready foundation aligned with the long game, so you can focus on building your product
rather than first inventing a platform. A useful way to think about Cur8s is this: it aims to do for
self-hosted infrastructure what frameworks like Rails once did for web apps—an opinionated,
batteries-included starting point that still leaves room to grow, customize, and understand what’s
happening underneath. It doesn’t hide the mechanics; it organizes them into something workable.

To make that possible, Cur8s brings together a small, carefully chosen set of components—each
addressing one of the *Eternal Problems of Self-Hosting*, each fitting naturally into Kubernetes’
reconciliation model:

- **k3s** — a lightweight, standards-compliant Kubernetes distribution that installs cleanly,
  upgrades predictably, and exposes the real API without ceremony.
- **FluxCD** — GitOps-driven operations that keep the cluster continuously aligned with declarative
  intent.
- **Envoy Gateway** — a modern, extensible entrypoint for HTTPS and HTTP routing, built on a
  battle-tested proxy.
- **cert-manager** — automated certificate issuance and renewal via ACME, ensuring seamless TLS.
- **ExternalDNS** — declarative DNS management that keeps your DNS provider in sync with the
  cluster.
- **CloudNativePG** — a production-grade Postgres operator with built-in backups, restores, and
  replication.
- **External Secrets Operator** — secure secret injection from providers like 1Password, keeping
  sensitive data out of Git and off machines.
- **VictoriaMetrics & VictoriaLogs** — a lean observability stack for metrics and logs that runs
  comfortably on modest hardware.

Each component is there because it solves a permanent problem and follows the same mental shape: you
declare intent, controllers reconcile reality. Cur8s doesn’t obscure Kubernetes—it makes Kubernetes
livable. From the first day, you deploy real applications using the same primitives you’ll still
rely on a year later. And none of this is welded shut. If you prefer Prometheus over
VictoriaMetrics, or Traefik over Envoy, or a managed database over CloudNativePG, you can swap them.
The architecture stays the same; only the implementations change.

## Growth Without Reinvention

Cur8s is designed for the actual life of a bootstrapper: one cluster, one machine, one person. You
begin with a single-node k3s installation—on a VPS, a dedicated box, or powerful local hardware—and
run the entire platform in one place. Routing, certificates, DNS integration, secrets, Postgres,
metrics, logs, and your own applications all live inside a single coherent operating model. As your
needs grow, nothing fundamental has to change. You can scale vertically by adding CPU, RAM, or disk
without altering your workflow or mental model. When your application finally outgrows what a single
machine can provide, that moment is not a crisis—it’s evidence of traction.

At that point, your next steps are evolutionary rather than disruptive. You can extend Cur8s into a
small multi-node k3s cluster or move to a managed Kubernetes offering from providers like
DigitalOcean, Hetzner, Vultr, Linode, or the larger clouds. Your manifests come with you. Your
operators come with you. The way you think about deployments, services, ingress, storage, and
secrets does not need to change. You are not switching platforms; you are stretching the same
architecture onto a larger stage.

## Start Where the Long Game Ends

The trilogy argues for a long-term view: learn durable skills, embrace the universal
responsibilities of running software on the internet, and choose an operating model that will not
betray you when your needs grow. Cur8s lets you begin from that endpoint instead of spending years
feeling your way toward it. It doesn’t pretend infrastructure is effortless, and it doesn’t
eliminate the need to learn, but it ensures that every hour you invest is spent inside a system
aligned with the direction you’ve already chosen.

You don’t need to build your own platform before you can ship your first product. You don’t need
deep Kubernetes expertise before deploying your first application. You don’t need to assemble your
own routing, database, secret management, and observability stacks before you find your first user.
You can begin inside a system shaped by hard-earned lessons and grow your understanding on top of
it, layer by layer, the same way you learned everything else.

Self-hosting is still the long game.  
Cur8s simply lets you begin at the end.
