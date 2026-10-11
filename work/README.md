# Work

This directory organizes exploratory work: related areas, weekly contributions, detailed tasks,
unfinished thinking, and a record of results. It supports both depth-first consolidation and
breadth-first delivery. [Working philosophy](working-philosophy.md) explains why we work this way;
this README defines how the system operates in the repository.

Keep unfinished project designs in work notes and explorations. Publish settled project knowledge,
engineering standards, and how-to guides under [`docs/`](../docs). Work material records intent and
developing understanding; it must distinguish agreed decisions, proposals, and verified results.
The philosophy and operating guidance stay here so the work system can be reused across projects.

This file governs the locations, responsibilities, and lifecycle rules for `work/` and its
subdirectories. The roadmap documents describe their own purpose and format, consistent with this
guide. [`Manage-work-notes`](../.agents/skills/manage-work-notes/SKILL.md) supplies the operating
procedures for agents. Repository instructions, including explicit permission for commits, apply
to work material as well as code.

## Reference boundary

References are one-way: files inside `work/` may refer to documentation, code, standards, skills,
and other work notes. Markdown files outside `work/` must not link or point into this directory,
including through plain-text paths, source citations, or instructions to read a specific work note.
This includes `docs/`, the repository README, contributor instructions, and skill Markdown. Code
must not point here either: a comment does not name a work note, or a plan's milestones, phases,
or rounds.

Keep task ownership, source indexes, draft status, and roadmap navigation here. Durable documents
must explain their scope using durable documentation or implementation evidence. When a source
moves here, remove incoming references from outside or replace them with an appropriate durable
reference; do not redirect those readers into the relocated draft.

Before moving or deleting a work artifact, locate references to its current path. After the change,
update or remove affected references within `work/` so no stale paths remain. References from
outside `work/` violate the boundary above; remove them or replace them with an appropriate durable
reference rather than redirecting them to another work path. If the change affects the roadmap's
work areas or weekly focus, update the relevant roadmap document using the owner's agreed
direction. Ask when the change requires a strategic choice that has not been settled.

The work-management skill discovers the selected notes directory and reads its governing README;
it does not hard-code paths into this repository's work tree.

## Current organization

Use the document that answers the question at hand:

| Question | Document |
| --- | --- |
| Why do we work this way? | [Working philosophy](working-philosophy.md): the enduring approach to exploration, review, and collaboration. |
| What broader work do we see, and why this order? | [Areas](roadmap/areas.md): related work, scope, concerns, relationships, and the preferred depth-first sequence. |
| What are we pursuing now? | [Iteration](roadmap/iteration.md): the active target, current week, provisional next week, and deferred work. |
| What did we accomplish and learn? | [Journal](roadmap/journal.md): dated results, decisions, and learning. |
| Where can I capture a thought quickly? | [Inbox](inbox.md): reminders and possibilities to consider later. |
| What does a particular task involve? | Its work-note `overview.md`, optional `plan.md`, and supporting material. |
| Where is a design still being explored? | Its exploration's `overview.md` and supporting files. |

Start with Iteration when choosing the next contribution. Consult Areas for the broader context
and preferred order. Read the selected task's overview and consolidate only the thinking needed
for its outcome, including when resuming parked work. A directory listing does not establish priority.

## Work roadmap

The roadmap lives in `roadmap/` as three documents: Areas, Iteration, and Journal. Areas describes
the broader work and preferred order; Iteration selects the current contribution; Journal preserves
the story of progress. Detailed execution stays in individual work notes.

Each document opens with Purpose and Format sections, followed by a horizontal rule separating
the introduction from its content. Read those sections before editing. Keep the introduction
about the document's role and structure; put project-specific material below the divider.

### Areas

`roadmap/areas.md`, titled **Areas**, groups related work and explains its scope, value, and
relationships. Order the areas as we would naturally approach them without iteration pressure.
Begin with an **Order and rationale** table containing Work area and Rationale columns. The table's
row order matches the areas below it; the rationale explains why one area precedes another.

Each area has an H2 heading, a short introduction, **Work** bullets, and **Why / what this unlocks**.
Separate areas with horizontal rules. Work bullets can include concerns, ideas, dependencies, and
unsettled decisions. Keep implementation steps in todos and detailed design reasoning in explorations.

Areas evolves as understanding changes. Distinguish dependencies from preferences and proposals
from agreed choices. The active target and demo constraints belong in Iteration. Creating or moving
a work note does not automatically place it in Areas or change the preferred order.

### Iteration

