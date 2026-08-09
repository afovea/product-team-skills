#!/usr/bin/env bash
#
# Package skills as upload-ready ZIPs for the Claude apps (claude.ai in a
# browser, and the Claude desktop app's Chat tab).
#
#   ./scripts/package-skills.sh                               # every skill
#   ./scripts/package-skills.sh product-designer qa-engineer  # only these
#   ./scripts/package-skills.sh --out download                # choose the folder
#
# Most people never run this. The built ZIPs are committed under download/ so
# they can be downloaded straight from GitHub without a terminal — see
# INSTALL.md. This script is how that folder is regenerated, and CI re-runs it
# to prove the committed ZIPs still match the skills.
#
# Those products take one skill at a time as a ZIP containing a single folder
# with a SKILL.md inside it, which is the layout of each directory under skills/.
#
# Two deliberate differences, both the same rule: nothing that could stop a
# skill firing survives the trip. `disable-model-invocation: true` in SKILL.md
# and `policy.allow_implicit_invocation: false` in agents/openai.yaml both mean
# "explicit invocation only", and the Claude apps have none — so both are
# stripped. The rest of openai.yaml is portable metadata and travels unchanged.

set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$SUITE_ROOT/skills"
OUT="$SUITE_ROOT/download"

NAMES=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;;
    -h|--help) sed -n '2,25p' "$0" | sed 's/^# \?//'; exit 0 ;;
    -*) echo "error: unknown option '$1'" >&2; exit 1 ;;
    *) NAMES+=("$1"); shift ;;
  esac
done
[[ "$OUT" = /* ]] || OUT="$SUITE_ROOT/$OUT"

command -v zip >/dev/null 2>&1 || {
  echo "error: 'zip' is not installed." >&2
  echo "  macOS:  already present, check your PATH" >&2
  echo "  Debian/Ubuntu: sudo apt install zip" >&2
  echo "  Fedora: sudo dnf install zip" >&2
  exit 1
}

# No names given means every skill.
if [[ ${#NAMES[@]} -eq 0 ]]; then
  for d in "$SRC"/*/; do NAMES+=("$(basename "$d")"); done
fi

# Validate up front rather than failing halfway through a 28-skill run.
MISSING=""
for n in "${NAMES[@]}"; do
  [[ -f "$SRC/$n/SKILL.md" ]] || MISSING="$MISSING $n"
done
if [[ -n "$MISSING" ]]; then
  echo "error: no such skill:$MISSING" >&2
  echo >&2
  echo "Available:" >&2
  for d in "$SRC"/*/; do echo "  $(basename "$d")" >&2; done
  exit 1
fi

mkdir -p "$OUT"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

for n in "${NAMES[@]}"; do
  rm -rf "${STAGE:?}/$n"
  cp -R "$SRC/$n" "$STAGE/$n"

  # Drop the Claude Code-only invocation flag from the frontmatter. Scoped to
  # the frontmatter block so a body that happens to mention the field — the
  # README quotes it — is left untouched.
  awk '
    NR == 1 && $0 == "---" { infm = 1; print; next }
    infm && $0 == "---"    { infm = 0; print; next }
    infm && /^disable-model-invocation:[[:space:]]/ { next }
    { print }
  ' "$SRC/$n/SKILL.md" > "$STAGE/$n/SKILL.md"

  # The same rule applied to the Codex invocation policy. Only the policy block
  # goes: the interface metadata is host-neutral, so it travels with the skill.
  # The second awk trims the blank line the removed block leaves behind, because
  # a trailing newline that comes and goes would churn the archive bytes.
  if [[ -f "$SRC/$n/agents/openai.yaml" ]]; then
    awk '
      /^policy:([[:space:]]|$)/ { skip = 1; next }
      skip && /^[[:space:]]*$/  { next }
      skip && /^[[:space:]]/    { next }
      { skip = 0; print }
    ' "$SRC/$n/agents/openai.yaml" \
      | awk '{ l[NR] = $0 }
             END { e = NR
                   while (e > 0 && l[e] ~ /^[[:space:]]*$/) e--
                   for (i = 1; i <= e; i++) print l[i] }' \
      > "$STAGE/$n/agents/openai.yaml"

    # A file that was nothing but policy has nothing left worth shipping.
    if [[ ! -s "$STAGE/$n/agents/openai.yaml" ]]; then
      rm -f "$STAGE/$n/agents/openai.yaml"
      rmdir "$STAGE/$n/agents" 2>/dev/null || true
    fi
  fi

  # Normalise everything the archive records besides the file contents, so the
  # same skills produce the same bytes on any machine and CI can diff the
  # committed result.
  #
  # mtime: without this each run stamps "now" and every ZIP looks modified.
  # mode:  zip stores the Unix mode, and `cp -R` applies the local umask, so a
  #        machine with a different umask would otherwise emit different bytes.
  find "$STAGE/$n" -type d -exec chmod 755 {} +
  find "$STAGE/$n" -type f -exec chmod 644 {} +
  find "$STAGE/$n" -exec touch -t 200001010000 {} +

  # Zip from the staging root so the archive contains `<name>/SKILL.md`, not a
  # bare SKILL.md — the uploader rejects an archive with no enclosing folder.
  # -X drops platform metadata.
  #
  # Feed zip an explicitly sorted file list rather than letting `-r` walk the
  # tree. Directory traversal order is filesystem-dependent, so `-r` packs the
  # same files in a different order on a different machine: identical size,
  # different bytes. Only skills with a references/ subdirectory have more than
  # one file, so those were the only two that ever disagreed. LC_ALL=C keeps
  # the sort itself locale-independent.
  rm -f "$OUT/$n.zip"
  ( cd "$STAGE" \
      && find "$n" -name '.DS_Store' -prune -o -print \
       | LC_ALL=C sort \
       | zip -qX "$OUT/$n.zip" -@ )
  echo "  $(basename "$OUT")/$n.zip"
done

echo
echo "Packaged ${#NAMES[@]} skill(s) into $(basename "$OUT")/"
echo
echo "To use one: Claude app or claude.ai -> Settings -> Customize -> Skills"
echo "            -> + -> upload the .zip -> toggle it on."
echo
echo "See INSTALL.md. Most people can skip this script and download the"
echo "committed ZIPs from GitHub instead."
