---
name: dev-task
description: >-
  Implement features, bug fixes, refactors, and other changes in an existing
  repository, from a one-line fix to cross-system work that needs research and
  a reviewed plan. Use whenever a task requires changing repository files; do
  not use when nothing in the repository changes, such as read-only analysis,
  questions, or code review.
---

# Dev Task

Deliver the requested behavior at the lowest justified total cost. Three rules shape every step:

- **Change scope:** prefer a local change. Widen it only to protect correctness, ownership, or compatibility, or to materially reduce total complexity or risk.
- **Process scope:** plan in proportion to uncertainty and risk. Work that meets every direct-path criterion in step 1 skips planning; other work gets evidence gathering and a reviewed plan before code.
- **Completion:** only fresh verification evidence and a complete-diff review without material findings prove completion; neither a commit nor an open PR does.

## Workflow

```mermaid
flowchart TD
    A["Requested change"] --> B["1. Inspect and route; recommend a task worktree"]
    B --> C{"All direct-path criteria true?"}
    C -->|Yes| D["5. Implement"]
    C -->|No| Q{"Exceptionally large or domain-heavy?"}
    Q -->|Yes| R["Offer $grill-with-docs"]
    R --> E["2. Gather review-plan inputs"]
    Q -->|No| E
    E --> F["3. Build four-part review plan"]
    F --> G["4. Review and revise plan"]
    G --> D
    D --> H["6. Verify"]
    H --> I["7. Summarize with $information-design"]
    I --> J{"8. PR available and in scope?"}
    J -->|Yes| K["Open or update draft PR"]
    J -->|No| L["Review complete diff"]
    K --> L
    L --> M{"Material findings?"}
    M -->|Yes| N["Fix"]
    N --> H
    M -->|No| O["Finalize delivery"]
```

## 1. Inspect and Route

Inspect enough repository context to choose a path from evidence.

Use the **direct path** only when every condition holds:

- outcome and invariants are unambiguous;
- owning subsystem and implementation pattern are clear;
- change is local and creates no material architecture, data, API, compatibility, security, or operational decision;
- validation is obvious;
- change is low-risk and readily reversible.

On the direct path, skip steps 2–4 and continue with implementation. Otherwise use the **reviewed path**.

Recommend a separate Git worktree for each task, including direct-path work, when the repository and environment support it. Work in an existing task-specific worktree if one is already assigned. Preserve uncommitted work in the current checkout when creating a new one; if the task builds on that work, copy it into the new worktree or stay in the current checkout.

Involve the user in proportion to the open decision:

- Decide reversible details independently.
- Ask one focused question only when a missing choice would change behavior, compatibility, risk, or scope.
- On the reviewed path, offer `$grill-with-docs` before gathering review-plan inputs when the work is exceptionally large or domain-heavy: it has dependent stages, crosses multiple domain boundaries, or leaves domain terms or consequential design choices unresolved. Line count alone does not qualify. Explain which uncertainties warrant the interview. Run it if the user accepts; otherwise continue the reviewed path using available evidence.

## 2. Gather Review-Plan Inputs

Collect the evidence needed to build and review the plan:

- observable outcome, invariants, scope, and explicit non-goals;
- current behavior or failure and its root cause;
- owning subsystem, integration boundaries, and likely future change surface;
- relevant code, tests, documentation, history, and conventions;
- existing concepts or utilities to reuse;
- compatibility, data, security, operational, rollout, and rollback constraints;
- risks, unresolved assumptions, and decisions requiring user input.

Treat required edits across unrelated modules as evidence that responsibility may be misplaced. Consult official or upstream documentation when external behavior affects the solution. Separate fact from inference when uncertainty could change the plan. Stop when remaining unknowns cannot change the solution or its proof.

## 3. Build the Review Plan

Start with a compact change contract: outcome, invariants, scope, and non-goals. Then write the following four sections with these exact headings.

### 1. Minimal Reasonable Solution

State the smallest solution that satisfies the contract without sacrificing correctness, ownership, compatibility, or justified future change cost, and list its implementation steps. Verify that it:

- fixes the root cause where the invariant is owned;
- keeps related behavior cohesive and future changes local;
- reuses existing concepts instead of creating parallel representations;
- adds an abstraction only when it removes more complexity than it creates;
- keeps blast radius and operational risk proportional to demonstrated value.

### 2. Matrix Decisions on Complications

Record every complication that creates a material fork:

| Complication | Options | Decision | Rationale and Cost |
| --- | --- | --- | --- |
| ... | ... | ... | ... |

Use exactly these four columns; do not combine or omit them. List viable options before choosing. Exclude reversible implementation details. If no material fork exists, write `Not applicable — no consequential complication`.

### 3. Refactoring Options

Record task-related refactoring options:

| Option | Value | Cost and Risk | Decision |
| --- | --- | --- | --- |
| ... | ... | ... | Include / Defer / Reject |

