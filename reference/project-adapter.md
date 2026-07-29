# Project adapter

The pipeline skills are project-agnostic. Everything specific to *your* repository — package manager, gate commands, generated artefacts, risky paths, host integrations — is declared here.

**A consuming project copies this file to `.claude/pipeline-adapter.md` and fills it in.** Pipeline skills read it at the start of a run.

## If there is no adapter

The pipeline still runs. Skills fall back to **discovery**, in this order:

1. Repository instructions — `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `README.md`.
2. Manifests — `package.json` scripts, `Makefile` targets, `pyproject.toml`, `Cargo.toml`, `go.mod`.
3. CI configuration — `.github/workflows/*`, or the equivalent. What CI runs on a pull request is the best available definition of "the gates".
4. Lockfile, for the package manager: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `package-lock.json` → npm, `bun.lockb` → bun.

State what was discovered and where it came from before running anything destructive. If no gate chain can be discovered, say so and ask — do not invent commands, and do not assume a JavaScript toolchain.

Discovery is a fallback, not a substitute. A project running the pipeline regularly should write the adapter: it is faster, deterministic, and it records intent that discovery cannot infer (which gates are allowed to fail, which paths are risky).

---

## Template

Copy from here down.

### `commands`

The gate chain, in the order it should run. Omit any that do not apply.

| Key | Command | Notes |
|---|---|---|
| `install` | | Rarely needed mid-run |
| `lint` | | Should accept a scope/path argument if possible |
| `typecheck` | | |
| `test` | | Full suite |
| `test.affected` | | Narrow run for per-chunk validation; falls back to `test` if absent |
| `build` | | |

If `lint` can be scoped to changed files, say how (`<lint> --filter <path>`). Per-chunk validation uses the scoped form; the final sweep uses the full form.

### `gates.chain`

Ordered list of every gate that must pass for a `scope: "full"` stamp. Each entry:

- **name** — short label used in reports
- **command**
- **blocking** — `true`, or `false` for a gate that is expected to fail
- **baseline** — for non-blocking gates, the currently accepted failure count, and how to read it from the output

A gate with `blocking: false` and a baseline is a *ratchet*: the run fails if the count gets worse, passes if it stays the same or improves. Record the baseline here so a regression is detectable. **If any gate in the chain is non-blocking, a `scope: "full"` stamp requires every blocking gate to pass and every ratchet to be no worse than baseline** — never stamp `full` while ignoring a worsened ratchet.

### `artefacts`

Generated files that must stay in sync with their source. For each:

- **source** — glob
- **generated** — path or glob
- **regenerate** — command
- **driftCheck** — command that fails when the generated output is stale
- **compare** — `structural` for JSON/YAML compared after parse (whitespace-insensitive), `bytes` otherwise

Never silently overwrite a generated artefact that drifts. Regenerate, report the diff, and let the caller decide.

### `paths.risk`

Globs that raise the tier when touched. The pipeline ships these defaults; extend rather than replace:

- database migrations, schema definitions, ORM entities
- infrastructure as code, container definitions, environment templates
- authentication, authorisation, session, billing, and permission code
- public API contracts and generated clients
- CI configuration and anything under a hooks directory

Add your own — contract schemas, workflow definitions, generated registries, anything whose breakage is expensive.

### `state`

- **directory** — where pipeline state lives. Default `.claude/cache/`. See [`state-schema.md`](./state-schema.md).
- **gateStampTtlSeconds** — how long a `full` stamp stays inheritable. Default `300`.
- **writable** — whether the host grants Write here. If `false`, skills report in chat and skip persistence.

### `integrations`

Optional host features. Each is **off unless declared** — the pipeline never assumes a specific agent host.

- **todoMirror** — the host's task-list primitive, if it has one, for mirroring progress. Name the tool.
- **independentReview** — an external reviewer run against the cumulative diff before completion. Declare how it is invoked, whether it is mandatory for Large, and the maximum number of runs (default `2`; the last verdict is final).
- **subagents** — names of any isolated-context agents available for repository inspection and planning. Absent means the pipeline reads files inline instead.

Anything named here is host-specific by definition. A pipeline skill must treat an undeclared integration as unavailable and carry on, never as an error.

---

## Worked example

A pnpm TypeScript monorepo with generated JSON-schema contracts and an architecture scanner carrying accepted debt.

```yaml
commands:
  lint:          pnpm lint            # scoped: pnpm lint --filter <path>
  typecheck:     pnpm check
  test:          pnpm test
  test.affected: bash scripts/affected-tests.sh
  build:         pnpm -r build

gates:
  chain:
    - name: contracts:validate
      command: pnpm contracts:validate
      blocking: true
    - name: contracts:registry
      command: pnpm contracts:registry
      blocking: true
    - name: check:drift
      command: pnpm check:drift
      blocking: true
    - name: check:workflow
      command: pnpm check:workflow
      blocking: true
    - name: check:architecture
      command: pnpm check:architecture
      blocking: false
      baseline:
        read: 'grep -E "^Architecture scan" | tail -1'
        accepted: 47          # update deliberately; a drop is an improvement to keep

artefacts:
  - source:     packages/contracts/src/schemas/*.schema.json
    generated:  packages/contracts/dist/schemas/*.schema.json
    regenerate: pnpm -r build
    compare:    structural
  - source:     packages/contracts/src/schemas/*.schema.json
    generated:  packages/contracts/src/schema-types.ts
    regenerate: pnpm contracts:generate
    driftCheck: pnpm check:drift
    compare:    bytes

paths:
  risk:
    - packages/contracts/src/schemas/**
    - workflows/*.json
    - "**/*.sql"
    - "**/migrations/**"
    - "**/*.tf"
    - Dockerfile*
    - docker-compose*.yml
    - .env.example
    - "**/auth/**"
    - "**/billing/**"

state:
  directory:           .claude/cache/
  gateStampTtlSeconds: 300
  writable:            true

integrations:
  todoMirror:        TodoWrite
  independentReview:
    invokedBy: .claude/hooks/codex-review.sh
    trigger:   completing the trailing todo item
    mandatory: large
    maxRuns:   2
  subagents:
    inspect: Explore
    plan:    Plan

tests:
  perPackage:
    - pnpm --filter @scope/contracts test
    - pnpm --filter @scope/workflow-engine test
    - pnpm --filter @scope/backend test        # unit only; integration needs Postgres
    - pnpm --filter @scope/providers test
```

The example is illustrative. None of these commands, package names, paths, or integrations are assumed by any pipeline skill.
