# Citrate Network

> An AI-native Layer-1 BlockDAG blockchain using **GhostDAG consensus**, paired with an EVM-compatible execution environment (LVM) and a standardized Model Context Protocol (MCP) layer.

## What you'll find here

This GitHub organization hosts the federated repositories that make up the Citrate Network. The codebase was originally developed as a monorepo (now preserved as [`citrate-monorepo-archive`](https://github.com/citratenetwork/citrate-monorepo-archive)) and split in May 2026 to enable per-component release cadences and independent audits.

## Repository index

### Core chain

- **`citrate-chain`** — The blockchain: consensus, execution, networking, RPC, contracts, node, CLI, wallet. Publishes 4 chain crates to crates.io.

### Client applications

- **`citrate-gui-native`** — Slint-native desktop wallet and DAG explorer
- **`citrate-learning-center`** — School pilot desktop application
- **`citrate-wallet-extension`** — Browser wallet extension
- **`citrate-buyer-webapp`** — Buyer-side marketplace web application
- **`citrate-dashboard`** — Network monitoring dashboard

### Compute and AI infrastructure

- **`citrate-inference-gateway`** — x402-compatible inference gateway
- **`citrate-compute-pool`** — Training pool coordinator + worker
- **`citrate-agent-runtime`** — Agent execution runtime + capsules

### SDKs

- **`citrate-sdk-js`** — TypeScript SDK (`@citratenetwork/sdk`)
- **`citrate-sdk-marketplace`** — Marketplace SDK
- **`citrate-sdk-python`** — Python SDK
- **`citrate-edu-sdk`** — Learning Center SDK

### Documentation and history

- **`citrate-docs`** — User-facing documentation site
- **`citrate-agentile-archive`** — Frozen historical record of the Agentile framework, sprint history, ADRs, planset, journals, and audits up to the May 2026 split
- **`citrate-simulation`** — Network simulation tooling

### Operational

- **`citrate-monorepo-archive`** — Pre-split monorepo, frozen and read-only
- **`.github`** — This repo: reusable workflows, org-level templates

## Reusable workflows

Repos in this org consume reusable CI workflows from this `.github` repo:

- `reusable-rust-ci.yml` — Rust build, test, clippy, fmt
- `reusable-solidity-ci.yml` — Foundry test + optional Slither
- `reusable-js-ci.yml` — npm/pnpm/yarn install, build, test, lint
- `reusable-python-ci.yml` — pip install, pytest, ruff, mypy

Usage in any repo's `.github/workflows/ci.yml`:

```yaml
jobs:
  rust:
    uses: citratenetwork/.github/.github/workflows/reusable-rust-ci.yml@main
    with:
      working-directory: '.'
      apt-packages: 'libclang-dev cmake libssl-dev pkg-config libfontconfig1-dev'
```

## License

Per-repo. See each repo's `LICENSE` file.
