# Skills

[![skills.sh](https://skills.sh/b/zhdanovme/skills)](https://skills.sh/zhdanovme/skills)

## Quick Start

Copy this prompt into your coding agent:

```text
Use https://github.com/zhdanovme/skills as the source repository. Add its
`dev-task` and `information-design` skills to the shared skills available in
your current agent environment. Merge the principles from the repository's
`AGENTS.md` into the appropriate shared or global agent rules. Determine the
correct locations and formats from the agent, tools, and conventions currently
in use. Preserve existing configuration, avoid duplicate instructions, and
verify that the installed skills and merged rules are discoverable and active.
```

A compact collection of agent skills for disciplined software development and information design. The repository favors high-value outcomes, explicit constraints, maintainable boundaries, effective communication, and evidence-based completion.

## Available Skills

| Skill | Purpose |
| --- | --- |
| [`dev-task`](dev-task/SKILL.md) | Route small changes directly and guide larger changes through root-cause research, architectural review, implementation, verification, and PR review. |
| [`information-design`](information-design/SKILL.md) | Structure AI responses, documentation, explanations, and landing pages around the reader's relevant uncertainties, decisions, and actions. |

## `dev-task`

Use `dev-task` when implementing a feature, bug fix, refactor, or other change in an existing repository. It guides the agent to:

- classify clear, local, low-risk work as a small change and implement it without planning ceremony;
- research larger or uncertain work in repository context, tracing the root cause and owning subsystem;
- review the plan for cohesion, coupling, cumulative change surface, consequential decisions, refactoring options, and test coverage;
- persist `.dev-tasks/<name>.md` only when a durable multi-step or decision-heavy plan is useful;
- implement and verify the systemically coherent change rather than optimizing only for the smallest immediate diff;
- open or update a pull request when PR delivery is in scope, then review the complete diff and address material findings;
- report the outcome, validation, diff cost, decisions, deviations, PR status, and remaining risks.

## `information-design`

Use `information-design` when creating, restructuring, or critiquing communication whose hierarchy, abstraction, precision, representation, or density materially affects the result. It guides the agent to:

- identify the audience, intended outcome, and highest-priority uncertainties;
- choose an appropriate abstraction level and reveal detail progressively;
- select prose, lists, tables, diagrams, or examples according to the relationship being communicated;
- derive structure, emphasis, and representation from the communication contract rather than artifact-specific templates;
- remove empty repetition while preserving redundancy that improves comprehension, trust, accessibility, error prevention, or conversion;
- audit the artifact for relevance, evidence, precision, representation, and attention cost.

## Repository Structure

```text
.
|-- AGENTS.md
|-- README.md
|-- dev-task/
|   `-- SKILL.md
`-- information-design/
    |-- SKILL.md
    `-- agents/
        `-- openai.yaml
```

- [`AGENTS.md`](AGENTS.md) defines the repository's shared principles for critical reasoning and information design.
- [`dev-task/SKILL.md`](dev-task/SKILL.md) contains the development workflow and its architecture, complexity, refactoring, and testing principles.
- [`information-design/SKILL.md`](information-design/SKILL.md) contains the artifact-agnostic information-design workflow and audit.
