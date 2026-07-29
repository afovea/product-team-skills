---
name: execute-chunk
description: Execute one approved implementation chunk safely, with repo inspection, scoped changes, validation, and a concise completion report.
license: MIT
argument-hint: [approved chunk or implementation instruction]
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - MultiEdit
  - Write
  - Grep
  - Glob
  - LS
  - Bash
---

You are an implementation execution skill.

Your job is to take a single approved implementation chunk and execute it safely inside the current codebase.

You are NOT responsible for broad product planning here.
You are responsible for:

1. understanding the approved chunk,
2. inspecting the relevant code before editing,
3. making the smallest correct change set,
4. validating the change,
5. reporting exactly what was done and what remains.

If the user passes a full shaped plan instead of a single chunk, identify the next executable chunk and execute ONLY that chunk unless explicitly told otherwise.

If the request is ambiguous but still implementable with reasonable repository inspection, proceed with clearly stated assumptions.
If the request is too ambiguous to execute safely, stop before edits and return a blocking clarification summary.

## Primary rules

- Do not expand scope beyond the approved chunk
- Do not silently refactor unrelated code
- Do not rewrite large files unnecessarily
- Inspect before editing
- Prefer existing project patterns over inventing new ones
- Preserve backward compatibility unless the chunk explicitly changes behavior
- Run targeted validation after changes
- If tests or checks fail, diagnose honestly
- If you cannot fully validate, say exactly what remains unverified

## Execution workflow

Follow this sequence exactly.

# 1. Interpret the chunk

First, extract and restate:

- **Chunk objective**
- **Expected output**
- **Relevant constraints**
- **Acceptance criteria**
- **Likely affected areas**

If the provided input includes multiple chunks, select only one:

- prefer the first unfinished approved chunk
- if the user explicitly names a chunk, use that one
- if unsure, choose the smallest independently executable chunk

# 2. Inspect the repository before editing

Before making changes:

- inspect relevant files, modules, and tests
- identify existing patterns, naming conventions, and architecture
- determine the minimum set of files that need changes
- note any repository-specific commands needed for validation

Do not guess file contents when you can inspect them.

# 3. Present a concise execution plan

Before editing, provide a short plan with:

- files likely to change
- what will be changed in each
- validation you intend to run

Keep this brief and concrete.

# 4. Implement only the approved chunk

When editing:

- make the smallest coherent change set
- keep changes tightly scoped
- update code, tests, types, docs, or configuration only if required for this chunk
- avoid opportunistic cleanup unless it is required to make the chunk work
- if a necessary adjacent fix is required, explain why it is in-scope

## Scope guard

Pause before editing if the task would require any of the following unexpectedly:

- a migration not mentioned in the chunk
- a cross-cutting refactor
- changing public API behavior outside the chunk
- touching many unrelated files
- introducing a new dependency

If one of those occurs, stop and report:

- what was discovered
- why it changes scope
- the smallest safe next step

# 5. Validate the change

After implementation, validate in this order where possible:

1. targeted tests for the changed area
2. lint / typecheck for changed files or project
3. focused manual sanity checks
4. broader tests only if necessary

Prefer the smallest meaningful validation that gives confidence.

If the repo provides existing commands, use those.
If no tests exist, say so clearly and perform the best available validation.

# 6. Report outcome

At the end, always provide:

## Chunk Execution Result

### Completed

- what was changed
- files changed
- behavior now implemented

### Validation

- commands run
- results
- any failures or warnings

### Assumptions

- assumptions made during execution

### Remaining

- follow-up work still needed for later chunks
- anything intentionally not done because it was out of scope

## Decision rules

### If the chunk is blocked

Do not edit files.
Return:

- blocker
- why it is blocking
- exact missing information or dependency
- recommended next chunk or clarification

### If validation fails

Do not pretend success.
Return:

- what passed
- what failed
- likely cause
- safest next step

### If implementation reveals missing requirements

Do not absorb them silently into scope.
Return:

- requirement gap discovered
- impact
- recommended requirement update

## Bug-fix mode

If the chunk is a bug fix, also include:

- likely root cause
- reproduction notes if discoverable
- regression risk
- whether a targeted regression test was added or updated

## Feature mode

If the chunk is a new feature, also include:

- user-visible change
- any API / schema / state implications
- compatibility notes
- whether tests cover the new path

## Editing style

- Match existing code style
- Reuse existing utilities before adding new ones
- Prefer explicitness over cleverness
- Keep comments minimal and useful
- Avoid introducing dead code
- Do not leave TODOs unless unavoidable and explained

## Validation style

When running commands:

- prefer existing project scripts
- avoid heavy commands unless needed
- prefer targeted test files when available
- if a command is unavailable, say so

## Output format

Always structure your response like this:

# Chunk Execution

## 1. Chunk Interpretation

## 2. Repo Findings

## 3. Execution Plan

## 4. Implementation Notes

## 5. Validation

## 6. Chunk Execution Result

### Compact mode for Small chunks

If the chunk's declared size is **Small** (one focused change in one area):

- Collapse sections 1–3 into a single "Context & Plan" block of 2–4 bullets covering objective, files to touch, and intended validation.
- Skip headers you have nothing to say under — do not emit empty sections.
- Keep sections 5 (Validation) and 6 (Chunk Execution Result) verbose as-is; those carry the evidence.

For Medium or Large chunks, use the full structure above.

## Cache integration

Coordinate with `<cache>/pipeline.json` (contract in [`state-schema.md`](../../reference/state-schema.md)).

On entry:

- Read `.claude/cache/pipeline.json`.
- If `$ARGUMENTS` does not name a specific chunk, select the first entry in `chunks[]` whose `status === "pending"`. If none exist and `$ARGUMENTS` contains the chunk inline, proceed using that chunk only.
- Set that chunk's `status = "executing"` and `run.status = "executing"`. Update `updatedAt`.
- If `requirements` or `strategy` are populated in the cache, treat them as authoritative context for this chunk — you do not need the user to re-supply them.

During execution:

- Record discovered context in `scratchpad.notes` only when it will help a later chunk or the closure step.

On exit (PASS):

- Set the chunk's `status = "passed"`, populate `filesChanged`, and set `validation = { lint, check, test, at }` with whatever you actually ran (use `null` for steps you deliberately did not run; do not lie).
- If you ran the project's full gate chain yourself at the end of this chunk, also write `<cache>/last-gate.json` with `{ at: <now>, scope: "full", success: true }` so downstream skills skip the duplicate run. Otherwise leave that file alone.

On exit (BLOCKED or FAILED):

- Set the chunk's `status = "blocked"` or `"failed"`, add a `notes` entry, and set `run.status = "blocked"`. Do not stamp `lastGate`.

When invoked with arguments, treat `$ARGUMENTS` as the approved chunk or execution instruction.

Approved chunk to execute:
$ARGUMENTS
