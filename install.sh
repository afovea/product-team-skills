#!/usr/bin/env bash
#
# Install product-team-skills into a consuming project.
#
#   ./install.sh /path/to/repo              # into one project
#   ./install.sh .                          # into the current directory
#   ./install.sh --personal                 # into ~/.claude/skills, every project
#   ./install.sh --submodule /path/to/repo  # pinned to a tag, symlinked for discovery
#   ./install.sh --verify                   # report what is installed where
#
# This is the filesystem route. Most people want the plugin instead — see
# INSTALL.md, which covers all five routes and the errors each one can throw.
#
# Project modes place the skills under the project's .claude/skills/ and append
# the routing brain to its CLAUDE.md with paths already rewritten — the step
# most likely to be got wrong by hand. Copy mode leaves the project free to
# diverge; submodule mode keeps updates deliberate.
#
# Personal mode installs the skills only. They become available in every
# project as /<name>, but their metadata also loads in every project, including
# ones with nothing to do with product work. The routing brain stays per-project.

set -euo pipefail

# v2.x nested the pipeline skills under skills/pipeline/. v3 puts every skill
# flat, so an older install leaves a stale subdirectory behind and the pipeline
# skills end up present twice. Flag it rather than deleting anything in someone
# else's tree.
warn_stale_layout() {
  local d="$1"
  [[ -d "$d/pipeline" ]] || return 0
  echo
  echo "  NOTE: $d/pipeline/ is left over from a v2.x install." >&2
  echo "        Every skill is flat now, so those are duplicates. Remove it:" >&2
  echo "          rm -r '$d/pipeline'" >&2
  echo
}

SUITE_URL="https://github.com/afovea/product-team-skills.git"
SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=""
TARGET=""

# How many skills this repo actually ships. Counted from the source, never from
# the destination: a destination may already hold skills that are nothing to do
# with this suite, and counting those reports an install that never happened.
suite_skill_count() {
  find "$SUITE_ROOT/skills" -maxdepth 2 -name SKILL.md | wc -l | tr -d ' '
}

# Report a missing prerequisite in terms of what to do about it, not what is
# absent. Only ever called for the tools the chosen mode actually needs.
require() {
  command -v "$1" >/dev/null 2>&1 && return 0
  echo "error: '$1' is required for this install mode but was not found." >&2
  echo "       $2" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
product-team-skills — filesystem install

Most people want the plugin instead. In Claude Code:

    /plugin marketplace add afovea/product-team-skills
    /plugin install product-team

That gives you all 27 skills plus the gate-enforcement hook, updatable with one
command. Use this script when you also want the routing brain, or when plugins
are unavailable (WSL, offline, a non-Claude-Code host).

Usage:

    ./install.sh /path/to/project     Skills + routing brain into that project
    ./install.sh .                    The same, into the current directory
    ./install.sh --personal           Skills into ~/.claude/skills (every project)
    ./install.sh --submodule PATH     Per-project, pinned to a tag, symlinked
    ./install.sh --verify             Report what is installed where
    ./install.sh --help               This message

No target is assumed. Pass a path, or '.' for the current directory.

Full guide, including the Claude desktop app, cloud sessions and claude.ai:
INSTALL.md
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --submodule) MODE="submodule"; shift ;;
    --copy)      MODE="copy"; shift ;;
    --personal)  MODE="personal"; shift ;;
    --verify|--check) MODE="verify"; shift ;;
    -h|--help)   usage; exit 0 ;;
    -*)          echo "error: unknown option '$1'" >&2; echo >&2; usage >&2; exit 1 ;;
    *)           TARGET="$1"; shift ;;
  esac
done

# ------------------------------------------------------------------- verify

