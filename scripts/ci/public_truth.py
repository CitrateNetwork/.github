#!/usr/bin/env python3
"""Public-truth check for the org profile, README and security policy (public-claims accuracy).

Text is normalised before matching (line breaks and runs of whitespace collapse to one
space, a hyphen split across a line break is joined, markdown emphasis is dropped), so a
reworded or re-wrapped claim is still caught. Exit 1 on any hit.

Usage: python3 scripts/ci/public_truth.py [root]
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

DASH = r"[\s\-‐-―]*"


def normalise(text: str) -> str:
    t = re.sub(r"-\s*\n\s*", "-", text)          # "Human-in-\n the-loop" -> "Human-in-the-loop"
    t = re.sub(r"[*_`]+", "", t)                   # markdown emphasis / code ticks
    t = re.sub(r"\s+", " ", t)
    return t


def sentences(t: str) -> list[str]:
    return re.split(r"(?<=[.!?|])\s+", t)


RULES: list[tuple[str, re.Pattern, re.Pattern | None]] = [
    ("owner rule: use HIC (Human In Control), never HITL",
     re.compile(r"\bH\.?I\.?T\.?L(s|'s)?\b"), None),
    ("owner rule: use HIC, never human-in-the-loop",
     re.compile(r"human" + DASH + r"in" + DASH + r"(the" + DASH + r")?loop", re.I), None),
    ("dead host (no DNS / 404 / 530)",
     re.compile(r"wss?://ws\.citrate\.ai|scan\.citrate\.ai|rpc2\.citrate\.ai|mirror\.citrate\.ai", re.I), None),
    ("citrate-chain/specs/testnet.toml does not exist (use node/config/testnet.toml)",
     re.compile(r"specs/testnet\.toml"), None),
    ("links a private repository",
     re.compile(r"citrate-monorepo-archive|citrate-agentile-archive", re.I), None),
    ("no PGP key is published for security@citrate.ai",
     re.compile(r"keys\s*\.\s*openpgp\s*\.\s*org|PGP (public )?key (from|at|via)", re.I), None),
    ("overstated supply-chain claim",
     re.compile(r"(\b(are|is) cosign[- ]signed|cosign[- ]signed (releases|crates|artifacts)|signed (via|with) cosign|SBOMs? \(?CycloneDX\)? attach|every (tier-1 )?release (ships|carries|includes|has)|CVE assigned for high)", re.I),
     re.compile(r"^.{0,25}(built to|once published|not yet|no public release|in progress)", re.I)),
    ("paid inference rails described as live (not deployed)",
     re.compile(r"(x402|pay" + DASH + r"per" + DASH + r"call|paid (inference|routes|calls))[^.|]{0,80}\b(live|available now|today|metered|generally available|in production)\b|x402-metered", re.I),
     re.compile(r"not (yet )?(deployed|live|mounted)", re.I)),
    ("names an audit finding ID; public copy must not describe open findings",
     re.compile(r"\bPBA-[A-Za-z0-9]+-\d+\b"), None),
]


def remote_v_tags(root: Path) -> list[str]:
    """Release tags on origin. Works under a shallow checkout, which fetches no tags."""
    for cmd in (["git", "-C", str(root), "ls-remote", "--tags", "origin", "v*"],
                ["git", "-C", str(root), "tag", "-l", "v*"]):
        try:
            out = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        except Exception:
            continue
        if out.returncode == 0:
            return [l.split("refs/tags/")[-1] for l in out.stdout.split() if "v" in l]
    return []


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    files = sorted(p for p in list(root.glob("*.md")) + list((root / "profile").glob("*.md")) if p.is_file())
    errs: list[str] = []
    for f in files:
        rel = f.relative_to(root)
        norm = normalise(f.read_text(errors="replace"))
        for label, rx, qual in RULES:
            for s in sentences(norm):
                m = rx.search(s)
                if not m:
                    continue
                if qual is not None:
                    window = s[max(0, m.start() - 40): m.end() + 40]
                    if re.search(r"not (yet )?(deployed|live|mounted)|built to|once published|not yet|no public release", window, re.I) and not re.search(r"\bare cosign|\bis cosign", s[m.start():m.end()], re.I):
                        continue
                errs.append(f"{rel}: {label}: ...{s[max(0, m.start() - 40):m.end() + 60]}...")

    # Reusable-workflow pins must resolve.
    tags = remote_v_tags(root)
    for f in files:
        for m in re.finditer(r"reusable-[a-z-]+\.yml@(v[0-9][\w.]*)", f.read_text(errors="replace")):
            if m.group(1) not in tags:
                errs.append(f"{f.relative_to(root)}: pins @{m.group(1)}, which is not a tag on origin; pin a commit SHA")

    bounty = root / "BOUNTY.md"
    sec = root / "SECURITY.md"
    if not bounty.exists():
        errs.append("BOUNTY.md is missing")
    else:
        b = bounty.read_text()
        for section in ("## In scope", "## Not deployed or not running", "## Safe harbor", "## Known issues", "## Rewards"):
            if section not in b:
                errs.append(f"BOUNTY.md lacks section '{section}'")
        ki = b.split("## Known issues", 1)[-1].split("\n## ", 1)[0]
        body = re.sub(r"\s+", " ", ki).strip()
        if re.search(r"^\s*([-*|]|\d+[.)])\s", ki, re.M) or body not in ("Published per finding once fixed. `OWNER TO FILL`.",):
            errs.append("BOUNTY.md Known issues must stay a placeholder until each finding is fixed and the owner publishes it")
        if "not in force" in b:
            for f in files:
                if f.name != "BOUNTY.md" and re.search(r"BOUNTY\.md", f.read_text(errors="replace")):
                    errs.append(f"{f.relative_to(root)} links BOUNTY.md while BOUNTY.md is marked not in force (counsel sign-off pending)")

    for e in errs:
        print(f"::error::public-truth: {e}")
    if errs:
        print(f"public-truth: FAIL ({len(errs)})")
        return 1
    print(f"public-truth: OK ({len(files)} files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
