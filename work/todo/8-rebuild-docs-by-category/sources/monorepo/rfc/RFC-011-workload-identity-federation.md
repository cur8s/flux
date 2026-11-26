## RFC-011: Workload Identity Federation

**Status:** Accepted

Accessing external systems is a common requirement for workloads running in a 
Kubernetes cluster. A typical example is a service that needs to read from or 
write to an object storage bucket, such as S3.

A common first instinct is to inject credentials into the cluster as secrets. 
Very quickly, this exposes a broader problem: *how are those credentials created
in the first place?* Are they provisioned using Terraform, CloudFormation, the
AWS console, or the AWS CLI? Who runs that process, and when? How are 
credentials scoped per environment? How are they rotated? What happens when a 
credential is leaked or a workload is redeployed? Operating a Kubernetes 
workload then requires understanding and coordinating multiple tools, scripts,
and workflows that live outside Kubernetes entirely.

This is the kind of complexity Cur8s explicitly tries to avoid. As described 
in the *[Why essays](../why/README.md)*, Cur8s aims to reduce the number of 
mental models required to operate a system. When access to external systems is
mediated primarily through static secrets, operators are forced to reason about
cloud IAM, secret provisioning pipelines, and rotation policies in parallel with
Kubernetes itself—effectively “renting” additional operational knowledge just to
make a workload function.

Cur8s addresses this by treating **workload identity** as the primary mechanism
for external access. Rather than proving access through possession of secret 
material, workloads authenticate by **who they are**. In Cur8s, a workload 
proves **who it is**, not **what secret it possesses**. This RFC defines 
**workload identity federation** as the preferred model for accessing external
systems.

## Core Rule

**Workloads should authenticate using identity, not static credentials.  
Federated workload identity is the default integration model.  
Secret material is a fallback, not a baseline.**

This rule aligns with Cur8s’ broader constraints:

- Environment-specific inputs are supplied externally ([RFC-009: Environment-Specific Inputs](RFC-009-environment-specific-inputs.md)).
- Readiness and convergence are handled declaratively ([RFC-010: Declarative Readiness](RFC-010-declarative-readiness.md)).
- Declarative intent remains external and auditable ([RFC-004: Declarative Cluster Control](RFC-004-declarative-cluster-control.md)).

## Workload Identity Federation, Explained by Example

Workload identity federation is a powerful pattern for accessing external 
systems without distributing credentials. It is less familiar than secret-based 
approaches, but it addresses a class of operational and security problems that
static credentials cannot. This section introduces the model at a conceptual 
level to clarify how Cur8s uses it and why it is central to the platform’s design.

Consider a concrete example: a PostgreSQL database managed by **CloudNativePG** 
that needs to write backups and WAL archives to an S3 bucket.

From CloudNativePG’s perspective, the interaction works as follows:

- CloudNativePG runs the database and its backup jobs under a Kubernetes 
  ServiceAccount associated with the database cluster.
- Kubernetes issues a signed JWT for that ServiceAccount at runtime.
- When CloudNativePG attempts to write backups to S3, the AWS SDK uses that JWT to request access.
- AWS IAM validates the ServiceAccount identity and its associated role mapping.
- AWS issues short-lived, scoped credentials dynamically.
- Those credentials expire automatically and are never stored in the cluster.

At no point are long-lived AWS access keys created, distributed, or mounted 
into the database pods.

In practice, CloudNativePG allows you to specify the ServiceAccount identity it
should use. On AWS, this is commonly done by annotating the ServiceAccount with
an IAM role via IRSA. For example:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: my-db
spec:
  serviceAccountTemplate:
    metadata:
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>
```

This snippet does not configure credentials. It declares **identity**. Once this
wiring is in place, CloudNativePG can access S3 without embedding secrets and 
without any custom application code. The operator and underlying SDKs handle the
credential exchange transparently.

The important point is not the specific protocol, but the shape of the interaction:  
the workload proves **who it is**, an external identity provider (such as AWS IAM)
decides **what it is allowed to do**, and credentials are issued
**just in time** and **expire automatically**.

This pattern is not unique to Kubernetes or AWS. Variations of workload identity
federation exist across cloud providers, service meshes, and modern 
infrastructure platforms. Cur8s deliberately aligns with this broader industry
direction rather than inventing a bespoke secret-distribution model.

## Configuring Workload Identity Federation

Cur8s does not define or abstract the mechanics of workload identity federation.
Federation is configured **according to the rules of the system being 
federated**, and Cur8s intentionally relies on those native mechanisms rather
than introducing its own layer of indirection.

For example, when running on AWS, workload identity federation is commonly 
configured using **IAM Roles for Service Accounts (IRSA)** (see the AWS 
documentation on *[IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)*).
This involves establishing trust between the Kubernetes cluster and AWS IAM, 
defining which Kubernetes `ServiceAccount` identities are allowed to assume 
which IAM roles, and granting those roles appropriately scoped permissions.

This configuration is not trivial, and Cur8s does not pretend otherwise. 
However, this investment aligns directly with the philosophy described in 
the *[Why essays](../why/README.md)*. Rather than accumulating ad-hoc scripts,
pipelines, and secret-handling workflows, Cur8s favors learning a small number
of durable, foundational concepts that compound over time.

Workload identity federation is one of those concepts. It is harder upfront 
than injecting access keys, but it eliminates entire classes of ongoing 
operational work: secret provisioning, rotation pipelines, credential leaks, 
and environment-specific glue code. The effort to understand and configure 
federation pays dividends every time a new workload is deployed or an existing
one is replaced.

Cur8s treats workload identity federation as **environment setup**, not 
platform behavior. Operators are expected to configure federation explicitly 
using the documentation and tooling of the external system. Cur8s’ 
responsibility begins once federation is in place; from that point on, 
workloads interact with external systems through identity, and Cur8s does 
not manage long-lived credentials inside the cluster.

## When Federation Is Not Available

Cur8s acknowledges that workload identity federation is not always possible.

Some external systems do not support federated identity or operate in 
environments where federation cannot be established. In these cases, secret
material may still be required.

However, these cases are treated as **exceptions**, not as the default model. 
The handling of secret material in such scenarios is defined separately in 
a follow-up RFC.

## Forbidden Patterns

Cur8s explicitly forbids:

- treating static credentials as the default integration mechanism
- embedding long-lived credentials in platform artifacts or manifests
- coupling workload access to manually distributed secrets when federation is available
- designs that require identity to be inferred from cluster state rather than declared

Any approach that elevates secret material over identity as the primary access
mechanism violates this RFC.

## Scope

This RFC defines **Cur8s’ workload identity and trust model**.

It does not define specific cloud providers, federation protocols, or 
implementation details. It also does not define how secret material is 
delivered when workload identity federation is not possible. Those concerns are
addressed in subsequent RFCs and implementation documentation.

## Revisions

Initial version.
