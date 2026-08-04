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

After validation, provide a concise, high-density summary:

1. what was done and what outcome was achieved;
2. how the task was implemented;
3. how the result was verified;
4. the size of the diff and which parts of the task account for it;
5. which actual decisions diverged from the original ones.

Present information in layers, starting with what reduces uncertainty most. Use Mermaid when a diagram explains a meaningful structure, flow, or change more effectively than text.
