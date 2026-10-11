# The Eternal Problems of Self-Hosting

Before you decide where or how to host your own software, it’s worth slowing down and looking at the
terrain you’re about to cross. Not the tools, not the platforms, not the hype cycles—but the
fundamental responsibilities that come with running something on the internet. These
responsibilities show up no matter what stack you choose, no matter what service you deploy on, and
no matter how simple your application seems at the beginning.

As bootstrapped developers, it’s easy to get pulled into debates about simplicity: which tool hides
the most complexity, which platform “just works,” which approach lets you avoid learning
infrastructure. But those debates skip a deeper truth: every application that becomes reachable on
the public internet inherits a shared foundation of operational problems. You can outsource them,
delay them, or abstract them away—but they never disappear. And the sooner you understand them, the
more capable and confident you’ll become as a builder.

This essay is a map of that foundation. Not a catalog of tools, but an exploration of the essential
problems every self-hosted system must eventually solve—and the long-lived protocols that bind the
internet together. Once you can see the terrain clearly, the hosting decisions ahead of you stop
feeling like guesswork and start feeling grounded—even obvious.

## DNS: Your Public Identity

The first boundary you cross when you put software on the internet is naming. DNS is how the world
finds you. It seems simple at first—point a domain to a server and move on—but the moment you build
anything with more than one moving part, DNS becomes a real control plane. A frontend might live at
one subdomain, your API at another. Internal services may need their own names. Certificates depend
on these names. Traffic flows depend on them. Architecture itself starts with DNS.

And for a bootstrapper, the goal is clear: DNS should be something your system can update
automatically, safely, and predictably. You don’t want to log into a provider dashboard and
copy-paste records by hand. You want naming to behave like code.

## Certificates and Trust: Proving You Are Who You Claim to Be

Once you have a name, you need trust. The modern web requires HTTPS everywhere, and HTTPS requires
valid certificates. You can buy them from commercial vendors, but for most solo developers, Let’s
Encrypt is the obvious path—free, automated, and widely supported.

But automation introduces new responsibilities. Certificates must be issued correctly, renewed on
time, rotated safely, and replaced seamlessly. The ACME protocol that powers Let’s Encrypt handles
this elegantly, but only if something in your system knows how to speak it.

For a bootstrapper, the goal is simple: certificates must take care of themselves. No manual
downloads. No calendar reminders. No downtime because something expired. Trust should be automatic.

## Routing Traffic: From a Domain to a Living System

Real applications grow quickly beyond a single process listening on a single port. You likely have a
frontend—static files, JavaScript, or a full SPA—and one or more backend APIs. You might have
internal admin endpoints, webhook receivers, or background workers.

Routing is what turns all of this into one coherent system. You need a gateway that terminates TLS,
forwards requests intelligently, enforces rules, and gives you room to evolve without breaking what
already works.

For a bootstrapper, the goal is order: a clear, predictable place where all inbound traffic is
shaped and directed. When routing is centralized and declarative, adding new pieces stops being
chaotic.

## The Runtime: Keeping Your Application Alive

After routing comes the question most people don’t ask until things go wrong: what keeps your
application running? Processes crash. Memory leaks. Machines reboot. Updates should happen without
dropping active requests. A PaaS handles all this for you, but when you self-host, you need your own
layer of protection.

Something must supervise your app. Something must restart it if it dies. Something must ensure it
starts automatically on boot. Something must handle graceful shutdowns during deployments.

For a bootstrapper, the goal is resilience: a runtime environment where failures are routine and
recovery is automatic. When the inevitable crash becomes a non-event, you know your foundation is
solid.

## Databases and State: Protecting the Beating Heart of Your System

Code can be rebuilt. Data cannot. Your database is the one piece of your system that must survive
every mistake you make. You need automatic backups. You need durable storage. You need a way to
restore your data that you’ve actually practiced. You need a migration workflow that will not
corrupt production when something goes wrong.

And as your system grows, you may add caches, queues, search indexes, or event logs. Each brings new
responsibilities: durability, replication, retention, indexing, monitoring.

For a bootstrapper, the goal is reverence: treat data as sacred. Automate backups, validate them,
store them on durable object storage, and rehearse disaster recovery before you need it.

