---
name: dev-task
description: >-
  A conceptual guide for implementing changes in an existing repository:
  understand the task in the context of the system, define Pareto-efficient
  scope and invariants, clarify consequential decisions, maintain .dev-tasks
  when useful, and report the result, validation, diff cost, and actual
  deviations after implementation.
---

# Dev Task

Implement the change as a deliberate part of the existing system, not as an isolated request. The goal is to deliver the task's core value with the smallest necessary increase in complexity.

## Understand the Task in Repository Context

Before implementation, understand the relevant architecture, behavior, constraints, conventions, and tests. Separate the desired outcome from the user's proposed implementation: the request may be incomplete, contradictory, or more expensive than the value it provides.

Interpret the requirement against the actual code, tests, documentation, and established conventions. If that context leaves multiple materially different readings that would change behavior, scope, compatibility, data, or architecture, surface the alternatives and ask a focused clarifying question before choosing one. Do not ask when repository evidence resolves the ambiguity or when the remaining choice is a reversible implementation detail.

## Define Scope and Invariants

If the scope is clear from the task and repository, proceed. Otherwise, clarify or explicitly define:

- the required observable outcome;
- what must remain unchanged;
- what is in and out of scope;
- what evidence will prove completion.

Choose the scope by the Pareto principle: maximize the outcome while minimizing added complexity. Do not include adjacent refactors, generalization, or speculative future-proofing when the task remains correct and coherent without them.

## Identify Consequential Decisions

Within the chosen scope, some alternatives may materially change behavior, architecture, data, compatibility, risk, or system cost. Identify these decision points and clarify the choice. Do not turn reversible implementation details into questions or ceremony.

A decision matrix is a tool for a genuine fork, not a mandatory artifact:

| Decision | Options | Choice | Rationale |
| --- | --- | --- | --- |
| ... | ... | ... | ... |

## Record the Task When Useful

If the scope required clarification **and** a matrix of consequential decisions emerged, create `<repo-root>/.dev-tasks/<name>.md`:

```markdown
# <Task>

## Task
- Outcome: ...
- Invariants: ...
- In scope: ...
- Out of scope: ...
- Validation: ...

## Decisions
| Decision | Options | Choice | Rationale |
| --- | --- | --- | --- |

## Actual Decisions
| Reason for Revision | Before | After | Scope Impact |
| --- | --- | --- | --- |
```

`Actual Decisions` is a deviation log, not a copy of the original decisions. If implementation must exceed the original scope, record the reason, the revised decision, and its scope impact, then continue with the smallest necessary expansion.

## Implement and Verify

Follow the chosen scope and the repository's existing patterns. Do not introduce unrelated changes. After implementation, verify actual behavior with appropriate tests, builds, static checks, or runtime validation.

## Report the Result

After validation, provide a detailed, high-density implementation report that reads like a strong pull-request review summary. Lead with the achieved outcome, then make the change easy to review without requiring the reader to reconstruct it from the diff.

Include the following when applicable:

1. **Outcome** — state the user-visible or system-level result and whether the requested scope is complete.
2. **Review summary** — explain the implementation by behavior or subsystem, including important data flow, control flow, interfaces, and repository patterns reused.
3. **Changed files** — group meaningful files by purpose and describe why each group changed; omit generated or mechanical details unless they affect review risk.
4. **Validation** — list the exact tests, typechecks, linters, builds, or runtime checks executed and their results. Distinguish passing evidence from checks that could not run.
5. **Diff cost** — report the diff size when available, explain what accounts for most of it, and call out added complexity, dependencies, migrations, or generated code.
6. **Decisions and deviations** — record consequential implementation decisions and any actual divergence from the original scope or plan. State explicitly when there were no material deviations.
7. **Risks and follow-ups** — identify remaining risks, unverified assumptions, compatibility concerns, or intentionally deferred work. State explicitly when none are known.

Prefer concrete evidence over generic claims. Mention exact commands and concise results rather than saying only that the change was tested. Separate implementation facts from reviewer judgment or residual uncertainty.

Scale the report to the change: keep trivial edits compact, but do not omit material review information merely to stay concise. Omit empty sections instead of filling them with boilerplate. Present information in layers, starting with what reduces uncertainty most. Use a table for dense file or validation mappings, and use Mermaid only when it explains a meaningful structure, flow, or change more effectively than text.
