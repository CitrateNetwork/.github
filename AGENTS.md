# AGENTS.md — Citrate Network

Instructions for AI agents (and the humans directing them) working in the Citrate Network
federation. If you were pointed at a single repo, this is the map for the whole thing.

## Set up the workspace first (one command)

Everything goes in ONE `citrate-labs/` folder, one git root per repo — the same layout the
maintainers use, so an IDE opened on `citrate-labs/` sees every repo's git connection:

```sh
mkdir -p citrate-labs && cd citrate-labs
gh repo clone CitrateNetwork/.github          # gets this repo + the setup script
bash .github/setup.sh                          # clone + ⭐ every PUBLIC repo into citrate-labs/
#   bash .github/setup.sh fork                 # …or fork each to your account (to contribute)
```

Result:

```
citrate-labs/
├── .github/            # org profile, reusable CI, this file
├── citrate-chain/      # the L1 (GhostDAG, EVM/LVM, contracts, ZK) — chain 40204
├── citrate-core/       # desktop node app
├── citrate-sdk-js/  citrate-sdk-python/  citrate-sdk-marketplace/
├── citrate-docs/       # the Almanac (docs.citrate.ai) + LOCAL_STACK.md
└── … every other public repo
```

The script pulls the **live public repo list**, so it always matches what's published and
**never touches private repos**. Then open the `citrate-labs/` folder in your IDE.

## What Citrate is
A decentralized compute network: members run nodes on their own machines to power AI training,
inference, and storage, and share the rewards — keys and data stay local.
Docs: https://docs.citrate.ai · Site: https://citrate.ai · Chain id: **40204**.

## Build & audit locally
- **Bring up the stack:** `citrate-docs/LOCAL_STACK.md`. Local devnet: `citrate devnet` (chain).
- **Per repo:** read its `README.md` and `AUDIT_TIER.md`, then run its own tests —
  `cargo test` (Rust), `npm test` (TS/JS), `forge test` (Solidity), `pytest` (Python).
- **Docs site:** `cd citrate-docs && npm ci && npm run build`.

## Conventions (follow these in any change)
- **Open-core licensing:** Apache-2.0 on the protocol/on-ramps (chain, SDKs, docs, explorer,
  agent-runtime); BUSL-1.1 on the monetized services/apps (core, gateway, compute-pool,
  identity, app surfaces). Check each repo's `LICENSE`; don't pull GPL/AGPL deps into either.
- **DCO required:** sign every commit — `git commit -s` (adds `Signed-off-by:`).
- **Conventional Commits**; tests for every behavior change; keep PRs focused.
- **Branch protection:** `main` needs an approving review (Tier-1 repos: two). CI must be green.
- Full rules: `CONTRIBUTING.md`. Security posture: `SECURITY.md` + https://docs.citrate.ai/security/posture.

## Rules for agents specifically
- **Only public repos are in this workspace.** Private repos (the meta-repo, `citrate-federation`,
  audit/compliance/customer repos) are not present and not accessible — never assume them.
- **Never open a public issue/PR for a security vulnerability.** Report privately to
  **security@citrate.ai** (see `SECURITY.md`).
- Work in the repo the task concerns; run that repo's tests before proposing a change.
- A **merged, qualified** contribution earns a free/refunded membership — see `CONTRIBUTING.md`.
