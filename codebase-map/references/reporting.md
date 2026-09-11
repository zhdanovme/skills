# Reporting and Visualization

The report should reduce the time needed to form a correct system model and decide where deeper investigation or refactoring is justified. Use progressive disclosure: whole-system thesis first, conceptual views next, quantitative and evidentiary detail after the reader knows what the numbers refer to.

## Format selection

Prefer the smallest portable format that satisfies the request:

- Use Markdown with Mermaid and tables for an inline or repository-portable report.
- Use MDX when the user requests a rich artifact or the workspace already has an MDX/React renderer.
- Reuse existing shadcn/ui Chart and Recharts conventions when present.
- Do not bootstrap a frontend, install chart dependencies, or introduce a documentation framework unless the user requested a runnable rich report.
- If a rich renderer is unavailable, deliver `report.md` rather than unverified MDX imports. Add `report-data.json` only when the user requests reusable data, several visuals depend on it, or another renderer will consume it.

For a persistent rich report, keep extracted data separate from presentation:

```text
codebase-map-report/
|-- report.mdx
|-- report-data.json
`-- diagrams/
    `-- <flow-or-structure>.mmd
```

Add components or a build project only when the target renderer requires them and that implementation is in scope. Record the repository revision, scan time, scope, exclusions, and commands in the data or report metadata.

## Report data contract

Use stable identifiers so every diagram, chart, table, and finding projects the same model. A rich `report-data.json` should contain only applicable top-level collections:

| Key | Content |
| --- | --- |
| `meta` | Repository revision, scope, timestamp, commands, counting semantics, exclusions, and limitations |
| `inventory` | Reconciled file, line, role, language, and module summaries |
| `demands` | Requirements, pressures, constraints, criticality, source status, confidence, and evidence references |
| `epics` / `capabilities` | Stable groups of related system outcomes and the demands they satisfy |
| `features` | Concrete user- or system-meaningful behaviors, entrypoints, outcomes, and aggregate runtime volume |
| `modules` | Semantic responsibilities, triggers, decisions, dependencies, data and side effects, failure behavior, feature allocation, assurance, and quantitative measurements |
| `volume_allocations` | Single-count implementation-unit assignments to runtime category, module, feature/shared/unattributed, with precision and confidence |
| `data` | Important state, schemas, stores, events, and ownership |
| `flows` | Triggers, steps, decisions, participants, reads/writes, side effects, failures, and assurance references |
| `evidence` | Tests, contracts, schemas, static checks, runtime assertions, or observability mechanisms |
| `relationships` | Directed typed links between model entities, with evidence and confidence where needed |
| `findings` | Ranked observations, interpretations, consequences, recommendations, validation, and confidence |

Do not duplicate independently calculated totals across components. Derive chart series from the canonical inventory or relationships, and include source entity identifiers in chart data so a reader can trace a visual mark back to evidence.

## Required visual coverage

A full report must satisfy this coverage contract:

| Reader uncertainty | Required visual treatment |
| --- | --- |
| What is the system and how do its major parts interact? | One Mermaid architecture flowchart with the system boundary, actors or entrypoints, semantic modules or deployable components, stores, external systems, and directed runtime relationships |
| What logic lives inside each material module? | A module-logic summary table plus Mermaid logic coverage for every material module; dedicate a diagram to complex or central modules and group simple modules only when the result remains readable |
| How do the critical behaviors execute across boundaries? | Mermaid sequence or flow diagrams for the selected high-value or high-risk runtime flows |
| How do important state or data relationships work? | Add Mermaid state, data-flow, or entity relationship views when lifecycle or ownership cannot be understood as efficiently from the architecture and flow diagrams |

The architecture view may also serve as the module map when it names the semantic modules and shows directed calls, events, or data movement clearly. Do not add a second diagram that answers the same question with no additional information. Renderer unavailability is not a reason to omit required Mermaid source; disclose the verification gap and use conservative syntax.

