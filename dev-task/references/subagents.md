# Subagents

Read this before the first dispatch. The orchestrator builds every brief from it and verifies every result; subagents never see the conversation or this skill.

## Choose the Agent

| Role | Claude Code | Codex | Without the named agent |
| --- | --- | --- | --- |
| Explorer | `Explore` | `explorer` | General agent with a read-only brief |
| Plan reviewer, diff reviewer | `dev-task-reviewer` | `dev-task-reviewer` | General agent with a read-only brief |
| Worker | `dev-task-worker` | `dev-task-worker` | General agent with the worker brief |

`dev-task-reviewer` and `dev-task-worker` ship with this skill and enforce part of what a brief requests. On Claude Code, the reviewer has no file-editing tools, and neither role can invoke skills or spawn agents. On Codex, the reviewer runs in a read-only sandbox, and neither role can load this skill. Shell access on Claude Code and the other skills on Codex remain available, and a general agent enforces nothing, so every brief states every restriction. If the runtime has no subagents, perform the role yourself as a separate pass with the same brief and criteria, and state in the summary that the review was not independent.

Start reviewers from the brief alone; never fork the orchestrator's conversation into them. Request worktree isolation per dispatch and only for parallel waves; see [parallel-execution.md](parallel-execution.md).

## Write the Brief

Each brief is self-contained:

```text
Role: <explorer | plan reviewer | worker | diff reviewer> in an orchestrated change.
Perform only this role. Do not run $dev-task or other skills, change git state, push,
open pull requests, edit .dev-tasks/, install anything beyond the setup line, spawn
agents, or ask the user.

Goal: <one sentence>. The result feeds: <decision>.
Change contract: <outcome, invariants, scope, non-goals>.
Input: <role input below>.
Criteria: <copied from SKILL.md at dispatch>.
Access: <read-only | write only: paths>.
Workspace: <absolute path | "your starting working directory" for an isolated worktree>.
Setup: <commands to run before the work, such as dependency installation | none>.
Stop and return NEEDS_DECISION with evidence and options when a choice would change
behavior, compatibility, risk, or scope.
This brief overrides your defaults for scope, criteria, and output format.
Return at most <N> words: <role output contract below>.
```

- Pass the artifact itself: the full plan text or its `.dev-tasks` path, the full stage text, the exact diff range. Never pass a paraphrase.
- Copy criteria from SKILL.md at dispatch instead of keeping a second copy here.
- Keep the author's assessment out of reviewer briefs. If a reviewer cannot understand the plan without the conversation, that is a finding about the plan.
- Give each explorer one question and each worker one stage.

## Role Contracts

### Explorer

- **Input:** one question, the plan decision it feeds, facts already known, and search hints.
- **Return:** the answer in one to three sentences; facts with `path:line` or command evidence; inferences with their basis; unknowns and what would resolve them. No solution recommendations.

### Plan Reviewer

- **Input:** the change contract, the full plan or its path, the evidence sources, and the step 4 checklist and rejection criteria.
- **Return:** `PASS` or `REVISE`, then findings with section, claim, `path:line` evidence, consequence, and severity `blocking` or `material`. Verify the plan's claims against the repository; report only findings that change the plan or its proof.

### Worker

- **Input:** the change contract, the full stage text, its write scope, its workspace and setup, the interfaces it consumes, its Test Coverage Plan rows with their commands, and whether test-first development applies.
- **Return:** `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, or `NEEDS_DECISION`; changed files; commands with exit codes; deviations from the brief.

### Diff Reviewer

- **Input:** the change contract, the plan, the diff range `<base>...<head>`, verification commands with their results, any red-run or mutation evidence for new tests, accepted deviations, and the step 8 review dimensions.
- **Return:** `PASS` or `REVISE`, then findings with `path:line`, a concrete failure scenario (the input or state that leads to a wrong result), severity, and `verified` or `suspected`. Judge from the code and the supplied evidence whether each new test would fail without the change it covers; never revert code to find out.

## Accept Results

- Treat every report as evidence to check. Open the `path:line` facts the plan relies on; read each stage diff and rerun its checks yourself. Rerunning checks is verification, not redoing the work.
- Verify each review finding against the code. Fix confirmed findings; reject the rest with a reason.
- After a revision that changes the solution or a matrix decision, dispatch a fresh reviewer; check local fixes yourself. When two review rounds report a blocking finding on the same decision, bring the decision to the user.
- Before dispatching a read-only role, record `git status --porcelain` and the checksum of the durable task file, which git ignores; confirm both are unchanged afterward.
- Keep one writer per worktree. Only the orchestrator changes git state and task status.