`roadmap/iteration.md`, titled **Iteration**, owns one active **Target**: the outcome we want to
reach, why it matters, and how we will recognize success. A target can span several weeks and
change as we learn. It may concern a capability, a dependable foundation, or a design question.

Keep the current week and a provisional next week. Use ISO week numbers and readable date ranges,
such as **Week 41: October 5–9, 2026**. The first weekly entry is the current working week;
do not advance focus based on the calendar alone. Directly beneath its heading, **Active work**
states what we are doing now. That field is the single source of truth for the current contribution.
Update it when the owner changes focus; Plan holds other intended contributions. Questions such
as "What are we working on?" and "What's next?" start with Active work. Each weekly entry contains:

- **Success:** The outcome and how we will recognize it.
- **Plan:** Brief, action-oriented bullets that evolve during the week, with links to relevant todos.
- **Demo:** The date, time, audience, and intended demonstration or review, when known.
- **Notes:** Informal progress, discoveries, decisions, questions, blockers, and changes of approach.

Dates identify the week; meeting times belong in Demo. Notes can be dated when useful, with no
requirement for daily entries. Record useful developments as they happen, then draw on them at closeout.

**Later / unresolved** holds relevant deferred work and questions about what comes next. Keep it
small enough to help select the next contribution. When work is blocked or deferred, record the
reason, its effect on the week's outcome, and what would allow it to resume. Broader possibilities
remain in Areas or their owning work notes and explorations.

Select the week's contribution according to available attention, dependencies, uncertainty, and
review or demo needs. A breadth-first contribution can draw from several areas; record any departure
from the preferred order and revisit consolidation using what the delivery teaches us. Do not
invent an active target or commit to new delivery scope without the owner's direction.

### Journal

`roadmap/journal.md`, titled **Journal**, records accomplishments, decisions, and learning in concise
bullets. Use H2 headings for months and H3 headings for dated entries with descriptive titles.
Separate months with horizontal rules. Draft entries carry **Draft** in their headings until the
owner reviews them; then remove the label.

Capture what changed, why it mattered, what was learned, and what was verified. Design and research
count alongside implementation. Distinguish a working demonstration from fully reviewed work.
Include commits or supporting material when useful. Record time only when supplied or measured;
identify approximations and never derive hours worked from commit timestamps.

At todo closeout, review the note, relevant commits, and supporting material to draft a journal
entry for owner review. Use the evidence associated with that task, rather than assuming every
commit in a date range belongs to it. Capture the account before removing the completed note;
completion verification and authorization to remove it still apply.

At weekly closeout, preserve the week's final account in a commit, following repository commit
rules. Summarize its results and learning in Journal and include a shell code block using the
actual commit containing that account:

```shell
git show <commit-id>:work/roadmap/iteration.md
```

Then remove the completed weekly section and bring the upcoming week forward. Keep unfinished
work in the next week, Later / unresolved, or its owning work note. Remove the iteration file only
when no active or upcoming iteration remains. Record a target's completion or change before
choosing the next target. Git preserves the detailed account; no separate iteration archive is required.

### Roadmap integrity check

Before saving a roadmap revision, verify all of the following:

- Purpose and Format remain separate from project content.
- The Areas table matches the area sections and explains the ordering, not merely the work.
- Iteration has one active target, a current week, and at most one provisional next week.
- The current week's Active work reflects the owner's selected contribution.
- Weekly sections use Success, Plan, Demo, and Notes; detailed execution remains in todos.
- Unknown scope and proposed choices remain distinguishable from agreed decisions.
- Journal entries distinguish verified results, learning, and work still needing review.
- Removed or moved material leaves no stale links, and closeout preserves its useful account.
- The revision follows the owner's agreed direction without adding commitments or changing priorities.

## Work inbox

[`inbox.md`](inbox.md) is a low-friction capture buffer for repository-related reminders and
possible actions that should not interrupt current work. An inbox entry preserves a thought before
the owner has decided whether it is worth doing, exploring, scheduling, or placing on the roadmap.
It is not a backlog, priority list, work commitment, or authorization to investigate or implement
the entry.

Record each item as a plain top-level bullet containing the smallest useful statement. Add one
short indented context line or a relevant link only when the item would otherwise be difficult to
understand later. Do not require dates, identifiers, priorities, tags, status fields, or checkboxes.
A request such as **Capture this and keep going** adds the entry without expanding the request, then
resumes the work that was already underway. Avoid duplicates that are obvious from reading the
inbox, but do not interrupt capture to research or classify the thought.