Use exactly these four columns; keep value, cost, and decision separate. Include a refactor only when required for correctness or ownership, or when it materially reduces task complexity, duplication, coupling, risk, or future blast radius. Defer adjacent cleanup. If no meaningful option exists, write `Not applicable — no task-related refactor`.

### 4. Test Coverage Plan

Map every invariant, material decision, and risk to evidence:

| Behavior or Risk | Test or Check | Level |
| --- | --- | --- |
| ... | ... | Unit / Integration / E2E / Static / Runtime |

Cover changed behavior, regression risk, boundaries, side effects, failure paths, required static checks, and rollout or rollback when state or compatibility changes. Prefer semantic assertions against stable outcomes. Assert exact wording only when it is an explicit contract.

All four sections are mandatory. Only Matrix Decisions on Complications and Refactoring Options may use `Not applicable`, with a concrete reason. Keep the four headings in the active plan.

**Durable task file.** Create `<repo-root>/.dev-tasks/<name>.md` only when the work is decision-heavy, crosses subsystems, has dependent stages, or needs handoff. Before creating anything under `.dev-tasks`, ensure the target repository's `.gitignore` contains the idempotent entry `.dev-tasks/`; create `.gitignore` if it does not exist, and preserve all existing entries. Start every durable task file with this YAML frontmatter:

```yaml
---
status: draft
---
```

`status` is required and accepts only these values:

| Status | Meaning |
| --- | --- |
| `draft` | Evidence gathering, plan creation, or plan review is in progress. |
| `todo` | The reviewed plan is ready for implementation. |
| `progress` | Implementation or verification is in progress. |
| `pr` | A pull request is open and remains the active delivery surface. |
| `done` | Verification and final review are complete, with no required work remaining. |

Use the lifecycle `draft -> todo -> progress -> pr -> done`. Skip `pr` for local-only work, producing `draft -> todo -> progress -> done`. Update the existing `status` field when the task changes state; do not add custom status values or retain a status history. Add an empty deviation log and record only material changes to scope or decisions.

## 4. Review and Revise the Plan

Review each section separately, then check that they agree:

- the solution satisfies the change contract and fixes the owning boundary;
- the matrix exposes material complications, viable options, and explicit decisions;
- refactor decisions match the chosen scope and solution;
- the test plan covers every invariant, decision, failure path, and material risk.

Reject a plan with a missing section, collapsed matrix fields, unsupported `Not applicable`, unresolved consequential decision, or uncovered risk. Use an independent reviewer when breadth or risk justifies the coordination cost. Revise until the plan passes; do not code before it does.

For a durable task file, set `status: todo` after the plan passes review.

## 5. Implement

Follow repository patterns and, on the reviewed path, the reviewed plan. Keep unrelated changes out of the diff. For a bug, add a regression test that fails on the original defect when practical. Follow test-first development when the user or repository requires it.

For a durable task file, set `status: progress` immediately before implementation begins.

If implementation invalidates the plan, stop and revise the affected plan sections. If a direct-path change stops meeting any direct-path criterion, stop and switch to the reviewed path. Record any material deviation before continuing.

## 6. Verify

Run targeted checks first — on the reviewed path, those in the Test Coverage Plan — then the broader relevant suite. Read the output and fix failures. Prove the observable outcome and every invariant with fresh evidence.

Inspect the task diff and working tree for missing, unrelated, or accidental changes.

## 7. Summarize with Information Design

After verification, use `$information-design` to build the implementation summary from the actual diff and evidence, not from the original plan. Lead with the outcome, then include only what helps the reader assess the change:

- **System context**, before the change details: how the affected part works (responsibility, relevant components or boundaries, important control or data flow) and where the change fits, limited to what the reader needs to understand the change and its impact — one or two sentences for a simple local edit;
- what changed, where, and why;
- exact validation commands and results;
- diff cost: size and what justified it;
- consequential decisions and deviations;
- remaining risks and deferred work.

Keep direct-change summaries compact. Separate verified fact from reviewer judgment. Omit empty sections and process narration. Use this summary as the basis for the PR description and final report.

## 8. Deliver and Review

Recommend a pull request as the default delivery for each task when a remote and PR access are available. If the user requested local-only work or PR creation is unavailable, deliver locally and state why there is no PR.

For PR delivery:

1. open or update the draft PR with the implementation summary, then set a durable task file to `status: pr` only after the PR exists;
2. review the complete PR diff for correctness, scope, tests, security, compatibility, unnecessary complexity, and accidental edits;
3. fix material findings and rerun affected checks;
4. regenerate the summary with `$information-design` when the diff or evidence changes;
5. update the PR description and readiness state.

For local-only work, perform the same diff review and deliver the summary without opening a PR. Finalize only when no material finding remains and the summary matches the verified diff. Set a durable task file to `status: done` only at that point, after either the `progress` or `pr` state. Add the PR link and status to the final report when applicable.
