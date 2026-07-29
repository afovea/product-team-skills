#!/usr/bin/env bash
#
# Install product-team-skills into a consuming project.
#
#   ./install.sh /path/to/repo              # into one project (default)
#   ./install.sh --submodule /path/to/repo  # pinned to a tag, symlinked for discovery
#   ./install.sh --personal                 # into ~/.claude/skills, every project
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

SUITE_URL="https://github.com/afaconti-glitch/product-team-skills.git"
MODE="copy"
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --submodule) MODE="submodule"; shift ;;
    --copy)      MODE="copy"; shift ;;
    --personal)  MODE="personal"; shift ;;
    -h|--help)   sed -n '2,16p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *)           TARGET="$1"; shift ;;
  esac
done

# Personal install: skills only, into ~/.claude/skills/, available in every
# project. No CLAUDE.md, .gitignore or adapter — those are project concerns.
# Note the cost: personal skills load their metadata in every project you open,
# including ones with nothing to do with product work.
if [[ "$MODE" == "personal" ]]; then
  SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  DEST="$HOME/.claude/skills"
  mkdir -p "$DEST"
  cp -R "$SUITE_ROOT"/skills/*  "$DEST/"
  warn_stale_layout "$DEST"
  echo "Installed to $DEST"
  echo "  $(find "$DEST" -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ') skills"
  echo
  echo "Available in every project as /<name>, e.g. /product-manager."
  echo "The routing brain is a per-project concern — run this without --personal"
  echo "in a project to add it to that project's CLAUDE.md."
  exit 0
fi

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$PWD}"

[[ -d "$TARGET" ]] || { echo "error: target '$TARGET' is not a directory" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$TARGET" == "$SUITE_ROOT" ]]; then
  echo "error: target is the suite itself. Pass the consuming project's path." >&2
  exit 1
fi

echo "Installing product-team-skills"
echo "  from:  $SUITE_ROOT"
echo "  into:  $TARGET"
echo "  mode:  $MODE"
echo

# ---------------------------------------------------------------- place files

if [[ "$MODE" == "submodule" ]]; then
  git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 || {
    echo "error: submodule mode needs '$TARGET' to be a git repository" >&2; exit 1; }
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
  echo "  copied $(find "$TARGET/.claude/skills" -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ') skills,"\
       "$(find "$TARGET/.claude/skills" -path '*/references/*.md' | wc -l | tr -d ' ') references,"\
       "$(ls "$TARGET/.claude/reference"/*.md | wc -l | tr -d ' ') shared docs"
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
echo "Done. Next:"
echo "  1. Fill in .claude/pipeline-adapter.md with this project's commands and gates."
echo "     Without it the pipeline still runs, discovering commands from your"
echo "     manifests and CI config, but it has to guess."
echo "  2. Put project-specific context ABOVE the routing block in CLAUDE.md."
echo "  3. Try it:  ask for something narrow and see which role gets invoked."
