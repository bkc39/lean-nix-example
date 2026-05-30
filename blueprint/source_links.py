#!/usr/bin/env python3
"""Generate a static `find` redirector for the blueprint's "Lean" links.

leanblueprint hard-codes each declaration's "Lean" link as
``{dochome}/find/#doc/{decl}`` (a doc-gen4 redirect). Rather than build and
host doc-gen4 API documentation, this script writes a small client-side page at
``blueprint/web/docs/find/index.html`` that resolves ``#doc/<decl>`` to the
declaration's source location on GitHub.

It scans the project's Lean sources for declaration positions (tracking
``namespace``/``end`` so names are fully qualified) and emits a JSON map
``fullName -> https://github.com/<owner>/<repo>/blob/<branch>/<path>#L<line>``.
Declarations it cannot locate fall back to the repository tree.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WEB = ROOT / "blueprint" / "web"
OUT_DIR = WEB / "docs" / "find"

# Matches a Lean declaration header, capturing the declaration's short name.
DECL_RE = re.compile(
    r"^\s*(?:@\[[^\]]*\]\s*)*"
    r"(?:private\s+|protected\s+|noncomputable\s+|partial\s+|unsafe\s+|scoped\s+|local\s+)*"
    r"(theorem|lemma|def|abbrev|instance|structure|inductive|class|opaque|axiom)\s+"
    r"([^\s({:\[\]]+)"
)


def repo_and_branch() -> tuple[str, str]:
    """Return ``(owner/repo, branch)``, preferring CI env vars then git."""
    repo = os.environ.get("GITHUB_REPOSITORY", "")
    branch = os.environ.get("GITHUB_REF_NAME", "")
    if not repo:
        url = _git("remote", "get-url", "origin")
        m = re.search(r"github\.com[:/](.+?)(?:\.git)?/?$", url)
        repo = m.group(1) if m else ""
    if not branch:
        branch = _git("rev-parse", "--abbrev-ref", "HEAD") or "main"
    return repo, branch


def _git(*args: str) -> str:
    try:
        return subprocess.run(
            ["git", "-C", str(ROOT), *args],
            capture_output=True,
            text=True,
            check=False,
        ).stdout.strip()
    except OSError:
        return ""


def declaration_locations() -> dict[str, tuple[str, int]]:
    """Map fully-qualified declaration names to ``(relpath, lineno)``."""
    locs: dict[str, tuple[str, int]] = {}
    for path in sorted(ROOT.rglob("*.lean")):
        if ".lake" in path.parts:
            continue
        rel = path.relative_to(ROOT).as_posix()
        namespaces: list[str] = []
        for lineno, line in enumerate(path.read_text().splitlines(), start=1):
            ns = re.match(r"\s*namespace\s+(\S+)", line)
            if ns:
                namespaces.append(ns.group(1))
                continue
            end = re.match(r"\s*end\s+(\S+)\s*$", line)
            if end and namespaces and namespaces[-1] == end.group(1):
                namespaces.pop()
                continue
            decl = DECL_RE.match(line)
            if decl:
                name = decl.group(2)
                full = ".".join(namespaces + [name]) if namespaces else name
                locs.setdefault(full, (rel, lineno))
    return locs


def main() -> None:
    repo, branch = repo_and_branch()
    blob = f"https://github.com/{repo}/blob/{branch}/"
    fallback = f"https://github.com/{repo}/tree/{branch}/"

    mapping = {
        full: f"{blob}{rel}#L{lineno}"
        for full, (rel, lineno) in declaration_locations().items()
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "index.html").write_text(
        """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Lean source redirect</title>
<script>
const MAP = __MAP__;
const FALLBACK = "__FALLBACK__";
const key = decodeURIComponent(location.hash.replace(/^#(doc\\/)?/, ""));
location.replace(MAP[key] || FALLBACK);
</script>
</head>
<body>
<p>Redirecting to the Lean source on GitHub&hellip;</p>
</body>
</html>
""".replace("__MAP__", json.dumps(mapping, indent=2, sort_keys=True)).replace(
            "__FALLBACK__", fallback
        )
    )
    print(f"Wrote {OUT_DIR / 'index.html'} ({len(mapping)} declarations, {repo}@{branch})")


if __name__ == "__main__":
    main()
