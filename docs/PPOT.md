# Using the Project Point of Truth

The Project Point of Truth, or PPoT, is a product team’s curated record of durable project knowledge. It gives product owners, designers, engineers, delivery teams, and AI assistants a common view of what is confirmed, assumed, decided, constrained, disputed, or still unknown.

The PPoT belongs in the root of the product repository:

```text
your-product/
├── PPoT.md
├── README.md
├── AGENTS.md or CLAUDE.md
└── ...
```

The product-team plugin supplies the practice and a starter template. It does not automatically create or own a product’s facts.

## Start a PPoT

Install the product-team skills, open the product repository, and ask:

```text
/ppot init
```

Or use natural language where the host supports automatic skill selection:

```text
Create a Project Point of Truth for this product.
```

The skill will offer to create `PPoT.md` from its starter template. It must not write the file until you approve the location and action.

Start small. Populate the project snapshot, product boundaries, outcomes, confirmed facts, decisions, and assumptions. Add other sections only when the project has durable knowledge that belongs there.

## What belongs in it

Record information likely to affect a future product or implementation decision:

- product purpose, users, boundaries, and non-goals;
- outcomes and precisely defined measures;
- confirmed product and domain facts;
- governing product behaviour;
- decisions and their rationale;
- legal, commercial, operational, or technical constraints;
- assumptions requiring validation;
- durable learning from research, delivery, experiments, or incidents;
- material risks, contradictions, and open questions.

A useful test is:

> Would knowing this change a decision someone might make about the product in six months?

If not, it probably does not belong in the PPoT.

## What does not belong

Do not use the PPoT for:

- backlogs, roadmaps, or daily delivery status;
- meeting transcripts or temporary working notes;
- detailed design-system or source-code documentation;
- unsupported opinions presented as facts;
- complete PRDs, research reports, or architecture documents;
- passwords, credentials, production access details, or personal data.

Link to authoritative evidence instead of duplicating it.

## Use it in ordinary language

You do not need to remember commands. Examples include:

- “Bring me up to speed on this product.”
- “What do we know about enterprise onboarding?”
- “Why did we decide against guest checkout?”
- “Record that UK accounts require address verification.”
- “We decided to release read-only sharing first.”
- “Track this as an assumption until research confirms it.”
- “Remember that customers interpret archive as reversible.”
- “Check this PRD against the project truth.”
- “Which facts are stale or unsupported?”
- “The roadmap and PPoT disagree about launch scope.”

In Claude Code, the equivalent explicit practices are:

| Practice | Invocation |
|---|---|
| Initialise | `/ppot init` |
| Brief | `/ppot brief` |
| Ask | `/ppot ask <question>` |
| Propose a fact | `/ppot capture <statement>` |
| Record a decision | `/ppot decide <decision>` |
| Record an assumption | `/ppot assume <assumption>` |
| Capture learning | `/ppot learn <learning>` |
| Check an artefact | `/ppot check <artefact>` |
| Review project knowledge | `/ppot review` |
| Resolve a conflict | `/ppot resolve <topic>` |
| Publish approved proposals | `/ppot publish` |

In Codex, use the same practice names with `$ppot`, for example `$ppot brief` or `$ppot check this PRD`.

## How the other product-team skills use it

Every product-team skill follows a small PPoT handshake.

### Pull before working

When product knowledge could affect the task, the skill reads the relevant parts of `PPoT.md`. It uses confirmed entries as established context, preserves the uncertainty of assumptions and provisional entries, and surfaces material conflicts.

The skill should not ask you to restate knowledge already recorded in the project.

### Push after working

Before finishing, the skill checks whether the work produced durable knowledge worth preserving. If it did, it presents a candidate rather than silently editing the PPoT.

For example:

```text
Possible PPoT update

Type: Decision
Statement: Workspace deletion will support recovery for 30 days.
Evidence: Retention section of the approved PRD.
Suggested owner: Product Owner and Security.
Status: Proposed.

Would you like me to draft this for the PPoT?
```

If no durable knowledge was produced, the skill says nothing about the PPoT.

## Propose, review, publish

PPoT changes follow a two-stage workflow:

1. Product-team skills and contributors propose an entry.
2. The `ppot` skill validates its type, certainty, evidence, ownership, review condition, and conflicts.
3. The Product Owner, project administrator, or delegated owner approves the exact change.
4. The `ppot` skill publishes only the approved entries.

Publishing `PPoT.md` and creating a Git commit are separate actions. A commit is created only when explicitly requested.

## Knowledge states

- `proposed` — drafted but not approved.
- `confirmed` — approved and supported as current project knowledge.
- `assumption` — explicitly unvalidated.
- `provisional` — temporarily accepted pending a condition.
- `disputed` — credible sources conflict.
- `superseded` — retained for traceability but no longer current.

An AI inference cannot become a confirmed fact without human approval and suitable evidence.

## Ownership and review

The Product Owner normally owns the overall integrity of the PPoT. Domain owners confirm information in their areas, contributors propose precise statements and evidence, and AI assistants identify gaps without granting their own proposals authority.

Review the PPoT:

- before major planning or prioritisation;
- before a significant release;
- after consequential research, decisions, or incidents;
- when a recorded review trigger occurs;
- at least monthly while the product is actively changing.

Use `/ppot review` to find expired reviews, unsupported facts, missing owners, overdue assumptions, unresolved conflicts, and unnecessary detail.

## Add a project reminder

Projects using the suite can add this to `AGENTS.md` or `CLAUDE.md`:

```md
For material product work, consult `PPoT.md` before making assumptions about
product purpose, users, outcomes, scope, terminology, behaviour, constraints,
or prior decisions.

Treat confirmed entries as current project knowledge. Clearly distinguish
assumptions, provisional decisions, disputes, and unknowns. When work produces
durable new knowledge, propose a PPoT update. Do not confirm or publish an entry
without explicit approval.
```

The individual product-team skills carry the same behaviour, but the repository reminder also covers work performed without one of those skills.
