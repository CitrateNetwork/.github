# Citrate Network

> An AI-native Layer-1 BlockDAG blockchain using **GhostDAG consensus**, paired with an EVM-compatible execution environment (LVM) and a standardized Model Context Protocol (MCP) layer.

## What you'll find here

This GitHub organization hosts the federated repositories that make up the Citrate Network. The codebase was originally developed as a monorepo (now preserved as [`citrate-monorepo-archive`](https://github.com/citratenetwork/citrate-monorepo-archive)) and split in May 2026 to enable per-component release cadences and independent audits.

## Open source and licensing

Citrate is **open-core**, and the whole chain and application layer are **public today** across this organization.

- **Infrastructure — Apache-2.0 (open source).** The chain, node and on-ramp software, the model architecture, the SDKs, the co-op contracts, the docs, and the explorer. Read it, fork it, build on it.
- **Application layer / commercial core — BUSL-1.1 (source-available).** The inference gateway, compute pool, cluster, node core, comms, quorum, identity, memories, the native app, the NIST agent, and the studio. The source is public and auditable today; each converts to **Apache-2.0** on the Change Date stated in its `LICENSE`.

Licensor: **Citrate Inc.** Each repository's `LICENSE` file is authoritative. A small set of **client, enterprise (Homestead), security, and internal** repositories stays private. Enterprise or client access: [citrate.ai/contact](https://citrate.ai/contact) or `hello@citrate.ai`. Full policy: [docs.citrate.ai/start/open-source](https://docs.citrate.ai/start/open-source).

## Repository index

### Infrastructure — Apache-2.0 (open source)

- **`citrate-chain`** — The L1: GhostDAG consensus, EVM/LVM execution, networking, RPC, contracts, node, CLI, wallet. Chain 40204.
- **`citrate-fed-types`** — Shared cross-repo type definitions for the federation.
- **`citrate-node-agent`** — Node supervision, cost-plus bidding, health.
- **`citrate-bundler`** — ERC-4337 bundler service for embedded wallets.
- **`nat`** — NAT, the federated neuroarchitectural transformer (model architecture). Memory-safe Rust, formally specified.
- **`citrate-coop`** — On-chain cooperative ownership and governance contracts.
- **`citrate-agent-runtime`** — Capability-scoped agent execution runtime + capsules.
- **`citrate-sdk-js`** — TypeScript SDK (`@citratelabs/sdk`).
- **`citrate-sdk-python`** — Python SDK.
- **`citrate-sdk-marketplace`** — Marketplace SDK (metered, pay-per-call inference).
- **`citrate-docs`** — The Almanac: docs.citrate.ai.
- **`citrate-explorer`** — CitrateScan, the AI-native BlockDAG explorer.

### Application layer / commercial core — BUSL-1.1 (source-available, converts to Apache-2.0)

- **`citrate-inference-gateway`** — x402-metered, pay-per-call AI inference gateway.
- **`citrate-compute-pool`** — Coordinator + workers for pooled AI training.
- **`citrate-cluster`** — GPU-fleet and compute-cluster tooling.
- **`citrate-core`** — Desktop app that turns your machine into a full node.
- **`citrate-comms`** — End-to-end-encrypted, server-blind team workspace.
- **`citrate-quorum`** — Human-in-the-loop governance surface for AI.
- **`citrate-identity`** — OIDC/OAuth2 authority with SIWE and passkeys.
- **`citrate-memories`** — Content-addressed knowledge graph for agents.
- **`citrate-native`** — Slint desktop wallet and agent client.
- **`nist-agent`** — NIST-compliant agent harness, a composable sidecar.
- **`citrate-studio`** — Native operator control surface.

### Methodology and org tooling

- **`agentile`** / **`agentile-skills`** — The institutional methodology for human-agent software, and the same methodology as an installable Claude Code skills marketplace.
- **`.github`** — This repo: org profile, reusable CI workflows, and `AGENTS.md`.

## Reusable workflows

Repos in this org consume reusable CI workflows from this `.github` repo:

- `reusable-rust-ci.yml` — Rust build, test, clippy, fmt
- `reusable-solidity-ci.yml` — Foundry build + test + Slither (default on)
- `reusable-js-ci.yml` — npm/pnpm/yarn install, build, test, lint
- `reusable-python-ci.yml` — pip install, pytest, ruff, mypy

Usage in any repo's `.github/workflows/ci.yml`:

```yaml
jobs:
  rust:
    # GH-B-003: pin to a release tag or a full commit SHA, never @main (a mutable
    # branch: one push to this repo would change every caller's CI with no diff).
    uses: citratenetwork/.github/.github/workflows/reusable-rust-ci.yml@v1
    with:
      working-directory: '.'
      apt-packages: 'libclang-dev cmake libssl-dev pkg-config libfontconfig1-dev'
```

## License

Open-core, per-repo — the `LICENSE` file in each repository is authoritative:

- **Apache-2.0** (infrastructure, open source): `citrate-chain`, `citrate-fed-types`, `citrate-node-agent`, `citrate-bundler`, `nat`, `citrate-coop`, `citrate-agent-runtime`, `citrate-sdk-js`, `citrate-sdk-python`, `citrate-sdk-marketplace`, `citrate-docs`, `citrate-explorer`.
- **BUSL-1.1** (application layer / commercial core, source-available; converts to Apache-2.0 on each `LICENSE`'s Change Date): `citrate-inference-gateway`, `citrate-compute-pool`, `citrate-cluster`, `citrate-core`, `citrate-comms`, `citrate-quorum`, `citrate-identity`, `citrate-memories`, `citrate-native`, `nist-agent`, `citrate-studio`.

Licensor: **Citrate Inc.**
