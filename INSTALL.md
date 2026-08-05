# How to install

Three ways in, all fully supported. Every one is written out click by click —
none of them assume you write code.

| You are using | Time | Go to |
|---|---|---|
| **Claude Code in the desktop app** — no terminal, all 27 roles at once | 3 min | **[Part 2](#part-2--claude-code-in-the-desktop-app)** |
| **Claude Code in a terminal** — same result, typed commands | 3 min | **[Part 3](#part-3--claude-code-in-a-terminal)** |
| **Claude for chatting** — browser or the app's Chat tab | 5 min | **[Part 4](#part-4--claude-for-chatting-browser-or-chat-tab)** |

Not sure which you have? **[Part 1](#part-1--which-claude-do-you-have)** tells
you from what is on your screen.

---

## What you are installing

27 expert personas. You ask Claude something, and it answers as a product
manager, a UX researcher, an accessibility specialist — with that discipline's
judgement instead of a generic answer.

There is also a **delivery pipeline** for running coding tasks step by step, and
a **routing brain** that picks the right expert for you. Both are optional and
both are covered below.

---

## Part 1 — which Claude do you have?

Look at your screen.

**Claude Code, desktop app.** You have the Claude app open and there are tabs
along the top — **Chat**, **Cowork**, **Code**. You are on **Code**, and it asked
you to pick a folder when you started.
→ **[Part 2](#part-2--claude-code-in-the-desktop-app)**

**Claude Code, terminal.** A window with a blinking cursor where you type
commands, and you started it by typing `claude`.
→ **[Part 3](#part-3--claude-code-in-a-terminal)**

**Claude web.** A web browser with `claude.ai` in the address bar. A message box
and your past conversations down the side.
→ **[Part 4](#part-4--claude-for-chatting-browser-or-chat-tab)**

**Claude app, Chat tab.** The Claude app, on **Chat** rather than **Code**. Same
product as Claude web, and your skills are shared between the two — install in
one and it appears in the other.
→ **[Part 4](#part-4--claude-for-chatting-browser-or-chat-tab)** *(the menus
differ slightly; both are written out)*

These instructions assume Claude is already installed and you are signed in.

---

## Part 2 — Claude Code in the desktop app

No terminal. This installs all 27 roles in one go.

### Step 1 · Open the Code tab

Open the Claude app and click the **Code** tab. It asks you to pick a **project
folder** before you can send a message.

**Pick anything. It does not matter.** You are not setting up a project — Claude
Code just always works somewhere, so it needs a folder to point at. Your
Documents folder is fine. So is a new empty folder on your Desktop.

The install goes onto your account, not into that folder: the roles then work in
**every** folder you ever open, and nothing is written into the one you picked.

> The one exception is the optional [routing brain](#part-5--optional--let-claude-pick-the-expert),
> which is per-folder by design. Everything else here is machine-wide.

### Step 2 · Type two lines

Click into the message box at the bottom — the same one you would type a question
into. Type this and press Enter:

```
/plugin marketplace add afovea/product-team-skills
```

Wait for it to say **Successfully added marketplace**. Then type this and press
Enter:

```
/plugin install product-team
```

> **Copy those two lines exactly.** The names look similar but they are
> different — `product-team-skills` is the collection, `product-team` is the
> thing you install. Typing `product-team-skills` in the second line gives you a
> "not found" error.

### Step 3 · Switch it on

Read what Claude says back:

- **"Plugin is now active."** — finished, go to Step 4.
- **"Run /reload-plugins to activate."** — type `/reload-plugins` and press
  Enter. If it warns you about re-reading the conversation, type
  `/reload-plugins --force`.

### Step 4 · Check it worked

Type `/product-` in the message box and stop. A list should drop down showing
`product-manager`, `product-designer`, `product-strategist`.

If that list appears, you are installed.

### Step 5 · Use it

Type `/`, pick a role, then **write the task on the same line** before pressing
Enter:

```
/product-manager Turn this vague feature request into a delivery-ready ticket.
```

```
/product-designer Our reports page is blank for new users. Design the empty state.
```

```
/accessibility-specialist This chart uses colour alone for four series. Problem?
```

A role with no task attached will just ask you what you want, so always give it
the work in the same message.

**Optional but recommended:** [Part 5](#part-5--optional--let-claude-pick-the-expert)
makes Claude choose the right expert so you do not have to remember 27 names.

---

## Part 3 — Claude Code in a terminal

Exactly the same result as Part 2. Use this if you prefer the terminal or do not
have the desktop app.

### Step 1 · Start Claude Code

Open a terminal:

- **Mac** — press `Cmd + Space`, type `Terminal`, press Enter.
- **Windows** — press Start, type `Terminal`, press Enter.
- **Linux** — press `Ctrl + Alt + T`.

Type this and press Enter:

```bash
claude
```

That is all. **You do not need to be in any particular folder** — a terminal is
always sitting in one already (your home folder, when you have just opened it),
and that is good enough to install from. The install goes onto your account, so
the roles then work everywhere and nothing is written into wherever you happened
to be.

<details>
<summary><b>Starting Claude Code in a specific folder, for later</b></summary>

Once you are actually using Claude Code on real files, you will want it pointed
at those files. Use `cd` — "change directory" — before starting it:

```bash
cd ~/Desktop
claude
```

`~` means your home folder, so `~/Desktop` is your Desktop.

To get a folder's path without typing it: on a Mac, type `cd ` (with the space)
then drag the folder onto the terminal window and the path fills itself in. On
Windows, right-click the folder and choose **Copy as path**, then paste.

</details>

> `claude: command not found`? This terminal cannot see Claude Code. If you have
> the desktop app, use [Part 2](#part-2--claude-code-in-the-desktop-app) instead
> — the app does not add a `claude` command to your terminal.

### Step 2 · Type two lines

You are now inside Claude Code — the prompt has changed. These go into Claude,
not into the terminal:

```
/plugin marketplace add afovea/product-team-skills
```

```
/plugin install product-team
```

### Step 3, 4 and 5

Identical to Part 2 — [switch it on](#step-3--switch-it-on),
[check it worked](#step-4--check-it-worked), [use it](#step-5--use-it).

---

## Part 4 — Claude for chatting (browser or Chat tab)

For Claude in a web browser, and the desktop app's **Chat** tab. No terminal, and
it works on the free plan.

Here you download a file for each role you want and upload it into Claude.

### Step 1 · Turn on two settings

Skills do not run without these. This is the most common reason an install
"does nothing".

1. Click your **name or profile picture**, usually bottom-left.
2. Click **Settings**.
3. Find **Capabilities**.
4. Switch on **Code execution** and **File creation**.

> No **Capabilities** section? Look for **Features** or **Beta features** — the
> label has moved between versions. You want two switches with those names.

### Step 2 · Download the roles you want

Each is one small file. **Click a link and it downloads.** Nothing opens.

**Suggested starting set** — click all five:

| Role | What it does |
|---|---|
| [product-designer.zip](https://github.com/afovea/product-team-skills/raw/main/download/product-designer.zip) | UX, UI, flows, interaction design, design QA |
| [content-designer.zip](https://github.com/afovea/product-team-skills/raw/main/download/content-designer.zip) | Wording, labels, error messages, onboarding copy |
| [accessibility-specialist.zip](https://github.com/afovea/product-team-skills/raw/main/download/accessibility-specialist.zip) | WCAG review, inclusive design, contrast, screen readers |
| [ux-researcher.zip](https://github.com/afovea/product-team-skills/raw/main/download/ux-researcher.zip) | Research planning, interviews, synthesis |
| [product-manager.zip](https://github.com/afovea/product-team-skills/raw/main/download/product-manager.zip) | Scope, priorities, outcomes, PRDs, tickets |

<details>
<summary><b>All 27 — click to see the full list</b></summary>

**Product and strategy**
[product-manager](https://github.com/afovea/product-team-skills/raw/main/download/product-manager.zip) ·
[product-strategist](https://github.com/afovea/product-team-skills/raw/main/download/product-strategist.zip) ·
[growth-product-marketing-manager](https://github.com/afovea/product-team-skills/raw/main/download/growth-product-marketing-manager.zip) ·
[pricing-strategist](https://github.com/afovea/product-team-skills/raw/main/download/pricing-strategist.zip)

**Research, insight and data**
[ux-researcher](https://github.com/afovea/product-team-skills/raw/main/download/ux-researcher.zip) ·
[data-analyst](https://github.com/afovea/product-team-skills/raw/main/download/data-analyst.zip) ·
[customer-success](https://github.com/afovea/product-team-skills/raw/main/download/customer-success.zip) ·
[storm-researcher](https://github.com/afovea/product-team-skills/raw/main/download/storm-researcher.zip)

**Design and experience**
[product-designer](https://github.com/afovea/product-team-skills/raw/main/download/product-designer.zip) ·
[content-designer](https://github.com/afovea/product-team-skills/raw/main/download/content-designer.zip) ·
[design-systems-specialist](https://github.com/afovea/product-team-skills/raw/main/download/design-systems-specialist.zip) ·
[motion-designer](https://github.com/afovea/product-team-skills/raw/main/download/motion-designer.zip) ·
[accessibility-specialist](https://github.com/afovea/product-team-skills/raw/main/download/accessibility-specialist.zip)

**Engineering, delivery and quality**
[software-engineer](https://github.com/afovea/product-team-skills/raw/main/download/software-engineer.zip) ·
[technical-architect](https://github.com/afovea/product-team-skills/raw/main/download/technical-architect.zip) ·
[devops-engineer](https://github.com/afovea/product-team-skills/raw/main/download/devops-engineer.zip) ·
[security-specialist](https://github.com/afovea/product-team-skills/raw/main/download/security-specialist.zip) ·
[qa-engineer](https://github.com/afovea/product-team-skills/raw/main/download/qa-engineer.zip) ·
[delivery-manager](https://github.com/afovea/product-team-skills/raw/main/download/delivery-manager.zip)

**Delivery pipeline** — for running coding tasks step by step. These are built
for Claude Code and do much less in chat.
[run-pipeline](https://github.com/afovea/product-team-skills/raw/main/download/run-pipeline.zip) ·
[requirements-generator](https://github.com/afovea/product-team-skills/raw/main/download/requirements-generator.zip) ·
[shape-task](https://github.com/afovea/product-team-skills/raw/main/download/shape-task.zip) ·
[execute-chunk](https://github.com/afovea/product-team-skills/raw/main/download/execute-chunk.zip) ·
[close-chunk](https://github.com/afovea/product-team-skills/raw/main/download/close-chunk.zip) ·
[cleanup-verify](https://github.com/afovea/product-team-skills/raw/main/download/cleanup-verify.zip) ·
[diagnose](https://github.com/afovea/product-team-skills/raw/main/download/diagnose.zip) ·
[design-critique](https://github.com/afovea/product-team-skills/raw/main/download/design-critique.zip)

</details>

> **Do not unzip these.** Claude wants the `.zip` exactly as downloaded. If your
> Mac unzipped it for you, see
> [My Mac unzipped the file](#my-mac-unzipped-the-file-automatically).

### Step 3 · Upload them

About fifteen seconds each. **The menu differs between the browser and the app**
— use your version:

**If you are in Claude web** (a browser):

1. **Settings** → **Capabilities** → **Skills**.
2. Click **+**.

**If you are in the Claude app** (Chat tab):

1. Click **Customize** in the left sidebar.
2. Click **Skills**.
3. Click **+**.

**Then, in both:**

1. Choose the option to **upload** or **create** a skill.
2. Pick one of the `.zip` files you downloaded.
3. Claude reads it and shows the name and description.
4. Make sure its toggle is **on**.

Repeat for each file.

You only need to do this in one of the two. Uploads attach to your account, so
what you add in the browser shows up in the app and the other way round.

### Step 4 · Check it worked

Your Skills list should show what you uploaded, each switched **on**.

### Step 5 · Use it

Start a new chat and **say which expert you want**, in ordinary words:

> As a product designer, our reports page is blank for new users. Design the
> empty state.

> Acting as an accessibility specialist, this chart uses colour alone to tell
> four lines apart. Is that a problem?

There are no slash commands here. Naming the role in your sentence is what brings
that expert in — and giving it the actual task in the same message is what gets
you work rather than a question back.

---

## Part 5 — optional · let Claude pick the expert

**Claude Code only** (Parts 2 and 3). Adds a decision layer so you can describe a
problem in plain words and Claude reaches for the right role by itself:

> "The error message when a payment fails is confusing. Rewrite it."
> → Content Designer

> "This chart tells four lines apart by colour alone."
> → Accessibility Specialist

It also defines six cross-functional squads, for questions like "is this ready to
ship?" that are not one discipline's call.

This lives in a file called `CLAUDE.md` inside your project folder, so it applies
per folder rather than everywhere.

**The easy way — ask Claude Code to do it.** Paste this into Claude Code:

```
Read https://raw.githubusercontent.com/afovea/product-team-skills/main/routing.md
and append it to this folder's CLAUDE.md, creating that file if it does not
exist. Wrap it in the comment markers <!-- product-team-skills:start --> and
<!-- product-team-skills:end -->. In the role tables, replace the "Skill file"
column with how I actually invoke each role, e.g. `/product-manager`.
```

Then start a new session so it is picked up.

That only writes `CLAUDE.md`. It does not copy any skills, because you already
have them from the plugin — a second copy on disk would shadow the first and then
quietly go out of date.

<details>
<summary><b>Doing it from a terminal instead — needs git</b></summary>

Identical result, done the same way every time. This is the only step in this
guide that needs `git` installed; the paste-in method above does not.

```bash
git clone https://github.com/afovea/product-team-skills.git
cd product-team-skills
./install.sh --routing-only /path/to/your/folder
```

</details>

---

## Something went wrong

### `Plugin "product-team" not found in marketplace "product-team-skills"`

You typed the collection's name where the plugin's name goes. They differ by one
hyphen. The second line is:

```
/plugin install product-team
```

### `Marketplace "productteam-skills" not found`

The first line did not run, or did not finish. Run it, wait for **Successfully
added marketplace**, then run the second.

### I installed it but `/product-manager` is not in the list

In order:

1. Did you skip [Step 3](#step-3--switch-it-on)? Type `/reload-plugins`, then
   `/reload-plugins --force` if it warns you.
2. Are you in a session that started before you installed? Start a new one.
3. Still missing? Close Claude Code, reopen it, and try again.

### `claude: command not found`

You typed a Claude Code command somewhere that is not Claude Code, or Claude Code
is not installed on this computer.

The desktop app does **not** give you a `claude` terminal command. If you are
following Part 2, everything goes into Claude's own message box.

### I uploaded a skill in chat and nothing is different

1. **Are Code execution and File creation on?** [Part 4 Step 1](#step-1--turn-on-two-settings).
   Most common cause. Switch them on and start a **new** chat.
2. **Is the skill toggled on?** Uploading does not always switch it on.
3. **Did you start the chat before installing?** Start a new one.
4. **Did you name the role in your message?** In chat, Claude picks the expert
   from what you wrote.

### My Mac unzipped the file automatically

Safari does this by default, leaving a folder instead of a `.zip`.

- **Quick fix:** right-click the folder → **Compress**. That makes a fresh `.zip`
  with the folder inside, which is the shape Claude wants.
- **Permanent fix:** Safari → Settings → General → untick **Open "safe" files
  after downloading**, then download again.
- Or use Chrome or Firefox, which do not unzip downloads.

### The upload was rejected or Claude says the file is invalid

Almost always an unzipped or re-zipped file — see above.

### I cannot find Customize, or Skills, or Capabilities

Menu names move between versions. Try in order: **Customize** in the sidebar ·
**Settings → Capabilities** · **Settings → Features** · profile picture →
**Settings**. You want a page listing skills with on/off switches.

### Claude keeps picking the wrong expert

**In chat:** say which one you want — "answer this as an accessibility
specialist, not a product designer". Uploading fewer roles improves its aim.

**In Claude Code:** it never picks on its own unless you added
[Part 5](#part-5--optional--let-claude-pick-the-expert). Invoke the role by name.

### Nothing here matches

Open an issue at
[github.com/afovea/product-team-skills/issues](https://github.com/afovea/product-team-skills/issues).
Say which Claude you are using, what you clicked, and what you saw. Screenshots
help.

---

## Which route gives you what

| | The 27 roles | Delivery pipeline | Routing brain | Gate enforcement |
|---|---|---|---|---|
| Claude Code — desktop app or terminal | ✅ all at once | ✅ | ✅ via [Part 5](#part-5--optional--let-claude-pick-the-expert) | ✅ |
| Claude for chatting | ✅ the ones you upload | partly — built for Claude Code | ❌ | ❌ |

**Gate enforcement** stops Claude ending a turn while a project's checks are
failing. It only applies to coding work, and only Claude Code can do it.

---

## Advanced routes

For teams and repositories. The [README](./README.md) has the detail.

| Route | Command | Adds |
|---|---|---|
| Cloud sessions | `enabledPlugins` in the repo's `.claude/settings.json` | the plugin, for everyone opening a cloud session on that repo |
| Project | `./install.sh /path/to/project` | 27 skills on disk + the routing brain |
| Personal | `./install.sh --personal` | 27 skills on disk, every project |
| Routing only | `./install.sh --routing-only /path` | the routing brain, nothing else |
| Submodule | `./install.sh --submodule /path` | pinned to a tag, symlinked |

`./install.sh --verify` reports every install it can find and flags conflicts.
Run it first if you are unsure what state you are in.

The ZIPs under `download/` are built by `scripts/package-skills.sh` and checked
by CI on every push, so they cannot drift from `skills/`. They differ from the
source in one way: `disable-model-invocation: true` is stripped, because chat has
no `/name` invocation and would otherwise ship skills that could never fire.
