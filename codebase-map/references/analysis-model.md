# Analysis Model

Use this model to keep repository facts, reconstructed meaning, and architectural judgments connected.

## Core entities

| Entity | Meaning | Typical evidence |
| --- | --- | --- |
| Demand | A functional requirement, non-functional pressure, constraint, or external obligation | Documentation, API contracts, configuration, tests, runtime mechanisms |
| Epic / capability group | A coherent family of related system outcomes; use the repository’s own term when available | Product documentation, domain language, grouped use cases, public surfaces |
| Feature | A concrete user- or system-meaningful behavior within an epic or capability group | Routes, commands, handlers, use cases, acceptance tests, product documentation |
| Flow | An end-to-end execution path that realizes a feature | Entrypoints, calls, messages, state transitions, reads/writes, tests |
| Module | A responsibility and ownership boundary, whether or not it matches a directory | Manifests, imports, public APIs, dependency rules, data ownership |
| Data | State, schema, event, or durable representation with meaningful ownership | Models, schemas, migrations, stores, message definitions |
| Evidence | A mechanism that demonstrates or constrains behavior | Tests, types, schemas, linters, contracts, runtime assertions, observability |
| Finding | A supported mismatch, risk, strength, or unknown | Relationships and measurements across the entities above |
| Opportunity | A change hypothesis that removes a supported cost or risk | Finding, expected simplification, validation path |

Use relationships such as `justifies`, `realizes`, `participates in`, `reads`, `writes`, `depends on`, `calls`, `publishes`, `consumes`, and `verifies`. Preserve direction because ownership and data-flow conclusions depend on it.

## Four views

### Demand

Explain what creates legitimate architecture pressure. Keep explicit requirements separate from inferred requirements. Include non-functional pressures only when evidence supports them, and retain important unknowns such as unstated scale, latency, compliance, tenancy, availability, or compatibility expectations.

Use an epic or capability group to compress related outcomes, then identify the concrete features that carry runtime volume. Prefer repository terminology; do not invent roadmap epics when only domain capabilities are observable. A feature should be stable enough to connect an entrypoint or trigger, an outcome, one or more flows, implementation units, and assurance evidence.

Keep semantic and implementation axes distinct:

- `epic/capability → feature → flow` explains delivered behavior;
- `module → implementation units → data` explains code ownership;
- feature-to-module relationships explain where behavior is implemented without pretending either axis contains the other.

### Structure

Map semantic modules, public boundaries, dependencies, integrations, and data ownership. A directory is evidence of a boundary, not proof of one. Compare declared structure with actual dependency and state access.

Distinguish:

- logical responsibility from physical placement;
- authored source from tests, docs, configuration, schemas, generated, and vendored material;
- intended dependency direction from observed dependency direction;
- shared read access from shared write ownership.

For each material module, build a logic summary with these fields:

| Field | Question answered |
| --- | --- |
| Responsibility and outcome | Why does the module exist, and what result does it own? |
| Triggers and entrypoints | What calls, event, job, route, or user action starts its behavior? |
| Decisions and invariants | Which policies, branches, calculations, or state rules shape the result? |
| Collaborators | Which modules or external systems does it call, publish to, or depend on? |
| Data and side effects | What does it read, transform, own, write, emit, or invoke? |
| Failure behavior | What can fail, and how are errors, retries, compensation, or partial results handled? |
| Feature and volume | Which features consume the module, and where is its authored runtime volume concentrated? |
| Assurance and confidence | What evidence protects this logic, and how certain is the reconstruction? |

The summary and its diagram should expose the module’s causal shape: trigger → orchestration or policy → data/integration effects → outcome or failure. Omit stages that do not exist rather than inventing a layered architecture.

### Behavior

Choose flows by explanatory value and risk. Prefer flows that cover a primary capability, a high-criticality mutation, an asynchronous boundary, an external integration, or a representative failure path.

For each selected flow, capture:

1. trigger and entrypoint;
2. policy or business decisions;
3. participating modules and boundary crossings;
4. data read, transformed, and written;
5. external calls or messages;
6. transaction, concurrency, retry, and idempotency behavior when relevant;
7. failure and compensation paths;
8. evidence that verifies the flow;
9. confidence and unresolved ambiguity.

Do not turn a call graph into a business flow. Collapse implementation detail that does not change responsibility, state, or a material decision.

### Assurance

Map evidence to what it protects. Classify tests by observed scope and dependencies rather than directory name alone:

- unit: one responsibility with controlled collaborators;
- integration: a meaningful boundary or real infrastructure collaboration;
- contract: compatibility across a provider/consumer or schema boundary;
- end-to-end: a user- or system-visible flow through deployed or near-deployed boundaries;
- non-functional: performance, resilience, security, concurrency, migration, or recovery behavior.

Also include types, schemas, static rules, invariant checks, runtime assertions, and observability when they materially constrain behavior. Code coverage is supporting evidence, not proof that important behavior is protected.

## Fitness synthesis

Fitness is relational. Do not score each view independently and average the numbers. Look for supported tensions:

| Relationship | Useful question | Example tension |
| --- | --- | --- |
| Demand ↔ Structure | Does responsibility align with capabilities and constraints? | One capability is scattered across unrelated owners |
| Demand ↔ Behavior | Is runtime complexity justified by the outcome and pressures? | A simple outcome crosses many orchestration layers |
| Demand ↔ Assurance | Is evidence proportional to criticality? | A critical mutation has only isolated unit tests |
| Structure ↔ Behavior | Do runtime paths respect boundaries and data ownership? | Several modules write the same state directly |
| Structure ↔ Assurance | Are risky boundaries independently verifiable? | A central integration has no contract tests |
| Behavior ↔ Assurance | Are failure, retry, state, and side-effect paths protected? | Happy path is covered but compensation is not |

Recognize justified complexity as well as problems. A complex module may be appropriate when it owns a genuinely complex capability, has coherent boundaries, and carries proportionate assurance.

## Finding contract

Every ranked finding should include:

| Field | Requirement |
| --- | --- |
| Observation | What the evidence shows, without recommendation language |
| Interpretation | Why it matters to the system model |
| Evidence | Concrete files, measurements, or relationships |
| Consequence | Current cost, risk, or architectural strength |
| Recommendation | The smallest plausible response, or `None` for a strength/unknown |
| Validation | Evidence needed before or after acting |
| Confidence | High, Medium, or Low, with the main uncertainty |

Rank opportunities by expected reduction in meaningful cost or risk, adjusted by confidence and change risk. Do not use raw LOC, test ratio, or dependency count as the ranking by itself.
