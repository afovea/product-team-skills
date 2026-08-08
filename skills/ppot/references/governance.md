# PPoT governance

## Authority

- Anyone may propose an entry or correction.
- Product-team skills and AI assistants may draft entries and identify gaps.
- The Product Owner, project administrator, or delegated domain owner approves confirmed knowledge.
- An agent inference cannot approve itself.
- A Git commit records a change; it does not by itself make the content true.

## Proposal and publication

1. Propose an atomic statement.
2. Classify its type and certainty.
3. Identify the owner, evidence, effective date, and review condition.
4. Check for duplicates and contradictions.
5. Obtain explicit approval for the exact entries to publish.
6. Edit only the approved entries.
7. Show the resulting change.
8. Commit only when separately requested.

Do not interpret “remember this” as approval to mark a statement confirmed. It authorises a proposal unless the user also has authority, supplies evidence, and explicitly approves publication.

## Conflict handling

When the PPoT conflicts with another credible source:

1. Present both claims and their sources.
2. State the affected decision or work.
3. Mark the knowledge disputed.
4. Name a resolution owner and target date.
5. Do not choose a source merely because it appears newer.
6. Record the resolution and supersede the obsolete entry after approval.

## Review cadence

Recommend review:

- before major planning or prioritisation;
- before a significant release;
- after consequential research, decisions, or incidents;
- when a review trigger occurs;
- at least monthly while the product is actively changing.

Review expired entries, missing evidence, absent owners, overdue assumptions, unresolved conflicts, duplicate knowledge, and detail that belongs in linked documentation instead.

## Sensitive information

Never store:

- passwords, keys, tokens, or credentials;
- private production access details;
- personal data or raw customer records;
- confidential contractual text when a controlled source can be linked;
- security details that would unnecessarily increase exposure.

Record the durable constraint or conclusion and link to the access-controlled source.

## Quality threshold

Prefer not to add an entry unless it could materially affect a future product or implementation decision. Keep the document concise enough to review and challenge.