Use a scheduled reminder instead when the desired outcome is a notification at a particular time.
Use an exploration when the owner wants to develop the thinking now, and a work note when the owner
has enough intent to classify the work as possible, intended, or parked.

Triage the inbox only when explicitly requested. Resolve each selected item by removing it as no
longer useful, handling it directly when authorized, adding it to an existing work note or
exploration, creating a work note in the state that matches current intent, or revising the roadmap
when the owner directs a change to the execution strategy. Convert an item to a scheduled reminder
when notification is the actual need. Remove a resolved entry after its action or destination has
been recorded so the inbox does not become a second copy of other work. Git history preserves its
ordinary past.

## Explorations

`explorations/` holds mutable, non-authoritative working material used to understand a problem,
compare possible designs, collect inspiration, and develop thinking before there is an agreed
outcome or committed delivery task. An exploration does not communicate intent, priority, or
implementation authorization, and it need not produce a work item or durable document. It is a
kind of working material, not a fourth work-note state.

Each exploration is a self-contained directory with a concise, stable, lowercase,
hyphen-separated name. Its only required file is `overview.md`, the current entry point and guide
to the exploration:

```text
work/
└── explorations/
    └── agent-runtime-lifecycle/
        ├── overview.md
        ├── event-driven-design.md
        ├── sketches/
        │   └── lifecycle.png
        └── sources/
            └── original-proposal.md
```

Begin `overview.md` with a descriptive level-one heading. It has no required front matter, fixed
sections, plan, or completion checklist. Rewrite it as the thinking develops so that it continues
to orient a reader to the problem, current understanding, relevant questions, candidate designs,
and supporting files. Add other files and directories whenever the subject benefits from distinct
alternatives, source material, inspiration, diagrams, or meaningful historical drafts. Use Git
history for ordinary revisions instead of retaining numbered copies with no independent value.

Natural requests include **Start an exploration about agent lifecycle**, **Continue the
agent-runtime-lifecycle exploration**, and **Let's work on the notes in the agent runtime
exploration**. Resolve an existing exploration by its directory name or `overview.md` heading. If
several explorations plausibly match, ask which one the owner means rather than guessing. Read the
overview first, inventory the directory, and load supporting material only as the requested work
requires it.

An exploration may lead to a separate idea, to-do, or parked work note. Dependable conclusions may
instead be written into self-contained documentation. Work material may link to the exploration,
but code and Markdown outside `work/` must not depend on it or link back to it. Do not automatically
convert or remove the exploration when an outcome emerges. Retain it while its reasoning or sources
remain useful, and discard it only when the owner explicitly asks after any durable knowledge has
been preserved.

## States

The states communicate current intent, not priority, maturity, or sequence. A note may be created
directly in any state and moved only when its intent changes. There is no required flow between
states and no implied ordering within a state.

When intent changes, move the entire note directory to whichever state is now accurate. Moving
does not imply progress, and a note need never move. After a move, review the overview and
optional plan so they describe the current understanding.

### `ideas/`

Work that may be worth pursuing but that the project does not currently intend to pursue: possible
features, questions, investigations, or early design thoughts. Natural instructions include
**Capture this as an idea.**

### `todo/`

Work the project currently intends to pursue. A note here may be actively underway or ready to
begin; the directory is not necessarily a prioritized queue. Natural instructions include **Add
this to todo** and **Continue working on this note**.

Give each to-do an action-oriented title: begin with an imperative verb and name the specific
object, deliverable, decision, investigation, or observable change. The title should communicate
what the project intends to do rather than merely naming a topic, desired quality, or milestone
state. An action verb alone is not enough when the rest of the title remains an open-ended
aspiration. A broader future note may still require refinement before it becomes the current
to-do, but its title should nevertheless describe the intended action.

Use these examples as naming guidance:

| Avoid | Prefer | Why |
|---|---|---|
| `Production-grade releases` | `Harden release publication` | Names concrete areas to change instead of a desired quality. |
| `Make releases production-grade` | `Harden release publication` | Adding `Make` does not turn a subjective aspiration into identifiable work. |
| `Task architecture` | `Adopt standard lifecycle phases` | States what will be adopted rather than naming an architectural topic. |
| `Improve e2e` | `Pin the Kubernetes test runtime` | Identifies the intended change instead of an unspecified improvement. |
| `Image mirror` | `Mirror component images to ghcr.io/cur8s` | Names a concrete deliverable. |
| `Local packaging` | `Investigate reproducible local OCI packaging` | Makes knowledge-gathering explicit when investigation is the intended work. |

