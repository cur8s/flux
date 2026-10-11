# Plan: Pin the Kubernetes test runtime

## Context

### Outcome

`test:e2e` always creates a Kubernetes `1.35` cluster from the current GA patch in
that minor. One exact `KUBERNETES_VERSION` value selects both the k3s image tag and
the same kubectl release. The test confirms that the client and API server it actually
created report that value before it applies the generated Flux manifest, then runs
Flux’s preflight and the existing controller and self-management readiness checks.

The runtime version is an explicit Cur8s e2e coverage target, not a changing side
effect of the k3d release or a narrower Kubernetes compatibility contract. Flux owns
the compatibility contract: the package is expected to work with every Kubernetes
version supported by the pinned Flux release. The target can advance only through a
deliberate review that selects the then-current Kubernetes GA N-1 minor, verifies the
pinned Flux release’s supported range, selects the newest stable patch in that minor,
and changes the single version input and documentation together. The configuration
does not discover new patches at runtime: advancing to a newly published patch is a
reviewed repository change.

This work does not change the Flux CLI-generated `deploy/flux.yaml` or add a static
schema validator. It makes one runtime test target explicit; it does not claim that a
single k3s e2e run proves every Kubernetes distribution and patch, nor does it narrow
Flux's upstream compatibility range.

### Current facts and constraints

- The current Kubernetes GA is `1.36`; Cur8s policy selects GA N-1, so the immediate
  target is Kubernetes `1.35`.
- Flux `v2.9.0` documents support for Kubernetes `1.34`, `1.35`, and `1.36`. Flux
  owns this compatibility range; the selected e2e target is one version within it.
- The repository pins k3d `5.9.0` but does not pass an image to it. Its default image
  is an implementation detail of that k3d release and may change when k3d advances.
- The repository pins kubectl `1.36.2`; the agreed policy changes it to exactly the
  selected `KUBERNETES_VERSION`, rather than relying on Kubernetes' one-minor client
  skew allowance.
- The runtime must work on contributor Apple Silicon machines and GitHub Actions
  Linux x86_64 runners. The selected `rancher/k3s` release tag must be published for
  both architectures.

### Pinning decision

The repository has one Kubernetes *test-version* authority:

1. `KUBERNETES_VERSION`: the newest reviewed GA patch in the Cur8s-tested N-1 minor
   (`1.35.6` in the example below).

The version is deliberately exact rather than `1.35`: Kubernetes tools and k3s image
tags use patch releases, and neither project provides a maintained `v1.35` image tag
that follows the latest stable patch. A k3s image includes its packaging suffix
(`k3s1` today), but the image tag is derived from `KUBERNETES_VERSION`; it is not a
second Kubernetes-version input. The e2e assertions prevent the configured image or
client from silently diverging from that value.

| Option | Example | Benefits | Costs and risks | Decision |
| --- | --- | --- | --- | --- |
| Let k3d choose its default | no image option | No configuration to maintain | The Kubernetes runtime changes with k3d; a review cannot identify what e2e tested | Reject |
| Exact k3s patch tag as a separate value | `K3S_IMAGE = "rancher/k3s:v1.35.6-k3s1"` | Clear image input | Duplicates the Kubernetes patch that kubectl must also use | Reject |
| Digest-only image | `rancher/k3s@sha256:<index>` | Immutable and multi-architecture when the digest is an OCI index | Fixes the runtime to one patch and obscures the intended release; conflicts with the rolling latest-patch contract | Reject |
| Tag plus manifest-list digest | `rancher/k3s:v1.35.6-k3s1@sha256:<index>` | Human-readable release intent plus immutable image content | Also fixes the runtime to one patch and requires a digest update for every patch; conflicts with the rolling latest-patch contract | Reject |
| Derive the k3s tag and kubectl version from one exact patch | `KUBERNETES_VERSION = "1.35.6"` | One Kubernetes-version authority; client and server target the same patch; an upgrade is a small reviewed change | A maintainer must advance it when a new GA patch is published; image tags do not offer digest-level content immutability | **Recommend** |
| Pre-pull a tag and pass a local image ID | local Docker image ID | Can prove the local daemon’s content | Not portable across hosts and architectures; hides the reviewed registry input | Reject |
| Vendor or mirror the image in this repository | image archive or internal registry | Can support an air-gapped runtime | Large operational scope that this package does not own; does not remove the need to pin an upstream image | Out of scope |

### Recommended representation

Put the one authored version input and its derived image tag in `mise.toml`’s `[env]`
section, beside the other task inputs:

