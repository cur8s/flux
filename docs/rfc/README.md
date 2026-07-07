# RFCs — the flux package's own contracts

Org-wide law — the platform architecture, the engine choice, component
versioning, the release model — lives in the flagship:
[cur8s/cur8s `docs/rfc/`](https://github.com/cur8s/cur8s/tree/main/docs/rfc).
This repository keeps only the contracts that are genuinely its own:

- [RFC-001: The Opinionated Flux Configuration](RFC-001-opinionated-flux-configuration.md)
  — exactly what this package installs, and the API surface it commits to.
- [RFC-002: The Flux Bootstrap Contract](RFC-002-flux-bootstrap-contract.md)
  — how the engine comes up on a bare cluster and self-manages thereafter.

RFC IDs are repo-scoped; references to another repo's RFCs always name
the repo.
