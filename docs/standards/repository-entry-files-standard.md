---
title: Repository entry files standard
scope: Root README.md, AGENTS.md, and README files inside directories
version: 1
---

# Repository entry files standard

This standard applies to the files people and coding agents read first: the root `README.md`,
`AGENTS.md`, and README files inside directories. It is intended for experienced developers and
coding agents who write or review those files.

## Required Conventions

Apply every applicable convention in this section.

### ENTRY-009: Write for experienced readers and current agents

**Applies to:** All content in the root `README.md`, `AGENTS.md`, and directory READMEs.

**Rule:**

- Assume readers are experienced developers and current top-tier coding agents; do not explain
  the basics of their field.
- Prefer tables and short lists to prose so readers can scan the file to orient themselves.
- Introduce an emerging tool readers may not know, such as mise, with a link to an authoritative
  introduction.

**Exception:** Use prose for a single connected explanation that a table or list would fragment,
such as the root `README.md` description.

**Example:** Explaining what a container image or a Git branch is explains the basics; explaining
what mise does for this repository introduces an emerging tool.

---

### ENTRY-001: Link instead of copying

**Applies to:** Content added to or edited in the root `README.md`, `AGENTS.md`, and directory
READMEs.

**Rule:** Before writing an explanation, procedure, or list, check whether another file already
covers it. If one does, link to that file rather than restating its content.

**Example:** A root `README.md` describes the repository in a few sentences, but links to the local
development guide rather than copying its setup steps.

---

### ENTRY-002: Keep the root README to a description, prerequisites, and a reading order

**Applies to:** The root `README.md`.

**Rule:**

- Write it for people.
- Open with the repository's name as the H1, followed by a description of at most three
  sentences.
- Follow with a `## Prerequisites` section containing a concepts table (ENTRY-003) and a software
  table (ENTRY-004), each labeled by its first column header rather than a subheading.
- End with a `## Read next` numbered list linking the documents to read, in reading order, each
  with a one-line statement of what it covers.
- Include nothing else: no task lists, directory layouts, quick-start commands, or procedures.

---

### ENTRY-003: List only external concepts as knowledge prerequisites

**Applies to:** The concepts table in the root `README.md`.

**Rule:**

- Use the columns `Concept` and `Why it matters here`.
- List the concepts a reader must bring from outside to understand the repository.
- Leave out what the repository itself teaches, such as its own design philosophy.
- Do not list tools separately; when a tool is essential to understanding a concept, name it in
  that concept's row.
- Link each concept to an authoritative introduction.
- In the second column, say how the concept applies to this repository, not only what it is.

**Example:** The gitops repository lists GitOps, naming Flux as the engine the package installs, and
OCI artifacts. It does not list pre-rendered manifests, which its product documentation teaches.

---

### ENTRY-004: List only major software that mise does not manage

**Applies to:** The software table in the root `README.md`.

**Rule:**

- Use the columns `Software` and `What it gives us`.
- List software that developers must install themselves and that a typical developer machine
  does not include, such as mise and Docker.
- Leave out tools that `mise.toml` manages and tools nearly every developer machine already has,
  such as Git and curl.
- In the second column, state the outcome the choice gives the project, not why the tool is needed
  or what it replaces.

**Example:** For Docker, write "The full end-to-end test on your own machine", not "Required to run
k3d".

---

### ENTRY-005: Keep AGENTS.md to rules an agent cannot infer

**Applies to:** `AGENTS.md`.

**Rule:**

- Write it for coding agents; people may read it too.
- Include only rules and constraints an agent cannot work out from the repository's contents.
- Leave out project descriptions, directory layouts, architecture summaries, and command lists.
- Phrase each rule as a direct command, preferring "do X only when Y" to "never do X".
- Put one rule in each bullet, and group bullets under short subject headings.

**Exception:**

- State a permission rather than a command when it marks the boundary of an adjacent restriction,
  such as which files may link into a restricted directory.
- Use "never do X" when X has no permitted case at all.

---

### ENTRY-006: Let each major directory explain itself

**Applies to:** Directories whose purpose or rules are not obvious from their name and contents.

**Rule:**

- Explain the directory in a short `README.md` inside it: its purpose and any non-obvious rules for
  working there.
- Do not describe directory layout centrally in the root `README.md` or `AGENTS.md`.
- Place the README where it is not included in generated or packaged content, such as outside a
  directory published as an artifact.

**Example:** `.agents/README.md` explains why `.claude/skills` is a symlink to `.agents/skills/`.

---

### ENTRY-007: Point to the command or file that lists changing details

**Applies to:** Lists of tasks, tools, versions, or similar details in any entry file.

**Rule:** Do not enumerate changing details that a command or configuration file already lists;
name the command or file instead, such as `mise tasks` or `mise.toml`.

---

### ENTRY-008: Keep procedures in how-to guides

**Applies to:** Setup steps, verification gates, and development workflows, and where the
repository documents them.

**Rule:**

- Write procedures in how-to guides under `docs/how-to/` and link to them from the root `README.md`
  reading order.
- Do not add a `CONTRIBUTING.md`; its role is divided between the root `README.md` and the how-to
  guides.