# Reports every place the suite is installed. Its job is to answer "what state
# am I actually in?" — the question a half-finished install leaves behind, and
# the one that sends people round the loop of installing a second copy.
if [[ "$MODE" == "verify" ]]; then
  TARGET="${TARGET:-$PWD}"
  [[ -d "$TARGET" ]] && TARGET="$(cd "$TARGET" && pwd)"
  EXPECTED="$(suite_skill_count)"
  FOUND=0

  echo "product-team-skills — installation report"
  echo "  this repo ships $EXPECTED skills"
  echo

  echo "Claude Code CLI"
  if command -v claude >/dev/null 2>&1; then
    echo "  found: $(claude --version 2>/dev/null | head -1)"
    if claude plugin list 2>/dev/null | grep -q 'product-team@'; then
      echo "  plugin: INSTALLED"
      claude plugin list 2>/dev/null | grep -A2 'product-team@' | sed 's/^/    /'
      FOUND=$((FOUND + 1))
    else
      echo "  plugin: not installed  (/plugin install product-team)"
    fi
  else
    echo "  not on PATH — the desktop app does not add it. That is fine;"
    echo "  it only means this script cannot check the plugin route for you."
  fi
  echo

  # Personal install. Count only directories this suite ships, so unrelated
  # personal skills are never mistaken for a partial install.
  echo "Personal install (~/.claude/skills)"
  PERSONAL=0
  for d in "$SUITE_ROOT"/skills/*/; do
    [[ -f "$HOME/.claude/skills/$(basename "$d")/SKILL.md" ]] && PERSONAL=$((PERSONAL + 1))
  done
  if [[ "$PERSONAL" -gt 0 ]]; then
    echo "  $PERSONAL/$EXPECTED suite skills present"
    [[ "$PERSONAL" -lt "$EXPECTED" ]] && echo "  INCOMPLETE — re-run: ./install.sh --personal"
    FOUND=$((FOUND + 1))
  else
    echo "  not installed"
  fi
  [[ -d "$HOME/.claude/skills/pipeline" ]] && \
    echo "  STALE: ~/.claude/skills/pipeline is a v2.x leftover — rm -r it"
  echo

  echo "Project install ($TARGET)"
  PROJECT=0
  for d in "$SUITE_ROOT"/skills/*/; do
    [[ -f "$TARGET/.claude/skills/$(basename "$d")/SKILL.md" ]] && PROJECT=$((PROJECT + 1))
  done
  if [[ "$PROJECT" -gt 0 ]]; then
    echo "  $PROJECT/$EXPECTED suite skills present"
    [[ "$PROJECT" -lt "$EXPECTED" ]] && echo "  INCOMPLETE — re-run: ./install.sh '$TARGET'"
    if [[ -f "$TARGET/CLAUDE.md" ]] && grep -qF "<!-- product-team-skills:start -->" "$TARGET/CLAUDE.md"; then
      echo "  routing brain: present in CLAUDE.md"
    else
      echo "  routing brain: MISSING — re-run: ./install.sh '$TARGET'"
    fi
    [[ -f "$TARGET/.claude/pipeline-adapter.md" ]] \
      && echo "  pipeline adapter: present" \
      || echo "  pipeline adapter: missing (optional — the pipeline discovers commands without it)"
    FOUND=$((FOUND + 1))
  else
    echo "  not installed"
  fi
  [[ -d "$TARGET/.claude/skills/pipeline" ]] && \
    echo "  STALE: $TARGET/.claude/skills/pipeline is a v2.x leftover — rm -r it"
  echo

  echo "Cloud sessions (.claude/settings.json in $TARGET)"
  if [[ -f "$TARGET/.claude/settings.json" ]] && grep -q 'product-team@productteam-skills' "$TARGET/.claude/settings.json" 2>/dev/null; then
    echo "  declared — cloud sessions on this repo will install the plugin"
  else
    echo "  not declared (see INSTALL.md, Route C)"
  fi
  echo

  echo "Verdict"
  if [[ "$FOUND" -eq 0 ]]; then
    echo "  Not installed anywhere this script can see."
    echo "  Quickest route:  /plugin install product-team   (see INSTALL.md)"
  elif [[ "$FOUND" -eq 1 ]]; then
    echo "  One install, no conflicts. Start Claude Code and type /product- to confirm."
  else
    echo "  $FOUND installs found."
    echo "  Filesystem and plugin copies can coexist: a filesystem skill claims the"
    echo "  bare /product-manager, while the plugin copy stays reachable as"
    echo "  /product-team:product-manager. Two FILESYSTEM copies (personal and"
    echo "  project) are worth reducing to one, or you will edit one and run the other."
  fi
  exit 0
fi

# No mode and no target: say what to do rather than guessing a destination.
if [[ -z "$MODE" && -z "$TARGET" ]]; then
  usage
  exit 1
fi
MODE="${MODE:-copy}"

