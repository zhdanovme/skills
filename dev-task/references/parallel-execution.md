# Parallel Execution

Read this before planning a wave with two or more stages. A wave shortens only implementation: evidence, the plan, reviews, merges, verification, and delivery stay sequential, and every worktree adds setup and merge cost.

## Decide Whether a Wave Pays Off

Plan a wave only when its stages satisfy the wave rules in SKILL.md and each stage is large enough to outweigh:

- its brief and the review of its diff;
- worktree setup: dependency installation, gitignored files such as `.env`, and cold build caches;
- concurrent checks: stages whose tests share a database, fixed ports, or containers need separate resources or sequential checks;
- the merge and its integration checks.

Otherwise run the stages sequentially in the task worktree, delegated or not.

## Run a Wave

1. Add a wave log to the durable task file, below the plan, and keep each stage's branch, worktree, and merge state there. The Execution Plan table keeps its six columns.
2. Commit every stage the wave depends on, including frozen contracts, on the task branch. A worktree starts from a commit; uncommitted work does not reach it.
3. Provide one worktree and branch per stage from the task branch `HEAD`, as described for your platform below, and decide how each gets ready to run checks: prepare a worktree you created yourself before dispatch, or put the preparation commands, such as dependency installation, on the brief's setup line.
4. Dispatch one worker per stage, at most three at a time, with its workspace and setup in the brief.
5. When a worker returns, record its worktree and branch in the wave log, read its stage diff, reject edits outside its write scope, rerun the stage checks in its worktree, and commit the stage on its branch.
6. Merge stage branches into the task branch one at a time in plan order, running the integration checks after each merge. A clean merge does not prove a working build: a symbol renamed in one stage and called by its old name in another fails only in checks.
7. Treat a merge conflict or a failed integration check as a decomposition error: fix it in the task worktree, record the deviation, and correct the remaining waves before continuing. Do not re-dispatch the same brief.
8. After the last wave, run the full relevant suite on the task branch, then remove the stage worktrees and delete their branches. Deliver one PR from the task branch.

When a worker returns `BLOCKED` or `NEEDS_DECISION`, pause the stages that depend on it until the orchestrator resolves it; independent stages continue.

## Platform Mechanics

### Claude Code

- Dispatch each wave stage with `isolation: "worktree"` on the `Agent` call. Keep isolation out of the `dev-task-worker` definition, because sequential stages run in the task worktree.
- The isolated worktree does not exist until dispatch, so the brief names the workspace as "your starting working directory" and puts dependency installation on the setup line. Never name the task worktree as a wave stage's workspace: parallel workers would then edit one checkout.
- Subagent worktrees branch from the repository's default branch unless the `worktree.baseRef` setting is `"head"`; inside a worktree, `"head"` resolves to that worktree's `HEAD`. Without it, a worker misses the task branch and its frozen contracts. The setting is persistent configuration: ask the user before changing it, and run the wave sequentially if they decline.
- Claude Code creates these worktrees under `.claude/worktrees/` and copies the gitignored files listed in `.worktreeinclude`. Locate a stage worktree with `git worktree list`; it stays on disk after its worker returns with changes, so remove it after the merge.

### Codex

- When the runtime offers no per-agent worktree isolation, create each stage worktree from the task worktree with `git worktree add .worktrees/<stage> -b <task-branch>-<stage> HEAD`, prepare it, and pass its absolute path in the brief.
- The `workspace-write` sandbox requires approval for edits outside the working directory and configured writable roots, so keep stage worktrees inside the task worktree.

### Both Platforms

- Keep stage worktree directories out of git status and out of the PR by appending their pattern to the file that `git rev-parse --git-path info/exclude` prints: `.claude/worktrees/` for Claude Code, `.worktrees/` for Codex. That file applies to every worktree of the repository; in a linked worktree `.git` is a file, so a literal `.git/info/exclude` path fails.
- Confirm that the project's test runners, linters, and watchers do not collect files from stage worktrees nested in the task worktree.
