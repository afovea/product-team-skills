# Healthcare security domain pack

Reference for [`security-specialist`](../SKILL.md). Read this **only when the product handles medical or health data** (PHI/PHR). It is domain-specific and does not apply to most projects.

Where it applies, cross-tenant isolation is the load-bearing invariant. Everything else is hardening.

## PHI handling

- **PHI inventory** — list every table, column, storage path and log field that holds PHI. This is the basis for retention, export, and breach-blast-radius reasoning. Without it, the other controls have no defined scope.
- **Minimum-necessary** — admin tooling defaults to redacted views, not raw PHI. Require an explicit "view raw" action with an audit log entry naming the actor, the record, and the time.
- **De-identification** for analytics and debugging — HIPAA Safe Harbor categories are a sensible baseline even outside US jurisdiction.
- **Cross-user leak in data fetches** — every handler that assembles records for a user must verify ownership of every entity it touches. A query filtered by record ID but not by owner is a one-line PHI leak, and it is the single most common way this fails.

## AI features on health data

Beyond the general AI guidance in the [audit cookbook](./security-audit-cookbook.md):

- **Hallucination boundaries** — the system prompt must forbid diagnosis, treatment recommendation, and contradiction of clinicians. Output validators catch shape drift, not content drift; content boundaries need their own review.
- **Ownership in prompt context** — every entity referenced in an AI prompt must be ownership-checked before it enters the context window, not after.
- **Adversarial inputs from the record itself** — users can place prompt injection in their own notes and uploaded documents. Everything in the prompt is adversarial, including content the user wrote about themselves.
- **Feedback loops** — if AI output becomes user-visible content that later AI calls re-ingest, that is a self-reinforcing injection vector.

## Regulatory boundary

- **Lawful basis** for each PHI category, typically explicit consent for medical data.
- **DPIA** — required under UK GDPR for high-risk processing; medical data qualifies. Document threats, mitigations, residual risk, and DPO sign-off.
- **Medical-device boundary** — informational personal health records are not medical devices, but features that diagnose, interpret abnormality, or recommend treatment can drift into MHRA / FDA scope. Flag content straying toward medical advice. Clinical neutrality is both a product value and a regulatory boundary.

## Limits

This pack does not substitute for HIPAA / NHS DSPT certification, DPO sign-off, or clinical-safety and medical-device regulatory review. Escalate to those humans rather than concluding compliance.
