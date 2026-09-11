# Metrics and Inventory

Use quantitative evidence to weight the conceptual model. State definitions and exclusions close to the result so readers do not mistake convenient proxies for semantic truth.

## Collection approach

Select the smallest reliable approach supported by the repository and environment:

- reuse existing repository analysis, workspace, coverage, or dependency commands when their semantics are known;
- use an available language-aware counter such as `cloc`, `scc`, or `tokei` when code/comment/blank separation matters;
- use version-control file enumeration or an equivalent ignore-aware scan to establish the included file set;
- use targeted source inspection and language-aware search for imports, calls, entrypoints, schemas, tests, and data access;
- use git history only when change pressure is in scope and the available history is representative.

Do not install a tool or add a repository script solely to produce the report. When a preferred tool is unavailable, use a transparent fallback and lower precision rather than inventing exact numbers. Record the commands, versions when relevant, included snapshot, exclusions, and counting definitions.

The quantitative baseline should distinguish:

- total, blank, and nonblank physical lines;
- bytes and file counts;
- distribution by semantic module, file role, and language;
- separate roles for production, tests, documentation, schemas/migrations, examples/fixtures, configuration, generated, vendor, and other material.

Physical nonblank lines are comparable only as approximate volume within similar languages and styles. Do not silently replace one counting definition with another between charts.

## Module resolution

Resolve module boundaries in this order:

1. user-specified scope or module roots;
2. declared workspaces, packages, build modules, and dependency rules;
3. responsibility and ownership boundaries observed in interfaces and data access;
4. top-level directories only as a fallback inventory grouping.

When physical directories differ from the semantic map, aggregate file measurements into the semantic modules and document the mapping. Do not present `src`, `tests`, and `docs` as peer business modules merely because they are sibling directories.

## File roles

Keep at least these roles separate:

| Role | Include | Common caveat |
| --- | --- | --- |
| Production | Authored executable source and queries | Language-generated source may need reclassification |
| Test | Unit, integration, contract, e2e, and non-functional tests | Fixtures and snapshots should not inflate test logic |
| Documentation | README, ADR, guides, and reference prose | Inline comments and docstrings require language-aware analysis |
| Schema/migration | Database, API, event, or serialization evolution | SQL queries are not automatically migrations |
| Example/fixture | Samples, seeds, snapshots, and test data | May be shipped as part of a library’s public contract |
| Configuration | Build, dependency, deployment, CI, and tool configuration | Infrastructure-as-code may contain substantive system logic |
| Generated | Reproducible generated output | Separate it even when committed |
| Vendor | Third-party source copied into the repository | Exclude from authored architecture conclusions |
| Other | Assets or unclassified material | Review large residual groups before reporting |

File format does not determine semantic role. For example, a repository may use Markdown or YAML as executable agent instructions, workflow definitions, or product configuration. Classify dominant artifacts by their actual responsibility when an extension-based grouping would materially distort the logic, test, or documentation distribution.

## Runtime volume ledger

Treat authored runtime logic as the primary quantitative base for module and feature analysis. Define it explicitly for the repository rather than assuming every source file is runtime logic.

Common authored-runtime categories are:

| Runtime category | Typical content |
| --- | --- |
| Domain / business logic | Policies, rules, calculations, domain state, invariants |
| Application / orchestration | Use cases, workflows, commands, jobs, coordination |
| Interfaces / adapters | HTTP/CLI/event handlers, persistence adapters, external integrations |
| Platform / cross-cutting | Authentication, authorization, validation, telemetry, error handling, runtime framework glue |

Keep tests, documentation, generated/vendor code, fixtures, snapshots, build/deploy configuration, and development tooling outside the authored-runtime denominator. Show schemas, migrations, infrastructure-as-code, and executable configuration separately unless they are clearly part of the runtime behavior being evaluated.

### Discover epics and features

Use several evidence surfaces together:

- repository/product documentation and domain terminology;
- routes, public APIs, commands, jobs, consumers, events, and scheduled entrypoints;
- application services, use cases, orchestrators, and domain operations;
- acceptance, integration, contract, and end-to-end tests;
- schemas, state transitions, external side effects, and user-visible outcomes.

An epic or capability group collects related outcomes. A feature is a concrete behavior with a recognizable trigger or entrypoint and outcome. Do not count CRUD endpoints, helpers, files, or classes as independent features unless they represent independent behavior in this system.

Stop decomposing when another split no longer improves ownership, flow, test-strategy, or refactoring decisions. Preserve an `unattributed` bucket when evidence cannot support a semantic assignment.

### Attribute implementation volume

Use the smallest practical implementation unit that avoids material distortion:

- whole files when they have one clear responsibility;
- symbols, classes, functions, or line ranges when a file mixes features;
- an explicit estimate when the language or tooling cannot isolate mixed responsibilities, with precision and confidence disclosed.

For mixed files, allocate imports, declarations, wrappers, braces, and similar syntax overhead by the narrowest responsibility the evidence supports. Assign feature-specific overhead with that feature; assign overhead used by several features or inseparable file-level glue to `shared/cross-cutting`; use `unattributed` only when even that classification is unsupported. On the module axis, assign the overhead once to the module that owns the file-level responsibility, or to `unattributed module` when ownership is genuinely ambiguous. State any range or estimation convention, and never force neutral overhead into a dominant feature merely to improve feature totals.