# Personal install: skills only, into ~/.claude/skills/, available in every
# project. No CLAUDE.md, .gitignore or adapter — those are project concerns.
# Note the cost: personal skills load their metadata in every project you open,
# including ones with nothing to do with product work.
if [[ "$MODE" == "personal" ]]; then
  DEST="$HOME/.claude/skills"
  mkdir -p "$DEST"
  cp -R "$SUITE_ROOT"/skills/*  "$DEST/"
  warn_stale_layout "$DEST"
  echo "Installed to $DEST"
  echo "  $(suite_skill_count) skills"
  echo
  echo "Available in every project as /<name>, e.g. /product-manager."
  echo "The routing brain is a per-project concern — run this without --personal"
  echo "in a project to add it to that project's CLAUDE.md."
  echo
  echo "Confirm with:  ./install.sh --verify"
  exit 0
fi

[[ -n "$TARGET" ]] || {
  echo "error: $MODE mode needs a project path." >&2
  echo "       ./install.sh --$MODE /path/to/project   (or '.' for here)" >&2
  exit 1; }

[[ -d "$TARGET" ]] || {
  echo "error: target '$TARGET' is not a directory." >&2
  echo "       Pass the path of the project you want the skills in." >&2
  exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$TARGET" == "$SUITE_ROOT" ]]; then
  cat >&2 <<EOF
error: the target is this repository itself.

This repo is the source, not an installation — installing it into itself
achieves nothing. Pass the path of the project you want the skills in:

    ./install.sh /path/to/your-project

Or, if you only want the skills available everywhere:

    ./install.sh --personal

Or skip the filesystem entirely and use the plugin, in Claude Code:

    /plugin marketplace add afovea/product-team-skills
    /plugin install product-team

See INSTALL.md.
EOF
  exit 1
fi

# python3 is only needed to rewrite an existing routing block in place. Fail
# here with the reason rather than part-way through a half-applied install.
if [[ -f "$TARGET/CLAUDE.md" ]] && grep -qF "<!-- product-team-skills:start -->" "$TARGET/CLAUDE.md"; then
  require python3 "It updates the routing block already in $TARGET/CLAUDE.md. Install Python 3, or delete that block to have it appended fresh."
fi

echo "Installing product-team-skills"
echo "  from:  $SUITE_ROOT"
echo "  into:  $TARGET"
echo "  mode:  $MODE"
echo

# ---------------------------------------------------------------- place files

if [[ "$MODE" == "submodule" ]]; then
  require git "Submodule mode clones this suite into your project."
  git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 || {
    echo "error: submodule mode needs '$TARGET' to be a git repository." >&2
    echo "       Run 'git init' there first, or use: ./install.sh '$TARGET'" >&2
    exit 1; }
  if [[ -e "$TARGET/.claude/skills-vendor" ]]; then
    echo "  .claude/skills-vendor already exists — leaving it alone"
  else
    git -C "$TARGET" submodule add -q "$SUITE_URL" .claude/skills-vendor
    LATEST_TAG="$(git -C "$SUITE_ROOT" tag -l 'v*' --sort=-v:refname | head -1)"
    if [[ -n "$LATEST_TAG" ]]; then
      git -C "$TARGET/.claude/skills-vendor" checkout -q "$LATEST_TAG"
      echo "  pinned to $LATEST_TAG"
    fi
  fi
  # Skills are discovered under .claude/skills/, so symlink each vendored
  # skill directory into place. Without this the submodule gives you routing
  # but no discovery — the files exist where nothing looks for them.
  mkdir -p "$TARGET/.claude/skills"
  for d in "$TARGET"/.claude/skills-vendor/skills/*/; do
    n="$(basename "$d")"
    [[ -e "$TARGET/.claude/skills/$n" ]] || \
      ln -s "../skills-vendor/skills/$n" "$TARGET/.claude/skills/$n"
  done
  echo "  symlinked skill directories into .claude/skills/ for discovery"
  SKILL_PREFIX=".claude/skills"