For a note created directly in `todo/`, derive the initial directory name from a concise form of
the action-oriented title, such as `pin-kubernetes-test-runtime`. The directory remains a
stable identifier afterward; do not rename it merely because the title is refined or the note
moves between states.

### `parked/`

Work the project is deliberately not pursuing now but still considers valuable enough to preserve.
Work may be parked because it depends on future work, belongs in a later version, is too difficult
for the current phase, lost priority, or requires more information. Parking does not mean
permanent rejection, and an existing plan may remain while it still provides useful context.
Natural instructions include **Capture this as parked work** and **Park this work note**.

## Work Note Structure

Each work note is stored in a directory with a concise, stable, lowercase, hyphen-separated name.
Areas explains the preferred order and Iteration selects current work, so do not add numeric
priority or sequence prefixes to directory names.
External issue identifiers may be used alone or with a description, such as `issue-25/` or
`issue-25-browser-auth/`.

Each state directory contains a hidden `.template.md` holding the template for a new note's
`overview.md` in that state; it also keeps an otherwise-empty state directory present in Git.
`work/` holds the state-independent `.template-plan.md` for the optional execution plan:

```text
work/
├── .template-plan.md
├── working-philosophy.md
├── roadmap/
│   ├── areas.md
│   ├── iteration.md
│   └── journal.md
└── todo/
    ├── .template.md
    └── browser-gateway/
        ├── overview.md
        └── plan.md   (optional)
```

The directory name is the identifier, its parent directory is the state, and Git records history.
Do not add IDs, state fields, dates, priorities, or tags until repeated practical need requires
them.

### `overview.md`

Every work note requires `overview.md`, the neutral entry point for a note in any state. Start a
new note by copying the state directory's `.template.md` to the new note directory's `overview.md`
and replacing every `{{ placeholder }}`.

Two YAML front-matter fields are required:

```yaml
---
title: "Browser gateway authentication"
summary: "Add authentication boundaries before exposing the gateway to more clients."
---
```

- `title` is a short descriptive label, readable in a table and clearer than the directory name.
- `summary` is a brief explanation that adds information beyond the title and stands alone in a
  work summary table. Prefer one clear sentence, use two when that reads better, and never make it
  a paragraph.

The Markdown body adds only useful context not already clear from the summary; when there is
none, remove the template's body prompt and keep the title heading. The body does not require
fixed sections and is not an execution plan. A note may hold additional supporting files, such as
research notes or experiment material; `overview.md` remains its entry point.

### Optional `plan.md`

Add `plan.md` only when work is concrete enough to plan. It tells a coding agent how the work is
expected to be implemented and verified. `Context` carries the stable planning narrative: the
outcome, including what is out of scope, and the approach, including where the executor stops for
review.

For uncertain designs, define focused slices with review points that help decide the next step.
For settled designs, specify the authorized series of slices so agents can prepare an integrated
result before human review. Make prerequisites, verification, stopping points, and the next action
clear enough to resume in short sessions. A 15-minute working window does not require every slice
to take 15 minutes.

The rest of the plan takes one of two forms:

- **Phases.** Work small enough to plan in full lists numbered phases, each with checkbox steps.
- **Milestones.** Larger work lists named milestones instead, in the order they are built. A
  milestone is a state the work reaches, with observable conditions that show it is done. Only the
  milestone about to start is broken into numbered phases; later milestones keep only their
  outcome and conditions until they start. A phase may be split into numbered rounds, each ending
  in a review, when its review needs them. When several milestones share a shape, `Context` can
  define their phases once. Refer to a milestone by its name, never by its position, so that
  removing or inserting one changes no other reference.

Keep the plan to what is left to do rather than a diary of previous work. Check steps off as they
finish. When a phase is complete, delete it, and when a milestone is complete, delete it too; Git
keeps the history. Before deleting, make sure what was learned lives where it lasts: design and
current-state knowledge in durable documentation, conventions in the standards, and technical
detail that later work relies on in a supporting file of the note. The planning context changes
only when the plan itself changes. Small or exploratory work may never need a plan.

A note may keep the technical notes its phases rely on beside the plan, such as
`implementation-notes.md`. They are supporting material, not part of the plan. They shrink as their
content moves into durable documentation, and are deleted when the work completes.

Start `plan.md` by copying [`.template-plan.md`](.template-plan.md), keeping the form that fits the
work, and replacing every `{{ placeholder }}`.

## Preserved source material

