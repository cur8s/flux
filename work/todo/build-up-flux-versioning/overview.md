---
title: "Build up Flux package versions"
summary: "Make version.env the single authored source for upstream Flux and cur8s revision values, then construct every package and release version from those inputs."
---

# Build up Flux package versions

Replace the combined root `VERSION` value and the separate literal Flux CLI pin with one
release-unit-owned `version.env`:

```dotenv
FLUX_VERSION=2.9.0
CUR8S_FLUX_REVISION=1
```

Mise loads the file through `[env] _.file`, while shared shell code can source the same file.
Version facts are built rather than decomposed: `FLUX_TAG` is `v2.9.0`, and
`CUR8S_FLUX_VERSION` is `v2.9.0` for revision 1 or `v2.9.0-2` for revision 2. The file contains
simple `KEY=value` assignments so it remains compatible with both mise's dotenv loader and shell
sourcing.

Version ownership follows the independently released package. This repository has one release
unit, so `version.env` belongs at its root; a multi-package repository would keep one equivalent
file at each independently versioned package root.
