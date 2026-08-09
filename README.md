# Skills

## Quick Start

Copy this prompt into your coding agent:

```text
Use https://github.com/zhdanovme/skills as the source repository. Add its
`dev-task` skill to the shared skills available in your current agent
environment. Merge the principles from the repository's `AGENTS.md` into the
appropriate shared or global agent rules. Determine the correct locations and
formats from the agent, tools, and conventions currently in use. Preserve
existing configuration, avoid duplicate instructions, and verify that the
installed skill and merged rules are discoverable and active.
```

A compact collection of agent skills for disciplined software development. The repository favors high-value outcomes, explicit constraints, small diffs, and evidence-based completion.

## Available Skills

| Skill | Purpose |
| --- | --- |
| [`dev-task`](dev-task/SKILL.md) | Implement repository changes with clear scope, explicit invariants, consequential decision tracking, focused verification, and concise result reporting. |

## `dev-task`

Use `dev-task` when implementing a feature, bug fix, refactor, or other change in an existing repository. It guides the agent to:

- understand the relevant architecture, behavior, conventions, constraints, and tests;
- separate the desired outcome from a proposed implementation;
- define observable results, invariants, scope, and completion evidence;
- identify decisions that materially affect behavior, architecture, data, compatibility, risk, or cost;
- create a `.dev-tasks/<name>.md` decision record only when clarification and decision tracking are genuinely useful;
- implement the smallest coherent change and verify its real behavior;
- report the outcome, implementation, validation, diff cost, and deviations from the original decisions.

## Repository Structure

```text
.
|-- AGENTS.md
|-- README.md
`-- dev-task/
    `-- SKILL.md
```

- [`AGENTS.md`](AGENTS.md) defines the repository's shared principles for complexity, critical reasoning, and information design.
- [`dev-task/SKILL.md`](dev-task/SKILL.md) contains the skill metadata and operating instructions.
