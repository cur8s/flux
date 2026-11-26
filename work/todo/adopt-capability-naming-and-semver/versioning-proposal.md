<!-- Provenance: the owner's versioning proposal, copied from ~/Downloads/cur8s-versioning-proposal.md on 2026-10-11 and recorded here unedited. -->

# Cur8s Versioning and Release Model

**Status:** Proposed architecture decision  
**Date:** October 11, 2026  
**Scope:** Cur8s capability packages, platform releases, and publication artifacts

## 1. Summary

Cur8s will use **independent Semantic Versioning (SemVer) for each capability package**. A Cur8s package version identifies the Cur8s distribution—not the version of the upstream software included in it. Upstream versions remain explicitly recorded as dependency metadata.

Each capability is independently built, tested, versioned, and published. A separate, versioned Cur8s platform release identifies a tested combination of exact capability versions through a bill of materials (BOM).

Published artifacts must be immutable and **byte-for-byte reproducible** from identical inputs. OCI artifacts are the primary distribution mechanism. Where a component must be installed before its OCI consumer exists—for example, Flux—a static bootstrap manifest can be published alongside the OCI artifact.

This proposal records the options evaluated and why the selected approach supersedes earlier, upstream-derived version schemes.

## 2. Problem and goals

Cur8s assembles and distributes Kubernetes capabilities. A package can include upstream software as well as Cur8s-maintained installation manifests, configuration, integration choices, and operational defaults. These elements can evolve on different schedules.

For example, Cur8s may need to correct its manifests while retaining the same upstream Flux version. Conversely, an upstream release may be adopted without requiring changes to other Cur8s capabilities. A single upstream-derived version cannot express these independent release histories cleanly.

The release model should:

1. Give every published Cur8s package an unambiguous, ordered release identity.
2. Permit a package release even when the bundled upstream version has not changed.
3. Preserve upstream provenance without conflating upstream and Cur8s versions.
4. Allow capabilities to evolve independently.
5. Identify exact, tested collections of capabilities for platform releases.
6. Support immutable, reproducible publication through OCI and any bootstrap distribution channels.

## 3. Options evaluated

The examples below are illustrative, not actual release history.

### Option A — Reuse the upstream version

**Example:** Publish the Cur8s Flux package as `2.7.0` when it contains Flux `2.7.0`.

**Benefit:** The upstream version is immediately visible.

**Problem:** A Cur8s-only change requires a new artifact but has no distinct release number unless Cur8s either replaces an existing release or invents a secondary scheme. Replacing an existing release is incompatible with immutable publication.

**Disposition:** Rejected.

### Option B — Add a fourth numeric component

**Example:** `2.7.0.1`.

**Benefit:** A fourth number appears to represent a Cur8s packaging revision.

**Problem:** Four-part numeric versions do not conform to SemVer's `MAJOR.MINOR.PATCH` structure.

**Disposition:** Rejected.

### Option C — Use SemVer build metadata

**Example:** `2.7.0+r.1`.

**Benefit:** It can encode Cur8s packaging information without changing the apparent upstream version.

**Problems:** SemVer build metadata does **not** affect version precedence; `2.7.0+r.1` and `2.7.0+r.2` have equal precedence. Moreover, the `+` separator cannot be used directly in an OCI tag under the standard tag grammar.

**Disposition:** Rejected as a release-ordering scheme.

### Option D — Append a prerelease-style packaging revision

**Example:** `2.7.0-r.0`, `2.7.0-r.1`, `2.7.1-r.0` (or a Cur8s-labelled suffix such as `2.7.0-cur8s.1`).

**Benefits:** The upstream version remains visible; each Cur8s packaging change gets a distinct version; the values are valid SemVer prerelease strings and can be used as OCI tags.

**Problems:** SemVer treats these as *prereleases* of the corresponding upstream-shaped final version. For example, `2.7.0-r.1` has lower precedence than `2.7.0`. More fundamentally, the scheme makes the Cur8s release identity subordinate to an upstream version, even though Cur8s packages also have their own compatibility and release histories.

**Disposition:** Initially preferred during discussion, then **superseded** by Option E. It is not the adopted policy.

### Option E — Independent SemVer for each Cur8s package

**Example:** A Cur8s GitOps package at `1.4.2` may incorporate Flux `2.7.0`; its next Cur8s release might be `1.4.3` for a packaging correction or `1.5.0` for a compatible feature addition.

**Benefits:** Cur8s can express its own compatibility contract, release packaging fixes independently, and retain upstream versions as separate, queryable provenance. Packages can advance at different rates without creating an artificial correspondence between Cur8s and upstream version numbers.

**Trade-off:** A package version alone no longer reveals the bundled upstream version. Release metadata, manifests, or a BOM must provide that information explicitly.

**Disposition:** **Selected.**

## 4. Decision

### 4.1 Package version identity

Each Cur8s capability has its own independent `MAJOR.MINOR.PATCH` version. That version describes a release of the Cur8s package as a whole: its upstream dependencies, generated resources, Cur8s configuration, and integration behavior.

An upstream software version is **dependency metadata**, not a component of the Cur8s package version.

For illustration:

| Cur8s package version | Included upstream Flux version | Reason for release |
| --- | --- | --- |
| `1.0.0` | `2.7.0` | Initial release |
| `1.0.1` | `2.7.0` | Cur8s manifest correction |
| `1.1.0` | `2.8.0` | Compatible capability update |
| `1.1.1` | `2.8.0` | Cur8s configuration fix |

