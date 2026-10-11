---
name: manage-work-notes
description: Manage repository work areas, iterations, journals, inboxes, work notes, and explorations. Use for work selection or ordering, iteration planning and closeout, journal drafting or review, quick reminders, and creating, planning, continuing, moving, or closing work notes and explorations.
---

# Manage Repository Work

The governing work README owns repository-specific locations, document roles, formats, states,
templates, and lifecycle rules. This skill selects and performs the requested workflow without
inventing another structure or changing the owner's strategy. Discover artifacts through that
README; keep repository-specific paths and formats out of this skill.

## Start

1. Locate the existing work directory from the requested artifact or repository structure.
2. Identify the artifact and requested operation. An explicitly named artifact or destination
   wins. Related artifacts of different kinds may coexist; similarity between a work note and an
   exploration is context, not a collision.
3. Choose the workflow.

   | Request | Workflow |
   |---|---|
   | Show current focus, next work, broader work areas, ordering rationale, or accomplishments | Roadmap Read → Finish |
   | Create, reconstruct, or revise work areas or an iteration | Roadmap Edit → Finish |
   | Draft, edit, or review journal entries | Journal Edit → Finish |
   | Close a weekly iteration | Iteration Closeout → Finish |
   | Capture a quick repository reminder, such as **Capture this and keep going** | Inbox Capture → Finish |
   | Triage inbox entries | Inbox Triage → destination workflow when needed → Finish |
   | Find, read, or list work material | Find → Finish |
   | Create or edit a work note, such as **Capture this as an idea**, **Add this to todo**, or **Capture this as parked work** | Find → Work Note Edit → Finish |
   | Create or revise a work-note plan | Find → Work Note Plan → Finish |
   | Implement or continue the actual task described by a work note | Find → Execute → Finish |
   | Change a work note's intent state, such as **Park this work note** | Find → Reclassify → Finish |
   | Rename a work note or exploration | Find → Rename → Finish |
   | Complete and remove a work note | Find → Complete → Remove → Finish |
   | Discard a work note | Find → Discard → Finish |
   | Start or edit an exploration, such as **Continue the agent-runtime exploration** | Find → Exploration Edit → Finish |
   | Move selected work-note material into an exploration | Find → Exploration Input → Finish |
   | Derive an outcome from an exploration | Find → Exploration Outcome → destination workflow → Finish |
   | Discard an exploration | Find → Discard → Finish |

   Any workflow that moves, renames, or deletes an artifact or supporting material includes
   Reference Maintenance, which includes Roadmap Edit when the artifact affects work areas or
   weekly focus.

   Combine workflows in logical order when the request explicitly includes multiple operations.
   When the owner asks to finish remaining work and close the note, run Execute before Complete and
   Remove. A request only to verify completion or remove an already-completed note does not
   authorize Execute.

4. Read the governing README's global rules and only the sections and artifacts needed by the
   selected workflow. Read a template only when the workflow will use it. For roadmap edits,
   also read the selected document's purpose and format; do not use a legacy template that the
   README has superseded.
   For module design or implementation, read the module development guidance identified by the
   README and the task's current design material.
5. Before writing, inspect the working tree and preserve unrelated changes.

Ask only when ambiguity would materially affect the destination, strategy, implementation scope,
or authorization for a destructive action. Do not commit, push, or alter remote systems unless the
user explicitly requests it.

When writing work material, clearly distinguish user-provided facts and decisions from proposals,
code observations, assumptions, and open questions.

Before substantive planning or execution, review relevant sources and existing consolidated
thinking. Reuse what remains applicable and update the consolidation only as the current scope or
new evidence requires, following the governing README's consolidation convention.

## Find

1. Use the governing README's discovery procedure.
2. For a work listing, inspect summary metadata before loading note bodies.
3. For a named work note, resolve it across note states, then read its `overview.md` and optional
   `plan.md`.
4. For a named exploration, resolve it by directory name or its `overview.md` heading, read the
   overview, inventory its directory, and load supporting files only as needed.
5. When resolving an existing artifact, ask if there is no clear unique match.

When creating an artifact, search only artifacts of the same kind for duplicates. A related
artifact of another kind may be useful context but does not block creation.

## Reference Maintenance

Use this workflow around any operation that moves, renames, or deletes a work artifact or its
supporting material.

1. Before changing or removing a path, locate references to its current location.
2. After the operation, update or remove affected references according to the governing README so
   no stale paths remain.
3. If work areas or weekly focus are affected, use Roadmap Edit. Follow the agreed direction;
   ask when a new strategic choice is needed. Completion alone does not select a new target or order.

## Roadmap Read

