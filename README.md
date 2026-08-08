# product-team-skills

A coordinated product team as **27 Agent Skills** — 19 role perspectives plus an 8-skill delivery pipeline — with a routing brain that decides which one a request belongs to.

Invoke a role when you want a specific discipline's judgement: a PRD, a component spec, an accessibility review, a threat model, a motion spec, a release decision. Run the pipeline when a coding task should be classified, chunked and verified rather than just done.

Every role is project-agnostic, so the same suite works on any codebase without dragging another project's context along.

**→ [What can my product team do?](./what-can-my-product-team-do.md)**  
See the kinds of end-to-end product work these skills can undertake individually and in combination.

## Quick start

**Find your row, then read that section.** Which Claude you are in decides the
method — they are not interchangeable, and using the wrong one is the single
most common failed install.

| Where you are | Method | Section |
|---|---|---|
| **Claude web** — `claude.ai` in a browser, chatting | Upload each role | [A](#a--claude-web-claudeai-in-a-browser) |
| **Claude app** — desktop app, **Chat** tab | Upload each role | [B](#b--claude-app-chat-tab) |
| **Claude app** — desktop app, **Code** tab | Two typed lines, all 27 | [C](#c--claude-app-code-tab-claude-code) |
| **Claude Code** — a terminal | Two typed lines, all 27 | [D](#d--claude-code-in-a-terminal) |
| **Claude Code on the web** — `claude.ai/code`, cloud sessions | A committed settings file | [E](#e--claude-code-on-the-web-cloud-sessions) |

---

### A · Claude web (`claude.ai` in a browser)

Chat, in a browser. Download the roles you want and upload them.

1. **Settings → Capabilities** → switch on **Code execution** and **File
   creation**. Skills do not run without both.
2. Download a role — say
   [product-designer.zip](https://github.com/afovea/product-team-skills/raw/main/download/product-designer.zip)
   or [product-manager.zip](https://github.com/afovea/product-team-skills/raw/main/download/product-manager.zip).
   All 27 are in [`download/`](./download). **Do not unzip them.**
3. **Settings → Capabilities → Skills → +** → upload the file → switch it on.
4. Ask for what you want, naming the role: *"As a product designer, our reports
   page is blank for new users. Design the empty state."*

Uploads attach to your account, so they appear in the app's Chat tab too — do
this once, not twice.

### B · Claude app, Chat tab

Same product as A, same files, **different menu**. The app has a
**Customize** entry that the browser does not.

1. **Settings → Capabilities** → switch on **Code execution** and **File
   creation**.
2. Download the roles you want from [`download/`](./download).
3. **Customize** in the left sidebar → **Skills** → **+** → upload → switch it on.
4. Ask for what you want, naming the role.

Already done it in the browser? Your skills are already here. Skip this.

### C · Claude app, Code tab (Claude Code)

Not chat — this is Claude Code inside the app. Installs all 27 at once, with no
terminal: the two lines go into the ordinary message box.

```
/plugin marketplace add afovea/product-team-skills
/plugin install product-team
```

If it says `Run /reload-plugins to activate.`, run that too. Then type
`/product-` — the roles should autocomplete:

```
/product-manager Turn this vague feature request into a delivery-ready ticket.
```

The app asks for a project folder before you can send anything. Pick any folder —
the install goes onto your account, works in every folder afterwards, and writes
nothing into the one you picked.

### D · Claude Code in a terminal

Identical to C. Run `claude` from any folder, then type the same two lines.

```
/plugin marketplace add afovea/product-team-skills
/plugin install product-team
```

### For C and D

You also get the delivery pipeline and the gate-enforcement hook. Add
[the routing brain](#the-routing-brain-optional-second-layer) with
`./install.sh --routing-only /path/to/project` and Claude picks the role for you.

> Copy those two lines exactly. The names differ by a hyphen — the repo is
> `product-team-skills`, the marketplace `productteam-skills`, the plugin
> `product-team`. `/plugin install product-team@product-team-skills` fails with
> `Plugin "product-team" not found in marketplace "product-team-skills"`.

### E · Claude Code on the web (cloud sessions)

Cloud sessions do not read your machine, and the plugin browser is unavailable
there. Declare the plugin in the repository instead, and everyone who opens a
cloud session on it gets the skills automatically.

Add this to `.claude/settings.json` **in that repository** and commit it:

```json
{
  "extraKnownMarketplaces": {
    "productteam-skills": {
      "source": { "source": "github", "repo": "afovea/product-team-skills" }
    }
  },
  "enabledPlugins": { "product-team@productteam-skills": true }
}
```

Merge these keys into the file if it already exists. If `.gitignore` contains
`.claude/`, add `!.claude/settings.json` or the file will never be committed.

---

**➡️ [Step-by-step guide for all of these, written for non-technical users](./INSTALL.md)**
— how to tell which Claude you are in, where to click, what you should see, and
what to do when it does not work.

> **Installed from the old `ProductTeam-skills` repo?** It has moved here — see [Migrating](#migrating-from-the-old-repo).

## Invoking a skill

**Whichever route you installed by, give the role the actual task in the same
message.** Summoning a role with nothing to do gets you a question back, not the
work.

### In a browser or the app's chat

Name the role in ordinary words. Claude picks the skill from what you wrote.

```
As a product designer, our reports page is blank for new users. Design the empty state.
Acting as an accessibility specialist, this chart uses colour alone for four series. Problem?
As a content designer, rewrite this error: "Error 4012: request failed."
```

If Claude picks the wrong expert, say so — "answer this as a content designer,
not a product manager". Uploading fewer skills makes it pick better.

### In Claude Code

Type `/` then the skill name.

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

### Automatic selection differs by host, on purpose

In Claude Code every skill sets `disable-model-invocation: true`, so describing a
design problem in prose will **not** auto-summon `/product-designer`. That is
deliberate: automatic invocation selects by description keyword-matching, and
testing showed that picks badly — "payments integration" pulled the Pricing
Strategist, "release risk" pulled the Delivery Manager. You get selection
explicitly with `/name`, or via [the routing brain](#the-routing-brain-optional-second-layer)
when you don't know which discipline you want.

The Claude apps have no `/name` invocation at all, so Claude choosing is the only
mechanism there. The ZIPs under [`download/`](./download) therefore ship with
that line stripped — keeping it would package skills that could never fire.
Naming the role in your sentence is how you steer the choice.

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

Five routes, one per product surface. **[INSTALL.md](./INSTALL.md) walks each
one through to a verified install**, with a troubleshooting section keyed to the
exact error text. The summary:

| Route | Command | You get |
|---|---|---|
| **Plugin** *(recommended)* | `/plugin install product-team` | All 27 skills **plus** the gate hook. Updatable with one command. No routing brain |
| **Desktop app** | **+** → Plugins → Add plugin | The same, without a terminal |
| **Cloud / web** | two keys in the repo's `.claude/settings.json` | The same, for everyone opening a cloud session on that repo |
| **Routing only** | `install.sh --routing-only /path/to/project` | The routing brain alone, for when the plugin already supplies the skills |
| **Per project** | `install.sh /path/to/project` | Skills in `<project>/.claude/skills/` **plus** the routing brain in its `CLAUDE.md` |
| **Personal** | `install.sh --personal` | Skills in `~/.claude/skills/` — every project. Skills only |
| **Submodule** | `install.sh --submodule /path/to/project` | Per-project, pinned to a tag, symlinked so discovery still works |
| **Claude apps** *(no terminal)* | download a ZIP from [`download/`](./download), upload it | The roles you upload, in claude.ai and the Chat tab. No routing brain, no hook |

The script is in the repo, so clone first for those routes:

```bash
git clone https://github.com/afovea/product-team-skills.git
cd product-team-skills
./install.sh --verify                     # what is installed right now?
./install.sh /path/to/your-project
```

It copies the skills, appends the routing brain to `CLAUDE.md` **with the paths already rewritten**, updates `.gitignore`, and seeds a pipeline adapter template. Re-running updates the routing block in place between its markers and leaves anything you wrote above it alone. Running it with no arguments prints the menu rather than guessing a target.

### Which route

- **Just want the skills?** Plugin — terminal, desktop app, or a committed `.claude/settings.json` for cloud sessions.
- **Want role arbitration too?** Plugin *plus* `install.sh --routing-only`. Routing lives in `CLAUDE.md`, which is per-project, so no plugin can carry it. Use `--routing-only` rather than a full per-project install: the latter puts a second copy of all 27 skills on disk, which claims the bare `/name` and then goes stale independently of the plugin.
- **Want it pinned and tracked in the consuming repo?** Submodule.
- **On claude.ai or the desktop app's Chat tab?** Those are a different product from Claude Code — download a ZIP from [`download/`](./download) and upload it, per [INSTALL.md](./INSTALL.md#part-4--claude-for-chatting-browser-or-chat-tab).

**The repo is the source, not an installation.** Cloning it makes the skills visible nowhere. Claude Code discovers them at `~/.claude/skills/<name>/SKILL.md` or `<project>/.claude/skills/<name>/SKILL.md`, or from an installed plugin. Pick a route above, or you will not see them.

### Precedence and duplicates

Enterprise overrides personal, and personal overrides project. Plugin skills are namespaced `plugin-name:skill-name`, so they never *collide* — but the bare name resolves to the filesystem copy. Install both ways and `/product-manager` runs the filesystem skill while the plugin copy stays reachable as `/product-team:product-manager`. Both work; you are just editing one and running the other.

`./install.sh --verify` reports every copy it can find, and says which combinations are worth reducing to one.

### Context cost, and how to turn it down

Installing 27 skills is not free. Two different costs, and the second is the one that actually bites.

**Always-on** — every skill's `name` and `description` are preloaded into the system prompt so the host knows what exists. That is **~2,300 tokens on every session**, including projects with nothing to do with product work. Nothing else loads until a skill is invoked.

**On-invoke** — the skill's body enters the conversation when you call it, and **stays there for the rest of the session**. That ranges from ~1k to ~9.5k tokens depending on the skill. This is the larger number by far.

See your own figures, per skill:

```bash
claude plugin details product-team
```

The heaviest bodies are worth knowing before you invoke them casually:

| Skill | always-on | on-invoke |
|---|---:|---:|
| `motion-designer` | ~270 | ~13k |
| `run-pipeline` | ~110 | ~7.9k |
| `security-specialist` | ~120 | ~7.7k |
| `storm-researcher` | ~90 | ~6.7k |
| *typical role* | ~50–150 | ~1.6–3.6k |

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
claude plugin install product-team

# 2. if you used a filesystem install from an older layout, clear the stale
#    nested pipeline directory — skills are flat now
rm -r ~/.claude/skills/pipeline            # personal installs
rm -r <project>/.claude/skills/pipeline    # project installs
```

Earlier versions nested the eight pipeline skills one level deeper, so an old install leaves that directory behind and they end up present twice. `install.sh` detects this and prints the exact command rather than deleting anything itself.

### Compatibility

The skills are plain markdown following the [Agent Skills](https://agentskills.io) standard, so they work with any host that reads `SKILL.md`. The plugin route, `/name` invocation and `claude plugin` CLI are Claude Code features. The routing brain is a `CLAUDE.md` convention and needs a host that reads that file.

Gate enforcement is the one capability that does not travel. Hooks are a Claude Code feature, so on any other `SKILL.md` host the pipeline skills still run and still report a failing gate — they just cannot be stopped by one. The skills remain fully portable; only the `Stop` hook is host-specific.

What survives on each surface:

| | Skills | Routing brain | Gate hook |
|---|---|---|---|
| Claude Code — terminal, desktop **Code** tab, cloud | ✅ | ✅ with a project install | ✅ |
| Claude apps — claude.ai, desktop **Chat** tab, Cowork | ✅ ones you upload | ❌ no `CLAUDE.md` | ❌ no hooks |
| Any other `SKILL.md` host | ✅ | depends on the host | ❌ |

Claude Code in **WSL** is the one Claude Code surface without plugins — use a filesystem install there.

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
├── download/                         # one upload-ready ZIP per skill, committed
│   ├── product-designer.zip          #   so non-technical users can install
│   └── ...                           #   without a terminal. CI keeps it in sync
├── scripts/
│   ├── gate-chain.py                 # standalone gate chain runner
│   └── package-skills.sh             # rebuilds download/
├── reference/                        # shared docs, deliberately not skills
│   ├── project-adapter.md
│   └── state-schema.md
├── routing.md                        # the routing brain
├── install.sh                        # filesystem install; --verify reports state
├── INSTALL.md                        # every install route, with troubleshooting
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
