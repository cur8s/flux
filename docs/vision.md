# Vision

This document explains why the flux package exists, who it serves,
what success means, and what is outside its scope. It records durable
intent, not implementation detail or current work.

## Problem

Every cur8s cluster runs Flux as its GitOps engine, and every cluster
must run the *same* Flux: same controllers, same configuration, same
bytes. Installing Flux ad hoc — helm charts, `flux bootstrap`,
hand-tuned manifests — produces drift between clusters, upgrades that
cannot be reviewed as diffs, and an engine whose capabilities quietly
exceed what the platform permits.

## Audience

The cur8s platform itself: the bootstrap tooling that brings clusters
up and the platform operators who run it. This is one component
repository of the [cur8s](https://github.com/cur8s/cur8s) platform,
not a general-purpose Flux distribution.

## Success

One immutable OCI artifact per version that takes a bare cluster —
zero pre-existing secrets — to a self-managing Flux installation, and
that upgrades itself when the tag advances. Every published version
is byte-for-byte reproducible from the pinned toolchain and proven by
a green end-to-end run before publication. Every change, including an
upstream version bump, is reviewable as a plain `git diff` of the
rendered tree.

## Out of Scope

Choosing what the engine deploys — that is the platform's job.
helm-controller and the image-automation controllers, forbidden by
the flagship's RFC-006. Configurable or multi-flavor installs: there
is one opinion, and it is the artifact. Org-wide policy — component
versioning law, the release model, the engine choice itself — which
lives in the flagship and is linked, never copied.
