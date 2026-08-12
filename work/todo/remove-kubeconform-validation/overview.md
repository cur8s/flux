---
title: "Remove kubeconform validation"
summary: "Remove a non-actionable, network-dependent schema check and rely on the pinned Kubernetes e2e runtime for semantic validation."
---

# Remove kubeconform validation

`artifact:validate` currently runs kubeconform against the Flux CLI-generated
`deploy/flux.yaml`. It downloads schemas from a mutable remote location and uses
`-ignore-missing-schemas`, so it is neither an offline reproducibility guarantee nor
a complete validation gate.

The repository does not author the substantive controller manifest: it is produced by
the pinned Flux CLI. If kubeconform reports that generated YAML is invalid, Cur8s
cannot safely hand-edit it; the actionable responses are to select a compatible Flux
or Kubernetes version, or report an upstream Flux issue. A pinned k3s e2e cluster
already applies the actual generated manifest to its Kubernetes API server and proves
the controllers and self-management resources become Ready. Once that runtime is
explicitly pinned and asserted, it is the relevant semantic compatibility gate.

Remove kubeconform from the toolchain, artifact build, and documentation without
replacing it with another static schema validator. Preserve the existing render,
drift, and e2e gates, and ensure their descriptions accurately state their separate
responsibilities. This work depends on completing the Kubernetes runtime-pinning
todo, which supplies the reproducible API-server target.
