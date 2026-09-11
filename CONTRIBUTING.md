# Contributing to CitrateNetwork

Default contribution guide for all [CitrateNetwork](https://github.com/CitrateNetwork)
repos. Individual repos may layer on additional rules (see each repo's `CONTRIBUTING.md`
or `AGENTS.md` if present). New here? Start with the repo's `README.md`, the
[federation handbook](https://docs.citrate.ai), and `citrate-docs/LOCAL_STACK.md` to run
the stack locally.

Citrate is **open-core**: the chain & consensus, SDKs, types, docs, explorer, and agent
runtime are Apache-2.0; the desktop app and the monetized services (inference gateway,
compute pool, identity) are source-available under BUSL-1.1. Either way, contributions are
welcome.

## 🍊 Contribute, and your membership is on us

Citrate is meant to be owned by the people who build it. **Land a qualified contribution
and your membership is free — or refunded if you've already paid** (see
[citrate.ai](https://citrate.ai) for what membership includes).

- A **qualified contribution** is a **merged pull request that adds real value to a
  meaningful feature, or resolves an open issue.**
- Documentation improvements, grammar, and typo fixes are **genuinely welcome and
  appreciated** — they just don't, on their own, qualify for the membership credit.
- **How to claim:** once your PR is merged, email **hello@citrate.ai** with a link to it
  (or note it in the PR). We'll credit a new membership or refund an existing one.

Not sure if an idea qualifies? Open an issue and ask before you build — we're happy to
tell you up front.

## Before you start

1. **Skim the repo's README** for what it does and how it builds.
2. **Check `AUDIT_TIER.md`** to understand the security posture expected of contributions.
3. **Search open issues + PRs** for related discussion. Avoid duplicate work.
4. For **non-trivial changes**: open an issue first to discuss approach. Saves churn.

## Pull request expectations

| Aspect | Standard |
|---|---|
| Fork & branch | Fork, branch `<type>/<topic>` (e.g. `fix/dispute-reentrancy`, `feat/agent-cron`) |
| Commit message | Conventional Commits; first line < 72 chars, body explains *why* not *what* |
| Tests | Every behavior change needs a test. Bug fixes need a regression test. |
| CI | Must pass green before review. Don't ping reviewers on red CI. |
| Reviews | `main` is protected — every PR needs an approving review (Tier-1 repos: two). No direct pushes. |
| Linked issue | Reference the issue number in the PR description |
| Breaking changes | Call them out explicitly in the PR body and `CHANGELOG.md` |
| Scope | Keep PRs focused; unrelated changes belong in separate PRs |

## Conventional commits

We use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`,
`docs:`, `test:`, `ci:`, `chore:`, `refactor:`. For security fixes use `fix(security):`
and follow `SECURITY.md`.

## Developer Certificate of Origin (required)

By contributing you agree to the [Developer Certificate of Origin](https://developercertificate.org/):
you wrote the change or have the right to submit it under the repo's license. **Sign off
every commit** with `git commit -s` (adds a `Signed-off-by:` line). By submitting, you
also grant Citrate Inc. a perpetual, worldwide, royalty-free license to use and relicense
your contribution as part of the Licensed Work (see the repo's `NOTICE` and
`docs/IP_POLICY.md`). If you're contributing on behalf of an employer, make sure you have
authorization.

## Security

**Do not open a public issue for a vulnerability.** Email **security@citrate.ai** (see
`SECURITY.md`). Coordinated disclosure, 90-day window.

## Where to ask

- **GitHub Discussions** on the repo (preferred for code questions).
- **conduct@citrate.ai** for conduct concerns · **security@citrate.ai** for vulnerabilities.
- **hello@citrate.ai** for membership / getting involved.

---
*Citrate and Citrate OpenWallet are trademarks of Citrate Inc.*
