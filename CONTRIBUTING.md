# Contributing to the CitrateNetwork

Default contribution guide for all [CitrateNetwork](https://github.com/CitrateNetwork) repos. Individual repos may layer on additional rules (see each repo's `CONTRIBUTING.md` or `AGENTS.md` if present).

## Before you start

1. **Skim the repo's README** for what it does and how it builds.
2. **Check `AUDIT_TIER.md`** to understand the security posture expected of contributions.
3. **Search open issues + PRs** for related discussion. Avoid duplicate work.
4. For **non-trivial changes**: open an issue first to discuss approach. Saves churn.

## Pull request expectations

| Aspect | Standard |
|---|---|
| Commits | Squash before merge unless multiple atomic logical changes |
| Commit message | First line < 72 chars, body explains *why* not *what* |
| Branch name | `<type>/<topic>` — e.g. `fix/dispute-reentrancy`, `feat/agent-cron` |
| Tests | Every behavior change needs a test. Bug fixes need a regression test. |
| CI | Must pass green before review. Don't ping reviewers on red CI. |
| Reviews | One approving reviewer for Tier-3 repos; two for Tier-1 |
| Linked issue | Reference the issue number in the PR description |
| Breaking changes | Call them out explicitly in the PR body and CHANGELOG.md |

## Conventional commits

We use [Conventional Commits](https://www.conventionalcommits.org/). Common types in this org:

- `feat:` new feature
- `fix:` bug fix
- `docs:` docs only
- `test:` adding/refactoring tests
- `ci:` CI/CD changes
- `chore:` housekeeping
- `refactor:` no behavior change

For security fixes, use `fix(security):` and follow `SECURITY.md`.

## Sign-off

By submitting a PR, you certify that you wrote or have the right to contribute the code under the project's license (BUSL-1.1 unless a repo carries a different LICENSE). We don't require DCO sign-off in every commit, but for substantive changes to Tier-1 repos, a `Signed-off-by:` line is appreciated.

## Bringing changes upstream

The chain and SDKs may receive forks/clones. If you're upstreaming work from a fork:

1. Rebase on the latest target branch first.
2. Open a draft PR early for visibility.
3. Reference the original branch/repo in the PR description.

## Where to ask questions

- **GitHub Discussions** for that specific repo (preferred for code questions).
- **Discord** invite in the org README for community/sync conversations.
- **conduct@citrate.ai** for conduct concerns.
- **security@citrate.ai** for vulnerabilities (see `SECURITY.md`).
