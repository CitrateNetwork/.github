#!/usr/bin/env bash
# canon-guardrail.sh — CC-1 (planset 2026-07-27-canonicalization-conversion, WS-2).
#
# A federation-wide gate that keeps RETIRED claims off public surfaces. It is the
# enforcement arm of the owner's locked decisions:
#
#   D-CC-2  No identity vendor is ever named publicly. Identity verification is
#           "Citrate's in-house verification (VERI)". CLEAR and Sumsub are retired.
#   D-CC-3  Throughput is "5,000 TPS sustained, 10,000 ceiling". The 773K executor
#           microbench figure is retired from public surfaces.
#   D-CC-4  No veteran-owned / SDVOSB / VOSB / service-disabled business-status
#           claim anywhere (dilution across partners disqualifies it).
#   D-CC-1  No retired per-device earnings range ("$120 to $2,400"). The offer is
#           Free / Pilot $48 / Enterprise, with no earnings promise.
#
# This is a SEPARATE check from disclaimer-check.sh: that one requires a claim to
# co-occur with a disclaimer; this one forbids a token from appearing at all.
#
# SCOPE (the metadata-leak lesson): scans prose AND package/repo metadata —
# .md/.mdx/.html/.txt/.ts/.tsx/.js/.jsx/.mjs/.json/.toml — because "veteran-owned"
# leaked to a blind agent via citrate-landing/package.json "description" while
# every served page was clean. A prose-only scan would miss that class.
#
# ALLOWLIST: paths in EXCLUDES (journals, .agentile, REGISTRY, archives, build
# output, this script) are skipped, and any single line carrying the marker
# `canon-allow` is skipped, so a doc that legitimately quotes a retired term to
# explain THIS policy does not trip the gate.

set -uo pipefail
TARGET="${1:-.}"
cd "$TARGET"

EXCLUDES=(
  '/.git/'
  '/node_modules/'
  '/.next/'
  '/out/'
  '/dist/'
  '/build/'
  '/target/'
  '/coverage/'
  '/_generated/'          # derived content (source .md is the truth)
  '/.canon-guardrail/'    # the fetched copy of THIS repo in CI
  '/.agentile/'           # methodology / field-logs — history, not a public claim
  '/REGISTRY/'            # rewrite-tracking registry references vendors as canon history
  '/PLANSET/'             # program-planning docs describe past/target state, not live claims
  'REDTEAM'               # red-team analysis discusses retired terms by its nature
  'canon-guardrail'       # this script + its workflow contain the patterns
  'disclaimer-check'
  'no-clear-no-773'
  '/CHANGELOG'
  'citrate-journals'
  'citrate-agentile-archive'
  'citrate-monorepo-archive'
  '/journals/'
  '/essays/'
  '/handoffs/'
)
EXCLUDE_PATTERN=$(printf '%s\n' "${EXCLUDES[@]}" | paste -sd'|' -)

# Retired-token classes. Kept as (label, pattern) pairs. VENDOR is scanned
# case-sensitively so the English word "clear"/"cleartext" never matches; only the
# proper-noun vendor CLEAR (whole word) and Sumsub do.
declare -a HITS=()
scan() { # $1=label  $2=grep-flags  $3=ERE
  local label="$1" flags="$2" re="$3" line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    echo "$line" | grep -q 'canon-allow' && continue
    HITS+=("[$label] $line")
  done < <(grep -rn $flags "$re" \
      --include='*.md' --include='*.mdx' --include='*.html' --include='*.txt' \
      --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.mjs' \
      --include='*.json' --include='*.toml' \
      . 2>/dev/null \
    | grep -vE "$EXCLUDE_PATTERN" \
    | { [ "$label" = "VENDOR" ] && grep -vE 'cleartext' || cat; })
}

scan VENDOR     '-E'  '\bCLEAR\b|Sumsub'
scan THROUGHPUT '-nE' '773,?000|773[Kk]\b|773[[:space:]]*(tx|[Tt][Pp][Ss])'
scan STATUS     '-inE' 'veteran[- ]owned|\bSDVOSB\b|\bVOSB\b|service-disabled|service disabled'
scan EARNINGS   '-nE' '\$120[[:space:]]*(to|-|–|—)[[:space:]]*\$?2,?400|\$2,?400[[:space:]]*(per|/)[[:space:]]*(device|machine)'

if [ "${#HITS[@]}" -gt 0 ]; then
  echo "FAIL: retired claim(s) found on a public surface (canon guardrail, CC-1):"
  printf '  %s\n' "${HITS[@]}"
  echo
  echo "These are retired by owner decision:"
  echo "  VENDOR      D-CC-2 — say \"Citrate's in-house verification (VERI)\", never CLEAR/Sumsub."
  echo "  THROUGHPUT  D-CC-3 — say \"5,000 TPS sustained, 10,000 ceiling\", not 773K."
  echo "  STATUS      D-CC-4 — no veteran-owned / SDVOSB claim (cap-table dilution disqualifies)."
  echo "  EARNINGS    D-CC-1 — offer is Free / Pilot \$48 / Enterprise; no \$120-\$2,400 earnings promise."
  echo
  echo "If a hit is a legitimate historical reference (e.g. a doc explaining this"
  echo "policy), add 'canon-allow' to that line, or add the path to EXCLUDES."
  exit 1
fi

echo "PASS: no retired CLEAR/Sumsub vendor, 773K throughput, or veteran-owned/SDVOSB"
echo "      claim on any scanned public surface (prose + package/repo metadata)."
exit 0