## Secrets and Configuration: Handling What Must Stay Hidden

Every system accumulates credentials—database passwords, API keys, OAuth secrets, encryption keys,
webhook tokens. These must be stored securely, injected safely, and rotated without breaking
production. Many solo founders underestimate this until the day a secret leaks into logs or ends up
in a Git commit.

For a bootstrapper, the goal is clarity: one reliable place where secrets live, one predictable
mechanism that delivers them to your applications, and a simple way to rotate them when needed. When
secrets behave like a managed resource rather than a loose collection of strings, everything becomes
safer.

## Identity: Knowing Who Is Using Your System

Identity becomes important the moment you need to know who your users are. You don’t have to build
authentication yourself—in fact, you probably shouldn’t. But you do need to understand the protocols
behind it. OAuth and OIDC define how modern identity works. Whether you use “Sign in with Google,” a
SaaS provider, or a self-hosted identity solution, the architecture is the same: exchanging tokens,
verifying claims, managing sessions.

For a bootstrapper, the goal is future-proofing: choose identity approaches that rely on open
standards. Protocols, not proprietary flows. That way you can switch providers, self-host later, or
expand capabilities without rewriting your foundations.

## Logging and Observability: Seeing What Your System Is Doing

Logs tell the story of your system. Metrics reveal patterns you’d never see otherwise. Traces show
you where time disappears. Without observability, every failure feels mysterious. With it, most
failures become routine.

You need a place to send logs. You need a mechanism to collect metrics. You need dashboards or
queries that help you understand what normal looks like—and what it looks like when things start to
drift.

For a bootstrapper, the goal is insight: enough visibility to know when things are healthy, when
they’re degrading, and why.

## Automation: Systems That Maintain Themselves

Every manual task you perform will eventually become a source of friction. Deployments, backups,
certificate renewals, log rotation, dependency updates, configuration changes—none of these should
require your direct involvement forever.

For a bootstrapper, the goal is liberation: build systems that take care of their own housekeeping
so your limited time can go toward building product, not babysitting machines.

## Foundational SaaS: What You Should Not Self-Host

Not everything belongs on your server. Some services become dramatically better when operated at
massive scale. Object storage is the clearest example: S3, GCS, Azure Blob, and their compatible
counterparts are cheap, durable, and globally replicated. Trying to self-host storage is almost
always a mistake.

Email deliverability is another. You can run your own SMTP relay for outbound mail, but you should
not run your own inbox, and you should not rely on a homegrown email-sending stack for critical
notifications. Reputation systems, spam detection, and global routing make this a problem best left
to specialists.

Password management is another clear case: integrate with a secure vault like 1Password or another
established provider rather than inventing your own.

For a bootstrapper, the goal is discernment: self-host the parts of your system that define your
product; outsource the commodities; and lean heavily on open protocols—SMTP for email, OIDC for
identity, S3-compatible APIs for storage—because protocols survive vendors. They give you the
freedom to switch providers, self-host later, or evolve your architecture without rewriting the
foundations of your system.

## A Cohesive Operating Model: The Hidden Glue

You can solve these problems one by one, but if you solve them inconsistently, the system becomes
fragile. What brings sanity to a self-hosted environment is a cohesive operating model—a predictable
way of declaring, updating, and maintaining every component. When DNS, certificates, routing,
identity, secrets, databases, observability, and automation all follow the same rhythm, everything
becomes more understandable. Your system becomes something coherent rather than a collection of
ad-hoc fixes.

For a bootstrapper, the goal is harmony: an infrastructure that feels integrated, predictable, and
aligned with how you think—not a pile of unrelated tools fighting for attention.

## Once You Understand the Terrain, Everything Else Gets Easier

The point of this essay is not to overwhelm you. It is to give shape to the problems you will
encounter so you’re not surprised by them later. Once you see the full terrain—naming, trust,
routing, runtimes, state, identity, secrets, observability, automation, and selective use of
SaaS—the hosting debate becomes clearer. You are no longer choosing blindly. You are choosing tools
and patterns that align with how the internet actually works.

When you understand the terrain, the next step—designing your hosting approach—stops feeling
uncertain. It becomes the natural continuation of a map you already know how to read.
