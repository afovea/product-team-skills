#!/usr/bin/env python3
"""Check that the install docs do not point at anything that is not there.

Two failure modes this catches, both of which strand a reader mid-install:

  - a heading link that no longer matches its heading, so the "go to Part 4"
    link silently does nothing
  - a local Markdown link whose target does not exist
  - a download/<skill>.zip link with no such file, so the button a
    non-technical user is told to click 404s

Run directly, or via scripts/verify.sh. Exits non-zero on any problem.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

DOCS = ["README.md", "INSTALL.md", "what-can-my-product-team-do.md", "docs/PPOT.md"]
ROOT = Path(__file__).resolve().parent.parent


def anchors(text: str) -> set[str]:
    """GitHub's heading-to-anchor slug: strip formatting, lower, drop
    punctuation, spaces to hyphens."""
    found = set()
    for line in text.splitlines():
        m = re.match(r"^#{1,6}\s+(.*)$", line)
        if not m:
            continue
        s = re.sub(r"`([^`]*)`", r"\1", m.group(1).strip())
        s = re.sub(r"\*\*|\*|_", "", s).lower()
        s = re.sub(r"[^\w\s-]", "", s)
        found.add(re.sub(r"\s", "-", s))
    return found


def main() -> int:
    docs = {name: (ROOT / name).read_text(encoding="utf-8") for name in DOCS}
    anchor_map = {name: anchors(text) for name, text in docs.items()}
    problems: list[str] = []

    for name, text in docs.items():
        source_dir = (ROOT / name).parent
        for target in re.findall(r"\]\((?!https?://|mailto:|#)([^)#]+)(?:#[^)]+)?\)", text):
            clean = target.strip("<>")
            if not (source_dir / clean).resolve().exists():
                problems.append(f"{name}: local link target does not exist -> {target}")

        for link in re.findall(r"\]\((\.?/?[\w.\-]*#[\w-]+)\)", text):
            target_file, _, anchor = link.partition("#")
            target = name if target_file in ("", "#") else target_file.lstrip("./")
            if target not in anchor_map:
                continue  # external or non-doc target
            if anchor not in anchor_map[target]:
                problems.append(f"{name}: broken heading link -> {link}")

        for skill in re.findall(r"download/([\w-]+)\.zip", text):
            if not (ROOT / "download" / f"{skill}.zip").is_file():
                problems.append(f"{name}: links download/{skill}.zip, which does not exist")

    # Every skill should be reachable from the install guide, or a reader
    # cannot install one that exists.
    shipped = {d.name for d in (ROOT / "skills").iterdir() if d.is_dir()}
    linked = set(re.findall(r"download/([\w-]+)\.zip", docs["INSTALL.md"]))
    for missing in sorted(shipped - linked):
        problems.append(f"INSTALL.md: no download link for '{missing}'")

    for p in problems:
        print(f"    {p}", file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
