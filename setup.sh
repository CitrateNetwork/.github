#!/usr/bin/env bash
# ── Citrate federation — local workspace bootstrap ───────────────────────────────────
# Clones (or forks) + stars EVERY PUBLIC CitrateNetwork repo into one `citrate-labs/`
# workspace, matching the maintainer layout so each repo is its own git root that your
# IDE picks up the moment you open the `citrate-labs/` folder.
#
#   bash setup.sh              # clone every public repo (read + audit)
#   bash setup.sh fork         # fork each to your account, clone your fork, set `upstream`
#   NO_STAR=1 bash setup.sh    # don't star (starring is on by default — it helps us a lot)
#   SHALLOW=1 bash setup.sh    # shallow clones (faster; no full history)
#
# Requires: gh (GitHub CLI, authenticated via `gh auth login`) and git.
# It only ever touches PUBLIC repos — private federation repos are never cloned.
set -euo pipefail
ORG="CitrateNetwork"
MODE="${1:-clone}"

command -v gh  >/dev/null 2>&1 || { echo "✗ Install the GitHub CLI first: https://cli.github.com"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "✗ git is required."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "✗ Run 'gh auth login' first."; exit 1; }

# Anchor at citrate-labs/: use this dir if it's already named that, else create/enter it.
if [ "$(basename "$PWD")" = "citrate-labs" ]; then ROOT="$PWD"; else ROOT="$PWD/citrate-labs"; fi
mkdir -p "$ROOT"; cd "$ROOT"
echo "▶ Workspace: $ROOT"
echo "▶ Mode: $MODE   (star: $([ "${NO_STAR:-0}" = 1 ] && echo off || echo on))"

# Live list of PUBLIC, non-archived repos — auto-includes new ones, never private.
REPOS="$(gh repo list "$ORG" --visibility public --no-archived --limit 300 --json name --jq '.[].name' | sort)"
COUNT="$(printf '%s\n' "$REPOS" | grep -c . || true)"
echo "▶ $COUNT public repositories"; echo

clone_flags=""; [ "${SHALLOW:-0}" = 1 ] && clone_flags="-- --depth 1"
ok=0; skip=0; fail=0
while IFS= read -r r; do
  [ -n "$r" ] || continue
  if [ -d "$r/.git" ]; then
    echo "  ✓ $r (present) — fast-forwarding"; git -C "$r" pull --ff-only --quiet 2>/dev/null || true; skip=$((skip+1))
  elif [ "$MODE" = "fork" ]; then
    if gh repo fork "$ORG/$r" --clone >/dev/null 2>&1; then echo "  ⑂ $r (forked + cloned, 'upstream' set)"; ok=$((ok+1)); else echo "  ✗ $r fork failed"; fail=$((fail+1)); fi
  else
    if gh repo clone "$ORG/$r" "$r" $clone_flags >/dev/null 2>&1; then echo "  ⬇ $r (cloned)"; ok=$((ok+1)); else echo "  ✗ $r clone failed"; fail=$((fail+1)); fi
  fi
  [ "${NO_STAR:-0}" = 1 ] || gh api --method PUT "user/starred/$ORG/$r" >/dev/null 2>&1 || true
done <<EOF
$REPOS
EOF

echo
echo "✔ Done: $ok set up, $skip already present, $fail failed."
echo "  Open the citrate-labs/ folder in your IDE — every repo is its own git root."
echo "  Next: read .github/AGENTS.md, then citrate-docs/LOCAL_STACK.md to build + audit locally."