else
  mkdir -p "$TARGET/.claude/skills"
  # Directory-per-skill, each containing SKILL.md and any references/.
  # No trailing slash on the glob: `cp -R src/*/ dest/` copies directory
  # *contents*, which collapses every skill onto one SKILL.md.
  cp -R "$SUITE_ROOT"/skills/*     "$TARGET/.claude/skills/"
  # Shared pipeline docs live outside skills/ so they are not mistaken for one.
  mkdir -p "$TARGET/.claude/reference"
  cp "$SUITE_ROOT"/reference/*.md  "$TARGET/.claude/reference/"
  echo "  copied $(suite_skill_count) skills,"\
       "$(find "$SUITE_ROOT/skills" -path '*/references/*.md' | wc -l | tr -d ' ') references,"\
       "$(ls "$SUITE_ROOT/reference"/*.md | wc -l | tr -d ' ') shared docs"
  SKILL_PREFIX=".claude/skills"
fi

warn_stale_layout "$TARGET/.claude/skills"

# ------------------------------------------------------- routing into CLAUDE.md

MARK_START="<!-- product-team-skills:start -->"
MARK_END="<!-- product-team-skills:end -->"
CLAUDE_MD="$TARGET/CLAUDE.md"

# Rewrite the paths in routing.md to match where the files actually landed.
ROUTING="$(sed -e "s#\`\.claude/skills/#\`$SKILL_PREFIX/#g" "$SUITE_ROOT/routing.md")"

if [[ -f "$CLAUDE_MD" ]] && grep -qF "$MARK_START" "$CLAUDE_MD"; then
  # The routing text goes via a temp file, not stdin: stdin is already taken by
  # the heredoc carrying the script, and supplying both silently feeds the
  # markdown to python as its source.
  ROUTING_TMP="$(mktemp)"
  printf '%s' "$ROUTING" > "$ROUTING_TMP"
  python3 - "$CLAUDE_MD" "$MARK_START" "$MARK_END" "$ROUTING_TMP" <<'PY'
import sys, pathlib
path, start, end, block_file = sys.argv[1:5]
block = pathlib.Path(block_file).read_text()
p = pathlib.Path(path); t = p.read_text()
head, _, rest = t.partition(start)
_, _, tail = rest.partition(end)
p.write_text(f"{head}{start}\n{block}\n{end}{tail}")
PY
  rm -f "$ROUTING_TMP"
  echo "  updated existing routing block in CLAUDE.md"
else
  { [[ -f "$CLAUDE_MD" ]] && printf '\n'; printf '%s\n%s\n%s\n' "$MARK_START" "$ROUTING" "$MARK_END"; } >> "$CLAUDE_MD"
  echo "  appended routing block to CLAUDE.md"
fi

# ------------------------------------------------------------------ gitignore

GI="$TARGET/.gitignore"
if [[ "$MODE" == "submodule" ]]; then
  grep -qF '!.claude/skills-vendor/' "$GI" 2>/dev/null || {
    printf '\n# Claude Code project state. The skills suite is the tracked submodule below.\n.claude/*\n!.claude/skills-vendor/\n' >> "$GI"
    echo "  updated .gitignore (keeps the submodule tracked)"; }
else
  grep -qE '^\.claude/?$' "$GI" 2>/dev/null || {
    printf '\n# Claude Code project state, including the copied skills suite.\n.claude/\n' >> "$GI"
    echo "  updated .gitignore"; }
fi

# ------------------------------------------------------------------- adapter

ADAPTER="$TARGET/.claude/pipeline-adapter.md"
if [[ -e "$ADAPTER" ]]; then
  echo "  pipeline adapter already present — leaving it alone"
else
  # The template sits next to state-schema.md in the repo, but lands one level
  # above it here, so its sibling link has to be rewritten on the way in.
  sed 's#](\./state-schema\.md)#](./reference/state-schema.md)#g' \
    "$SUITE_ROOT/reference/project-adapter.md" > "$ADAPTER"
  echo "  seeded .claude/pipeline-adapter.md (template — fill it in)"
fi

echo
echo "Done. Confirm it worked:"
echo "  1. cd '$TARGET' && claude"
echo "  2. Type '/product-' — the roles should autocomplete."
echo "     Nothing there? Run ./install.sh --verify, then see INSTALL.md."
echo
echo "Then:"
echo "  - Fill in .claude/pipeline-adapter.md with this project's commands and gates."
echo "    Without it the pipeline still runs, discovering commands from your"
echo "    manifests and CI config, but it has to guess."
echo "  - Put project-specific context ABOVE the routing block in CLAUDE.md."
echo "  - Give a role the task in the same message:"
echo "      /product-manager Turn this request into a delivery-ready ticket."
