<!--
Template for .dev-tasks/<task>/execution-plan.md, written in step 4 for review and grill. Delete every
instruction comment as you fill a section.
-->

# Execution Plan: <task title>

## Stages

Frozen contracts: <interfaces committed before any parallel wave, or none>

| Stage | Wave | Depends on | Write scope | Checks | Executor |
| --- | --- | --- | --- | --- | --- |

<!--
Derive the stages from the plan in task.md; Checks name rows of its Test Coverage Plan, and Executor is
orchestrator or worker. Use exactly these six columns.

- Give each stage a short kebab-case id, such as s1-server. Its spec file always reuses the id, and so
  do its branch suffix and worktree directory whenever the orchestrator creates them.
- Stages that share a wave run in parallel, each in its own worktree; read
  references/parallel-execution.md before planning one.
- Assign a stage to a worker only when delegation saves more than it costs: the brief and the diff
  review, plus worktree setup and merge for parallel stages. Otherwise the orchestrator implements it
  and the stage needs no spec.
- Put stages in the same wave only when they:
  - have disjoint write scopes, including generated files, snapshots, and lockfiles;
  - leave shared integration files, such as registries, routing, dependency-injection configuration,
    migration ordering, catalogs, changelogs, and .dev-tasks/, to orchestrator stages before or after
    the wave;
  - consume only interfaces frozen by an earlier committed stage;
  - can run their own checks without the other stages of the wave.
- Cut stages along ownership boundaries and keep code with its tests. A decomposition that needs edits
  across many unrelated modules signals misplaced responsibility.
- For a change the orchestrator implements in one stage, replace the table with
  "Single stage, implemented by the orchestrator" and keep the verification schedule.
-->

## Verification Schedule

| Check | Covers | Runs at | Runs by | Estimated time |
| --- | --- | --- | --- | --- |

Planned full-suite runs: <number>

<!--
Schedule every check to run once, at the most integrated point where its failure can still be traced to
its stage cheaply. Time goes to fixes, not to repeated runs of the same checks.

- Stage: static checks and the stage's targeted tests, run by its executor in its workspace. The
  orchestrator reads the report and the diff instead of rerunning them in the stage workspace.
- Wave: after merging every stage of a wave, run the static checks, the targeted tests of all its
  stages, and its integration checks once on the task branch. Schedule a wave run only when a later
  wave builds on the wave; otherwise the final run covers it.
- Final: once on the integrated task branch, the static checks, the relevant suite, and every stage
  check the suite does not cover. Stage-level runs only give the executor fast feedback; this run and
  the wave runs are the evidence.
- Verify a stage on its own before merging only when a failure after the merge would be expensive to
  trace: data migrations, security boundaries, public API changes.
- On a failure, map it to a stage through the failing test and the write scopes; bisect over the
  wave's merge commits only when the mapping is ambiguous. After a fix, rerun the failed checks, then
  the final run once.
- Plan one full-suite run. More than one before any fix means the schedule repeats work.
-->