Use the governing README to locate the document relevant to the question:

- Current focus or next contribution: read Active work in the current weekly entry, identified by
  the governing README, then its plan and notes as needed. Target supplies the larger goal.
- Broader work or ordering: read the relevant areas and the reasoning behind their order.
- Accomplishments or learning: read the relevant journal entries, limiting history to what is needed.

For "What are we working on?" or "What's next?", lead with Active work. Use Find to consult the
corresponding task when a concrete next step is needed. Do not infer the selected contribution
from todo listings, areas ordering, or the calendar. If Active work is missing, report the missing
selection; do not invent it. Keep the response read-only. If there is no active iteration, report
that fact and use the areas to discuss possible work; do not create a target or iteration without
a request.

## Roadmap Edit

1. Identify the requested document and read its role and format from the governing README and
   the live document. Create or reconstruct it only when requested.
2. Apply the owner's agreed scope and ordering. Keep preferred depth-first order in the areas and
   the active target, weekly selection, and demo constraints in the iteration.
   Update Active work when the owner selects a different current contribution.
3. Update the current account in place. Weekly plans evolve; notes can retain useful developments.
   Keep the next week provisional and unknown scope visibly open. Use Journal Edit for lasting
   results and learning rather than accumulating completed iterations.
4. Before saving, apply the governing README's roadmap integrity checks.

- Keep execution detail in linked work notes.
- Do not add or reorder work merely because a note was created or reclassified.

## Journal Edit

1. Read the journal format and relevant existing entries. A read-only review reports findings;
   it does not silently edit entries or remove draft labels.
2. For a draft, gather the task or week's intent, accomplishments, decisions, learning, and
   verification from its notes and relevant implementation evidence. Inspect associated commits;
   do not assume every commit in a date range belongs to the work.
3. Create or refine the entry in the governing format, reusing an existing draft when it covers
   the same work. Preserve chronology and keep completed accounts separate from future intentions.
4. Label generated entries as drafts until the owner reviews them. Incorporate corrections and
   remove the label when the owner accepts the entry, not after an agent's own review.

Distinguish demonstrations from fully reviewed work and state what was verified. Record time only
when supplied or measured, identifying approximations; commit timestamps do not establish hours.

## Iteration Closeout

1. Read the iteration and confirm which week is being closed. Finalize its account from success
   conditions, completed work, demo or review results, and notes. State unfinished work honestly;
   do not treat the whole target as complete merely because the week ended.
2. Find a commit preserving that final account, or prepare it for a commit when none exists.
   Creating a commit still requires explicit user authorization. If it is missing, retain the
   weekly section and make the prepared account reviewable before requesting the commit.
3. Verify the chosen commit contains the final account. Use Journal Edit to summarize it and
   include a fenced shell command using the actual commit ID and discovered repository-relative
   iteration path. Do not assume the previous commit is correct or write placeholder IDs.
4. Preserve unfinished work in the upcoming week, deferred-work section, or owning work note,
   following the README. Record changed scope and conditions for resuming deferred work.
5. Remove the completed weekly section only after its final committed account and journal summary
   are preserved. Bring the upcoming week forward; remove the file only when no active or upcoming
   iteration remains. Do not create an archive directory unless requested.
6. Record target completion or change in the journal before choosing its replacement. Apply only
   the owner's agreed next target and scope, using Reference Maintenance when paths change.

## Inbox Capture

1. Read the inbox and check for an obvious duplicate.
2. Append the smallest useful top-level bullet.
3. Add brief context or a relevant link only when needed to preserve meaning.
4. Resume any work already underway.

- Do not investigate, classify, plan, implement, create another artifact, or revise the roadmap.
- Capture is not authorization to act on the entry.

If the user expects notification at a particular time, use the available reminder mechanism only
when that action is requested; do not silently substitute the repository inbox.

## Inbox Triage

1. Triage only when requested.
2. Follow an explicit destination or action without asking again.
3. When the outcome is unclear, help the owner choose whether to remove the entry, handle it
   directly, update or create another work artifact, revise the roadmap, or schedule a reminder.
4. Perform only the authorized destination workflow.
5. Remove the entry after it is resolved.

## Work Note Edit

1. Before creating a note, use Find to search the work-note states for the same or equivalent work.
2. When a match exists, update it only when authorized; otherwise report it.
3. For a new note, choose the state from the owner's current intent, use the governing template,
   and validate its directory name and title against any state-specific naming convention in the
   governing README.
4. When editing, rewrite the overview to reflect current understanding rather than appending a log.

- Do not add the note to the roadmap automatically.
- This workflow changes work material only; it does not begin implementation.

## Work Note Plan

