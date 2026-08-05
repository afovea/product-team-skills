#!/usr/bin/env bash
#
# Package skills as upload-ready ZIPs for the Claude apps (Chat tab, claude.ai,
# Cowork).
#
#   ./scripts/package-skills.sh                          # every skill
#   ./scripts/package-skills.sh product-manager qa-engineer   # only these
#
# Those products do not read this repository and do not use plugins. They take
# one skill at a time as a ZIP containing a single directory with a SKILL.md
# inside it — which is exactly the layout of each directory under skills/.
#
# Output lands in dist/. Upload via Customize -> Skills -> + in the desktop app,
# or the skills settings on claude.ai.

set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$SUITE_ROOT/skills"
OUT="$SUITE_ROOT/dist"

command -v zip >/dev/null 2>&1 || {
  echo "error: 'zip' is not installed." >&2
  echo "  macOS:  already present, check your PATH" >&2
  echo "  Debian: sudo apt install zip" >&2
  echo "  Fedora: sudo dnf install zip" >&2
  exit 1
}

# No names given means every skill.
if [[ $# -gt 0 ]]; then
  NAMES=("$@")
else
  NAMES=()
  for d in "$SRC"/*/; do NAMES+=("$(basename "$d")"); done
fi

# Validate up front rather than failing halfway through a 27-skill run.
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

for n in "${NAMES[@]}"; do
  rm -f "$OUT/$n.zip"
  # Zip from skills/ so the archive contains `<name>/SKILL.md`, not a bare
  # SKILL.md — the uploader rejects an archive with no enclosing directory.
  # -x drops the macOS metadata that otherwise rides along.
  ( cd "$SRC" && zip -qr "$OUT/$n.zip" "$n" -x '*.DS_Store' '__MACOSX/*' )
  echo "  dist/$n.zip"
done

echo
echo "Packaged ${#NAMES[@]} skill(s) into dist/"
echo
echo "Next:"
echo "  1. Settings -> Capabilities: enable Code execution and File creation."
echo "  2. Customize -> Skills -> + -> upload a ZIP, then toggle it on."
echo
echo "The uploader takes one ZIP at a time, so upload the roles you will"
echo "actually use rather than all 27. See INSTALL.md, Route D."
