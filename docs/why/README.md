# Why

The [RFCs](../rfc/README.md) are *applied* philosophy — normative rules. This
document is the philosophy those rules apply. If the RFCs say *what must be
true*, this says *why we believe it*.

The audience is the **solo builder or small team playing the long game** — not
a large organization assembling a customizable internal platform.

## 1. Self-hosting is a high-leverage investment

Most early projects fail — not from bad infrastructure, but from the brutal
realities of product-market fit, distribution, and timing. If failure is the
likely outcome, the rational move is the path where *even failure leaves you
stronger*: skills that compound for a decade.

A PaaS teaches you a vendor's worldview; when you leave, most of that knowledge
stays behind. Self-hosting forces you to learn the permanent fabric of running
software on the internet — DNS, TLS, routing, state, observability — and those
skills travel with you across every future project. You can't eliminate
operational complexity; you can only choose who carries it, and what you learn
by carrying it.

## 2. The eternal problems

Every internet-facing system eventually confronts the same fixed set of
problems, regardless of stack: **naming** (DNS), **trust** (certificates),
**routing**, **runtime supervision**, **state and backups**, **secrets**,
**identity**, **observability**, and **automation** — plus the discipline to
*selectively* outsource true commodities (object storage, email deliverability,
password vaults). These don't disappear with a clever tool; they are the terrain.

Prefer **open protocols over vendor abstractions** — SMTP, OIDC, S3-compatible
APIs — because protocols outlive vendors. They preserve your freedom to switch,
self-host, or evolve without rewriting your foundations.

## 3. Order over chaos

Strip Kubernetes of its enterprise baggage — multi-team governance, global
failover, giant meshes — and what remains is small and durable: **one mental
model** where you *declare intent and controllers reconcile reality toward it*.
Every concern — workloads, networking, config, certificates, secrets, DNS —
gets the same shape, instead of becoming a museum of one-off scripts. *Using*
Kubernetes is the skill that compounds; *running* the control plane need not be
(start with single-node k3s; let success earn the complexity).

This reconciliation model is exactly why a GitOps engine is the foundation's
first and load-bearing component.

## 4. Begin where the long game ends

You don't need to invent a platform before shipping a product. The most
effective way to grow is to start *inside* a system that already embodies
long-lived principles — coherent enough to trust, open enough to inspect,
structured enough to evolve.

That is what this foundation is for. It encodes the trilogy above as concrete
invariants: **durable skills over disposable convenience, open protocols over
vendor lock-in, Kubernetes as the stable substrate, and automation through
controllers rather than ad-hoc scripts.** Each layer added on top — starting
with Flux here — is one more of the *eternal problems* solved once, declaratively,
in a way you can read, version, and reason about for years.

---

These ideas are encoded as enforceable constraints in the
[RFCs](../rfc/README.md). Read [RFC-001](../rfc/RFC-001-role-of-rfcs.md) for how
those constraints carry authority.
