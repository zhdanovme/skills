# Subagents

Read this before the first dispatch. The orchestrator builds every brief from it and verifies every result; subagents never see the conversation or this skill.

## Choose the Agent

| Role | Claude Code | Codex | Without the named agent |
| --- | --- | --- | --- |
| Explorer | `Explore` | `explorer` | General agent with a read-only brief |
| Plan reviewer, diff reviewer | `dev-task-reviewer` | `dev-task-reviewer` | General agent with a read-only brief |
| Worker | `dev-task-worker` | `dev-task-worker` | General agent with the stage spec |

`dev-task-reviewer` and `dev-task-worker` ship with this skill and enforce part of what a brief requests. On Claude Code, the reviewer has no file-editing tools, and neither role can invoke skills or spawn agents. On Codex, the reviewer runs in a read-only sandbox, and neither role can load this skill. Shell access on Claude Code and the other skills on Codex remain available, and a general agent enforces nothing, so every brief states every restriction. If the runtime has no subagents, perform the role yourself as a separate pass with the same brief and criteria, and state in `result.md` that the review was not independent.

Start reviewers from the brief alone; never fork the orchestrator's conversation into them. Request worktree isolation per dispatch and only for parallel waves; see [parallel-execution.md](parallel-execution.md).

## Write the Brief

A worker's brief is its stage spec, built from [../templates/stage.md](../templates/stage.md). Explorers and reviewers get a self-contained brief:

```text
Role: <explorer | plan reviewer | diff reviewer> in an orchestrated change.
Perform only this role. Do not run $dev-task or other skills, change git state, push,
open pull requests, edit files, install anything, spawn agents, or ask the user.

Goal: <one sentence>. The result feeds: <decision>.
Change contract: <outcome, invariants, scope, non-goals>.
Input: <role input below>.
Criteria: <copied from SKILL.md and the templates at dispatch>.
Stop and return NEEDS_DECISION with evidence and options when a finding hinges on a
product choice rather than a defect.
This brief overrides your defaults for scope, criteria, and output format.
Return at most <N> words: <role output contract below>.
```

- Pass the artifact itself: the paths of `task.md` and `execution-plan.md`, the full stage spec, the exact diff range. Never pass a paraphrase.
- Copy criteria from SKILL.md and the templates at dispatch instead of keeping a second copy here.
- Keep the author's assessment out of reviewer briefs. If a reviewer cannot understand the plan without the conversation, that is a finding about the plan.
- Give each explorer one question and each worker one stage.

## Role Contracts

### Explorer

- **Input:** one question, the plan decision it feeds, facts already known, and search hints.
- **Return:** the answer in one to three sentences; facts with `path:line` or command evidence; inferences with their basis; unknowns and what would resolve them. No solution recommendations.

### Plan Reviewer

- **Input:** the change contract, the paths of `task.md` and `execution-plan.md`, the evidence sources, and the step 4 checklist and rejection criteria together with the templates' section rules.
- **Return:** `PASS` or `REVISE`, then findings with section, claim, `path:line` evidence, consequence, and severity `blocking` or `material`. Verify the plan's claims against the repository; report only findings that change the plan or its proof.

### Worker

- **Input:** its stage spec, which carries the change contract, the full stage text, its write scope, its workspace and setup, the interfaces it consumes, the checks the verification schedule assigns to it, and whether test-first development applies.
- **Return:** `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, or `NEEDS_DECISION`; changed files; commands with exit codes; deviations from the brief.

### Diff Reviewer

- **Input:** the change contract, the paths of `task.md` and `execution-plan.md`, the diff range `<base>...<head>`, verification commands with their results, any red-run or mutation evidence for new tests, accepted deviations, and the step 8 review dimensions.
- **Return:** `PASS` or `REVISE`, then findings with `path:line`, a concrete failure scenario (the input or state that leads to a wrong result), severity, and `verified` or `suspected`. Judge from the code and the supplied evidence whether each new test would fail without the change it covers; never revert code to find out.

## Accept Results

- Treat every report as evidence to check. Open the `path:line` facts the plan relies on and read each stage diff. A worker's checks count once they rerun where the verification schedule places them, usually on the merged branch; do not repeat them stage by stage.
- Verify each review finding against the code. Fix confirmed findings; reject the rest with a reason, and record both under Reviews in `task.md`.
- After a revision that changes the solution or a matrix decision, dispatch a fresh reviewer; check local fixes yourself. When two review rounds report a blocking finding on the same decision, bring the decision to the user.
- Before dispatching a read-only role, record a fingerprint of the working tree and confirm it is unchanged afterward. `git status --porcelain` alone misses edits to files that are already modified, so hash the content too: `{ git status --porcelain; git diff HEAD; git ls-files -o --exclude-standard -z | xargs -0 shasum; } | shasum`.
- Keep one writer per worktree. Only the orchestrator changes git state, task status, and files under `.dev-tasks/`.
