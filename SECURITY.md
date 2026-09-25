# Security Policy

This document covers all repositories under the [`CitrateNetwork`](https://github.com/CitrateNetwork) GitHub organization. Individual repos may add a repo-specific `SECURITY.md` that **augments** (not replaces) this policy.

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Preferred (encrypted, no key exchange): use **GitHub private vulnerability reporting** — on the affected repository, open the **Security** tab → **Report a vulnerability**. This gives a private, GitHub-encrypted channel with no PGP key to fetch.

Alternatively, email **security@citrate.ai**. We do not publish a PGP key yet, so send sensitive details through private vulnerability reporting rather than plain email. Our [`security.txt`](https://citrate.ai/.well-known/security.txt) lists the same contacts.

Bounty policy: coming soon. It will be linked here once counsel has reviewed it (OWNER).

Include in your report:
- The repo + commit SHA (or version tag) where you observed the issue
- Steps to reproduce or a proof-of-concept
- Your assessment of the impact severity (critical / high / medium / low)
- Whether you intend public disclosure on any timeline

We acknowledge within **72 hours** and aim to triage within **5 business days**. For critical vulnerabilities in `citrate-chain` (consensus, execution, on-chain crypto), expect a faster turnaround.

## Scope

Severity tiers and audit cadence per repo are documented in each repo's `AUDIT_TIER.md`. The summary
below is the same table that appears on the [security posture page](https://docs.citrate.ai/security/posture).

| Tier | Repositories | Audit policy | Vulnerability handling |
|---|---|---|---|
| **Tier 1**: consensus, value, keys, identity | `citrate-chain` (node, contracts, ZK), `citrate-core`, `citrate-identity`, `citrate-inference-gateway`, `citrate-compute-pool`, `citrate-coop`, `citrate-agent-runtime`, `citrate-sdk-js`, `citrate-sdk-python` | Full adversarial audit before every stable release | Coordinated disclosure; a GitHub Security Advisory (with a CVE request) for fixed High and Critical issues in released code |
| **Tier 3**: docs and content | `citrate-docs`, `.github`, and other content-only repositories | Content review | Triage as documentation corrections, no CVE |

A repository's own `AUDIT_TIER.md` is authoritative for that repository. A public repository without an
`AUDIT_TIER.md` is handled as Tier 1 for reports.

No advisories have been published yet.

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

## Supply-chain integrity (current practice)

- `citrate-chain`'s release workflow is built to sign artifacts with cosign (keyless OIDC) and attach CycloneDX SBOMs, but no public release carries signed assets yet: the signed `v0.5.0-beta2-tier2` build is still a draft. Treat current prereleases, including the `citrate-core` desktop builds, as unsigned and without SBOMs.
- `@citratelabs/sdk` on npm is published with a provenance attestation. `@citratelabs/marketplace-sdk` is not yet.
- Supply-chain hardening is in progress: required review and CI checks on every public repository, third-party GitHub Actions pinned to commit SHAs, and signed releases with SBOMs.

Verifying a signed release artifact, once published:

```bash
# cosign verify-blob with the issuer / identity from the release
cosign verify-blob --certificate-identity-regexp 'https://github\.com/CitrateNetwork/.*' \
                   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
                   --signature <artifact>.sig --certificate <artifact>.pem \
                   <artifact>
```

## Audit firms + history

Per-repo audit history lives in each repo's `audits/` directory, when present. History from before the repositories were split is kept in a private archive and is not public. No external-firm audit has been completed yet; the next planned audit is the chain Tier-1 pass before the `v0.5.0` stable tag.

## Contact

- Vulnerability reports: security@citrate.ai
- Press/disclosure coordination: same address; tag `[PRESS]` in the subject.
- General questions: open a GitHub Discussion in the relevant repo.
