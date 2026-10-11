# Journal

## Purpose

This document records accomplishments, decisions, and learning over time, explaining what
changed and why it mattered. It preserves the story of progress as [Areas](areas.md) and
[Iteration](iteration.md) evolve. Design and research outcomes count alongside implemented features.

## Format

Months use H2 headings. Each entry uses an H3 heading with a date and short descriptive title,
followed by concise bullets about accomplishments, decisions, and learning. Include commits,
work notes, or other evidence when useful. Horizontal rules separate months. Draft entries retain
"Draft" in the heading until reviewed.

An iteration closeout entry summarizes the week's results and learning, followed by a shell
code block that retrieves its final committed account. Use the commit containing that account,
before the completed weekly section was removed from the rolling document:

```shell
git show <commit-id>:work/roadmap/iteration.md
```

---
