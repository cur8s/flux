# Working philosophy

> [!NOTE]
> This essay explains the philosophy behind exploratory engineering and collaboration with coding
> agents. It describes how I develop understanding, choose work, and build confidence in a system.
> The philosophy remains useful as the tools and repository procedures supporting it change.

I approach software development as exploratory research and development. I usually have a sense of
the problem I want to solve and some important properties of the system I want to build. Much of
the terrain between them becomes visible through the work itself. A conversation can expose an
assumption. An implementation can reveal a dependency. A demonstration can change someone's
understanding of what they need. Those discoveries are part of developing the system.

The image that fits this work is an explorer making a map while travelling. A mountain gives a
sense of direction long before the route to it is understood. Travelling reveals rivers, passes,
and places where an earlier assumption was wrong. Each encounter improves the map and informs the
next leg of the journey. I need to retain that sense of direction while remaining free to choose a
different route.

That is how I want to organize engineering work. I need an evolving understanding of the whole
system: its capabilities, responsibilities, relationships, constraints, and invariants. I also
need a clear next move. These views operate at different levels. The larger direction gives each
piece of work a purpose; the work supplies evidence that can refine that direction. A detailed
execution plan becomes useful when I understand a task well enough to describe how to carry it
out. Until then, questions, alternatives, and uncertainty need to remain visible.

Conversation is one way I develop that understanding. I often begin with a collection of concerns
and possibilities whose connections are still emerging. Talking them through helps me identify
what matters, separate decisions from suggestions, and discover where an apparent disagreement is
really a difference in vocabulary. Recording this thinking helps me resume it later. The record
should distinguish tentative ideas, current design choices, and completed capabilities, so that
someone returning to the work can tell what has been established.

When developing a module, I use those conversations to build a domain specification. The design
docs establish a shared vocabulary, describe the important concepts and invariants, and draw the
boundary around the module's responsibilities. I then explore interfaces and key types with a
coding agent. Seeing how the model might be expressed and used puts another layer of detail on
the domain. A method signature can expose an unclear responsibility; a return type can reveal a
guarantee that the specification has not yet explained. Those discoveries update the docs as well
as the code.

I keep that interface exploration free of tests. At this point, I am still discovering the shape
I want. Tests would consume time and tokens describing choices that may change before I have
accepted them. I want enough code to inspect the proposed model, then a few working slices to
learn whether it fits. As those slices acquire behavior, tests help establish that their rules
and guarantees hold. The design develops through conversation, interface exploration, and
implementation, with each informing the others.

My natural way of working is depth first. I like to focus on a self-contained component,
understand its contracts, resolve the prerequisites I discover, and bring its implementation to a
dependable state. I want to examine the code and tests closely enough to explain why they are
there. Clear boundaries and readable code make that understanding possible. Finishing a component
this way provides a foundation that later work can use with confidence.

Depth-first investigation often uncovers more work than I initially expect. Understanding one
boundary may require reconsidering another. Tests may reveal that a contract is unclear, or review
may show that a shared convention needs to be improved. Following each discovery can make the work
grow and its duration difficult to predict. There is also a limit to what I can learn about a
component before seeing it used in a complete workflow. Some design questions only become concrete
when the parts operate together.

For those questions, I work breadth first. I let coding agents connect enough of the system to
produce a working experience, then use the result to evaluate the product and how its parts fit
together. Seeing a workflow makes it easier to ask whether it is useful, whether the
responsibilities fit, and whether the original direction still makes sense. It can reveal that a
carefully considered feature is intimidating to users, or that a simpler experience should come
first. That evidence helps me choose where to focus the next round of detailed work.

The two modes form a continuing cycle. Breadth-first work reveals the shape of the system in use.
Depth-first work consolidates that learning into components I understand and trust. The balance
depends on what is uncertain, the consequences of the decisions, and the external constraints.
Sometimes the right next move is to finish a module. Sometimes it is to connect several modules
and learn from the result. I make a deliberate return to consolidation and keep unfinished review
and engineering questions visible along the way.

A working demonstration and a thoroughly reviewed component establish different kinds of progress.
Both matter. I want to be able to say which behavior works, which contracts have been settled,
which code has received detailed review, and which assumptions still need evidence. This lets me
make useful deliveries while retaining an honest account of the system's maturity. A component can
be complete for an agreed scope while the broader system continues to evolve.

Reviewable slices are how I move between these modes. A slice carries one coherent behavior
through the relevant layers of a module. When I am uncertain about a design, that working path
gives me something concrete to reason about and reveals how the parts fit together. Reviewing
the first few slices helps determine the module's shape and the next step. When the direction is
established, I can give an agent enough context to implement a series of slices and present the
integrated result. I may then review that result as a whole and work backward through its details.
The useful size of a slice depends on the question it helps answer and how much I already understand.

Coding agents can produce code rapidly and carry out substantial work when the direction and
conventions are clear. My ability to understand and accept that work remains a limiting factor. I
retain responsibility for architectural choices, domain meaning, and acceptance. I want agents to
prepare the work for those judgments: follow established conventions, verify behavior, explain
important decisions, and surface unresolved questions at useful review points.

Tests have a central role in that preparation. I want to understand what a test establishes, why
its environment is necessary, and how its result builds confidence in the contract. Tests that are
difficult to interpret take time to review while leaving behavior unclear. Readable tests,
appropriate integration checks, and clear ownership boundaries help me judge a change. A long test
suite or a passing build still needs an explanation of what has been verified and where
uncertainty remains.

Each completed component should also make later work easier. Demonstrated implementation patterns
provide a basis for engineering standards and practical guidance. Once a pattern has been
demonstrated and accepted, agents should be able to apply it consistently and reviewers should
catch routine deviations before they reach me. This allows more of my attention to go toward
questions that require judgment. Conventions remain open to deliberate improvement as new work
provides evidence, while giving ongoing work a dependable baseline.

External deadlines influence the next move. A review or demonstration can justify building a
workflow across several components. The resulting feedback may redirect subsequent work. I want
that pressure to lead to explicit choices about scope, evidence, and consolidation. An iteration
can deliver a capability, finish a foundation, or answer a question that changes the route. Its
value depends on the progress it enables, and new discoveries can change the approach.

Continuity matters because useful work must fit around the time I actually have. A short working
window should let me return to a question, review a slice, or advance an implementation without
reconstructing the entire project. Clear current context, recognizable stopping points, and
recorded decisions make this possible. Preserving the thread of understanding between sessions
allows even short periods of attention to contribute to a coherent larger effort.

I also need a narrative of the work. Code records changes, but it does not fully explain the
reasoning that made them worthwhile. A concise dated account of accomplishments and discoveries
helps me explain what changed, why I invested time, and how the direction evolved. Research that
rules out an approach or clarifies a boundary deserves a place in that account. Recording the
story while it is fresh makes later reviews more accurate and preserves what I learned.

The work system supporting this approach should preserve understanding and reduce the effort
required to continue. Its structure should help me distinguish current direction, immediate work,
open exploration, accepted decisions, and completed results. As the structure evolves, the deeper
aim stays consistent: each piece of work should improve the system, strengthen my confidence in
it, and inform what I choose to do next.
