#!/usr/bin/env bash
# public-truth.sh: the org profile, README and security policy must not make claims
# the code or the live network contradict (public-claims accuracy). Logic lives in public_truth.py.
# Usage: bash scripts/ci/public-truth.sh [root]   (exit 1 on any hit)
set -euo pipefail
exec python3 "$(dirname "${BASH_SOURCE[0]}")/public_truth.py" "${1:-.}"
