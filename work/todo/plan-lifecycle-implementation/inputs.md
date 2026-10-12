# Inputs folded into implementation planning

These were separate work notes until they were folded into this todo, so that planning starts
from one place without losing their content. Each section keeps the note's summary and body as
written; the originals are in Git history before the commit that folded them in. Links inside
them may point at notes that no longer exist; treat them as historical.

**Current path translation:** the original input bodies below are preserved as history. The
implemented layout now captures input in `upstream/flux.yaml`, authors config in `src/config/`,
and reviews rendered output in `artifacts/rendered/`. Old `oci/` review references mean that
rendered tree; future local OCI packaging belongs in ignored `artifacts/oci/`. Use the current
`test:run` for the combined drift and cluster gate. This layout change completes none of the
remaining input requirements below.

## Kubernetes test runtime pinning

Formerly `pin-kubernetes-test-runtime`. Test the Cur8s Kubernetes N-1 target on its latest patch, selected once for both k3s and kubectl.

The e2e gate is now the semantic compatibility gate for the Flux CLI-generated installation: it
applies the rendered manifest to a Kubernetes API server and proves the controllers and
self-management resources become Ready. k3d currently chooses its own default k3s image, so the
Kubernetes version tested can change when k3d changes without a reviewed repository change.

Cur8s tests the current Kubernetes GA N-1 minor. With Kubernetes `1.36` current, the immediate
e2e target is Kubernetes `1.35`. Flux owns the compatibility contract: Flux `v2.9.0` supports
Kubernetes `1.34` through `1.36`, and this package is expected to work throughout that upstream
range. The one test target is coverage, not a narrower Cur8s support claim. Its runtime contract is
the latest GA patch in that minor, rather than a fixed container digest. One exact
`KUBERNETES_VERSION` value selects the reviewed k3s image tag and the same `kubectl` release;
maintainers advance it when a new GA patch is published.

The image tag contains a k3s packaging suffix (`k3s1` today), but it does not introduce another
Kubernetes version setting. Then pass the derived image to k3d, assert the created API server and
client report the selected version, run Flux preflight against it, and document both the e2e target
and Flux's supported Kubernetes range. How the version is authored in `mise.toml` and whether
the `kubectl` pin may be derived from it by template follow the conventions settled by
[`standardize-mise-and-task-scripts`](../standardize-mise-and-task-scripts/overview.md). Kubeconform and its static schema target were intentionally
removed in `46bc99c`; this todo does not replace that validator or modify Flux-generated YAML.

Its detailed plan, with the agreed pinning decisions, is preserved in
[pin-kubernetes-test-runtime-plan.md](pin-kubernetes-test-runtime-plan.md).

## Flux patch bump

Formerly `bump-flux-to-latest-patch`. Advance the tracked upstream from v2.9.0 to the newest v2.9.x release (v2.9.6 when last checked).

`upstream:check` reported Flux `v2.9.6` against the tracked `v2.9.0` on 2026-10-11. Re-check the
latest 2.9.x patch when starting, then update `FLUX_VERSION` in `mise.toml`, refresh `mise.lock`
for all four platforms, re-render, review the `oci/` diff, and run the drift and e2e gates.
`CUR8S_FLUX_REVISION` stays `1`. Independent of the lifecycle work, unless the owner's
versioning proposal (independent SemVer per package) is adopted first, in which case the bump
also assigns a new Cur8s package version.

## Production bootstrap path

Formerly `complete-production-bootstrap`. Give standalone operators a complete, reproducible path from install.yaml to OCI-backed Flux self-management.

The user guide provides the initial `install.yaml` command, then tells operators to create an
`OCIRepository` and apply the package's `sync.yaml`. The complete production resources and a direct
way to obtain the sync manifest are not provided; the only executable example is embedded in the
local k3d task and targets an insecure development registry.

