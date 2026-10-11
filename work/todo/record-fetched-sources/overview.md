---
title: "Record fetched sources"
summary: "Make the fetch phase write a committed record of every upstream input it downloaded — including the container images the manifests run — with digests, as a standard in every component repository."
---

# Record fetched sources

Traceability is a Cur8s requirement: for any version it must be clear exactly what was downloaded
from upstream. The previous `FETCH.lock` was removed in `2575527` because, for Flux alone, its
fields repeated the tool pin and git. As a cross-repository convention the record earns its place
anyway: cert-manager and later components download Helm charts and release files from remote
registries, where a digest is the only evidence the input did not change.

Define one small, uniform record written by `fetch` (name and format to decide; the old
`src/<component>/artifacts/FETCH.lock` is a reasonable default) that lists each input's source,
version, and digest. For Flux that is the pinned CLI version and the generated manifest's digest.

Include the container images referenced by the rendered manifests, each with its upstream digest.
This answers "what will this version run?" and is the input list for
[`mirror-images-to-ghcr`](../mirror-images-to-ghcr/overview.md). Decide which tool resolves
digests (for example `crane digest`) and pin it following the tool-pinning convention from
[`standardize-mise-and-task-scripts`](../standardize-mise-and-task-scripts/overview.md).

`check` must fail if the committed record differs from a fresh fetch. Keep the release descriptor
(`cur8s.yaml`) and the record from duplicating each other: the descriptor states identity, the
record states provenance.

Depends on [`adopt-lifecycle-phases`](../adopt-lifecycle-phases/overview.md) for the `fetch` and
`check` phase names.