## Report spine

### 1. System thesis

Answer in one screen:

- what the system is and what outcomes it provides;
- its dominant architectural shape;
- where most responsibility and implementation volume live;
- the most important fitness conclusion;
- the largest uncertainty that could change the assessment.

Include the required Mermaid system-architecture view and a few decisive metrics. It should establish the whole-system model before module detail: system boundary, actors or entrypoints, runtime components or semantic modules, owned stores, external systems, and important directed relationships. Do not open with a dense dashboard.

### 2. Demand

Show capabilities, functional requirements, non-functional pressures, constraints, criticality, and unknowns. Distinguish explicit from inferred demand. Prefer a concise capability/pressure table over a feature catalog.

### 3. Structure

Show semantic modules, responsibilities, data ownership, material dependencies, integrations, and implementation distribution. Pair the module diagram with quantitative volume so readers can interpret concentration in context.

### 4. Module logic summaries

Begin with one exact summary table:

| Module | Logic thesis | Triggers / entrypoints | Decisions / invariants | Data / side effects | Dependencies | Features / runtime volume | Assurance | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

Then provide Mermaid logic coverage for every material module. A logic view must show how the module turns a trigger into an outcome through meaningful orchestration, policy decisions, state changes, integrations, side effects, and failure paths; a box with incoming and outgoing dependency arrows alone is not a module-logic summary. Give complex, central, or high-risk modules dedicated diagrams. Several simple modules may share a diagram when each module’s causal path remains distinguishable. Keep exact LOC, feature allocation, test evidence, file references, and confidence next to the relevant module rather than encoding all of them into diagram nodes.

### 5. Runtime volume decomposition

Make this a substantive section, not a row of top-level counters. State the authored-runtime denominator, excluded categories, counting method, classification coverage, feature-specific share, shared share, unattributed rate, and precision limits. Then include:

1. runtime composition by domain/business, application/orchestration, interfaces/adapters, platform/cross-cutting, and unattributed logic;
2. the complete material module-volume table;
3. epic/capability and feature subtotals;
4. the module × feature allocation ledger, grouped by module and including shared/cross-cutting and unattributed rows;
5. a treemap, sunburst, stacked bar, or matrix when it reduces comparison cost more than the tables alone.

The tables must reconcile to the same runtime total. Keep epic/feature and module as separate axes connected through allocations; do not render them as one containment tree when features cross modules. Use a treemap or sunburst only for a true hierarchy such as `runtime → epic → feature` or `runtime → module`, never for a hybrid of both axes.

### 6. Behavior

Show only the key flows needed to explain value, risk, and boundary behavior. Diagram each selected flow with Mermaid sequence, flowchart, or state syntax according to the relationship being explained. For each flow, connect trigger, policy decisions, modules, data, side effects, failure behavior, evidence, and confidence.

### 7. Assurance

Map evidence to critical capabilities, flows, boundaries, and failure modes. Explain the observed test strategy and important gaps. Avoid presenting a test pyramid or coverage percentage as the strategy itself.

### 8. Fitness and opportunities

Lead with ranked cross-view findings. Recognize justified complexity and architectural strengths as well as risks. Use the finding contract from `analysis-model.md`; keep recommendations proportional to evidence and do not imply that assessment alone authorizes implementation.

### 9. Evidence and method

Record commands, definitions, exclusions, module mappings, source references, confidence limits, and material unknowns. Put detailed inventories here or in `report-data.json` so they remain auditable without dominating the main narrative.

## Representation choices

