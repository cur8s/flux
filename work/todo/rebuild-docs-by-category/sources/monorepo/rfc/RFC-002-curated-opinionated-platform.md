# RFC-002: Curated Opinionated Platform

**Status:** Accepted

Cur8s intentionally provides a **curated, opinionated platform**.

At the Platform layer, flexibility is treated as a cost rather than a goal. 
Every choice exposed becomes a surface that must be understood, tested, 
upgraded, and supported across all workloads. Over time, unconstrained 
flexibility erodes coherence and turns the platform into a collection of 
exceptions instead of a reliable foundation. Cur8s responds by limiting the 
platform to a **finite, intentional set of capabilities**. These capabilities 
are chosen to work together, are reasoned about as a whole, and define what the
platform supports. When a capability is not provided, absence is intentional.

Cur8s is shaped by the problems described in the 
*[Why essays](../why/README.md)*: the realities of self-hosting, the cost of 
renting knowledge, and the need for order over ad-hoc complexity. It is 
optimized for the solo builder or small team playing the long game, not for 
large organizations seeking a customizable internal platform. In this context, 
the platform makes decisions on behalf of its users, and users are expected to 
adapt to the platform rather than reshape it to fit local preferences.

## Where Flexibility Belongs

This posture applies strictly to the **Platform** layer.

Applications remain free to configure themselves within the boundaries the 
platform provides. Application teams can make local trade-offs, evolve 
independently, and experiment, as long as they do not redefine platform 
behavior. By concentrating flexibility at the application layer and constraining
it at the platform layer, Cur8s preserves adaptability without sacrificing
coherence.

## Changing the Platform

When a required capability is not provided by the platform, the response is not
to add configuration or exceptions. The response is to change the platform 
deliberately. Such changes require an RFC. This ensures new capabilities are 
evaluated in terms of their global impact and long-term cost, rather than 
introduced as incremental accommodations.

## Scope

This RFC defines the **posture** of the Cur8s Platform. It does not describe 
how curation is implemented or how platform capabilities are packaged or 
delivered.

## Revisions

Initial version.
