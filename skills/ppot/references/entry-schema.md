# PPoT entry schema

Use the smallest entry that preserves meaning, provenance, and reviewability. One entry should contain one independently challengeable statement.

## Shared fields

| Field | Requirement | Purpose |
|---|---|---|
| ID | Required | Stable reference such as `FACT-003` or `DEC-012` |
| Title | Required | Short human-readable label |
| Statement | Required | One atomic claim, choice, or question |
| Status | Required | Current certainty and lifecycle state |
| Owner | Required for publication | Role or person accountable for correctness |
| Source | Required for confirmed facts and decisions | Authoritative evidence, preferably linked |
| Effective | When relevant | Date the statement became applicable |
| Reviewed | Required for confirmed entries | Most recent verification date |
| Review by | Date-sensitive knowledge | Date or event that causes revalidation |
| Supersedes | When relevant | Earlier entry replaced by this one |
| Notes | Optional | Only context needed to interpret the statement |

Use ISO dates: `YYYY-MM-DD`.

## Entry types

| Prefix | Type | Use for |
|---|---|---|
| `OUTCOME` | Outcome | Intended user or business result and its measures |
| `USER` | User knowledge | Evidence-backed user segment, need, or behaviour |
| `FACT` | Confirmed fact | Verifiable current project truth |
| `RULE` | Product rule | Behaviour that the product must consistently exhibit |
| `DEC` | Decision | Chosen direction and its rationale |
| `CONSTRAINT` | Constraint | Legal, commercial, operational, or technical boundary |
| `ASM` | Assumption | Unvalidated belief being used for decisions |
| `MEM` | Durable learning | Reusable conclusion from research, delivery, or incidents |
| `CONFLICT` | Contradiction | Material disagreement between credible sources |
| `Q` | Open question | Unknown that blocks or affects a decision |
| `RISK` | Risk | Uncertain event with meaningful product impact |

## Status vocabulary

- `proposed`: drafted but not approved.
- `confirmed`: approved and supported as current project knowledge.
- `assumption`: explicitly unvalidated.
- `provisional`: temporarily accepted pending a condition or review.
- `disputed`: credible sources conflict.
- `superseded`: retained for traceability but no longer current.

Do not use `confirmed` merely because the user stated something confidently. Confirmed knowledge requires an accountable owner and suitable evidence.

## Type-specific additions

### Decision

Include context, rationale, alternatives rejected, consequences, decision maker, and reconsideration trigger.

### Assumption

Include confidence, risk if wrong, validation method, decision deadline, and evidence so far.

### Durable learning

Include where it was observed, why it matters, evidence, and the condition that could invalidate it.

### Conflict

Include both claims and sources, affected decision, resolution owner, target date, and final resolution when known.

### Outcome or metric

Define the population, numerator, denominator, time window, exclusions, data source, baseline, target, and guardrails when they matter. A metric name and number alone are not a durable definition.

## Example decision

```md
### DEC-004 — Release read-only external sharing first

- **Decision:** External sharing will be read-only in the first release.
- **Status:** confirmed
- **Date:** 2026-08-08
- **Decided by:** Product Owner
- **Context:** Editable sharing introduces unresolved permission and audit requirements.
- **Rationale:** Read-only sharing validates demand without creating an unsafe authorisation model.
- **Alternatives rejected:** Editable sharing at launch — permission model is not ready.
- **Consequences:** Editing remains limited to workspace members.
- **Reconsider when:** The external-collaborator permission model is approved.
- **Source:** [Sharing PRD](docs/sharing-prd.md)
- **Supersedes:** none
```
