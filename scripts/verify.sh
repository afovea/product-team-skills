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

PYTHONPYCACHEPREFIX="${TMPDIR:-/tmp}/product-team-skills-pycache"
export PYTHONPYCACHEPREFIX
for p in scripts/gate-chain.py hooks/gate-stop.py; do
  if python3 -m py_compile "$p" 2>/dev/null; then ok "$p"; else bad "$p does not compile"; fi
done

group "Manifests are valid JSON"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json \
         .codex-plugin/plugin.json hooks/hooks.json; do
  if python3 -m json.tool "$f" >/dev/null 2>&1; then ok "$f"; else bad "$f is not valid JSON"; fi
done

# One suite, two plugin manifests. A version that moves in one and not the other
# ships the same skills under two different numbers.
PV() { python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['version'])" "$1" 2>/dev/null; }
CLAUDE_V="$(PV .claude-plugin/plugin.json)"
CODEX_V="$(PV .codex-plugin/plugin.json)"
if [ -n "$CLAUDE_V" ] && [ "$CLAUDE_V" = "$CODEX_V" ]; then
  ok "plugin versions agree ($CLAUDE_V)"
else
  bad "plugin versions differ — claude '$CLAUDE_V', codex '$CODEX_V'"
fi

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

# The suite's central design decision is that roles do not fire on their own —
# keyword matching picks badly, which is measured in the README. Claude Code is
# told that with `disable-model-invocation`, Codex with a policy block in
# agents/openai.yaml. A skill that sets one but not the other behaves
# differently depending on who runs it, which is the drift this catches.
group "Both hosts agree on which skills may fire on their own"
PARITY_ISSUES=0
for f in skills/*/SKILL.md; do
  d="$(dirname "$f")"; n="$(basename "$d")"; oy="$d/agents/openai.yaml"
  fm="$(awk '/^---$/{c++; next} c==1' "$f")"
  if printf '%s\n' "$fm" | grep -q '^disable-model-invocation:[[:space:]]*true'; then
    if [ ! -f "$oy" ]; then
      bad "$n: suppressed in Claude Code, but has no agents/openai.yaml for Codex"
      PARITY_ISSUES=1
    elif ! grep -q '^[[:space:]]*allow_implicit_invocation:[[:space:]]*false' "$oy"; then
      bad "$n: agents/openai.yaml does not set allow_implicit_invocation: false"
      PARITY_ISSUES=1
    fi
  elif [ -f "$oy" ] && grep -q 'allow_implicit_invocation' "$oy"; then
    # ppot is the deliberate exception: its natural-language phrases are its
    # interface, so it must stay implicitly invokable on both hosts.
    bad "$n: fires on its own in Claude Code, but Codex is told not to"
    PARITY_ISSUES=1
  fi
done
[ "$PARITY_ISSUES" -eq 0 ] && ok "$(ls -d skills/*/ | wc -l | tr -d ' ') skills invoke the same way on both"

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
  # Consume the complete listing. `grep -q` exits at the first match, which
  # makes `unzip` receive SIGPIPE under `set -o pipefail` for larger skills.
  unzip -Z1 "$z" | awk -v want="$n/SKILL.md" '
    $0 == want { found = 1 }
    END { exit !found }
  ' || { bad "$z: no $n/SKILL.md"; ZIP_ISSUES=1; }
  # The Claude apps have no /name invocation, so a skill still carrying this
  # flag would install cleanly and then never fire.
  if unzip -p "$z" "$n/SKILL.md" | awk '/^---$/{c++; next} c==1' \
       | grep -q '^disable-model-invocation:'; then
    bad "$z still carries disable-model-invocation"; ZIP_ISSUES=1
  fi
  # Same reasoning for the Codex form of the same instruction. Captured into a
  # variable rather than piped, so a short-circuiting match cannot SIGPIPE unzip.
  OPENAI_YAML="$(unzip -p "$z" "$n/agents/openai.yaml" 2>/dev/null || true)"
  case "$OPENAI_YAML" in
    *allow_implicit_invocation*)
      bad "$z still carries allow_implicit_invocation"; ZIP_ISSUES=1 ;;
  esac
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

# The same install, in the layout Codex and other SKILL.md hosts read. Checked
# here rather than by hand, because the two layouts share one code path and a
# change made for one is exactly how the other quietly breaks.
group "The open-standard layout lands where Codex looks"
mkdir -p "$TMP/agents"
./install.sh --agents "$TMP/agents" >/dev/null
AGENTS_GOT="$(find "$TMP/agents/.agents/skills" -maxdepth 2 -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
[ "$AGENTS_GOT" = "$WANT" ] && ok "$WANT skills in .agents/skills" || bad "copied $AGENTS_GOT of $WANT"
[ ! -d "$TMP/agents/.claude" ] \
  && ok "no .claude directory in an agents install" || bad "leaked a .claude directory"
grep -q 'product-team-skills:start' "$TMP/agents/AGENTS.md" 2>/dev/null \
  && ok "routing brain in AGENTS.md" || bad "routing brain missing from AGENTS.md"
! grep -q '\.claude/skills' "$TMP/agents/AGENTS.md" 2>/dev/null \
  && ok "no paths pointing at the other layout" || bad "AGENTS.md names .claude paths"
[ -f "$TMP/agents/.agents/pipeline-adapter.md" ] \
  && ok "pipeline adapter seeded in .agents/" || bad "pipeline adapter missing"

mkdir -p "$TMP/agents-routing"
./install.sh --agents --routing-only "$TMP/agents-routing" >/dev/null
grep -q '`\$product-manager`' "$TMP/agents-routing/AGENTS.md" 2>/dev/null \
  && ok "role table rewritten to \$name" || bad "role table still uses Claude invocations"

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
