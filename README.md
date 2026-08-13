# Skills

[![skills.sh](https://skills.sh/b/zhdanovme/skills)](https://skills.sh/zhdanovme/skills)

## Quick Start

Install all skills and extend the global `AGENTS.md`:

### macOS, Linux, and Unix

```sh
./install.sh
```

### Windows (PowerShell)

```powershell
.\install.ps1
```

The default target is `$CODEX_HOME`, or `~/.codex` when `CODEX_HOME` is not
set. Skills are copied into `<target>/skills`. The repository's `AGENTS.md` is
added to `<target>/AGENTS.md` between these markers:

```text
<!-- ZHDANOVME:SKILLS:START -->
<!-- ZHDANOVME:SKILLS:END -->
```

Running the installer again replaces the existing marked block instead of
adding a duplicate. Content outside the block and unrelated skills remain
untouched. To use a different Codex directory:

```sh
./install.sh /path/to/codex
```

```powershell
.\install.ps1 -Target C:\path\to\codex
```

If Windows blocks local scripts, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Codex discovers skill changes automatically. Restart Codex only if a newly
installed skill does not appear.

### Agent-assisted setup

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

The install scripts perform the same skill installation and managed
`AGENTS.md` extension automatically.

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
|-- install.ps1
|-- install.sh
|-- tests/
|   |-- install_test.ps1
|   `-- install_test.sh
`-- dev-task/
    `-- SKILL.md
```

- [`AGENTS.md`](AGENTS.md) defines the repository's shared principles for complexity, critical reasoning, and information design.
- [`dev-task/SKILL.md`](dev-task/SKILL.md) contains the skill metadata and operating instructions.
