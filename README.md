# product-team-skills

A coordinated product team as **27 Agent Skills** — 19 role perspectives plus an 8-skill delivery pipeline — with a routing brain that decides which one a request belongs to.

Invoke a role when you want a specific discipline's judgement: a PRD, a component spec, an accessibility review, a threat model, a motion spec, a release decision. Run the pipeline when a coding task should be classified, chunked and verified rather than just done.

Every role is project-agnostic, so the same suite works on any codebase without dragging another project's context along.

## Quick start

**Claude Code (terminal):**

```
/plugin marketplace add afovea/product-team-skills
/plugin install product-team@productteam-skills
```

**Claude Desktop** — `/plugin` is terminal-only, so use the CLI:

```bash
claude plugin marketplace add afovea/product-team-skills
claude plugin install product-team@productteam-skills
```

Restart your session. All 27 skills appear in **Settings → Skills** and become invocable by name.

```
/product-manager Turn this vague feature request into a delivery-ready ticket.
```

> **Installed from the old `ProductTeam-skills` repo?** It has moved here — see [Migrating](#migrating-from-the-old-repo).

## Invoking a skill

Type `/` then the skill name, **and give it the task in the same message.** Invoking bare loads the persona with no brief, and it will just ask you what you want.

```
/product-designer Our reports page is blank for new users. Design the empty state.
/security-specialist Review this migration for RLS gaps.
/accessibility-specialist This chart uses colour alone for four series. Problem?
/run-pipeline Add a /health route returning DB connectivity.
```

Two forms both work:

| Form | Use when |
|---|---|
| `/product-designer` | Normal use — shortest form |
| `/product-team:product-designer` | Unambiguous. Needed only if a personal or project skill shares the name |

### They do not fire on their own

Every skill sets `disable-model-invocation: true`. Describing a design problem in prose will **not** auto-summon `/product-designer`. That is deliberate: automatic invocation selects by description keyword-matching, and testing showed that picks badly — "payments integration" pulled the Pricing Strategist, "release risk" pulled the Delivery Manager.

You get selection two ways instead:

- **Explicitly**, with `/name` — when you know which discipline you want.
- **Via the routing brain**, by asking in plain prose — when you don't. See [The routing brain](#the-routing-brain-optional-second-layer).

### Once invoked, a skill stays loaded

The persona persists across turns for the rest of the conversation. Invoke a different one to switch; start a fresh session to drop it.

## The 27 skills

### Product and strategy

| Invoke | Use when |
|---|---|
| `/product-manager` | Value, scope, outcomes, prioritisation, PRDs, backlog structure |
| `/product-strategist` | Market positioning, vision, strategic bets, competitive framing |
| `/growth-product-marketing-manager` | Adoption, activation, messaging, funnel, CRO, content strategy, SEO |
| `/pricing-strategist` | Pricing models, tier structure, packaging, willingness-to-pay |

### Research, insight and data

| Invoke | Use when |
|---|---|
| `/ux-researcher` | Research planning, discovery, interviews, synthesis, validation |
| `/data-analyst` | Metrics, dashboards, funnels, experiments, behavioural evidence |
| `/customer-success` | Customer feedback, retention signals, adoption blockers |
| `/storm-researcher` | Contested or strategic research — five-perspective scan, contradiction mapping, adversarial review |

### Design and experience

| Invoke | Use when |
|---|---|
| `/product-designer` | UX, UI, flows, interaction design, design QA |
| `/content-designer` | UX writing, labels, errors, onboarding, comprehension |
| `/design-systems-specialist` | Components, tokens, theming, UI foundation choice, component source intake |
| `/motion-designer` | Animation, transitions, micro-interactions, pointer effects, ambient/WebGL backgrounds, motion tokens, reduced motion, animation performance |
| `/accessibility-specialist` | WCAG review, inclusive design, assistive-tech risk, data-visualisation accessibility |

### Engineering, delivery and quality

| Invoke | Use when |
|---|---|
| `/software-engineer` | Implementation, feasibility, trade-offs, library selection, version-matched API use |
| `/technical-architect` | System design, integration strategy, scalability, standing-dependency evaluation |
| `/devops-engineer` | CI/CD, environments, deployment and rollback, observability — risk in the *running system* |
| `/security-specialist` | Threat modelling, audits, auth/RLS review, DPIA, supply chain and licence boundaries, AI safety |
| `/qa-engineer` | Test planning, regression, bug reporting, durable proof of verification |
| `/delivery-manager` | Delivery planning, dependencies, ceremonies — risk to *schedule and flow* |

### Delivery pipeline

| Invoke | Use when |
|---|---|
| `/run-pipeline` | **Start here for any coding task.** Classifies Small / Medium / Large and dispatches |
| `/requirements-generator` | Turning a rough request into a confirmation-ready brief |
| `/shape-task` | Decomposing a brief into requirements, strategy and chunks |
| `/execute-chunk` | Implementing one approved chunk with scoped edits and targeted validation |
| `/close-chunk` | Verifying a chunk against its acceptance criteria |
| `/cleanup-verify` | Post-run sweep: regenerate artefacts, rebuild, run the gate chain, report drift |
| `/diagnose` | Root-cause analysis — reproduce → isolate → verify → fix |
| `/design-critique` | Final-pass design review with a SHIP / SHIP_WITH_NOTES / HOLD decision |

Two roles carry reference material that loads only when needed: `/security-specialist` (a nine-category audit cookbook and a health-data domain pack) and `/motion-designer` (standards, libraries and component-gallery intake).

## Install options

| Route | Command | You get |
|---|---|---|
| **Plugin** *(recommended)* | `claude plugin install product-team@productteam-skills` | All 27 skills, visible in Settings → Skills, updatable with one command. Skills only |
| **Per project** | `install.sh /path/to/project` | Skills in `<project>/.claude/skills/` **plus** the routing brain in its `CLAUDE.md` |
| **Personal** | `install.sh --personal` | Skills in `~/.claude/skills/` **plus** the global memory block in `~/.claude/CLAUDE.md` — every project |
| **Global memory** | `install.sh --memory` | The global memory block only. No skills, so none of the per-skill context cost |
| **Submodule** | `install.sh --submodule /path/to/project` | Per-project, pinned to a tag, symlinked so discovery still works |

The script is in the repo, so clone first for those routes:

```bash
git clone https://github.com/afovea/product-team-skills.git
./product-team-skills/install.sh /path/to/your-project
```

It copies the skills, appends the routing brain to `CLAUDE.md` **with the paths already rewritten**, updates `.gitignore`, and seeds a pipeline adapter template. Re-running updates the routing block in place between its markers and leaves anything you wrote above it alone.

### Which route

- **Just want the skills, everywhere, visible?** Plugin.
- **Want role arbitration too?** Plugin *plus* a per-project install — they stack. Only the per-project route can add `routing.md`, because `CLAUDE.md` is a per-project file.
- **Want a rule to hold in every session, not only in product work?** `--memory`. It stacks with the plugin, which ships skills and hooks and so cannot reach `CLAUDE.md` on its own.
- **Want it pinned and tracked in the consuming repo?** Submodule.

**The repo is the source, not an installation.** Cloning it makes the skills visible nowhere. Claude Code discovers them at `~/.claude/skills/<name>/SKILL.md` or `<project>/.claude/skills/<name>/SKILL.md`; the Skills panel lists only plugin-provided skills. Pick a route above, or you will not see them.

### Global memory

Some rules are not about product work and should not wait to be routed to a role — they have to hold in any session that can reach a browser, a shell or a repository. Those live in one block in [`routing.md`](./routing.md), between its `global-memory` markers.

It reaches you by two routes, from that single source, so the two cannot drift apart:

| Route | Where it lands | Reach |
|---|---|---|
| `install.sh --personal` or `--memory` | `~/.claude/CLAUDE.md` | Every project on that machine |
| `install.sh /path/to/project` | the project's `CLAUDE.md`, inside the routing block | That project, for anyone who clones it |

Both are idempotent and marker-delimited: re-running replaces the block in place and leaves everything you wrote around it alone.

### Account-level memory

`~/.claude/CLAUDE.md` covers every Claude Code session **on one machine**. It does not reach the Claude apps (web, desktop, mobile) or the Claude in Chrome extension. Those read your account's preferences, which sync to every session you are signed into, on every device.

**Nothing in this repo can write there** — it is a setting on your account, not a file on disk. To make a rule hold on those surfaces too, paste it into Claude's settings under personal preferences:

```text
When driving a browser, act on element references from the page's structured
representation — the accessibility tree — never on screen coordinates read off
a screenshot. Coordinates are true only for the instant the screenshot was
taken; layout shift, lazy loading, scroll position, zoom or a consent banner
move the target while the coordinates stay the same, so the click still lands,
on whatever is underneath it now, and the run reads as a pass. If a control has
no referenceable element, report it as an accessibility finding rather than
working around it with coordinates.
```

The two are complementary rather than alternatives: the account preference covers the Chrome extension and the apps, the install routes cover Claude Code.

### Precedence and duplicates

Enterprise overrides personal, personal overrides project, and any of them overrides a plugin skill of the same name. So a personal install **shadows the plugin silently** — both work, but you are running the copy you probably did not mean to update. Pick one route per machine.

### Context cost, and how to turn it down

Installing 27 skills is not free. Two different costs, and the second is the one that actually bites.

**Always-on** — every skill's `name` and `description` are preloaded into the system prompt so the host knows what exists. That is **~1,800 tokens on every session**, including projects with nothing to do with product work. Nothing else loads until a skill is invoked.

**On-invoke** — the skill's body enters the conversation when you call it, and **stays there for the rest of the session**. That ranges from ~1k to ~9.5k tokens depending on the skill. This is the larger number by far.

See your own figures, per skill:

```bash
claude plugin details product-team
```

The heaviest bodies are worth knowing before you invoke them casually:

| Skill | always-on | on-invoke |
|---|---:|---:|
| `motion-designer` | ~210 | ~9.5k |
| `run-pipeline` | ~80 | ~5.8k |
| `security-specialist` | ~90 | ~5.6k |
| `storm-researcher` | ~70 | ~4.9k |
| *typical role* | ~50 | ~1.3–2.5k |

#### Turn the always-on cost off entirely

```bash
claude plugin disable product-team          # off, still installed
claude plugin enable product-team           # back on
claude plugin disable --all                 # every plugin
```

`disable` takes `--scope user|project|local`, so you can switch the suite off globally and leave it on in one repo, or the reverse.

#### Scope it to the projects that need it

Installing at project scope keeps the always-on cost out of every unrelated session:

```bash
claude plugin install product-team@productteam-skills --scope project
```

#### Drop skills you never use

There is no per-skill disable. Two ways to trim anyway:

- **Filesystem install** — delete the directories you do not want. `install.sh --personal` then `rm -r ~/.claude/skills/motion-designer` removes that skill and its always-on share. Losing `motion-designer` alone saves ~210 tokens per session, more than four typical roles.
- **Fork the plugin** — remove the skill directories from `skills/` and point your marketplace at your fork. Survives updates; a filesystem deletion does not.

#### Managing the on-invoke cost

- A skill loads **once** per session. Re-invoking the same one adds a short note, not a second copy.
- Start a fresh session to clear loaded skills, rather than invoking a different one to "switch".
- After auto-compaction, invoked skills are re-attached at up to 5,000 tokens each within a **combined 25,000-token budget**, most-recent first. Invoke many heavy skills in one session and the earliest ones get dropped entirely — so if a skill seems to stop influencing behaviour after a long session, re-invoke it.

### Migrating from the old repo

This suite previously lived at `afovea/ProductTeam-skills`, which is now archived. If you installed from there:

```bash
# 1. point the marketplace at the new repo
claude plugin marketplace remove productteam-skills
claude plugin marketplace add afovea/product-team-skills
claude plugin install product-team@productteam-skills

# 2. if you used a filesystem install from an older layout, clear the stale
#    nested pipeline directory — skills are flat now
rm -r ~/.claude/skills/pipeline            # personal installs
rm -r <project>/.claude/skills/pipeline    # project installs
```

Earlier versions nested the eight pipeline skills one level deeper, so an old install leaves that directory behind and they end up present twice. `install.sh` detects this and prints the exact command rather than deleting anything itself.

### Compatibility

The skills are plain markdown following the [Agent Skills](https://agentskills.io) standard, so they work with any host that reads `SKILL.md`. The plugin route, `/name` invocation and `claude plugin` CLI are Claude Code features. The routing brain is a `CLAUDE.md` convention and needs a host that reads that file.

Gate enforcement is the one capability that does not travel. Hooks are a Claude Code feature, so on any other `SKILL.md` host the pipeline skills still run and still report a failing gate — they just cannot be stopped by one. The skills remain fully portable; only the `Stop` hook is host-specific.

## The routing brain (optional second layer)

[`routing.md`](./routing.md) goes in a project's `CLAUDE.md` and decides which role or squad a request belongs to, so you can ask in prose instead of picking a skill:

> "The error message when a payment fails is confusing. Rewrite it." → Content Designer
> "This chart distinguishes four series by colour alone." → Accessibility Specialist
> "Fix the typo in the footer." → no specialist; it is a mechanical edit

It also defines **six squads** for cross-functional work — Discovery, Definition, Delivery, Validation, Growth, Platform — because "is this ready to ship?" is not one discipline's call.

Measured at **89.6% selection accuracy** across 16 cases (up from 70.8%). Two findings drove the improvement, both worth knowing if you edit it:

- **Keyword collision beats persona overlap.** A single salient word drags a request to the wrong role. Where roles genuinely overlap, routing coped fine.
- **The roles table outweighs the prose rules below it.** One case failed 0/3 across three prose edits, then passed when two words changed in the table. Put load-bearing distinctions in the table.

## Delivery pipeline

`/run-pipeline` is the entry point. It classifies scope, surfaces a plan for confirmation, then dispatches — Small runs a single scoped change, Medium adds requirements/shaping and a chunk loop, Large adds repository inspection and an architect plan.

Two documents make it portable:

| Document | Purpose |
|---|---|
| [`reference/project-adapter.md`](./reference/project-adapter.md) | Your project's package manager, gate chain, generated artefacts, risky paths, host integrations. Copy to `.claude/pipeline-adapter.md` and fill in |
| [`reference/state-schema.md`](./reference/state-schema.md) | The shared state contract, and how skills degrade when state is unavailable |

**It runs without an adapter.** Skills fall back to discovering commands from repository instructions, manifests, CI config and the lockfile, and state what they found. Writing the adapter makes it deterministic and lets you declare what discovery cannot infer — which gates may fail, which paths are risky, whether an independent reviewer exists.

Nothing assumes a JavaScript toolchain, a specific agent host, or a writable cache.

### Verified by running, not reading

| Testbed | Result |
|---|---|
| npm project **with** an adapter — blocking drift gate, ratcheted style gate at accepted baseline 3, deliberately stale artefact | `run-pipeline`, `execute-chunk`, `close-chunk`, `cleanup-verify` all correct |
| Python/Make project with **no adapter** and no cache | Discovery fallback correct, zero JavaScript assumptions |

Specifically observed: a "one-line" schema change correctly promoted Small → Medium; `execute-chunk` skipping the build and drift gates because the chunk did not touch a declared risk path; `close-chunk` re-running the gate chain itself rather than trusting the implementer's report; `cleanup-verify` regenerating a stale artefact, refusing to commit it, withholding the gate stamp and returning `BLOCKED`.

### Enforcing the gates

Everything above describes what the pipeline *should* do. A skill that says "run the gate chain" is an instruction, and an instruction can be skipped. `cleanup-verify` returning `BLOCKED` is a report, not a stop.

The plugin ships a `Stop` hook that makes it a stop. Hooks are the only layer in Claude Code that runs as code rather than as instruction, so the gate chain becomes non-negotiable rather than well-intentioned.

| File | Role |
|---|---|
| `scripts/gate-chain.py` | Resolves and runs the gate chain, reports a JSON result, writes a stamp |
| `hooks/gate-stop.py` | The `Stop` hook: refuses to end the turn while a blocking gate is failing |
| `hooks/hooks.json` | Registers the hook. Loads automatically when the plugin is enabled |

**It only wakes up for an open run.** A `Stop` hook fires every turn, so the hook first looks for a pipeline state file under `.claude/`. No state file, no gates, no cost. Detection is by shape rather than by exact filename, so renaming the state contract does not break it. A run can opt out entirely with `"gate_required": false` in its state.

**A pass is bound to the tree it ran against.** The stamp records a fingerprint of `HEAD`, the full uncommitted diff, and the contents of every untracked file git is not ignoring. That last part matters: new source files are untracked until they are committed, and without hashing them a green result would go on vouching for a file it had only ever seen in its first version. Any subsequent edit invalidates the stamp.

**It will not trap you.** After three consecutive blocks on the same tree the hook releases the turn with a warning rather than looping.

`gate-chain.py` is standalone and dependency-free, so pipeline skills can invoke it directly instead of describing the chain in prose:

```bash
python3 scripts/gate-chain.py run --stamp     # run the chain, stamp on pass
python3 scripts/gate-chain.py status          # is there a valid stamp?
python3 scripts/gate-chain.py gates           # show the resolved chain
```

Gate resolution follows the same declare-then-discover pattern as the rest of the pipeline, first hit wins:

1. `.claude/pipeline-gates.json`
2. a ` ```gates ` fenced block in `.claude/pipeline-adapter.md`
3. discovery from `package.json`, `Makefile` or `pyproject.toml`

The adapter form is one gate per line, `name: command`, with a leading `?` marking a gate non-blocking:

```gates
lint: npm run lint
typecheck: npm run typecheck
test: npm test
?style: npm run style
```

Scratch files live in `.claude/.gate/`, which excludes itself from version control. Nothing needs adding to a consuming project's `.gitignore`.

## Repository layout

```
product-team-skills/
├── .claude-plugin/
│   ├── plugin.json                   # makes this an installable plugin
│   └── marketplace.json              # makes the repo an addable marketplace
├── skills/                           # all 27 skills, flat, one directory each
│   ├── product-manager/SKILL.md
│   ├── motion-designer/
│   │   ├── SKILL.md
│   │   └── references/motion-resources.md
│   ├── security-specialist/
│   │   ├── SKILL.md
│   │   └── references/               # audit cookbook, healthcare pack
│   ├── run-pipeline/SKILL.md         # pipeline skills sit alongside roles
│   └── ...
├── hooks/                            # deterministic enforcement
│   ├── hooks.json                    # registers the Stop hook
│   └── gate-stop.py                  # blocks the turn on a failing gate
├── scripts/
│   └── gate-chain.py                 # standalone gate chain runner
├── reference/                        # shared docs, deliberately not skills
│   ├── project-adapter.md
│   └── state-schema.md
├── routing.md                        # the routing brain
├── install.sh
└── README.md
```

`reference/` holds documents that five pipeline skills share. They are not skills, so they sit outside `skills/` rather than being forced into a directory that pretends otherwise.

## Conventions

- All skills use **UK English**.
- Frontmatter carries `name` and `description` (the two fields the standard requires) plus `license`, `compatibility`, `disable-model-invocation`, and a `metadata` block with `version`, `persona_type`, `tags`, `intents` and `output_types`. Everything past the first two is this repo's own convention; hosts ignore what they do not recognise.
- Keep skill bodies **under 500 lines**, per [Anthropic's authoring guidance](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices). Past that, move detail into that skill's `references/` and link to it with a stated trigger for when to read it.
- Every skill ends with `## Maintenance` listing its review triggers. Treat that as a versioning prompt: bump the skill's `version` whenever behaviour-shaping content changes.

## Versioning

Semver, tagged `v<MAJOR>.<MINOR>.<PATCH>` on `main`.

- **MAJOR** — breaking change to a skill's contract or to installed paths.
- **MINOR** — new skill, new intent, new output type.
- **PATCH** — wording, clarifications, frontmatter fixes.

Consuming projects should pin to a tag and update deliberately.

## Licence

[MIT](./LICENSE). Use it, fork it, adapt it. Attribution appreciated but the licence only requires the copyright notice.

## Contributing

Issues and pull requests welcome.

- Follow the existing skill structure when adding one.
- Update [routing.md](./routing.md): a row in the relevant table, squad memberships if cross-functional, and an entry in the specialist-routing examples. **The table matters more than the prose** — see the routing findings above.
- Bump the skill's frontmatter `version` on behaviour-shaping changes.
- Tag a release after merge to `main`.
