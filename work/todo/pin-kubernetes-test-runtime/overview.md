---
title: "Pin the Kubernetes runtime and validation schemas"
summary: "Make build and end-to-end results reproducible by aligning Kubernetes versions and removing mutable schema downloads from validation."
---

# Pin the Kubernetes runtime and validation schemas

The repository currently validates manifests against Kubernetes `1.33.0`, installs kubectl
`1.36.2`, and lets k3d choose its default k3s image. With the current k3d pin, that default is
`v1.35.5-k3s1`, so the schema target, client, and end-to-end runtime do not describe one deliberate
compatibility target.

Kubeconform also downloads schemas from a mutable remote path during validation. This makes the
build network-dependent even though the generated Flux manifest itself is available offline, and
`-ignore-missing-schemas` allows resources to be skipped without asserting that the skipped set is
intentional.

Decide whether the package supports one Kubernetes version or a small compatibility matrix. Pin the
k3s node image, align `KUBE_VERSION` and the kubectl version policy, and define how those pins
advance together. Vendor the required validation schemas or reference them through an immutable
source, then make validation fail when an unexpected schema is missing. Update CI documentation so
its network and reproducibility claims match the resulting implementation.
