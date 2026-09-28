---
status: draft
complexity: null
---

<!--
Template for .dev-tasks/<task>/task.md. Create the file in step 1, fill the sections the task's
complexity requires, delete the others, and delete every instruction comment as you fill a section.

| Section | by-pass | review | grill |
| --- | --- | --- | --- |
| Request, Pre-research, Change Contract, Deviation Log | yes | yes | yes |
| Evidence, Plan, Reviews | no | yes | yes |
| Open Questions | no | no | yes |
| Grill Outcomes | no | no | yes |

Raise `complexity` from `null` to `by-pass`, `review`, or `grill` at the end of pre-research.
-->

# <Task title>

## Request

<!-- All: the requested outcome in the requester's terms, with a link to its source when one exists. -->

## Pre-research

<!--
All: what you inspected (files, commands, history) and what it showed; the current behavior and the
owning subsystem; and why the complexity fits: confirm every by-pass condition, or name the ones that
fail; for grill, name the questions that only the user can settle.
-->

## Change Contract

<!-- All; keep it to one line per field for by-pass. -->

- **Outcome:**
- **Invariants:**
- **Scope:**
- **Non-goals:**

## Evidence

<!--
review, grill: the evidence the plan needs, with path:line for consequential facts and inferences
labeled as such when uncertainty could change the plan:
- current behavior or failure and its root cause;
- owning subsystem, integration boundaries, and likely future change surface;
- relevant code, tests, documentation, history, and conventions;
- existing concepts or utilities to reuse;
- compatibility, data, security, operational, rollout, and rollback constraints;
- risks and unresolved assumptions.
-->

## Open Questions

<!--
grill: questions whose answers would change behavior, compatibility, risk, or scope and that evidence
cannot settle. This list is the agenda of the $grill-me interview.
-->

## Grill Outcomes

<!--
grill: each question with the user's answer, the decision it produced, and the plan section it changed.
Questions left open become explicit assumptions in the matrix.
-->

## Plan

<!--
review, grill: all four sections are mandatory. Only sections 2 and 3 may use `Not applicable`, with a
concrete reason.
-->

### 1. Minimal Reasonable Solution

<!--
State the smallest solution that satisfies the contract without sacrificing correctness, ownership,
compatibility, or justified future change cost, and list its implementation steps. Verify that it:
- fixes the root cause where the invariant is owned;
- keeps related behavior cohesive and future changes local;
- reuses existing concepts instead of creating parallel representations;
- adds an abstraction only when it removes more complexity than it creates;
- keeps blast radius and operational risk proportional to demonstrated value.
-->

### 2. Matrix Decisions on Complications

| Complication | Options | Decision | Rationale and Cost |
| --- | --- | --- | --- |

<!--
Record every complication that creates a material fork. Use exactly these four columns; do not combine
or omit them. List viable options before choosing. Exclude reversible implementation details. If no
material fork exists, write `Not applicable — no consequential complication`.
-->

### 3. Refactoring Options

| Option | Value | Cost and Risk | Decision |
| --- | --- | --- | --- |

<!--
Record task-related refactoring options with a decision of Include, Defer, or Reject. Use exactly these
four columns; keep value, cost, and decision separate. Include a refactor only when required for
correctness or ownership, or when it materially reduces task complexity, duplication, coupling, risk, or
future blast radius. Defer adjacent cleanup. If no meaningful option exists, write
`Not applicable — no task-related refactor`.
-->

### 4. Test Coverage Plan

| Behavior or Risk | Test or Check | Level |
| --- | --- | --- |

<!--
Map every invariant, material decision, and risk to evidence at the level Unit, Integration, E2E,
Static, or Runtime. Cover changed behavior, regression risk, boundaries, side effects, failure paths,
required static checks, and rollout or rollback when state or compatibility changes. Prefer semantic
assertions against stable outcomes; assert exact wording only when it is an explicit contract. Where
and when each check runs belongs to the verification schedule in execution-plan.md.
-->

## Reviews

<!--
review, grill: one entry per plan or diff review round with the reviewer (independent or self), the
verdict, and every finding with its disposition: fixed where, or rejected with the reason.
-->

## Deviation Log

<!--
All: material changes to scope, decisions, or complexity after pre-research, each with its reason.
Leave empty until one happens.
-->
