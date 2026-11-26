---
title: "Pin the Kubernetes test runtime"
summary: "Test the Cur8s Kubernetes GA N-1 target on its latest patch by pinning one KUBERNETES_VERSION for both k3s and kubectl, asserting client and server versions, and running Flux preflight."
---

# Pin the Kubernetes test runtime

The end-to-end gate in `verify:run` is the semantic compatibility gate for the Flux CLI-generated installation: it applies the rendered manifest to a Kubernetes API server and proves the controllers and self-management resources become Ready. Today k3d chooses its own default k3s image, so the tested Kubernetes runtime can shift whenever k3d changes without a reviewed repository change.

**Agreed direction:**

- Cur8s tests the current Kubernetes GA N-1 minor (with Kubernetes `1.36` current, the target is `1.35`). Flux owns the full compatibility contract (`v2.9.x` supports Kubernetes `1.34`–`1.36`); the single test target is explicit e2e coverage, not a narrower Cur8s support claim.
- Pin the latest reviewed GA patch in that minor via `KUBERNETES_VERSION` (rolling latest-patch contract, not a fixed container digest), derive `K3S_IMAGE`, and match `kubectl` to the exact same version.
- Follow [Mise standard](../../../docs/standards/mise-standard.md) (`MISE-003` keeps `[tools]` pins literal strings rather than templated, so `kubectl` uses the matching literal version alongside `KUBERNETES_VERSION`).
- Assert both client and server versions after cluster creation, run `flux check --pre`, and document the e2e target and advance procedure.

See [plan.md](plan.md) for the detailed plan and phase breakdown. Kubeconform and its static schema target were intentionally removed in `46bc99c`; this todo does not reintroduce static schema validation or modify Flux-generated YAML.
