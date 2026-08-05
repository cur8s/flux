---
title: "Pin the Kubernetes end-to-end test runtime"
summary: "Make end-to-end results reproducible by pinning the k3s node image and explicitly defining the Kubernetes versions this package supports."
---

# Pin the Kubernetes end-to-end test runtime

The repository pins its command-line tools and supplies `KUBE_VERSION` to kubeconform, but the k3d
configuration does not pin the k3s node image. A change in k3d's default image could therefore
change the cluster used by `test:e2e` even when the repository commit and tool pins are unchanged.

Investigate whether the package should test one explicitly supported Kubernetes version or a small
compatibility matrix. Align the chosen k3s image, kubeconform target, and kubectl version policy,
and define how those pins advance together. Decide whether an immutable image digest is worthwhile
or whether an explicit k3s release tag provides sufficient reproducibility and maintainability.
