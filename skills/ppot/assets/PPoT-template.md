---
title: Project Point of Truth
project: "<project name>"
document_owner: "<name or accountable role>"
version: "1.0"
last_reviewed: YYYY-MM-DD
next_review: YYYY-MM-DD
status: active
---

# Project Point of Truth

> This document records the project’s current confirmed facts, governing decisions, constraints, assumptions, and durable learning. It is a curated source of truth, not a backlog, activity log, or substitute for detailed documentation.

## How to use this document

- Treat `confirmed` entries as current unless their review condition has expired.
- Treat `assumption`, `provisional`, and `disputed` entries as uncertain.
- If code, documentation, and this file disagree, surface the conflict.
- Prefer linked authoritative evidence over unsupported interpretation.
- Do not add secrets, personal data, transcripts, or temporary working notes.
- Agents may propose changes; the document owner or delegated owner approves confirmed knowledge.

## Project snapshot

- **Purpose:** <why this product exists>
- **Primary users:** <who it serves>
- **Primary problem:** <problem being solved>
- **Value proposition:** <why users choose it>
- **Lifecycle stage:** <discovery / beta / live / maintenance>
- **Current focus:** <most important current outcome>
- **Product Owner:** <name or role>
- **Technical owner:** <name or role>

## Product boundaries

### In scope

- <durable capability or responsibility>

### Out of scope

- <explicit non-goal>

## Outcomes and measures

### OUTCOME-001 — <outcome name>

- **Statement:** <desired user or business outcome>
- **Status:** proposed
- **Owner:** <role>
- **Measures:** <metric and precise definition>
- **Baseline:** <value and measurement date>
- **Target:** <value and target date>
- **Guardrails:** <measures that must not materially deteriorate>
- **Source:** <authoritative source>
- **Reviewed:** YYYY-MM-DD
- **Review by:** YYYY-MM-DD

## Users and needs

### USER-001 — <user segment>

- **Statement:** <who this group is or what evidence shows>
- **Primary need:** <job or problem>
- **Status:** proposed
- **Owner:** <role>
- **Source:** <research source>
- **Reviewed:** YYYY-MM-DD

## Canonical vocabulary

| Term | Canonical meaning | Do not confuse with |
|---|---|---|
| `<term>` | <project-specific definition> | <similar term> |

## Confirmed project facts

### FACT-001 — <fact title>

- **Statement:** <one precise, testable statement>
- **Status:** proposed
- **Owner:** <person or role>
- **Effective:** YYYY-MM-DD
- **Reviewed:** YYYY-MM-DD
- **Review by:** YYYY-MM-DD or `event: <trigger>`
- **Source:** <authoritative evidence>

## Governing product rules

### RULE-001 — <rule title>

- **Rule:** <expected product behaviour>
- **Status:** proposed
- **Applies when:** <scope or precondition>
- **Exceptions:** <exceptions or none known>
- **Rationale:** <why the rule exists>
- **Owner:** <role>
- **Source:** <authoritative evidence>
- **Reviewed:** YYYY-MM-DD

## Decisions

### DEC-001 — <decision title>

- **Decision:** <what was decided>
- **Status:** proposed
- **Date:** YYYY-MM-DD
- **Decided by:** <person or group>
- **Context:** <problem requiring a decision>
- **Rationale:** <why this option was selected>
- **Alternatives rejected:** <alternative and reason>
- **Consequences:** <important consequence>
- **Reconsider when:** <date, metric, event, or condition>
- **Source:** <ADR, PRD, minutes, ticket, or commit>
- **Supersedes:** none

## Constraints and commitments

### CONSTRAINT-001 — <constraint title>

- **Statement:** <what the project must or must not do>
- **Type:** <legal / contractual / technical / commercial / operational>
- **Status:** proposed
- **Impact:** <what decisions this constrains>
- **Owner:** <role>
- **Source:** <authoritative evidence>
- **Review by:** YYYY-MM-DD or `event: <trigger>`

## Systems and data authority

| Subject | Authoritative source | Owner | Notes |
|---|---|---|---|
| <subject> | <system, document, or service> | <role> | <important boundary> |

## Assumptions requiring validation

### ASM-001 — <assumption title>

- **Statement:** <what is currently assumed>
- **Status:** assumption
- **Confidence:** low / medium / high
- **Risk if wrong:** <consequence>
- **Validation:** <how it will be tested>
- **Owner:** <role>
- **Decision needed by:** YYYY-MM-DD
- **Evidence so far:** <source or none>

## Durable learning

### MEM-001 — <learning title>

- **Learning:** <reusable conclusion>
- **Status:** proposed
- **Observed:** YYYY-MM-DD
- **Context:** <where this was learned>
- **Why it matters:** <future decision or mistake it affects>
- **Evidence:** <research, incident, experiment, issue, or commit>
- **Owner:** <role>
- **Review trigger:** <condition that could invalidate it>

## Known contradictions

### CONFLICT-001 — <conflict title>

- **Statement A:** <claim and source>
- **Statement B:** <conflicting claim and source>
- **Status:** disputed
- **Impact:** <what cannot safely be decided>
- **Resolution owner:** <role>
- **Resolve by:** YYYY-MM-DD

## Open questions

| ID | Question | Why it matters | Owner | Needed by |
|---|---|---|---|---|
| Q-001 | <question> | <blocked decision> | <role> | YYYY-MM-DD |

## Current product risks

| ID | Risk | Evidence | Response | Owner | Review |
|---|---|---|---|---|---|
| RISK-001 | <risk> | <source> | <mitigate / accept / investigate> | <role> | YYYY-MM-DD |

## Source index

| Source | Authority | Owner | Location |
|---|---|---|---|
| <source> | <what it is authoritative for> | <role> | <path or link> |

## Maintenance record

| Date | Reviewer | Scope | Result |
|---|---|---|---|
| YYYY-MM-DD | <name> | Full review | <summary> |
