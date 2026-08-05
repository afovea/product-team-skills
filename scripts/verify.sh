#!/usr/bin/env bash
#
# Every check CI runs. CI calls this script and nothing else, so running it
# locally exercises the identical code path — no second copy of the checks to
# drift, and no "passed on my machine, failed on the runner".
#
#   ./scripts/verify.sh
#
# Exits non-zero if anything fails, after running everything rather than
# stopping at the first problem.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAILED=0

group() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok()    { printf '  ok    %s\n' "$1"; }
bad()   { printf '  FAIL  %s\n' "$1"; FAILED=1; }

# ---------------------------------------------------------------- syntax

group "Scripts parse"
for s in install.sh scripts/package-skills.sh scripts/verify.sh; do
  if bash -n "$s" 2>/dev/null; then ok "$s"; else bad "$s does not parse"; fi
done

for p in scripts/gate-chain.py hooks/gate-stop.py; do
  if python3 -m py_compile "$p" 2>/dev/null; then ok "$p"; else bad "$p does not compile"; fi
done

group "Manifests are valid JSON"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  if python3 -m json.tool "$f" >/dev/null 2>&1; then ok "$f"; else bad "$f is not valid JSON"; fi
done

# ------------------------------------------------------------ skill contract

group "Skills carry the frontmatter the standard requires"
SKILL_ISSUES=0
for f in skills/*/SKILL.md; do
  fm="$(awk '/^---$/{n++; next} n==1' "$f")"
  for key in name description; do
    printf '%s\n' "$fm" | grep -q "^$key:" || { bad "$f: missing '$key'"; SKILL_ISSUES=1; }
  done
  # The directory name is what a user types, so it has to match `name`.
  want="$(basename "$(dirname "$f")")"
  got="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p')"
  [ "$want" = "$got" ] || { bad "$f: name '$got' != directory '$want'"; SKILL_ISSUES=1; }
done
[ "$SKILL_ISSUES" -eq 0 ] && ok "$(ls -d skills/*/ | wc -l | tr -d ' ') skills"

# ------------------------------------------------------------------- zips

# download/ is what a non-technical user installs — they click a link rather
# than running anything — so a stale ZIP is a silent wrong install.
group "Downloadable ZIPs match the skills"
if ! command -v zip >/dev/null 2>&1; then
  bad "zip is not installed, cannot verify download/"
else
  ./scripts/package-skills.sh >/dev/null
  if git diff --quiet -- download/; then
    ok "download/ in sync ($(ls download/*.zip | wc -l | tr -d ' ') ZIPs)"
  else
    bad "download/ is out of date — run ./scripts/package-skills.sh and commit"
    git diff --stat -- download/
  fi
fi

group "ZIPs are shaped the way the uploader needs"
ZIP_ISSUES=0
for z in download/*.zip; do
  n="$(basename "$z" .zip)"
  # An archive with no enclosing folder is rejected on upload.
  unzip -l "$z" | grep -q " $n/SKILL.md\$" || { bad "$z: no $n/SKILL.md"; ZIP_ISSUES=1; }
  # The Claude apps have no /name invocation, so a skill still carrying this
  # flag would install cleanly and then never fire.
  if unzip -p "$z" "$n/SKILL.md" | awk '/^---$/{c++; next} c==1' \
       | grep -q '^disable-model-invocation:'; then
    bad "$z still carries disable-model-invocation"; ZIP_ISSUES=1
  fi
done
[ "$ZIP_ISSUES" -eq 0 ] && ok "$(ls download/*.zip | wc -l | tr -d ' ') ZIPs correctly shaped"

# -------------------------------------------------------------- install.sh

# `if` context, not a bare call: under `set -e` a bare failing command aborts
# the script, and every one of these is *expected* to fail.
expect_exit() {
  local label="$1" want="$2"; shift 2
  local got=0
  if "$@" >/dev/null 2>&1; then got=0; else got=$?; fi
  [ "$got" -eq "$want" ] && ok "$label (exit $got)" \
                         || bad "$label: exit $got, expected $want"
}

group "install.sh guard rails"
expect_exit "bare run is rejected"          1 ./install.sh
expect_exit "repo as target is rejected"    1 ./install.sh .
expect_exit "unknown option is rejected"    1 ./install.sh --nope
expect_exit "--submodule without a path"    1 ./install.sh --submodule
expect_exit "--routing-only without a path" 1 ./install.sh --routing-only
expect_exit "missing directory is rejected" 1 ./install.sh /no/such/place
expect_exit "--help succeeds"               0 ./install.sh --help
expect_exit "--verify succeeds"             0 ./install.sh --verify

group "A project install lands complete"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
WANT="$(ls -d skills/*/ | wc -l | tr -d ' ')"

if ./install.sh "$TMP/project" >/dev/null 2>&1; then
  bad "installing into a non-existent directory should have been rejected"
fi
mkdir -p "$TMP/project"
./install.sh "$TMP/project" >/dev/null

GOT="$(find "$TMP/project/.claude/skills" -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
[ "$GOT" = "$WANT" ] && ok "$WANT skills copied" || bad "copied $GOT of $WANT skills"

grep -q 'product-team-skills:start' "$TMP/project/CLAUDE.md" \
  && ok "routing brain in CLAUDE.md" || bad "routing brain missing"
[ -f "$TMP/project/.claude/pipeline-adapter.md" ] \
  && ok "pipeline adapter seeded" || bad "pipeline adapter missing"

./install.sh "$TMP/project" >/dev/null
[ "$(grep -c 'product-team-skills:start' "$TMP/project/CLAUDE.md")" -eq 1 ] \
  && ok "re-running does not duplicate the routing block" \
  || bad "re-running duplicated the routing block"

group "Routing-only writes CLAUDE.md and nothing else"
mkdir -p "$TMP/routing"
./install.sh --routing-only "$TMP/routing" >/dev/null
[ ! -d "$TMP/routing/.claude" ] && ok "no skills copied" || bad "copied skills it should not have"
grep -q '`/product-manager`' "$TMP/routing/CLAUDE.md" \
  && ok "role table rewritten to invocations" || bad "role table not rewritten"
! grep -q '\.claude/skills' "$TMP/routing/CLAUDE.md" \
  && ok "no dangling skill-file paths" || bad "left paths pointing at files that do not exist"

# ------------------------------------------------------------------- docs

group "Documentation links resolve"
if python3 scripts/check-docs.py; then ok "anchors and download links"; else bad "see above"; fi

# ------------------------------------------------------------------ result

printf '\n'
if [ "$FAILED" -eq 0 ]; then
  printf '\033[1mAll checks passed.\033[0m\n'
else
  printf '\033[1mSome checks failed.\033[0m\n'
fi
exit "$FAILED"