| Reader question | Preferred representation |
| --- | --- |
| What are the system boundaries and major runtime relationships? | Mermaid architecture flowchart with labeled boundaries and directed edges; required for a full report |
| What logic does each module execute? | Module summary table plus Mermaid flowchart from trigger through decisions and effects; required for every material module |
| How does a critical interaction unfold? | Mermaid sequence diagram |
| How does an entity change state? | Mermaid state diagram |
| Who owns, reads, writes, or publishes important data? | Mermaid flowchart or `erDiagram`, depending on whether movement or structure is the uncertainty |
| Where is authored volume concentrated? | Treemap or ranked horizontal bar chart |
| How is runtime logic composed? | Stacked bar plus exact runtime-category table |
| How much runtime volume does each module own? | Ranked module table and horizontal bar |
| How much runtime volume implements each epic and feature? | Hierarchical table or treemap with exact subtotals |
| Which modules implement which features, and at what volume? | Feature × module matrix or stacked bars plus the allocation ledger |
| How do production, test, docs, and schema volume compare? | Stacked horizontal bars |
| Which modules combine volume, coupling, criticality, or weak assurance? | Scatter or bubble chart with a companion table |
| Which flows have which evidence? | Heatmap or exact matrix table |
| Which module realizes which capability? | Matrix table; diagram only when relationships remain sparse |
| What changed over time? | Line or area chart only when the time series is representative |

Use shadcn/ui Chart components as a visual system and Recharts as the quantitative renderer when available. Always provide titles, units, definitions, accessible labels, and a nearby interpretation. Preserve the underlying values in `report-data.json` or a table.

For portable Markdown, replace unavailable quantitative charts with a sorted numeric table. An optional proportional text bar may aid scanning, but keep the exact value and share in separate columns so the result remains accessible and auditable. Do not use a Mermaid flowchart to imitate a bar chart. Use Mermaid `xychart-beta` only when the target renderer is known to support it and the rendered result is verified.

## Mermaid constraints

- Diagram semantic boundaries, meaningful transitions, or runtime sequence—not every file and import.
- In the architecture view, use subgraphs or explicit nodes to distinguish the system boundary, deployable units, semantic modules, data stores, and external systems.
- In module logic views, show the applicable path from trigger or entrypoint through orchestration and policy decisions to data, integrations, outputs, and failures; do not invent absent stages.
- Collapse internal details until each node has a distinct responsibility.
- Keep direction explicit and label non-obvious calls, events, reads, writes, or ownership relationships. Do not rely on color or line style alone to distinguish them.
- Split diagrams by view or flow when one diagram becomes a hairball.
- Use stable identifiers and quote labels containing punctuation.
- Verify syntax with an available Mermaid renderer when possible; otherwise keep to conservative `flowchart`, `sequenceDiagram`, and `stateDiagram-v2` syntax.

## Avoid misleading visuals

Do not use:

- a single architecture-health gauge or composite score;
- pie charts for many modules or similar proportions;
- an unsimplified repository dependency graph;
- 3D, decorative, or duplicated charts;
- LOC as a proxy for quality or business value;
- color alone to encode risk or confidence;
- numeric precision unsupported by the extraction method.

Every visual must answer a named question more efficiently than prose or a short table. Remove it if it merely repeats the surrounding text.

## Final audit

Verify the rendered or portable artifact, not only its source:

- the opening supplies a usable whole-system picture;
- a Mermaid architecture view shows the system boundary, runtime parts, stores, external systems, and directed relationships;
- Demand, Structure, Behavior, and Assurance use consistent entities and names;
- every material module appears in the logic-summary table and in a legible Mermaid logic view;
- complex, central, or high-risk modules have enough dedicated visual depth to expose decisions, data effects, integrations, and failures;
- authored runtime scope and exclusions are explicit;
- module totals and feature/shared/unattributed totals reconcile to the same runtime denominator;
- classification coverage, feature-specific share, shared share, and unattributed rate are visible, and a partial map is not presented as complete;
- chart totals reconcile with the evidence inventory;
- diagrams and prose describe the same relationships;
- facts, inferences, assessments, and unknowns remain distinguishable;
- each ranked opportunity follows from a visible cross-view mismatch;
- the report remains understandable without hover-only content or hidden interactions;
- all local links and referenced artifacts resolve.
