# Installing product-team-skills

**Start here: [Step 0 — which product are you using?](#step-0--which-product-are-you-using)**

Almost every failed install comes from running the right command in the wrong
product. "Claude" is four different things, and they install skills four
different ways. Pick your row, follow that section, stop.

---

## Step 0 — which product are you using?

| What you are looking at | That product is | Go to |
|---|---|---|
| A **terminal** where you typed `claude` | Claude Code CLI | [Route A](#route-a--claude-code-in-a-terminal) — 2 min |
| The **Claude desktop app**, on the **Code** tab | Claude Code Desktop | [Route B](#route-b--claude-code-desktop-app) — 2 min |
| The **Claude desktop app**, on the **Chat** tab, or **claude.ai** in a browser | Claude apps (chat) | [Route D](#route-d--claude-apps-chat-and-cowork) — 5 min |
| **claude.ai/code**, a GitHub Action, or a cloud/remote session | Claude Code cloud | [Route C](#route-c--claude-code-cloud-and-web-sessions) — 3 min |
| You want the skills **committed into one repo** for your team | any | [Route E](#route-e--filesystem-install-installsh) — 3 min |

> **The single most common mistake.** The Claude desktop app contains both
> Claude Code (**Code** tab) and the chat product (**Chat** tab). They do not
> share an install mechanism. The Code tab uses plugins; the Chat tab uses
> uploaded skills. Installing into one does not install into the other.

### Three names that look alike

You will type all three. They are deliberately listed here because guessing
wrong is the most common terminal error:

| Thing | Value | Where you type it |
|---|---|---|
| GitHub repo | `afovea/product-team-skills` | `marketplace add` |
| Marketplace | `productteam-skills` — **no hyphen after `product`** | `install …@productteam-skills` |
| Plugin | `product-team` | `install product-team` |

Typing `product-team@product-team-skills` — the natural guess — fails with:

```
Plugin "product-team" not found in marketplace "product-team-skills".
```

**You can avoid the whole problem: `claude plugin install product-team` works
without the `@marketplace` suffix.** Use that form.

---

## Route A — Claude Code in a terminal

**Requirement:** Claude Code v2.1.143 or later. Check with `claude --version`.
If `/plugin` is not recognised, update: `npm install -g @anthropic-ai/claude-code@latest`.

### 1. Add the marketplace

Inside a Claude Code session:

```
/plugin marketplace add afovea/product-team-skills
```

Expect: `Successfully added marketplace: productteam-skills`

### 2. Install the plugin

```
/plugin install product-team
```

Expect: `Successfully installed plugin: product-team@productteam-skills (scope: user)`

### 3. Activate it

Read the install summary Claude Code prints:

| It says | You do |
|---|---|
| `Plugin is now active.` | Nothing. Go to step 4. |
| `Run /reload-plugins to activate.` | Run `/reload-plugins`. If it warns about re-reading the conversation, run `/reload-plugins --force`. |

### 4. Verify before you rely on it

```
/plugin list
```

You should see `product-team@productteam-skills` with `Status: enabled`.

Then type a `/` and start typing `product-` — `product-manager`,
`product-designer` and `product-strategist` should appear in the completion
list. If they do, you are done.

### 5. Use it

Give the skill the task **in the same message**. Invoking bare just loads the
persona and it will ask you what you want.

```
/product-manager Turn this vague feature request into a delivery-ready ticket.
```

**Prefer the CLI?** The same thing from a shell, outside a session:

```bash
claude plugin marketplace add afovea/product-team-skills
claude plugin install product-team
```

Shell installs never apply to a session that is already open. Start a new
session, or run `/reload-plugins` in the open one.

---

## Route B — Claude Code Desktop app

Use this when you are on the **Code** tab of the Claude desktop app. You do not
need a terminal and you do not need the `claude` CLI.

1. Click the **+** button next to the prompt box.
2. Choose **Plugins** → **Add plugin**. The plugin browser opens.
3. If `product-team` is not listed, add the marketplace first: type
   `/plugin marketplace add afovea/product-team-skills` into the prompt box,
   then reopen the browser.
4. Select **product-team**, choose a scope (**User** installs it everywhere —
   pick this if unsure), and install.
5. Verify: **+** → **Plugins** should now list `product-team` and its skills.

Then use it exactly as in [Route A step 5](#5-use-it).

> **Two limits worth knowing.** The plugin browser is not available in cloud
> sessions, and plugins installed here do not carry into cloud sessions — see
> [Route C](#route-c--claude-code-cloud-and-web-sessions). Plugins are also not
> available in WSL sessions; on Windows use the desktop app's own sessions, or
> [Route E](#route-e--filesystem-install-installsh).

---

## Route C — Claude Code cloud and web sessions

Cloud sessions (claude.ai/code, GitHub Actions, remote environments) do not
read your machine. They clone the repository and read **its** configuration —
so the install has to be committed to the repo you are working in.

Create or edit `.claude/settings.json` **in that repository** and commit it:

```json
{
  "extraKnownMarketplaces": {
    "productteam-skills": {
      "source": {
        "source": "github",
        "repo": "afovea/product-team-skills"
      }
    }
  },
  "enabledPlugins": {
    "product-team@productteam-skills": true
  }
}
```

If the file already exists, merge these two keys into it rather than replacing
the file.

Commit and push. The plugin installs at session start for everyone who opens a
cloud session on that repo — no per-person setup.

> If your `.gitignore` contains `.claude/`, this file will not be committed and
> nothing will happen. Add an exception: `!.claude/settings.json`. A previous
> run of `install.sh` may have added that `.claude/` line for you.

**Verify:** start a cloud session and type `/product-` in the prompt. The role
skills should appear.

---

## Route D — Claude apps (Chat and Cowork)

This is the **Chat** tab of the desktop app, claude.ai in a browser, and Cowork
sessions. It is a different product from Claude Code: it does not read this
repository, does not use plugins, and does not use marketplaces. Skills are
uploaded one at a time as ZIP files.

### 1. Turn the prerequisites on

In **Settings → Capabilities**, enable **Code execution** and **File creation**.
Skills do not run without them.

### 2. Build the ZIPs

Clone the repo and run the packager:

```bash
git clone https://github.com/afovea/product-team-skills.git
cd product-team-skills
./scripts/package-skills.sh
```

This writes one upload-ready ZIP per skill into `dist/`.

Nothing to clone from? `./scripts/package-skills.sh product-manager product-designer`
packages just those two.

### 3. Upload the ones you want

Open **Customize** in the desktop app sidebar (or the skills settings on
claude.ai) → **Skills** → **+** → upload a ZIP → toggle the skill on.

**Upload only the roles you will use.** There are 27 ZIPs and the uploader takes
one at a time, so uploading everything is a twenty-minute job for skills you may
never invoke. Three or four roles is a sensible start.

### 4. What does not travel

- **The routing brain** (`routing.md`) needs a `CLAUDE.md`, which these products
  do not read. Roles work; automatic role selection does not.
- **The gate-enforcement hook** is a Claude Code feature. The pipeline skills
  still run and still report a failing gate — nothing can *stop* the turn.

Uploaded skills sync between claude.ai and the desktop app's Chat tab, and are
private to your account.

---

## Route E — filesystem install (`install.sh`)

Use this when you want the skills **plus the routing brain** in a specific
project, or when plugins are unavailable (WSL, an offline machine, a
non-Claude-Code host that reads `SKILL.md`).

```bash
git clone https://github.com/afovea/product-team-skills.git
cd product-team-skills
./install.sh --verify                    # what is installed right now?
./install.sh /path/to/your-project       # into one project
```

Running `./install.sh` with no arguments prints this menu rather than doing
anything — it will not guess a target.

| Command | Result |
|---|---|
| `./install.sh /path/to/project` | Skills in `<project>/.claude/skills/`, routing brain appended to its `CLAUDE.md`, `.gitignore` and pipeline adapter seeded |
| `./install.sh .` | The same, into the current directory |
| `./install.sh --personal` | Skills in `~/.claude/skills/` — available in every project. Skills only, no routing brain |
| `./install.sh --submodule /path/to/project` | Per-project, pinned to a tag, symlinked so discovery still works |
| `./install.sh --verify` | Reports every place the suite is installed, and flags conflicts |

Re-running is safe. The routing block is replaced in place between its markers,
anything you wrote above it is left alone, and an existing pipeline adapter is
never overwritten.

**Verify:** `./install.sh --verify`, then start Claude Code in that project and
type `/product-`.

### Windows

`install.sh` is a bash script. On Windows use [Route B](#route-b--claude-code-desktop-app)
(the desktop app), or run the script from Git Bash or WSL. Note that plugins do
not load in WSL sessions, so inside WSL the filesystem install is the working
route.

---

## Did it work? One check per route

| Route | Check | Healthy answer |
|---|---|---|
| A, B | `/plugin list` | `product-team@productteam-skills` · `enabled` |
| A, B | `claude plugin details product-team` | `Skills (27)` |
| C | Start a cloud session, type `/product-` | Role skills autocomplete |
| D | Customize → Skills | Your uploaded skills, toggled on |
| E | `./install.sh --verify` | Reports the install and no conflicts |

In every route the real proof is the same: type `/` and start typing
`product-`. If the roles autocomplete, you are installed.

---

## Troubleshooting

Matched against the exact message you get.

### `Plugin "product-team" not found in marketplace "product-team-skills"`

You used the repo name where the marketplace name goes. The marketplace is
`productteam-skills`, with no hyphen after `product`. Use
`/plugin install product-team` and skip the suffix entirely.

### `Marketplace "productteam-skills" not found`

The marketplace was never added, or was removed. Run
`/plugin marketplace add afovea/product-team-skills` first.

### `command not found: claude`

You are not in a Claude Code terminal. Either you are in the Chat tab or on
claude.ai ([Route D](#route-d--claude-apps-chat-and-cowork)), or Claude Code is
not installed on this machine. The desktop app does **not** put `claude` on your
PATH — use [Route B](#route-b--claude-code-desktop-app) instead.

### `/plugin` is not recognised, or "unknown command"

Either your Claude Code is too old — check `claude --version`, then
`npm install -g @anthropic-ai/claude-code@latest` and restart — or you are not
in Claude Code at all (see the row above).

### Install said it succeeded, but `/product-manager` is not there

In order:

1. Did you skip the activation step? Run `/reload-plugins`, then
   `/reload-plugins --force` if it warns.
2. Was it a shell install (`claude plugin install`) into an already-open
   session? Those never apply to the running session. Start a new one.
3. Still missing — clear the plugin cache and reinstall:
   ```bash
   rm -rf ~/.claude/plugins/cache
   claude plugin install product-team
   ```
   Then restart Claude Code.

### The skills are there but nothing routes automatically

Working as designed. Every skill sets `disable-model-invocation: true`, so
describing a problem in prose will not summon a role. Invoke it by name, or
install the routing brain with [Route E](#route-e--filesystem-install-installsh)
— it is a `CLAUDE.md` convention and only the filesystem route can add it.

### A skill answers, but ignores what I asked

You invoked it bare. `/product-designer` on its own loads the persona with no
brief. Put the task in the same message.

### `/product-manager` runs an older copy than the one I updated

You have the suite installed twice. Filesystem skills and plugin skills live in
different namespaces: a personal or project skill named `product-manager` claims
the bare `/product-manager`, while the plugin copy stays reachable as
`/product-team:product-manager`. Both work — you are just editing one and
running the other.

Run `./install.sh --verify` to see every copy, then keep one.

### Marketplace is stale — a new skill is missing

Third-party marketplaces have auto-update **off** by default:

```
/plugin marketplace update productteam-skills
/plugin install product-team
```

### `.claude/skills/pipeline/` exists and pipeline skills appear twice

Left over from a v2.x install, where the pipeline skills were nested one level
deeper. Delete it:

```bash
rm -r ~/.claude/skills/pipeline            # personal install
rm -r <project>/.claude/skills/pipeline    # project install
```

### Every turn ends with a Python error

The gate-enforcement `Stop` hook needs `python3` on your PATH. It only wakes up
when a pipeline run is open, so this appears once you start using
`/run-pipeline`. Install Python 3, or disable the hook with
`claude plugin disable product-team`.

---

## Uninstall / start clean

```bash
claude plugin uninstall product-team              # plugin install
claude plugin marketplace remove productteam-skills   # and its marketplace
```

Filesystem installs are removed by deleting the directories — `./install.sh --verify`
prints the exact paths in use.

For cloud sessions, remove the two keys from the repository's
`.claude/settings.json`.

---

## What each route actually gives you

| | Skills | Routing brain | Gate hook | Updates with |
|---|---|---|---|---|
| **A / B** plugin | ✅ all 27 | ❌ | ✅ | `claude plugin update product-team` |
| **C** cloud | ✅ all 27 | ❌ | ✅ | commit a new pin |
| **D** Claude apps | ✅ ones you upload | ❌ | ❌ | re-upload |
| **E** project | ✅ all 27 | ✅ | ❌ | re-run `install.sh` |
| **E** submodule | ✅ all 27 | ✅ | ❌ | bump the submodule |

Routes stack. Plugin **plus** a per-project `install.sh` run is a reasonable
combination — you get the gate hook from the plugin and the routing brain from
the project. Just do not install the same skills at two *filesystem* levels; see
the duplicate-copy entry in [Troubleshooting](#troubleshooting).
