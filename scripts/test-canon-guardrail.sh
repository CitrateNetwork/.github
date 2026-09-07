#!/usr/bin/env bash
# test-canon-guardrail.sh — regression harness for scripts/canon-guardrail.sh.
#
# Pins two invariants that GH-B-009 broke and one that must keep working:
#
#   INV-1  a plain retired claim on a public surface is CAUGHT (gate FAILs).
#   INV-2  a retired claim is STILL caught when the same line also happens to
#          mention an allowlist token (e.g. `citrate-journals`, a `/handoffs/`
#          path, `canon-guardrail`). Before the fix, the exclusion filter was
#          applied to grep's whole `path:lineno:content` output, so any of ~20
#          tokens appearing in the CONTENT silently suppressed a real hit — a
#          one-token bypass of the compliance gate. This is the same over-broad
#          suppression class the org already fixed once in secret-scan (BV-X-01).
#   INV-3  path-based exclusions still work: a retired claim inside an excluded
#          PATH (journals/, .agentile/, …) is correctly skipped.
#   INV-4  the per-line `canon-allow` opt-out still works.
#
# Exit 0 if all invariants hold; non-zero (with a diff) otherwise.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
GUARD="$HERE/canon-guardrail.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
check() { # check <name> <expected: FAIL|PASS> <target-subdir> <needle-optional>
  local name="$1" expect="$2" dir="$3" needle="${4:-}"
  local out rc
  out="$(bash "$GUARD" "$dir" 2>&1)"; rc=$?
  local got="PASS"; [ "$rc" -ne 0 ] && got="FAIL"
  if [ "$got" != "$expect" ]; then
    echo "NOT OK: $name — expected gate=$expect, got gate=$got"
    echo "$out" | sed 's/^/    /'
    fail=1
    return
  fi
  if [ -n "$needle" ] && ! echo "$out" | grep -q "$needle"; then
    echo "NOT OK: $name — gate=$got as expected, but output did not mention '$needle'"
    fail=1
    return
  fi
  echo "ok: $name (gate=$got)"
}

# INV-1: plain retired claim → caught.
d1="$WORK/inv1"; mkdir -p "$d1"
printf 'We are a veteran-owned business.\n' > "$d1/plain.md"
check "INV-1 plain retired claim is caught" FAIL "$d1" "veteran-owned"

# INV-2: retired claim + allowlist token on the SAME line → still caught.
d2="$WORK/inv2"; mkdir -p "$d2"
printf 'We are a veteran-owned business. See citrate-journals for history.\n' > "$d2/bypass.md"
check "INV-2 retired claim is caught despite an exclusion token in the line body" FAIL "$d2" "veteran-owned"

# INV-3: retired claim inside an excluded PATH → skipped.
d3="$WORK/inv3"; mkdir -p "$d3/journals"
printf 'Historical note: veteran-owned language used pre-2026.\n' > "$d3/journals/old.md"
check "INV-3 retired claim under an excluded path is skipped" PASS "$d3"

# INV-4: per-line canon-allow marker → skipped.
d4="$WORK/inv4"; mkdir -p "$d4"
printf 'This doc explains why we retired veteran-owned. canon-allow\n' > "$d4/allow.md"
check "INV-4 canon-allow marker opts a line out" PASS "$d4"

if [ "$fail" -ne 0 ]; then
  echo "---"
  echo "test-canon-guardrail: FAIL"
  exit 1
fi
echo "test-canon-guardrail: PASS (4/4 invariants)"
exit 0