1. Plan only when the work is concrete enough. For module work, distinguish interface exploration
   from implementation slices; keep later slices open to what the first ones reveal.
2. Create or revise `plan.md` using the governing template, in the form the governing README
   prescribes for the size of the work.
3. Detail only the work about to start; later work keeps only its outcome and completion
   conditions until it starts.
4. Match review points to uncertainty. For unsettled designs, define focused slices that help
   decide what follows. For settled designs, specify the authorized series of slices and integrated
   review. Make prerequisites, verification, stopping points, and the next action clear.
5. Keep the plan actionable and current without beginning implementation.
6. Ask for information only when a material planning choice cannot be inferred safely.

## Execute

1. Use the selected work note as task context.
2. Follow repository implementation and verification instructions.
   During interface exploration, refine the proposed types and domain docs without writing tests.
   During slice implementation, carry the selected behavior through its relevant module layers
   and verify its behavior and invariants.
3. Check plan steps as they finish, and delete finished parts of the plan as the governing README
   directs.
4. Stop at each review point the plan defines, and wait for the owner before continuing.
5. Revise plan narrative only when the approach changes.

- Keep the execution plan focused on remaining work. Capture meaningful progress, discoveries,
  or blockers in weekly notes when tracking the iteration; daily narration is not required.
- A request to edit or plan a note does not authorize execution. Ask when implementation intent
  remains materially ambiguous.

## Reclassify

1. Determine the destination state from the owner's stated intent.
2. Check for a destination collision.
3. Run Reference Maintenance around moving the entire work note to the matching state.
4. Review the title against any destination-specific naming convention and revise it when needed.
   Preserve the stable directory name unless the owner also requested a rename.
5. Revise stale content after the move.

Do not move a note to imply progress or priority.

## Rename

1. Rename a work note or exploration only when the owner requests a new artifact name.
2. Check the governing naming convention and destination for a collision.
3. Run Reference Maintenance around renaming the artifact directory.

Do not rename an artifact merely because its heading or title wording changes.

## Exploration Edit

1. Before creating an exploration, use Find to search existing explorations for the same subject.
2. For a new exploration, follow the governing convention.
   - A related work note does not block creation; use it as context or link it when useful.
3. For an existing exploration, use its directory as the edit scope.
4. Keep `overview.md` useful as the current orientation.
5. Reorganize or rewrite supporting material as requested.

- Do not add work-note state, roadmap placement, or implementation authorization.
- Exploration content remains provisional.

## Exploration Input

1. Resolve the source work note and destination exploration, creating the exploration through
   Exploration Edit when needed.
2. Move or rewrite only the selected material, preserving provenance and enough context for it to
   remain understandable.
3. Apply Reference Maintenance whenever a source path changes.
4. Keep the source work note unless the owner explicitly requests whole-note conversion and
   removal.
5. For an explicitly requested whole-note conversion, preserve durable knowledge, integrate the
   useful material into the exploration, then use Discard to remove the source note.

A related work note and exploration may coexist. Moving material does not change the note's intent
state or roadmap placement.

## Exploration Outcome

Create a separate work note only when the owner decides to pursue concrete work, using Work Note
Edit. Publish self-contained durable documentation only when the conclusions are dependable. Do
not automatically convert, move, or remove the exploration.

## Complete

1. Verify from implementation and project evidence that the work note's intended outcome is
   complete.
2. Run the governing completion and verification checks. For a read-only completion review,
   report any missing closeout material without editing it.
3. If the outcome or verification is incomplete, retain the note and report what is unfinished.

## Remove

1. Require Complete to have succeeded and the request to authorize removal.
2. Use Journal Edit to capture the closeout account for owner review before deleting the note.
   Reuse an existing account when it already covers the work; a draft remains labeled until accepted.
3. Run Reference Maintenance around deleting the completed note. Preserve unfinished related work
   and update weekly links using the agreed scope without selecting a new strategy.

## Discard

1. Proceed only for the work note or exploration the user explicitly selected for discard.
2. Preserve durable knowledge as required by the governing README.
3. If the target or uncommitted content is unclear, ask before deleting.
4. Delete the selected artifact without completion checks, applying Reference Maintenance.

## Finish

1. After Inbox Capture, verify only that the intended entry was recorded, then resume the work
   already underway.
2. For other changes, inspect the diff against the request and applicable governing rules, then run
   relevant verification without expanding the task.
3. Report the resulting artifact and meaningful verification, assumptions, or unresolved
   questions.
4. When Reference Maintenance changes a file outside the work directory, identify it as a boundary
   repair.

Keep read-only answers and simple capture acknowledgements brief.
