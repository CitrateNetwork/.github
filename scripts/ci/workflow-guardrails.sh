#!/usr/bin/env bash
# workflow-guardrails.sh — RM-Q tripwire for the three dot-github HIGH findings.
#
#   GH-B-001 / DGH-001  a security gate that never runs because its workflow file
#                       lives outside .github/workflows/ (GitHub dispatches only
#                       from that directory).
#   GH-B-002 / DGH-006  a fail-open gate in a reusable pipeline: continue-on-error
#                       on a lint/test/build/audit/scan step, or `|| echo` / `|| true`
#                       swallowing a gate's exit code.
#   GH-B-003 / GH-B-004 / DGH-002  a mutable-branch supply-chain hop: a third-party
#                       action or reusable workflow pinned to a branch (@master,
#                       @main, …) instead of a tag or SHA, or a cross-repo `ref:`
#                       checkout on a moving branch that is then executed.
#
# Fail-closed: any hit exits non-zero. Run from the repo root.
set -uo pipefail

ROOT="${1:-.}"
cd "$ROOT" || { echo "cannot cd to $ROOT" >&2; exit 2; }

FAIL=0
note() { printf 'FAIL[%s]: %s\n' "$1" "$2"; FAIL=1; }

# Emit `lineno:content` for PATTERN in FILE, skipping YAML comment-only lines so
# the tripwire never trips on prose that quotes the very pattern it hunts.
scan() { # scan <pattern> <file>
  grep -nE "$1" "$2" | while IFS= read -r m; do
    body="${m#*:}"
    case "$body" in
      *[![:space:]]*) : ;;   # non-blank
      *) continue ;;
    esac
    trimmed="${body#"${body%%[![:space:]]*}"}"
    [ "${trimmed:0:1}" = "#" ] && continue
    printf '%s\n' "$m"
  done
}

# ── C1  on:-triggered workflow outside .github/workflows/ ──────────────────────
# Any YAML with a top-level `on:` (or a `workflow_call:` entry) that is not under
# .github/workflows/ is inert — GitHub will never dispatch it, and no caller can
# `uses:` a reusable workflow from a non-standard path.
while IFS= read -r f; do
  case "$f" in
    ./.github/workflows/*) continue ;;
  esac
  if grep -Eq '^[[:space:]]*(on|workflow_call)[[:space:]]*:' "$f"; then
    note C1 "workflow with an 'on:'/'workflow_call:' trigger outside .github/workflows/: $f (GitHub will never run it)"
  fi
done < <(find . -type d -name .git -prune -o -type f \( -name '*.yml' -o -name '*.yaml' \) -print)

# ── C2  fail-open gate steps in reusable workflows ────────────────────────────
WF=$(find ./.github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null)
for f in $WF; do
  while IFS= read -r line; do
    note C2 "continue-on-error:true (fail-open gate) in $f:${line%%:*}"
  done < <(scan '^[[:space:]]*continue-on-error:[[:space:]]*true' "$f")

  # `|| echo` / `|| true` swallow a non-zero exit — the tool can fail while the
  # step (and the job) stays green.
  while IFS= read -r line; do
    note C2 "exit-code swallow ('|| echo' / '|| true') in $f:${line%%:*}"
  done < <(scan '\|\|[[:space:]]*(echo|true)([[:space:]]|$)' "$f")
done

# ── C3  mutable-branch supply-chain hops ──────────────────────────────────────
for f in $WF; do
  # uses: owner/repo@<branch> where <branch> is a well-known moving branch.
  while IFS= read -r line; do
    ref="$(printf '%s' "$line" | sed -E 's/.*@([A-Za-z0-9._/-]+).*/\1/')"
    note C3 "action/workflow pinned to mutable branch '@$ref' in $f:${line%%:*} (pin a tag or full SHA)"
  done < <(scan 'uses:[[:space:]]*[^[:space:]]+@(master|main|develop|trunk|stable|nightly|latest)([[:space:]#]|$)' "$f")

  # ref: <branch> in a checkout step — a cross-repo fetch on a moving branch.
  while IFS= read -r line; do
    note C3 "cross-repo 'ref:' on a mutable branch in $f:${line%%:*} (pin a full SHA)"
  done < <(scan '^[[:space:]]*ref:[[:space:]]*(master|main|develop|trunk|stable|nightly)[[:space:]]*$' "$f")
done

# ── C4  ${{ }} interpolation inside a run: body (template injection) ───────────
# GH-B-005 / DGH-005: GitHub expands ${{ }} into the shell SCRIPT text BEFORE the
# shell runs, so an `inputs.*` or `github.event.*` value that lands in a `run:`
# body is executed as code, not read as data — a caller (or a caller that forwards
# untrusted PR data into an input) gets shell injection. The fix is to pass the
# value through `env:` and reference it as a quoted shell variable, which the
# shell then treats as data. This check fails on any ${{ … }} inside a run: body.
for f in $WF; do
  while IFS= read -r ln; do
    note C4 "\${{ }} expansion inside a run: body in $f:$ln (route the value through env: and reference \"\$VAR\")"
  done < <(awk '
    function indent(s,   i){ i=match(s, /[^ ]/); return (i? i-1 : length(s)) }
    {
      line=$0
      if (line ~ /^[[:space:]]*#/) next
      if (in_run) {
        if (line ~ /[^[:space:]]/ && indent(line) <= run_indent) { in_run=0 }
        else { if (line ~ /\$\{\{/) print NR; next }
      }
      if (line ~ /^[[:space:]]*run:[[:space:]]*[|>]/) { in_run=1; run_indent=indent(line); next }
      if (line ~ /^[[:space:]]*run:[[:space:]]*[^|>[:space:]]/ && line ~ /\$\{\{/) print NR
    }
  ' "$f")
done

if [ "$FAIL" -ne 0 ]; then
  echo "---"
  echo "workflow-guardrails: FAIL — see the FAIL[...] lines above."
  exit 1
fi
echo "workflow-guardrails: PASS"
exit 0
