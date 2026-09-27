# Skills

[![skills.sh](https://skills.sh/b/zhdanovme/skills)](https://skills.sh/zhdanovme/skills)

## Quick Start

Install all skills and extend the global agent rules of both Codex and
Claude Code:

### macOS, Linux, and Unix

```sh
./install.sh
```

### Windows (PowerShell)

```powershell
.\install.ps1
```

### Targets

With no arguments the installer writes to both agent homes:

| Agent | Default home | Skills | Subagents | Rules file |
| --- | --- | --- | --- | --- |
| Codex | `$CODEX_HOME`, or `~/.codex` | `<home>/skills` | `<home>/agents/*.toml` | `<home>/AGENTS.md` |
| Claude Code | `$CLAUDE_CONFIG_DIR`, or `~/.claude` | `<home>/skills` | `<home>/agents/*.md` | `<home>/CLAUDE.md` |

Skills that delegate work ship subagent definitions as
`<skill>/subagents/<platform>/<skill>-*`. The installer owns the `<skill>-*`
files of that platform in `<home>/agents`: it replaces them on every run and
removes stale ones, while other agent files stay untouched.

Both rules files receive the same repository `AGENTS.md` content between these
markers:

```text
<!-- ZHDANOVME:SKILLS:START -->
<!-- ZHDANOVME:SKILLS:END -->
```

Running the installer again replaces the existing marked block instead of
adding a duplicate. Content outside the block is preserved unchanged, and
unrelated skills remain untouched.

Install one agent only, or point it at a different directory:

```sh
./install.sh --codex                    # Codex default home only
./install.sh --claude                   # Claude Code default home only
./install.sh --codex /path/to/codex
./install.sh --claude /path/to/claude
./install.sh /path/to/codex             # a bare directory is a Codex home
```

```powershell
.\install.ps1 -Codex                    # Codex default home only
.\install.ps1 -Claude                   # Claude Code default home only
.\install.ps1 -Target C:\path\to\codex
.\install.ps1 -ClaudeTarget C:\path\to\claude
```

If Windows blocks local scripts, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Codex and Claude Code discover skill changes automatically. Restart the agent
only if a newly installed skill does not appear.

### Agent-assisted setup

Copy this prompt into your coding agent:

```text
Use https://github.com/zhdanovme/skills as the source repository. Add its
`codebase-map`, `dev-task`, `information-design`, and `learn-from-pr-reviews`
skills to the shared skills available in your current agent environment, and
register the subagent definitions under `dev-task/subagents/` for your agent. Merge
the principles from the repository's `AGENTS.md` into the appropriate shared or global agent
rules. Determine the correct locations and formats from the agent, tools, and
conventions currently in use. Preserve existing configuration, avoid duplicate
instructions, and
verify that the installed skills and merged rules are discoverable and active.
```

The install scripts perform the same skill and subagent installation and managed
rules extension automatically, for `AGENTS.md` and `CLAUDE.md` alike.

A compact collection of agent skills for disciplined software development and information design. The repository favors high-value outcomes, explicit constraints, maintainable boundaries, effective communication, and evidence-based completion.

## Available Skills

| Skill | Purpose |
| --- | --- |
| [`codebase-map`](codebase-map/SKILL.md) | Explain a repository through Mermaid system architecture and module logic, runtime volume, assurance, and architectural fitness. |
| [`dev-task`](dev-task/SKILL.md) | Route small changes directly and guide larger changes through root-cause research, architectural review, staged or parallel implementation with subagents, verification, and PR review. |
| [`information-design`](information-design/SKILL.md) | Structure AI responses, documentation, explanations, and landing pages around the reader's relevant uncertainties, decisions, and actions. |
| [`learn-from-pr-reviews`](learn-from-pr-reviews/SKILL.md) | Read PR feedback and preserve durable, project-specific prevention rules in `AGENTS.md`. |

## `codebase-map`

Use `codebase-map` when onboarding to a repository, assessing its architecture, comparing module size and responsibility, reviewing test strategy, or identifying evidence-backed refactoring opportunities. It guides the agent to:

- reconstruct the system through Demand, Structure, Behavior, and Assurance rather than presenting disconnected repository metrics;
- connect requirements and capabilities to runtime flows, semantic modules, data ownership, and tests;
- visualize the system architecture and the runtime logic of every material module with appropriately scoped Mermaid diagrams;
- decompose authored runtime logic into reconciled module, epic/capability, and feature volumes without double-counting shared code;
- measure production, test, documentation, configuration, schema, generated, and vendor volume transparently;
- treat volume, complexity, criticality, change pressure, assurance, and confidence as distinct measurements;
- derive architectural Fitness from cross-view mismatches instead of a synthetic health score;
- deliver a portable Markdown/Mermaid report or a richer MDX report using an existing shadcn/ui and Recharts renderer.

## `dev-task`

Use `dev-task` when implementing a feature, bug fix, refactor, or other change in an existing repository. It guides the agent to:

- classify clear, local, low-risk work as a small change and implement it without planning ceremony;
- recommend a separate worktree for each task and a pull request when repository access permits;
- split independently deliverable parts of a request into separate tasks, each with its own worktree and PR, when at least one part needs the reviewed path;
- offer `$grill-with-docs` before planning exceptionally large or domain-heavy changes;
- show the complete workflow first, then detail each stage in the same order;
- keep the main session as the orchestrator and delegate only bounded roles: built-in explorers for evidence, `dev-task-worker` for plan stages, and the read-only `dev-task-reviewer` for plan and diff review, each from a self-contained brief;
- gather repository evidence for larger or uncertain work before building its review plan;
- build and review five explicit plan sections: Minimal Reasonable Solution, Matrix Decisions on Complications, Refactoring Options, Test Coverage Plan, and Execution Plan;
- decompose implementation into stages and, when write scopes are disjoint and contracts are frozen, run parallel waves of workers in separate worktrees merged into one task branch;
- persist `.dev-tasks/<name>.md` only when a durable multi-step or decision-heavy plan is useful, add `.dev-tasks/` to the target repository's `.gitignore`, and track its lifecycle through the structured `draft`, `todo`, `progress`, optional `pr`, and `done` statuses;
- implement and verify the systemically coherent change rather than optimizing only for the smallest immediate diff;
- create the implementation summary with `$information-design` from the verified diff and evidence;
- use that summary for PR delivery, review the complete diff, fix material findings, and refresh the summary before final delivery.

## `information-design`

Use `information-design` when creating, restructuring, or critiquing communication whose hierarchy, abstraction, precision, representation, or density materially affects the result. It guides the agent to:

- identify the audience, intended outcome, and highest-priority uncertainties;
- separate foundational theory from the practical information-design workflow;
- build the smallest conceptual spine before significant derived invariants, decisions, and operational details;
- select prose, lists, tables, diagrams, or examples according to the relationship being communicated;
- derive structure, emphasis, and representation from the communication contract rather than artifact-specific templates;
- remove empty repetition while preserving redundancy that improves comprehension, trust, accessibility, error prevention, or conversion;
- audit the artifact for relevance, evidence, precision, representation, and attention cost.

## `learn-from-pr-reviews`

Use `learn-from-pr-reviews` when reading or addressing pull-request feedback. It guides the agent to:

- collect top-level reviews, inline threads, replies, and relevant PR conversation;
- distinguish current PR actions from reusable project rules;
- validate each candidate against the accepted outcome and current repository evidence;
- create or update the root `AGENTS.md` with one deduplicated `Code Consistency` section;
- preserve concise, scoped prevention rules while excluding one-off feedback and review history.

## Repository Structure

```text
.
|-- AGENTS.md
|-- README.md
|-- install.ps1
|-- install.sh
|-- tests/
|   |-- install_test.ps1
|   |-- install_test.sh
|   `-- subagents_test.py
|-- codebase-map/
|   |-- SKILL.md
|   |-- agents/
|   |   `-- openai.yaml
|   |-- references/
|   |   |-- analysis-model.md
|   |   |-- metrics.md
|   |   `-- reporting.md
|-- dev-task/
|   |-- SKILL.md
|   |-- agents/
|   |   `-- openai.yaml
|   |-- references/
|   |   |-- parallel-execution.md
|   |   `-- subagents.md
|   `-- subagents/
|       |-- claude/
|       |   |-- dev-task-reviewer.md
|       |   `-- dev-task-worker.md
|       `-- codex/
|           |-- dev-task-reviewer.toml
|           `-- dev-task-worker.toml
|-- information-design/
|   |-- SKILL.md
|   `-- agents/
|       `-- openai.yaml
`-- learn-from-pr-reviews/
    |-- SKILL.md
    `-- agents/
        `-- openai.yaml
```

- [`AGENTS.md`](AGENTS.md) defines the repository's shared principles for critical reasoning and information design.
- [`codebase-map/SKILL.md`](codebase-map/SKILL.md) contains the repository-system model, evidence discipline, and architecture-fitness workflow.
- [`dev-task/SKILL.md`](dev-task/SKILL.md) contains the development workflow and its architecture, complexity, refactoring, testing, and delegation principles; its `references/` hold the subagent brief contracts and the parallel worktree protocol, and `subagents/` holds the Claude Code and Codex definitions of its worker and reviewer.
- `agents/openai.yaml` files are Codex UI metadata for a skill, not subagent definitions.
- [`tests/`](tests) verify both installers and the consistency of shipped subagent definitions: `sh tests/install_test.sh`, `pwsh tests/install_test.ps1`, and `python3 tests/subagents_test.py`.
- [`information-design/SKILL.md`](information-design/SKILL.md) contains the artifact-agnostic information-design workflow and audit.
- [`learn-from-pr-reviews/SKILL.md`](learn-from-pr-reviews/SKILL.md) contains the PR-feedback triage and durable project-memory workflow.