These are examples of possible version assignments, not a prescribed mapping from Flux releases to Cur8s releases.

### 4.2 Version increment policy

Apply SemVer to the **Cur8s package's compatibility contract**, considering both upstream and Cur8s-owned changes:

- **MAJOR:** An incompatible change to the Cur8s package's documented behavior or interfaces.
- **MINOR:** New backward-compatible functionality or capabilities.
- **PATCH:** Backward-compatible fixes, packaging corrections, or dependency updates that do not introduce new functionality or incompatibility.

An upstream major, minor, or patch designation is a useful signal, but **does not mechanically determine** the Cur8s version increment. The actual effect on the Cur8s package's contract determines the bump. This also allows a Cur8s-only change to trigger any appropriate version increment.

### 4.3 Independent packages and repositories

Capabilities should be independently buildable, testable, versionable, and publishable. Repository boundaries should support that separation rather than enforcing a single repository-wide release number.

Candidate capability boundaries discussed include GitOps/Flux, certificates, secrets, gateway, PostgreSQL, metrics, logging, and Grafana. These are illustrative capability areas; this proposal does not standardize the final names or require a strict one-to-one mapping between Cur8s packages and upstream products.

### 4.4 Separate platform releases

The Cur8s platform has a separate release version. A platform release identifies an **exact, tested combination** of capability package versions in a BOM. A package can release without requiring every other package to increment its version.

Illustrative BOM (schema not finalized):

```yaml
platformVersion: 1.4.0
packages:
  cur8s-gitops: 1.3.2
  cur8s-certificates: 1.1.0
  cur8s-secrets: 1.0.4
  cur8s-gateway: 2.0.1
```

Platform versions and package versions are independent identities. The BOM defines their relationship.

### 4.5 Publication invariants

The publication model must satisfy the following:

1. **Immutable releases:** Once published, a version must not be reassigned to different content.
2. **Byte-for-byte reproducibility:** Identical publisher inputs must produce identical artifact bytes, not merely semantically equivalent Kubernetes resources.
3. **Exact references:** Consumers use explicit package versions; release processes resolve those versions to immutable content.
4. **Consistent representations:** When the same generated installation manifest is offered through multiple channels, publication reuses those bytes rather than regenerating the content independently for each channel.

Reproducibility is a requirement for all publishers, not only the Flux publisher. Build and publication procedures must therefore control nondeterministic inputs such as timestamps, ordering, generated identifiers, and archive metadata wherever they affect the published bytes.

OCI is the primary distribution mechanism for Cur8s packages. GitHub Actions was the chosen publication mechanism in the discussions.

## 5. Flux as the bootstrap example

Flux highlights an important distinction between **bootstrapping a controller** and **configuring it to manage itself**.

### 5.1 Bootstrap artifact

A static, published manifest installs the minimal controllers needed to begin OCI-based reconciliation. The Flux controller installation manifest is generated once and used as the published installation content. It can be exposed both as an OCI artifact and as a YAML release asset, with the latter supporting a simple initial `kubectl apply -f <URL>` workflow.

The bootstrap URL and exact resource layout are implementation details to be defined in the Flux package; this proposal does not assign an unverified URL.

### 5.2 Self-management resources

The consuming cluster repository defines its own Flux `OCIRepository` and `Kustomization` resources to select and reconcile the desired Cur8s GitOps package. These cluster-specific resources live with the consumer rather than being embedded in the reusable Cur8s artifact.

Bootstrap and self-management remain **separate files or application steps**. This separation supports Kubernetes CRD ordering and lets different consuming repositories choose different bootstrap or self-management configurations while consuming the same published package.

Once Flux is installed, it reconciles the declared package version through the OCI-based path.

## 6. Consequences

**Advantages**

- A Cur8s packaging fix does not need an upstream release to receive its own version.
- Upstream updates and Cur8s changes share one understandable compatibility-oriented versioning policy.
- Capability teams and repositories can release independently.
- Platform releases remain reproducible through an exact BOM rather than a globally shared version number.
- Bootstrap can be simple while ongoing management remains declarative and cluster-specific.

**Costs and obligations**

- Upstream provenance must be surfaced explicitly; it cannot be inferred from the Cur8s version string.
- Each package needs a documented compatibility contract so version increments are meaningful.
- The platform BOM and published artifact metadata must be maintained and validated.
- Publisher implementations need deterministic generation and verification tests.

## 7. Open implementation details

The architectural direction above is settled, but the conversations did not finalize every implementation detail. The following should be decided in follow-on work rather than silently treated as agreed:

- The exact schema and location of upstream dependency/version metadata.
- The canonical format, schema, and repository location of the platform BOM.
- The complete release/tag naming convention, OCI repository layout, and digest handling.
- The concrete reproducibility test procedure and which artifact layers or envelopes it verifies.
- Artifact signing, provenance attestations, retention, and recovery policy.
- The detailed upgrade and rollback workflow.
- The precise resource set and build commands used by the minimal Flux bootstrap artifact.

## 8. Decision record

**Adopt independent SemVer per Cur8s capability package; track upstream versions separately; publish immutable, byte-for-byte reproducible artifacts; and version tested platform combinations independently using an exact BOM.**

This decision **replaces** the previously considered upstream-derived `2.7.0-r.N` scheme. That earlier scheme remains documented above as a considered alternative, not as active release policy.
