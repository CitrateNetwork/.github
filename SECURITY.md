# Security Policy

This document covers all repositories under the [`CitrateNetwork`](https://github.com/CitrateNetwork) GitHub organization. Individual repos may add a repo-specific `SECURITY.md` that **augments** (not replaces) this policy.

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Email: **security@citrate.ai** (PGP key: see `keys/security@citrate.ai.asc` in the [`citrate-monorepo-archive`](https://github.com/CitrateNetwork/citrate-monorepo-archive) repo). Encrypt anything sensitive.

Include in your report:
- The repo + commit SHA (or version tag) where you observed the issue
- Steps to reproduce or a proof-of-concept
- Your assessment of the impact severity (critical / high / medium / low)
- Whether you intend public disclosure on any timeline

We acknowledge within **72 hours** and aim to triage within **5 business days**. For critical vulnerabilities in `citrate-chain` (consensus, execution, on-chain crypto), expect a faster turnaround.

## Scope

Severity tiers and audit cadence per repo are documented in each repo's `AUDIT_TIER.md`. The TL;DR:

| Tier | Audit policy | Vulnerability handling |
|---|---|---|
| **Tier 1** (chain, GUI, SDKs, wallet-extension, agent-runtime, gateway, compute-pool, buyer-webapp, learning-center, boeing-shell, dashboard) | Full audit before every stable release | Coordinated disclosure; CVE assigned for high+ |
| **Tier 3** (docs, archives, simulation, commercial, compliance) | Content review only | Triage as docs corrections, no CVE |

## Responsible disclosure

We follow a **90-day coordinated disclosure** window. After receiving a report:

1. **Day 0**: acknowledge receipt within 72 hours.
2. **Day 1-7**: triage, reproduce, classify severity.
3. **Day 7-60**: develop + test fix.
4. **Day 60-75**: prepare release notes, advisory, CVE if applicable.
5. **Day 75-90**: coordinated disclosure window; you and we publish.

We will **not** pursue legal action against researchers who:
- Report in good faith.
- Avoid privacy violations, data destruction, or service interruption.
- Don't publicly disclose during the coordination window.

## Out of scope

- Findings on dependencies (file upstream).
- Best-practice violations without a concrete exploit (e.g., "use of `unsafe` block" without a documented misuse).
- Social engineering of team members.
- Physical access attacks against operator hardware.

## Supply-chain integrity

- Crates published from `citrate-chain` are signed via cosign keyless OIDC. See the chain's `.github/workflows/release.yml` for the signing pipeline.
- npm packages from `citrate-sdk-*` are published with provenance attestations.
- SBOMs (CycloneDX) attach to every Tier-1 release.

Verifying a release artifact:

```bash
# cosign verify-blob with the issuer / identity from the release
cosign verify-blob --certificate-identity-regexp 'https://github\.com/CitrateNetwork/.*' \
                   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
                   --signature <artifact>.sig --certificate <artifact>.pem \
                   <artifact>
```

## Audit firms + history

Per-repo audit history lives in each repo's `audits/` directory (when present) or in the [`citrate-monorepo-archive`](https://github.com/CitrateNetwork/citrate-monorepo-archive) for pre-split history. The next planned audit is the chain Tier-1 pass before the `v0.5.0` stable tag.

## Contact

- Vulnerability reports: security@citrate.ai
- Press/disclosure coordination: same address; tag `[PRESS]` in the subject.
- General questions: open a GitHub Discussion in the relevant repo.
