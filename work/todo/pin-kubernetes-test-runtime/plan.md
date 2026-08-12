# Plan: Pin the Kubernetes runtime and validation schemas

## Context

### Outcome

The package has one explicit Kubernetes compatibility target: the current GA N-1
minor, Kubernetes `1.35`. End-to-end tests run the generated Flux installation on an
explicitly pinned k3s image from that minor line. The repository documents what
“supported” means, why the target is compatible with the pinned Flux release, and
how all of the pins advance.

The Kubernetes API server in the pinned e2e cluster is the semantic validation gate
for the Flux CLI-generated manifests. This work changes repository automation and
documentation only. It does not add code to Flux, modify Flux-generated YAML, or
expand the package’s supported controller surface.

### Approach

The N-1 target is a Cur8s policy, not an inferred Flux capability. For the currently
pinned Flux `v2.9.0`, upstream documents support for Kubernetes `1.34`, `1.35`, and
`1.36`; `1.35` is therefore an appropriate single package target. Flux does not
publish a stable machine-readable compatibility-range interface that this repository
should scrape or parse. `flux check --pre` should remain a runtime preflight against
the actual e2e cluster, but it is not the source of the package compatibility policy.

Retain the explicit `kubectl 1.36.2` pin for now. Kubernetes supports kubectl within
one minor version of the API server, so it is supported with a Kubernetes `1.35`
runtime. Treat this as a checked skew policy, not an open-ended promise that newer
kubectl will always work: before changing either minor, verify their distance remains
at most one.

Do not add a replacement static validator for `deploy/flux.yaml`. Its substantive
content comes from the pinned Flux CLI; Cur8s cannot hand-correct a schema failure
without forking or changing the selected Flux release. The pinned API server and
controller-readiness checks exercise the actual install, including the authored
`sync.yaml`, and provide the actionable compatibility result. Removing kubeconform
is deliberately separate work so this plan can establish the runtime contract first.
The full k3s image remains a separately pinned current patch release within `1.35`;
the e2e assertion checks the server minor.

When either the Flux or Kubernetes minor advances, select the new current Kubernetes
GA N-1 target, confirm it lies in the pinned Flux release’s documented support range,
update the exact k3s image, verify the kubectl skew, and run all release gates. Record
the resulting supported target in the user guide rather than duplicating an upstream
support matrix.

## Phases

### Phase 1: Define and assert the compatibility contract

Make the single-target policy an executable repository fact without claiming that a
single e2e run proves support for every Kubernetes distribution or every patch.

- [ ] Set a single Kubernetes `1.35` minor source of truth in the pinned task
  configuration, and derive the k3s image selection from it without changing
  `version.env`’s Flux-version ownership.
- [ ] Choose and pin an exact supported `rancher/k3s` image for Kubernetes `1.35`;
  pass that image explicitly to k3d rather than accepting k3d’s changing default.
- [ ] Add a cluster-creation or e2e assertion that the API server reports the expected
  Kubernetes minor, and run `flux check --pre` against that cluster before bootstrapping.
- [ ] Keep `kubectl 1.36.2` unless the skew check requires a change, and make the
  one-minor client/server skew rule visible beside its pin.

### Phase 2: Keep pins and tests coherent

Make the build, drift test, and k3d lifecycle enforce the same contract while keeping
the normal artifact workflow intact.

- [ ] Update task descriptions, configuration comments, and dependency handling to
  name the Kubernetes minor, exact k3s runtime, and supported kubectl skew accurately.
- [ ] Run `mise run artifact:build`, `mise run test:drift`, `mise run test:e2e`, and
  `git diff --check`; confirm the e2e cluster reports Kubernetes `1.35`, passes Flux
  preflight, and reaches the existing self-management readiness contract.

### Phase 3: Document the maintained boundary

Describe the package’s real compatibility and validation behavior for operators and
contributors without turning documentation into a second copy of Flux’s support table.

- [ ] Update the user guide with the Kubernetes `1.35` supported/tested target,
  explain that its compatibility is checked against the pinned Flux release’s upstream
  support statement, and link operators to upstream for the full current range.
- [ ] Update the architecture document to describe the pinned k3s runtime and the e2e
  API-server acceptance and readiness checks as the compatibility gate.
- [ ] Update CONTRIBUTING with the pin-advance procedure: select GA N-1, verify the
  Flux range and kubectl skew, update the k3s image, then run both gates.