Each unit contributes its volume exactly once to:

1. one semantic module or `unattributed module`;
2. one feature, `shared/cross-cutting`, or `unattributed feature`;
3. one runtime category.

Relationships may show that several features consume shared code, but must not copy that code’s LOC into every feature. Preserve the invariant:

```text
authored runtime total
= sum(module runtime volume)
= sum(feature runtime volume + shared/cross-cutting + unattributed)
```

Report these measures separately:

```text
classification coverage = (named-feature runtime + shared/cross-cutting runtime) / authored runtime total
feature-specific share = named-feature runtime / authored runtime total
shared share = shared/cross-cutting runtime / authored runtime total
unattributed rate = unattributed runtime / authored runtime total
```

Classification coverage measures whether the ledger explains the runtime, while feature-specific share describes how much code can meaningfully be assigned to individual behaviors. Legitimate shared code is not an attribution failure. A full codebase map should reach at least 90% classification coverage or explicitly present itself as partial; always show the other three measures so a large shared bucket remains visible rather than being used to inflate completeness.

### Required volume tables

#### Runtime composition

| Runtime category | Files / units | Runtime LOC | Share of runtime | Notes |
| --- | ---: | ---: | ---: | --- |
| Domain / business | ... | ... | ... | ... |
| Application / orchestration | ... | ... | ... | ... |
| Interfaces / adapters | ... | ... | ... | ... |
| Platform / cross-cutting | ... | ... | ... | ... |
| Unattributed | ... | ... | ... | ... |

#### Module volume

| Module | Responsibility | Runtime LOC | Share of runtime | Named features | Shared LOC | Test LOC | Largest feature | Confidence |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

Include every material semantic module. Group small residual modules only when the threshold and combined volume are shown.

`Named features` is the count of distinct named features with feature-specific runtime allocated to the module. Exclude `shared/cross-cutting` and `unattributed` buckets from this count.

#### Epic and feature volume

| Epic / capability | Feature | Runtime LOC | Share of epic | Share of runtime | Module count | Entrypoint or outcome | Test evidence | Confidence |
| --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

Include epic subtotals and explicit shared/cross-cutting and unattributed totals.

#### Module × feature allocation ledger

| Module | Epic / capability | Feature | Runtime LOC | Share of module | Share of feature | Files / symbols | Entrypoint or flow | Test evidence | Confidence |
| --- | --- | --- | ---: | ---: | ---: | --- | --- | --- | --- |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

Group this table by module so the reader can drill from each application module into its epics and features. Use multiple rows when a feature crosses modules. Add explicit `shared/cross-cutting` and `unattributed` rows so feature and module totals reconcile.

For large reports, lead with epic and module subtotals, then provide the complete ledger in a collapsible section or separate data artifact. Do not hide unattributed volume in `Other` without its amount and reason.

## Measurement families

### Volume

- authored runtime files and lines by runtime category, semantic module, epic/capability, and feature;
- feature-to-module allocation, classification coverage, feature-specific share, shared share, and unattributed rate;
- shared/cross-cutting and unattributed runtime volume;
- production/test/documentation/configuration/schema composition;
- concentration in the largest modules or capabilities;
- distribution of file sizes, with outliers linked back to responsibility.

Use test-to-production or documentation-to-production ratios only to compare similar modules. Do not treat a universal ratio as a target.

### Structural complexity

- incoming and outgoing module dependencies;
- dependency cycles and edges that oppose intended layering;
- capability spread across modules and responsibility spread within a module;
- shared mutable data and cross-boundary writes;
- central modules whose fan-in and fan-out make change expensive.

Raw dependency counts can be distorted by framework conventions or generated imports. Inspect material edges before interpreting them.

### Behavioral complexity

- meaningful steps and policy decisions in a flow;
- module and process boundaries crossed;
- state transitions and durable writes;
- synchronous and asynchronous external interactions;
- branching, retries, compensation, concurrency, and failure modes.

Count only when the definition is stable across compared flows. Otherwise use a qualitative comparison with evidence.

### Assurance

- test composition by observed level;
- critical capability and flow coverage by evidence type;
- boundary, contract, failure-path, migration, and non-functional protection;
- high-criticality or high-change areas without proportionate evidence.

Coverage percentage may complement this map when fresh coverage data exists, but it must not replace semantic traceability.

### Change pressure

When repository history is representative, measure recent churn, contributor concentration, co-change, or defect history. State the time window and exclude mechanical rewrites when identifiable. Absence of history is an unknown, not low change pressure.

## Reconciliation checks

Before reporting:

- reconcile module, role, and language totals to the same included-file set;
- reconcile module runtime totals and feature/shared/unattributed totals to the authored runtime denominator;
- report classification coverage, feature-specific share, shared share, and unattributed rate, and explain the unattributed remainder;
- inspect mixed-responsibility files that materially affect the largest module or feature totals;
- show excluded, generated, vendor, binary, and unclassified material;
- review the largest `other` and `configuration` groups for misclassification;
- verify that charts use the same snapshot and counting semantics;
- record whether dirty and untracked files were included;
- avoid cross-language precision that the counting method cannot support.
