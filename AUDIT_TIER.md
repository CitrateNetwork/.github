# Audit Tier — `CitrateNetwork/.github`

**Tier: 3 (content / configuration review)** — per [`AUDIT_POSTURE.md`](AUDIT_POSTURE.md).

This repo ships no runtime or on-chain code. Its contents are org-default community
health files (`SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `profile/`),
policy docs, and reusable CI workflows. Findings are handled as documentation /
configuration corrections; no CVE is assigned for this repo's own artifacts.

## Elevated-blast-radius caveat

Although this repo is Tier 3 for its own content, its `.github/workflows/reusable-*.yml`
are the **CI trusted computing base for every repo that calls them**. A change to a
reusable workflow, or to `scripts/canon-guardrail.sh`, can affect many downstream
repos at once. Therefore:

- Changes to `.github/workflows/**` and `scripts/**` get **Tier-1-level review**
  (a second reviewer, and a green `ci.yml`) even though the repo is Tier 3 overall.
- `ci.yml` runs the workflow-guardrails tripwire (GH-B-001/002/003/004/005) and the
  canon-guardrail regression suite (GH-B-009) on every push and PR.

## Required-artifact self-check (GH-B-011)

| Artifact | Present |
|---|---|
| `AUDIT_TIER.md` | this file |
| `SECURITY.md` | yes |
| `CODE_OF_CONDUCT.md` | yes |
| `CONTRIBUTING.md` | yes |
| `.github/workflows/ci.yml` | yes (workflow-guardrails + canon-guardrail regression) |
| `.github/dependabot.yml` | yes (github-actions) |
| Branch protection on `main` | **OWNER action** — admin/settings, not a repo file. Required by `AUDIT_POSTURE.md` and by GH-B-003 (a push here reaches every caller). Enable required review + required `ci.yml` status check. |
