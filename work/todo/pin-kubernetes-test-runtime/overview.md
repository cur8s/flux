---
title: "Pin the Kubernetes test runtime"
summary: "Test the Cur8s Kubernetes N-1 target on its latest patch, selected once for both k3s and kubectl."
---

# Pin the Kubernetes test runtime

`test:e2e` is now the semantic compatibility gate for the Flux CLI-generated installation: it
applies the rendered manifest to a Kubernetes API server and proves the controllers and
self-management resources become Ready. k3d currently chooses its own default k3s image, so the
Kubernetes version tested can change when k3d changes without a reviewed repository change.

Cur8s supports and tests the current Kubernetes GA N-1 minor. With Kubernetes `1.36` current and
Flux `v2.9.0` supporting Kubernetes `1.34` through `1.36`, the immediate target is Kubernetes
`1.35`. Cur8s' runtime contract is the latest GA patch in that minor, rather than a fixed container
digest. One exact `KUBERNETES_VERSION` value selects the reviewed k3s image tag and the same
`kubectl` release; maintainers advance it when a new GA patch is published.

The image tag contains a k3s packaging suffix (`k3s1` today), but it does not introduce another
Kubernetes version setting. Then pass the derived image to k3d, assert the created API server and
client report the selected version, run Flux preflight against it, and document the target and
advance procedure. Kubeconform and its static schema target were intentionally removed in
`46bc99c`; this todo does not replace that validator or modify Flux-generated YAML.
