#!/usr/bin/env python3
"""Stop hook: refuse to end the turn while a pipeline run has failing gates.

Wired from hooks/hooks.json. Reads the Stop event JSON on stdin and answers
on stdout. Exit 0 always, because Claude Code only parses decision JSON on
exit 0.

Behaviour:
  no open run          -> silent pass, no gates run
  valid stamp          -> silent pass, no gates run
  gates pass           -> stamp written, silent pass
  gates fail           -> {"decision": "block"} with the failing output
  repeated failures    -> stops blocking after MAX_BLOCKS, warns the user

The run-open sentinel is a state file written by the pipeline and removed
when the run closes. Point STATE_FILES at whatever your state contract
actually uses; a run is treated as open when the file exists and does not
carry "gate_required": false.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

# A run is treated as open when the pipeline has left a state file behind.
# Rather than hardcode one filename, look for anything state-shaped under
# .claude/, so this keeps working if the state contract is renamed.
STATE_GLOBS = ("*state*.json", "pipeline/*.json", "pipeline/*/*.json")
OPT_OUT_KEY = "gate_required"   # set false in the state file to skip the gates

MAX_BLOCKS = 3          # consecutive blocks before deferring to the human
GATE_DIR = ".gate"      # everything this tool leaves behind lives here
BLOCK_COUNTER = "blocks.json"
GATE_TIMEOUT = 1800


def emit(payload: dict) -> None:
    sys.stdout.write(json.dumps(payload))
    sys.stdout.flush()


def project_dir(event: dict) -> Path:
    # CLAUDE_ first so an existing Claude Code install resolves exactly as
    # before; the rest are the same idea under other hosts' names. Codex's Stop
    # event carries `cwd` too, so the event fallback already covers it.
    raw = (os.environ.get("CLAUDE_PROJECT_DIR")
           or os.environ.get("CODEX_PROJECT_DIR")
           or event.get("cwd")
           or os.getcwd())
    return Path(raw).resolve()


def runner_path() -> Path:
    """gate-chain.py lives in scripts/, one level up from hooks/."""
    # Codex supplies CLAUDE_PLUGIN_ROOT as a compatibility variable alongside
    # its own PLUGIN_ROOT, so the first entry usually wins on both hosts. The
    # __file__ fallback below covers a host that sets neither.
    for var in ("CLAUDE_PLUGIN_ROOT", "PLUGIN_ROOT"):
        root = os.environ.get(var)
        if root:
            candidate = Path(root) / "scripts" / "gate-chain.py"
            if candidate.is_file():
                return candidate
    return Path(__file__).resolve().parent.parent / "scripts" / "gate-chain.py"


def state_files(root: Path) -> list[Path]:
    # Both host layouts are scanned rather than one chosen, because a run is
    # open if any of them says so. `.claude/` is listed first only so its
    # results sort first; neither directory has to exist.
    found: list[Path] = []
    for base in (root / ".claude", root / ".agents"):
        for pattern in STATE_GLOBS:
            for path in sorted(base.glob(pattern)):
                if path.is_file() and GATE_DIR not in path.parts:
                    found.append(path)
    return found


def open_run(root: Path) -> bool:
    files = state_files(root)
    if not files:
        return False
    for path in files:
        try:
            state = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return True  # unreadable state is not a reason to skip the gates
        if isinstance(state, dict) and state.get(OPT_OUT_KEY) is False:
            continue
        return True
    return False


def call(args: list[str], root: Path) -> tuple[int, str]:
    proc = subprocess.run([sys.executable, str(runner_path()), *args],
                          cwd=root, capture_output=True, text=True,
                          timeout=GATE_TIMEOUT)
    return proc.returncode, proc.stdout


def block_count(root: Path, fingerprint: str) -> int:
    path = root / ".claude" / GATE_DIR / BLOCK_COUNTER
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        data = {}
    # A new fingerprint means the tree changed, so the count starts again.
    return data.get("count", 0) if data.get("fingerprint") == fingerprint else 0


def record_block(root: Path, fingerprint: str, count: int) -> None:
    path = root / ".claude" / GATE_DIR / BLOCK_COUNTER
    path.parent.mkdir(parents=True, exist_ok=True)
    ignore = path.parent / ".gitignore"
    if not ignore.is_file():
        ignore.write_text("*\n", encoding="utf-8")
    path.write_text(json.dumps({"fingerprint": fingerprint, "count": count}),
                    encoding="utf-8")


def clear_blocks(root: Path) -> None:
    (root / ".claude" / GATE_DIR / BLOCK_COUNTER).unlink(missing_ok=True)


def summarise(summary: dict) -> str:
    failed = summary.get("failed_gate") or "unknown gate"
    gate = next((g for g in summary.get("gates", [])
                 if g.get("name") == failed), {})
    lines = [
        f"Gate chain failed at `{failed}`. The turn cannot close until it passes.",
        f"Command: {gate.get('command', 'n/a')} (exit {gate.get('exit_code', 'n/a')})",
    ]
    if gate.get("output"):
        lines.append("Output:\n" + gate["output"])
    lines.append(
        "Fix the cause rather than the symptom, then let the gates re-run. "
        "Do not edit, skip or disable the gate itself."
    )
    return "\n\n".join(lines)


def main() -> int:
    try:
        event = json.loads(sys.stdin.read() or "{}")
    except json.JSONDecodeError:
        event = {}

    # Belt and braces against a hook loop.
    if event.get("stop_hook_active"):
        return 0

    root = project_dir(event)

    if not open_run(root):
        return 0

    code, out = call(["status"], root)
    if code == 0:
        return 0  # stamp already vouches for this exact tree

    try:
        fingerprint = json.loads(out).get("fingerprint", "")
    except json.JSONDecodeError:
        fingerprint = ""

    code, out = call(["run", "--stamp"], root)
    try:
        summary = json.loads(out)
    except json.JSONDecodeError:
        summary = {"passed": False, "error": "gate runner produced no summary"}

    if summary.get("passed"):
        clear_blocks(root)
        return 0

    count = block_count(root, fingerprint) + 1
    record_block(root, fingerprint, count)

    if count > MAX_BLOCKS:
        emit({
            "systemMessage": (
                f"Gate chain still failing after {MAX_BLOCKS} attempts "
                f"({summary.get('failed_gate') or summary.get('error')}). "
                "Releasing the turn so you can take a look."
            )
        })
        return 0

    if summary.get("error"):
        emit({"decision": "block", "reason": summary["error"]})
        return 0

    emit({"decision": "block", "reason": summarise(summary)})
    return 0


if __name__ == "__main__":
    sys.exit(main())
