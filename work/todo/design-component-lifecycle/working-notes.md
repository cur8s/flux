# Lifecycle working notes

## Selected scope and owner decision

The owner agreed the repository layout and requested implementation, documentation, and todo
updates. This is an implemented subset of the broader lifecycle design, which remains open.

| Path | Ownership and role | Git treatment |
| --- | --- | --- |
| `upstream/flux.yaml` | Captured upstream input, preserved by build clean. | Committed. |
| `src/config/` | Authored overlays and current self-management configuration. | Committed. |
| `artifacts/rendered/` | Regenerated controller installation, release descriptor, and copied sync file. | Committed for review. |
| `artifacts/oci/` | Future locally packaged OCI output. | Ignored; packaging is not implemented. |

The repository produces one package, so repeating `flux` in local component directories adds no
boundary. All generated output has one disposable parent, `artifacts/`. Captured upstream output
is an input to rendering and stays outside that tree. Orientation is authored in upstream, src,
and tooling READMEs and in [the pipeline explanation](../../../docs/architecture/01-source-to-artifact.md),
not in generated output.

## Alternatives considered

- Keeping top-level `oci/` alongside another output directory was rejected: output has one parent.
- `payload/` and `dist/` were rejected in favor of `artifacts/rendered/` and reserved `artifacts/oci/`.
- The original component nesting was redundant for this single-package repository.
- The [six-phase candidate](candidate-six-phases.md) and unedited owner proposals remain design
  history; their old path examples do not override this later layout decision.

## Implemented boundary and remaining work

Task paths, Kustomize input traversal, Git ignore rules, agent generation rules, current docs, and
active plans follow the new layout. Registry component identity remains `flux`, reconciliation
still selects `./deploy`, and the package still ships the current sync file. `oci:publish` still
packages at push time; no local packaging task has been added.

Local OCI packaging and reproducibility, promoting the tested digest, provenance records, owned
images, consumer ownership of sync, independent package SemVer, and the broader release safeguards
remain unfinished. The [requirements](requirements.md) and [implementation planning](../plan-lifecycle-implementation/overview.md)
retain those inputs. The mechanical mise conventions review and documentation rebuild also remain open.

## Verification

- All 17 task scripts pass `bash -n`; `git diff --check` passes.
- Whole-tree clean removes rendered output and disposable probes, including one under the future
  OCI directory; captured input, its README, and every authored source file retain their hashes.
- Clean plus render regenerates exactly the same three rendered files with identical SHA-256
  hashes. Fresh upstream capture also preserves the captured bytes and orientation README.
- The installation and descriptor remain byte-identical to the old layout. The copied sync file
  differs only in its local-path comment; the resource still selects `./deploy`.
- Current local Markdown links and anchors pass checks, with no work-reference boundary violation.
- `artifacts/oci/` is ignored and rendered files remain eligible for Git review. No local OCI
  directory is created by rendering.
- `test:run` completes fresh capture and render, then refuses the uncommitted new upstream and
  rendered paths as expected. It does not reach its cluster test. This implementation does not
  commit to bypass that restriction, run an end-to-end cluster test, or publish remotely.
