---
stage: <stage id, such as s1-server>
wave: <wave number>
depends_on: [<stage ids>]
state: todo
workspace: <absolute path | isolated worktree, recorded on return>
branch: <branch | isolated worktree branch, recorded on return>
---

<!--
Template for .dev-tasks/<task>/stages/<stage>.md, one per worker stage, written before the stage is
dispatched. Only the orchestrator edits this file: it moves `state` from todo (spec written) to
progress (dispatched or being corrected) to done (diff accepted and the stage integrated into the task
branch with its scheduled checks passing), and it fills the Report when the worker returns.

Dispatch the worker with the content below this comment, not with the file's path: a stage worktree
holds an older copy of this file or none.
-->

# <stage id>: <stage title>

Role: worker in an orchestrated change.
Perform only this role. Do not run $dev-task or other skills, change git state, push,
open pull requests, edit .dev-tasks/, install anything beyond the setup line, spawn
agents, or ask the user.

Goal: <one sentence>. The result feeds: <the stages or wave that depend on it>.
Change contract: <outcome, invariants, scope, and non-goals from task.md>.
Stage: <the full stage text: what to build and how it fits the plan>.
Consumes: <frozen interfaces and where they live | none>.
Access: write only <the stage's write scope>.
Workspace: <absolute path | "your starting working directory" for an isolated worktree>.
Setup: <commands to run first, such as dependency installation | none>.
Test-first: <required | not required>.
Checks: <the checks the verification schedule assigns to this stage, with exact commands>.
Stop and return NEEDS_DECISION with evidence and options when a choice would change
behavior, compatibility, risk, or scope.
This brief overrides your defaults for scope, criteria, and output format.
Return at most <N> words: status (DONE, DONE_WITH_CONCERNS, BLOCKED, or NEEDS_DECISION),
changed files, commands with exit codes, and deviations from this brief.

## Report

<!-- The worker's status, changed files, commands with exit codes, and deviations, plus the orchestrator's acceptance result. -->
