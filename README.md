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
`dev-task`, `information-design`, and `learn-from-pr-reviews` skills to the
shared skills available in your current agent environment. Merge the principles
from the repository's `AGENTS.md` into the appropriate shared or global agent
rules. Determine the correct locations and formats from the agent, tools, and
conventions currently in use. Preserve existing configuration, avoid duplicate
instructions, and
verify that the installed skills and merged rules are discoverable and active.
```

The install scripts perform the same skill installation and managed
`AGENTS.md` extension automatically.

A compact collection of agent skills for disciplined software development and information design. The repository favors high-value outcomes, explicit constraints, maintainable boundaries, effective communication, and evidence-based completion.

## Available Skills

| Skill | Purpose |
| --- | --- |
| [`dev-task`](dev-task/SKILL.md) | Route small changes directly and guide larger changes through root-cause research, architectural review, implementation, verification, and PR review. |
| [`information-design`](information-design/SKILL.md) | Structure AI responses, documentation, explanations, and landing pages around the reader's relevant uncertainties, decisions, and actions. |
| [`learn-from-pr-reviews`](learn-from-pr-reviews/SKILL.md) | Read PR feedback and preserve durable, project-specific prevention rules in `AGENTS.md`. |

## `dev-task`

Use `dev-task` when implementing a feature, bug fix, refactor, or other change in an existing repository. It guides the agent to:

- classify clear, local, low-risk work as a small change and implement it without planning ceremony;
- show the complete workflow first, then detail each stage in the same order;
- gather repository evidence for larger or uncertain work before building its review plan;
- build and review four explicit plan sections: Minimal Reasonable Solution, Matrix Decisions on Complications, Refactoring Options, and Test Coverage Plan;
- persist `.dev-tasks/<name>.md` only when a durable multi-step or decision-heavy plan is useful;
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
|   `-- install_test.sh
|-- dev-task/
|   |-- SKILL.md
|   `-- agents/
|       `-- openai.yaml
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
- [`dev-task/SKILL.md`](dev-task/SKILL.md) contains the development workflow and its architecture, complexity, refactoring, and testing principles.
- [`information-design/SKILL.md`](information-design/SKILL.md) contains the artifact-agnostic information-design workflow and audit.
- [`learn-from-pr-reviews/SKILL.md`](learn-from-pr-reviews/SKILL.md) contains the PR-feedback triage and durable project-memory workflow.
