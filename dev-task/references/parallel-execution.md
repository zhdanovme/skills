# Parallel Execution

Read this before planning a wave with two or more stages. A wave shortens only implementation: evidence, the plan, reviews, merges, verification, and delivery stay sequential, and every worktree adds setup and merge cost.

## Decide Whether a Wave Pays Off

Plan a wave only when its stages satisfy the wave rules in [../templates/execution-plan.md](../templates/execution-plan.md) and each stage is large enough to outweigh:

- its brief and the review of its diff;
- worktree setup: dependency installation, gitignored files such as `.env`, and cold build caches;
- concurrent checks: stages whose tests share a database, fixed ports, or containers need separate resources or sequential checks;
- the merge and the wave's share of the verification schedule.

Otherwise run the stages sequentially in the task worktree, delegated or not.

## Run a Wave

1. Write a stage spec for every stage of the wave from [../templates/stage.md](../templates/stage.md). Its frontmatter tracks the stage's state, workspace, and branch; the stage table in `execution-plan.md` keeps its six columns.
2. Commit the task folder and every stage the wave depends on, including frozen contracts, on the task branch. A worktree starts from a commit; uncommitted work does not reach it.
3. Provide one worktree and branch per stage from the task branch `HEAD`, as described for your platform below, and decide how each gets ready to run checks: prepare a worktree you created yourself before dispatch, or put the preparation commands, such as dependency installation, on the brief's setup line.
4. Dispatch one worker per stage, at most three at a time, with its workspace and setup in the brief.
5. When a worker returns, record its report, worktree, and branch in its stage spec in the task worktree, read its stage diff, reject edits outside its write scope, and commit the stage on its branch. Do not rerun its checks here; the verification schedule runs them on the merged branch.
6. Once every stage of the wave is committed, merge the stage branches into the task branch one at a time in plan order, then run the wave's checks from the verification schedule once, if it schedules any. A clean merge does not prove a working build: a symbol renamed in one stage and called by its old name in another fails only in checks. Set each stage spec to `done` once its merge and scheduled checks pass.
7. Treat a merge conflict or a failed check as a decomposition error. Map the failure to a stage through the failing test and the write scopes, and bisect over the wave's merge commits only when the mapping is ambiguous. Fix it in the task worktree, rerun the failed checks, record the deviation, and correct the remaining waves before continuing. Do not re-dispatch the same brief.
8. After the last wave, run the final checks from the verification schedule once, then remove the stage worktrees and delete their branches. Deliver one PR from the task branch.

When a worker returns `BLOCKED` or `NEEDS_DECISION`, pause the stages that depend on it until the orchestrator resolves it; independent stages continue.

Stage specs and the rest of `.dev-tasks/` change only on the task branch. Never edit or commit them in a stage worktree; a stage branch that touches them conflicts with the task branch at merge.

## Platform Mechanics

### Claude Code

- Dispatch each wave stage with `isolation: "worktree"` on the `Agent` call. Keep isolation out of the `dev-task-worker` definition, because sequential stages run in the task worktree.
- The isolated worktree does not exist until dispatch, so the brief names the workspace as "your starting working directory" and puts dependency installation on the setup line. Never name the task worktree as a wave stage's workspace: parallel workers would then edit one checkout.
- Subagent worktrees branch from the repository's default branch unless the `worktree.baseRef` setting is `"head"`; inside a worktree, `"head"` resolves to that worktree's `HEAD`. Without it, a worker misses the task branch and its frozen contracts. The setting is persistent configuration: ask the user before changing it, and run the wave sequentially if they decline.
- Claude Code creates these worktrees under `.claude/worktrees/` and copies the gitignored files listed in `.worktreeinclude`. It names each worktree and branch itself, so record them in the stage spec when the worker returns; `git worktree list` shows them. A worktree with changes stays on disk after its worker returns, so remove it after the merge.

### Codex

- When the runtime offers no per-agent worktree isolation, create each stage worktree from the task worktree with `git worktree add .worktrees/<stage> -b <task-branch>-<stage> HEAD`, prepare it, and pass its absolute path in the brief.
- The `workspace-write` sandbox requires approval for edits outside the working directory and configured writable roots, so keep stage worktrees inside the task worktree.

### Both Platforms

- Keep stage worktree directories out of git status and out of the PR by appending their pattern to the file that `git rev-parse --git-path info/exclude` prints: `.claude/worktrees/` for Claude Code, `.worktrees/` for Codex. That file applies to every worktree of the repository; in a linked worktree `.git` is a file, so a literal `.git/info/exclude` path fails.
- Confirm that the project's test runners, linters, and watchers do not collect files from stage worktrees nested in the task worktree.