```toml
# Cur8s tests the latest GA patch of this N-1 minor. Advance this value when a new
# GA patch is published and it is within the pinned Flux release's support range.
KUBERNETES_VERSION = "1.35.6"
# `k3s1` is the current k3s packaging revision, not a second Kubernetes version.
K3S_IMAGE = "rancher/k3s:v{{ env.KUBERNETES_VERSION }}-k3s1"
```

The `kubectl` tool pin must use the same value:

```toml
[tools]
kubectl = "{{ env.KUBERNETES_VERSION }}"
```

`cluster:create` should pass `--image "$K3S_IMAGE"` to k3d. Keep
`.mise/k3d-config.yaml` for topology and k3s settings rather than placing a second
image value there. This gives every cluster task the same mise-provided input and
keeps the Kubernetes target alongside the k3d and kubectl tool pins.

Before relying on the representation, prove the pinned k3d version accepts the
derived tag and creates a cluster on both the local ARM64 environment and CI’s AMD64
environment. The release tag is an upstream reference rather than a content digest;
that is an intentional consequence of the rolling latest-patch contract. The advance
procedure must verify that the selected stable tag is available for both architectures.

The exact patch in the example is a placeholder for the latest stable Kubernetes
`1.35` k3s release verified when implementation begins. Selecting a new patch is an
implementation action, not an unreviewed background update.

## Phases

### Phase 1: Confirm the runtime-pin decision

The rolling, latest-patch representation is agreed before changing automation or
durable documentation.

- [x] Approve `KUBERNETES_VERSION` as the one Kubernetes version authority for both
  k3s and kubectl.
- [x] Approve an exact, non-digest k3s release tag derived from that value: Cur8s
  maintains the latest GA patch in the selected minor rather than content-pinning a
  patch with an image digest.
- [x] Confirm that e2e covers one Kubernetes N-1 minor at a time. This is explicit
  test coverage, not a claim that the package is incompatible with other Kubernetes
  versions supported by the pinned Flux release.

### Phase 2: Select and wire the exact runtime

Resolve the newest stable k3s patch in the approved Kubernetes minor and make the
derived tag the only k3d image input.

- [ ] Verify the selected Kubernetes minor is GA N-1 and lies within the pinned Flux
  release’s documented support range; identify the newest stable patch in that minor
  and confirm its k3s tag exists for linux/arm64 and linux/amd64.
- [ ] Add `KUBERNETES_VERSION` and the derived `K3S_IMAGE` to `mise.toml`; set
  `kubectl = "{{ env.KUBERNETES_VERSION }}"`; pass `K3S_IMAGE` explicitly to
  `k3d cluster create` without adding a competing image field to the k3d
  configuration file.
- [ ] Test the derived tag with the pinned k3d version on the local architecture and
  in CI. Record the update rule: advance `KUBERNETES_VERSION` to every new GA patch,
  and review the `k3s1` packaging suffix if the upstream release uses another value.

### Phase 3: Assert the actual runtime and run the Flux gate

Make a wrong, ignored, or substituted image reference fail close to cluster creation.

- [ ] After the API is ready, query `kubectl version -o json` and fail unless the
  client is `v$KUBERNETES_VERSION` and the server GitVersion begins with
  `v$KUBERNETES_VERSION` (allowing k3s' `+k3s…` suffix); print both versions for
  diagnostics.
- [ ] Run `flux check --pre` against the just-created e2e cluster before bootstrapping
  Flux. Treat it as a live prerequisite check, not a machine-readable Flux
  compatibility-range source.
- [ ] Preserve the existing API-server apply, controller availability, artifact fetch,
  self-management readiness, failure-preservation, and successful-cleanup behavior.
- [ ] Run `mise run artifact:build`, `mise run test:drift`, `mise run test:e2e`, and
  `git diff --check` on the resulting change.

### Phase 4: Record the maintained contract

After the implementation decision is proven, update durable documentation to match
the behavior rather than duplicating this temporary decision analysis.

- [ ] Update the user guide to distinguish the Cur8s e2e target from Flux's
  compatibility contract: state the tested Kubernetes minor and link to, or state,
  the Kubernetes range supported by the pinned Flux version.
- [ ] Update architecture documentation to identify the explicit k3s image pin,
  API-server e2e validation boundary, and Flux as the owner of the compatibility
  range.
- [ ] Update CONTRIBUTING with the advance procedure: select GA N-1, confirm Flux
  support, choose the newest stable k3s patch and packaging suffix, update the one
  `KUBERNETES_VERSION` input, verify its tag is multi-architecture, and run the two
  gates.