Provide a production-safe, copy-and-paste path for the versioned `OCIRepository` and self-management
`Kustomization`. Decide whether the source of truth should remain a documented example or become a
version-specific release asset generated from authored configuration. Document package tag syntax,
public and authenticated registry behavior, ordering after controller bootstrap, readiness checks,
upgrade selection, and recovery without duplicating manifests that can drift.

The owner's Flux bootstrap proposal, in the lifecycle design todo, decides that the consuming
repository owns the `OCIRepository` and `Kustomization`, so `sync.yaml` leaves the package; what
remains here is the copy-and-paste example for operators.

## Notification Receiver contract

Formerly `clarify-notification-receiver-contract`. Resolve the mismatch between informational-only notification guidance and the installed Receiver webhook surface.

The user guide says Notification Controller reports events without influencing reconciliation, but
the rendered installation includes the `Receiver` CRD and the `webhook-receiver` Service. A Receiver
accepts external events and can request reconciliation, so the installed surface is broader than the
documented informational-only model.

Decide whether `Receiver` should remain installed but explicitly outside the package's recommended
contract, or whether the receiver CRD, Service, and related controller behavior should be removed or
disabled. Prefer a narrow documentation correction if the upstream controller surface cannot be
safely reduced. If the rendered surface changes, update component verification to enforce the
chosen contract. The owner's Flux bootstrap proposal treats only source-controller and
kustomize-controller as essential and leaves notification-controller to the package definition,
which the lifecycle design todo settles.

## Upgrade and recovery testing

Formerly `test-upgrades-and-recovery`. Extend end-to-end coverage from fresh bootstrap to self-managed upgrades, repeat application, and defined recovery behavior.

The current end-to-end test proves a fresh cluster can bootstrap Flux and hand control to the OCI
artifact, but it does not exercise an already self-managed installation moving between component
versions. That transition is where controller, CRD, and reconciliation compatibility problems are
most likely to appear.

Add coverage for reapplying the same version, a Cur8s configuration-revision upgrade, an upstream
Flux upgrade, and recovery from a candidate that cannot become Ready. First decide whether rollback
to an earlier immutable artifact is supported or whether recovery requires advancing to a corrected
version. Also decide whether the baseline should be a published release or a second locally built
fixture, and which lifecycle cases belong in required CI versus a slower scheduled test.

## Licensing and security policy

Formerly `define-licensing-and-security-policy`. Choose an explicit project license and establish a vulnerability-reporting path before distributing the package for external use.

The repository currently has neither a `LICENSE` file nor a `SECURITY.md`. Public repository access
does not itself grant permission to use, modify, or redistribute the source or its OCI artifact.

Choose the license explicitly; do not infer one from adjacent Cur8s repositories. Record it in the
repository and confirm that its terms cover source, generated manifests, and OCI distribution.
Define a private vulnerability-reporting path, the information reporters should include, and any
supported-version or disclosure expectations that the project is prepared to maintain.

## Automated upstream update proposals

Formerly the idea `automate-upstream-update-proposals`. Detect new Flux releases and prepare reviewable update proposals without automatically selecting, merging, or publishing a version.

`upstream:check` currently reports that a newer Flux release exists and leaves the update entirely
manual. A scheduled workflow could reduce maintenance effort by preparing the mechanical part of
an update while preserving the rule that version advancement is an explicit reviewed decision.

Explore a workflow that updates `FLUX_VERSION` in `mise.toml`, regenerates the fetched source and OCI
review surface, runs policy, drift, and end-to-end checks, and opens a proposal containing relevant
upstream release information. It must never merge, tag, or publish automatically. Determine how to
authenticate automated proposals safely, how to handle a newer release while a proposal is already
open, and whether upstream release notes provide enough compatibility information to summarize
without adding another source of truth. Whether Renovate can read the version pins depends on
the templated-pin decision in
[`standardize-mise-and-task-scripts`](../../todo/standardize-mise-and-task-scripts/overview.md).