A work item may have a `sources/` directory for earlier drafts, archives, or plans. Begin with its
`overview.md` for current scope and direction; a source index helps locate the original material.
Keep original provenance visible. A historical plan's checkboxes, review labels, and past
authorizations do not make it an active execution plan or authorize new work. Explicitly agreed
decisions remain relevant except where the owner has revised them; capture unresolved conflicts
with the owning work item.

Keep unfinished explanations and alternatives here until they can become dependable docs for an
agreed scope. Follow the [documentation strategy](../docs/README.md) when promoting that knowledge.
Moving a source preserves it; it does not imply acceptance, completion, or abandonment.

## Consolidate thinking when a task starts

Each organized work item begins by consolidating the sources needed for its selected outcome.
This happens when the task is picked up, within its scope and time budget. Repository cleanup does
not require finishing every collection first. Parked collections remain deferred until selected;
a delivery task can consume a relevant subset without activating the collection's entire scope.

Start from the overview, the current plan, and source index. Compare relevant source sections with
the owner's current direction, accepted guidance, and implementation evidence. Produce a concise
`working-notes.md` describing the selected scope, decisions, useful rationale, alternatives, and
open questions. Distinguish user decisions from proposals and code observations, and keep links to
supporting sources. A different existing document can serve this role if it already has that purpose.

Use the result to define the implementation or refinement plan and verification criteria. Enough
consolidation means the selected outcome is understandable and actionable; it does not require
settling every future capability or eliminating every duplicate. Resolve material conflicts with
the owner and continue independent work. Preserve useful unresolved thinking; remove only confirmed
superseded duplication after its distinct value is carried forward, following the existing rules
for explicit abandonment of a work item.

Shared material keeps one primary home. A task links to existing consolidated thinking and adds
only what its scope requires. Broader designs stay with their owners. Update source indexes and affected links as consolidation proceeds; publish
settled knowledge into self-contained docs without incoming references to work.

## Preparing changes for review

Read the README, coding instructions, and relevant standards for the files being changed. Explain
the concrete problem, resulting behavior, significant decisions, verification, and remaining
limitations in the review handoff. Keep secrets, registry credentials, and tokens out of commits
and notes. Follow the selected work item's verification requirements, the repository's
verification gates, and the completion checks below. A dispatched CI run is not a passing result
for the revision under review.

## Completion Checklist

Completion is an outcome available from any state, not a state change. Before deleting a completed
work note, verify the intended outcome using checks appropriate to the affected material. Removing
the note does not independently require application builds.

1. Complete the intended outcome, including implementation, documentation, and tests when
   applicable.
2. Update every affected durable document.
3. Create any newly needed durable document under `docs/`.
4. For changes limited to work notes or documentation, inspect the content and affected links, then
   run applicable formatting or documentation checks.
5. For implementation changes, follow the testing and verification requirements that apply to the
   affected code.
6. Reuse successful verification results only while they still cover the current changes. Rerun
   affected checks when relevant source, configuration, dependencies, or verification requirements
   have changed, or when earlier failures remain unresolved.
7. Run full builds when the affected scope or another applicable repository requirement calls for
   them.
8. Draft the journal account for owner review using the task's relevant commits and working notes.
9. Repair references to the removed note, including links in Areas and Iteration. Update weekly
   work using the agreed scope; completion alone does not select a new target or preferred order.

Delete the note only after every applicable completion and verification requirement has succeeded.

Abandonment is the other terminal outcome: when the project explicitly discards a note, delete it
without the checklist after moving any durable knowledge to `docs/`; committed history remains
recoverable through Git.

## Relationship to Issue Trackers

An external tracker such as GitHub Issues or Jira may coexist with work notes: the tracker
handles coordination, discussion, and reporting, while the note holds local reasoning, planning,
and preserved agent context. A note may carry an external identifier in its name without
duplicating tracker metadata; neither system replaces the other.

## Discovering Work

Read `roadmap/iteration.md` for the active target and current weekly contribution,
`roadmap/areas.md` for related work and the preferred order, and `roadmap/journal.md` for dated
results. The roadmap's order and weekly selection do not change work-note states. If there is no
active iteration, report that fact and use Areas to discuss possible next work; do not invent a
target or create an iteration unless requested.

To list work without loading every note, inspect only the YAML front matter in:

```text
work/ideas/*/overview.md
work/todo/*/overview.md
work/parked/*/overview.md
```

A work listing may report each note's state, directory, title, and summary.

Discover explorations separately through:

```text
work/explorations/*/overview.md
```

Use the parent directory as the stable identifier and the first level-one heading as the title.
Explorations have no state or summary metadata and should not be mixed into a prioritized work-note
listing unless the user asks for both kinds of material.
