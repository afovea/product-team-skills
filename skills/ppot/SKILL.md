---
name: ppot
description: Consult, review, and maintain a project's PPoT.md Project Point of Truth. Use when someone asks what is known about a product, requests a project briefing, says "remember this" or "record our decision", wants to capture a fact, constraint, assumption, risk, question, or durable learning, checks a PRD or proposal against established project knowledge, resolves conflicting sources, reviews stale knowledge, or approves a proposed PPoT update.
---

# Project Point of Truth

Treat `PPoT.md` as the human-governed register of durable project facts, decisions, constraints, assumptions, and learning. Help the team use it without turning it into a backlog, transcript, or unsourced memory dump.

## Find the PPoT

1. Look for `PPoT.md` in the project root before searching elsewhere.
2. If it exists, read only the sections relevant to the request, then expand when needed.
3. If it does not exist:
   - for a read request, say that the project has no PPoT and identify the assumptions that therefore remain unverified;
   - for an initialise request, offer to create it from [`assets/PPoT-template.md`](assets/PPoT-template.md);
   - do not create it without explicit approval.

Use [`references/entry-schema.md`](references/entry-schema.md) when drafting or publishing entries. Use [`references/governance.md`](references/governance.md) for approval, conflict, review, and sensitive-data rules.

## Route the request

Map explicit commands and natural language to the same practice:

| Practice | Typical request | Default effect |
|---|---|---|
| `init` | “Create a PPoT for this project” | Draft or create after approval |
| `brief` | “Bring me up to speed” | Read only |
| `ask` | “What do we know about enterprise onboarding?” | Read only |
| `capture` | “Record that cancellation is available for 14 days” | Draft proposal |
| `decide` | “We decided to launch read-only sharing first” | Draft proposal |
| `assume` | “We think administrators configure integrations” | Draft proposal |
| `learn` | “Remember that users interpret archive as reversible” | Draft proposal |
| `check` | “Check this PRD against the project truth” | Read and compare |
| `review` | “Which facts are stale or unsupported?” | Read and audit |
| `resolve` | “The roadmap and PPoT disagree” | Draft resolution |
| `publish` | “Approve and save the first two proposals” | Write after checks |

Arguments may follow the practice name, for example `/ppot decide ...` or `$ppot check ...`. Do not require command syntax when the intent is clear from natural language.

## Read practices

### Brief

Summarise only what the PPoT supports:

- product purpose and current focus;
- active outcomes and measures;
- confirmed product boundaries and constraints;
- important active decisions;
- assumptions and their confidence;
- unresolved conflicts and open questions;
- stale knowledge that should not be relied on without review.

Keep the briefing concise and cite entry IDs where available.

### Ask

Answer from the PPoT and label each material statement as confirmed, provisional, assumed, disputed, superseded, or unknown. Do not silently fill gaps from general knowledge. If another project source is needed, distinguish that evidence from the PPoT.

### Check

Compare the supplied artefact, proposal, or implementation against relevant PPoT entries. Classify findings as:

- consistent;
- missing from the PPoT;
- contradictory;
- possibly stale;
- decision required.

Explain the impact and name the affected entry IDs or sections.

### Review

Check for expired review dates, missing owners, weak or absent sources, duplicate IDs, overdue assumptions, unresolved conflicts, superseded information presented as current, and important project knowledge that appears to be missing. Propose corrections; do not publish them automatically.

## Write practices

### Draft

For `capture`, `decide`, `assume`, `learn`, and `resolve`:

1. Turn the input into one atomic statement.
2. Choose the correct entry type and next stable ID.
3. Preserve the user’s degree of certainty:
   - “is” may be a proposed fact but still needs evidence;
   - “we decided” is a proposed decision until approval is established;
   - “we think” or “we expect” is an assumption;
   - an agent inference is never a confirmed fact.
4. Add or explicitly mark missing owner, evidence, effective date, and review condition.
5. Check for an existing or conflicting entry.
6. Present a proposal before writing.

Use this compact proposal shape:

```text
Proposed <ID> — <title>
Type: <type>
Statement: <atomic statement>
Status: proposed | assumption | provisional | disputed
Owner: <owner or missing>
Evidence: <source or missing>
Review: <date, event, or missing>
Affected entry: <ID or none>
```

Ask for the missing information only when it materially changes classification or publication. Otherwise draft with visible placeholders.

### Publish

Publish only after the user explicitly approves specific proposals.

Before editing:

1. Re-read the current `PPoT.md` so an earlier draft cannot overwrite newer work.
2. Confirm which proposals are approved and which remain unapproved.
3. Validate the entry type, status, ID, owner, evidence, and review condition.
4. Preserve existing unrelated content and formatting.
5. Supersede old entries rather than erasing consequential history.
6. Refuse secrets, credentials, personal data, or production access details.

After editing, show exactly what changed. Do not create a Git commit unless the user separately and explicitly requests one.

## PPoT handshake with other skills

Other product-team skills may surface candidate PPoT updates. Accept their candidate statement and evidence as a draft, then apply this skill’s classification and governance checks. Do not assume that a candidate produced by another skill is already approved.

When this skill discovers a product contradiction that belongs to another practice, state the conflict and the decision required. Do not silently resolve it by choosing the newest-looking source.

## Boundaries

- Keep `PPoT.md` a concise current register and source index, not the container for every supporting document.
- Link to PRDs, ADRs, research, analytics, policies, tickets, and code rather than duplicating them.
- Do not use the PPoT as a backlog, roadmap, meeting log, changelog, or design-system reference.
- Avoid prompting for a PPoT update when the information is temporary, obvious from code, or unlikely to affect a future decision.
- Prefer no update over a low-value update.

## Completion standard

A PPoT response is complete when it:

- separates established knowledge from uncertainty;
- names its evidence or makes missing evidence visible;
- identifies conflicts instead of hiding them;
- preserves human approval for confirmed knowledge;
- leaves a precise next action.

## Maintenance

Review this skill when the PPoT schema, approval model, project-memory conventions, Codex or Claude skill invocation, or product-team handshake changes. Keep the starter template, entry schema, governance reference, and user guide aligned.
