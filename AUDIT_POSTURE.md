# Federation Audit Posture

Authoritative document for the CitrateNetwork federation's audit standards. Applies across all 21 repos. Per-repo classification lives in each repo's `AUDIT_TIER.md`.

## Federation-wide expectations

Every repo in the org carries:

| Artifact | Source | Notes |
|---|---|---|
| `LICENSE` | Repo root | BUSL-1.1 by default (see citrate-chain/LICENSE for full terms); customer-specific repos may layer on proprietary terms |
| `AUDIT_TIER.md` | Repo root | Tier-1 (full audit) or Tier-3 (content review) classification |
| `SECURITY.md` | Inherited from this `.github` repo | Repo-specific overrides allowed |
| `CODE_OF_CONDUCT.md` | Inherited | |
| `CONTRIBUTING.md` | Inherited | |
| `.gitignore` | Repo root | Must exclude `target/`, build artifacts, `.env*`, OS junk |
| `.github/workflows/ci.yml` | Repo root | At minimum: build + test passes on push to main |

Tier-1 repos additionally carry:

| Artifact | Notes |
|---|---|
| `audits/` directory | Dated audit reports + intake folders |
| `dependabot.yml` (inherited) | Weekly cadence for dependencies |
| Branch protection on `main` | Required status checks + 1 reviewer minimum |
| Signed commits | Encouraged; required for chain stable tags |
| Release signing | cosign keyless OIDC for every artifact in GitHub Releases |
| SBOM in release | CycloneDX for Rust, npm-audit attestation for JS |

## Release gates per tier

### Tier 1

| Tag pattern | Audit required | Visibility |
|---|---|---|
| `v0.x.y-alpha.N`, `v0.x.y-beta.N` | No (prerelease) | Public artifacts, draft GH Release |
| `v0.x.y-rc.N` | No (release candidate) | Public artifacts, draft GH Release |
| `v0.x.y` stable | **Yes** — written attestation from named auditor with commit SHA | Promoted from draft to public after attestation |
| `v1.0.0` and major-version bumps | **Yes** — re-audit even if previous audit recent | Promoted from draft to public after attestation |

### Tier 3

| Tag pattern | Audit required | Visibility |
|---|---|---|
| Any | No | Public |

## Federation-wide CI conventions

Reusable workflows live in [`CitrateNetwork/.github/.github/workflows/`](https://github.com/CitrateNetwork/.github/tree/main/.github/workflows):

- `reusable-rust-ci.yml` — cargo fmt, clippy, test
- `reusable-solidity-ci.yml` — forge build + test, optional Slither
- `reusable-js-ci.yml` — install + build + test + lint with graceful no-script handling
- `reusable-python-ci.yml` — pip install + ruff + mypy + pytest

Repos that consume them via `uses:` should NOT inline duplicate logic. If a one-off step is needed, add it AFTER the reusable workflow call.

## Vulnerability disclosure

See [`SECURITY.md`](SECURITY.md). All Tier-1 repos must include a `SECURITY.md` link in their README pointing back to this org-level policy.

## Audit history

Federation-wide audit history is summarized below. Individual audit reports live in each repo's `audits/` directory; pre-split audit reports live in [`citrate-monorepo-archive`](https://github.com/CitrateNetwork/citrate-monorepo-archive)'s `audits/`.

| Date | Auditor | Scope | Outcome |
|---|---|---|---|
| Pre-split | various | Monorepo as of 2026-05-17 | See archive `audits/` |
| Planned: Q3 2026 | TBD | `citrate-chain` Tier-1 pass before `v0.5.0` stable | — |

## Changelog of this document

| Date | Change |
|---|---|
| 2026-05-18 | Initial federation audit posture published (PSL-13 / Audit-Posture-Sweep) |
