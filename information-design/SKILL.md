---
name: information-design
description: >-
  Design, restructure, or critique AI responses, documentation, explanations,
  landing-page information architecture, and other communication artifacts to
  reduce task-relevant uncertainty with minimal attention cost. Use when
  hierarchy, conceptual-versus-derived sequencing, abstraction, representation,
  precision, or content density materially affects understanding, decisions,
  trust, or action.
---

# Information Design

## Theory

### Communication Objective

Treat communication as deliberate reduction of task-relevant uncertainty under limited attention and time. Optimize for the reader's understanding, decision, or action—not density, brevity, or completeness in isolation.

The highest-value artifact provides the smallest model from which the reader can derive the most useful conclusions. Information earns attention by changing understanding or action, supplying necessary evidence, or preventing material error.

### Information Layers

Distinguish two structural layers:

| Layer | Function | Typical content |
| --- | --- | --- |
| Conceptual information | Provides the generative model | concepts, entities, boundaries, relationships, causal rules |
| Derived information | Applies the model to the current context | invariants, constraints, decisions, procedures, examples, edge cases |

The **conceptual spine** is the smallest generative model that explains relationships and lets the reader reconstruct or predict downstream details. Present it before details that depend on it.

A derivative becomes a meaningful invariant only when it remains stable across the relevant cases and constrains multiple downstream conclusions or actions. Do not promote an incidental detail by calling it an invariant.

### Information Value and Claim Status

Evaluate information by uncertainty reduced per unit of attention. Prefer concepts that compress many facts and derivatives that constrain many cases or directly change a decision.

Keep structural role separate from claim status: conceptual and derived information may each be an established fact, inference, recommendation, or unknown. Attach evidence to the claim it supports and label status when confusion could mislead the reader.

## Practice

### 1. Establish the Communication Contract

Before shaping the artifact, determine:

- intended audience and relevant prior knowledge;
- question, decision, or action the artifact must support;
- reader's important current uncertainties;
- available evidence, constraints, format, and justified level of precision.

Infer these from context when the result remains safe and coherent. Clarify only ambiguity that would materially change the artifact; otherwise state the consequential assumption and proceed.

Derive content, hierarchy, emphasis, and representation from this contract. Do not choose them by matching the medium to a predetermined template or checklist.

### 2. Rank the Uncertainties

Rank what the reader must understand or believe by its effect on comprehension, decision quality, trust, risk, or action.

Include information only when it resolves a ranked uncertainty, supplies necessary evidence, prevents a material error, or enables the next step. Exclude information included merely because it is available, familiar, or impressive.

Separate established facts, interpretations, recommendations, and unknowns when confusing them could mislead the reader. Match precision to the evidence and purpose; avoid false precision and vague hedging.

### 3. Build the Conceptual Spine

Identify the concepts, entities, boundaries, relationships, and causal rules needed to interpret the subject. Keep only concepts that compress several facts, explain an important relationship, or predict relevant consequences.

State the conceptual spine explicitly before dependent details whenever it explains two or more later rules. Do not force the reader to infer the model from procedures or examples.

Build the model at the precision required by the communication contract. Preserve distinctions the reader needs; avoid terminology or structure that costs more attention than it saves.

### 4. Add Derivatives by Information Gain

Reveal information in this order when it fits the reader's task:

1. outcome, answer, or whole-system picture;
2. conceptual spine;
3. significant derived invariants and constraints;
4. decision implications, recommendations, or actions;
5. necessary procedures, examples, exceptions, and edge cases.

Prefer derivatives that constrain many downstream cases or directly change a decision or action. Omit derivatives the reader can safely reconstruct from the conceptual spine. Add decisive rationale and evidence at the layer they support, before dependent operational detail.

Stop when another layer no longer improves the intended understanding, decision, or action.

### 5. Choose the Representation

Select the representation that communicates the important relationship most efficiently:

- use prose for a coherent argument or explanation;
- use bullets for independent points;
- use a table for repeated-field comparisons or exact mappings;
- use a diagram for meaningful structure, hierarchy, flow, state, or sequence;
- use an example when an abstraction alone is likely to be misunderstood.

Use visuals only when spatial encoding reduces uncertainty better than text. Do not add diagrams that decorate or duplicate the surrounding content.

### 6. Control Redundancy

Remove repetition that adds no comprehension, evidence, or actionability. Preserve deliberate redundancy when it improves recall, accessibility, trust, error prevention, or conversion—for example, repeating a primary action after meaningful decision points.

Do not compress so aggressively that the reader must reconstruct missing context. Prefer the smallest representation that remains clear and usable.

### 7. Audit the Result

Before delivering the artifact, verify:

- Does the opening address the highest-priority uncertainty?
- Does a minimal conceptual spine appear before details that depend on it?
- Does each named invariant constrain multiple relevant conclusions or actions?
- Does every section—including each derived detail—improve understanding, decision quality, trust, risk control, or action?
- Are facts, interpretations, recommendations, and unknowns distinct, and is material uncertainty disclosed where it could change the reader's conclusion?
- Are abstraction, detail, and precision appropriate for the audience and evidence, and are important relationships represented in the clearest suitable form?
- Is every repetition intentional?
- Can anything be removed without reducing the artifact's effectiveness?

Deliver the artifact itself. Explain the information-design process only when the user asks for the rationale or an audit.
