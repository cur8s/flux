---
title: "Rebuild the docs as product, architecture, how-to, and standards"
summary: "Replace the three flat documents in docs/ with numbered product, architecture, how-to, and standards directories, written one reviewed file at a time from the collected sources."
---

# Rebuild the docs as product, architecture, how-to, and standards

**Agreed with the owner:**

- `docs/` adopts four category directories — `product/`, `architecture/`, `how-to/`, and
  `standards/` — modeled on the documentation strategy used in the sales-agent repository:
  two-digit prefixes for reading order, a short purpose callout opening each document, and one
  authoritative home per subject.
- There is no domain model, interaction model, or walkthrough to write for this package; add one
  only if the material later calls for it.
- `product/` is where the philosophy of pre-rendered manifests is captured — rendering before
  the cluster, never inside it.
- Every new document is drafted from the [sources](sources/README.md), reviewed by the owner until
  agreed, and committed on its own. The owner builds the documentation up systematically, one file
  at a time.
- Sources are collected in this todo: copies of flux's current `docs/` and the monorepo's `docs/`
  only. `CONTRIBUTING.md` is separate and out of scope.

**Defaults proposed, not yet objected to:**

- Flux's current docs are copied, not moved. Each original is deleted in the commit whose new
  document replaces it, with its incoming references repaired in that commit, so live docs never
  have a gap or two competing homes.
- The `docs/README.md` strategy document is written first, short and adapted, and refined at the
  end.
- The `product/` file list is revisited once the vision is agreed.
