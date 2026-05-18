# Citrate Network — `.github`

> Org-defaults repo for the [Citrate Network](https://github.com/CitrateNetwork) federation.
> This README mirrors the federation walkthrough from
> [`CitrateNetwork/citrate-labs`](https://github.com/CitrateNetwork/citrate-labs)
> (the canonical source, per Rule 9), then documents the org-level CI infrastructure
> that lives in this repo.
>
> What's *only* in this repo:
> - `profile/README.md` — the landing page rendered on https://github.com/citratenetwork
> - `.github/workflows/reusable-*.yml` — reusable CI workflows consumed by every org repo
> - `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `AUDIT_POSTURE.md`, `dependabot.yml` — org defaults
>
> See [§ Org-level CI infrastructure](#org-level-ci-infrastructure) at the bottom for the CI details.

---

## Federation walkthrough

> Canonical source: [`CitrateNetwork/citrate-labs/README.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/README.md).
> This section mirrors it so the federation overview is discoverable directly from the org-defaults repo.

The Citrate Network is an AI-native Layer-1 BlockDAG using **GhostDAG consensus**, with
an EVM-compatible execution environment (LVM) and a standardized Model Context Protocol
(MCP) layer.

This walkthrough covers:

1. [What `citrate-labs` is](#what-citrate-labs-is)
2. [Federation layout](#federation-layout)
3. [Prerequisites](#prerequisites)
4. [Clone the federation](#clone-the-federation)
5. [Run a private network for testing](#run-a-private-network-for-testing)
6. [Connect to the public testnet](#connect-to-the-public-testnet)
7. [Using individual repositories](#using-individual-repositories)
8. [Working in the Agentile methodology](#working-in-the-agentile-methodology)
9. [Federation sync](#federation-sync)
10. [Licensing and IP](#licensing-and-ip)
11. [Document index](#document-index)

---

### What `citrate-labs` is

**`CitrateNetwork/citrate-labs`** is the **root** of the federation — a coordinating
workspace that brackets every active Citrate repo into a single tree on disk. It is
**not** itself a code repository. It hosts:

- the umbrella **license, IP, patent, and trademark** documents that govern the
  federation as a whole;
- a single-source-of-truth **README + walkthrough** for new contributors and operators;
- **sync tooling** so that a commit at the parent triggers a fan-out report across
  every child repo with changes;
- onboarding docs for the **Agentile methodology** that governs how work flows across
  the federation.

The actual code lives in the child repositories. The control plane that pins them
together lives at [`CitrateNetwork/citrate-federation`](https://github.com/CitrateNetwork/citrate-federation).

### Federation layout

```
Citrate-Labs/                              ← parent meta-repo
├── .github/                               CitrateNetwork/.github         (THIS REPO — org defaults)
├── citrate-federation/                    control plane + manifest.toml + agentile/
├── citrate-agentile-archive/              frozen pre-split history
│
├── citrate-chain/                         core chain — node, RPC, contracts, CLI
├── citrate-gui-native/                    Slint-native desktop wallet
├── citrate-learning-center/               school-pilot desktop app
├── citrate-wallet-extension/              browser wallet extension
├── citrate-buyer-webapp/                  buyer-side marketplace web app
├── citrate-dashboard/                     network monitoring dashboard
├── citrate-boeing-shell/                  Boeing-class shell client
│
├── citrate-inference-gateway/             x402-compatible inference gateway
├── citrate-compute-pool/                  training pool coordinator
├── citrate-agent-runtime/                 agent execution runtime
├── citrate-simulation/                    network simulation tooling
│
├── citrate-sdk-js/                        @citratenetwork/sdk (TypeScript)
├── citrate-sdk-python/                    Python SDK
├── citrate-sdk-marketplace/               marketplace SDK
│
├── citrate-docs/                          user-facing docs site
├── citrate-commercial/                    commercial / partnerships
└── citrate-compliance/                    compliance + legal artifacts
```

Each subdirectory is an independent git repository under the
[`CitrateNetwork`](https://github.com/CitrateNetwork) GitHub organization. The parent
does **not** vendor their source; it tracks only meta files and ignores child working
trees.

See [`docs/ARCHITECTURE.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/ARCHITECTURE.md) for the wire diagram and component relationships.

### Prerequisites

A working setup needs:

| Tool | Version | Used by |
|---|---|---|
| **Git** | ≥ 2.40 | everything |
| **Rust toolchain** | stable (`rustup default stable`) | `citrate-chain`, GUI, gateway, compute-pool, runtime |
| **Foundry** | latest | Solidity contracts in `citrate-chain` |
| **Node.js** | ≥ 20 LTS | `citrate-sdk-js`, web apps, wallet extension |
| **pnpm** | ≥ 8 | web apps (the SDKs use npm) |
| **Python** | ≥ 3.11 | `citrate-sdk-python` |
| **Slint deps** | `libfontconfig1-dev libxkbcommon-dev libwayland-dev` (Linux) | `citrate-gui-native`, `citrate-learning-center` |
| **clang / cmake / pkg-config / libssl-dev** | distro defaults | Rust C-binding deps |
| **SSH key registered with GitHub** | — | private-repo cloning |

Quick install (Debian/Ubuntu):

```bash
sudo apt-get install -y build-essential pkg-config libssl-dev libclang-dev cmake \
                        libfontconfig1-dev libxkbcommon-dev libwayland-dev git
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -L https://foundry.paradigm.xyz | bash && foundryup
curl -fsSL https://fnm.vercel.app/install | bash && fnm install --lts && fnm use lts
corepack enable pnpm
```

### Clone the federation

Two equivalent paths:

#### Option A — workspace-driven (recommended)

The `citrate-federation` control plane ships a bootstrap that clones every active
repo as a sibling. From an empty parent directory:

```bash
mkdir -p ~/Projects && cd ~/Projects
git clone git@github.com:CitrateNetwork/citrate-federation Citrate-Labs/citrate-federation
cd Citrate-Labs/citrate-federation
./scripts/bootstrap.sh                  # clones all 17 active repos as siblings
```

After bootstrap, `~/Projects/Citrate-Labs/` mirrors the layout shown above. Clone
the parent meta-repo on top (it overlays the meta files, since `citrate-*` working
trees are git-ignored):

```bash
cd ~/Projects && git clone git@github.com:CitrateNetwork/citrate-labs Citrate-Labs --no-checkout
cd Citrate-Labs && git checkout main -- README.md LICENSE NOTICE PATENTS.md \
    TRADEMARK.md SECURITY.md CONTRIBUTING.md AGENTILE.md docs scripts .gitignore .githooks
./scripts/install-hooks.sh
```

#### Option B — manual

```bash
mkdir -p ~/Projects/Citrate-Labs && cd ~/Projects/Citrate-Labs
for repo in citrate-federation citrate-chain citrate-gui-native citrate-learning-center \
            citrate-wallet-extension citrate-buyer-webapp citrate-dashboard \
            citrate-boeing-shell citrate-inference-gateway citrate-compute-pool \
            citrate-agent-runtime citrate-simulation citrate-sdk-js \
            citrate-sdk-python citrate-sdk-marketplace citrate-docs \
            citrate-commercial citrate-compliance citrate-agentile-archive; do
  git clone "git@github.com:CitrateNetwork/${repo}.git"
done
git clone git@github.com:CitrateNetwork/.github.git .github
```

Then verify:

```bash
cd citrate-federation
./scripts/status.sh           # last commit, dirty flag, CI status per repo
./scripts/drift-check.sh      # confirm every consumer matches manifest.toml pins
```

### Run a private network for testing

The fastest path to a working, fully-private Citrate network is the one-machine
devnet. It runs a single node plus a wallet plus the agent runtime, all bound to
localhost. See [`docs/PRIVATE_NETWORK.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/PRIVATE_NETWORK.md) for the
multi-node and multi-machine variants.

#### 1. Build the chain

```bash
cd citrate-chain
cargo build --release --bin citrate-node --bin citrate-cli
```

#### 2. Initialize a fresh chain state

```bash
./target/release/citrate-cli devnet init \
    --chain-id 9001 \
    --datadir ~/.citrate/devnet \
    --validators 1
```

This writes a genesis block, a validator key, and a node config under
`~/.citrate/devnet/`.

#### 3. Start the node

```bash
./target/release/citrate-node run \
    --datadir ~/.citrate/devnet \
    --rpc-bind 127.0.0.1:8545 \
    --p2p-listen 127.0.0.1:30303 \
    --no-discovery
```

You should see "GhostDAG ordering active" within a few seconds and blocks ticking.
The JSON-RPC endpoint is now live at `http://127.0.0.1:8545`.

#### 4. Connect a wallet

Pick one:

- **Desktop wallet** — `cd citrate-gui-native && cargo run --release` and add the
  RPC URL `http://127.0.0.1:8545` under Network → Custom RPC.
- **Browser extension** — `cd citrate-wallet-extension && pnpm install && pnpm build`,
  then load `dist/` as an unpacked extension in your browser and add the same RPC URL.
- **CLI** — `./target/release/citrate-cli account create` then
  `./target/release/citrate-cli account list`.

#### 5. Optional: start the inference gateway

```bash
cd citrate-inference-gateway
cargo run --release -- --rpc-url http://127.0.0.1:8545 --listen 127.0.0.1:8080
```

Test it:

```bash
curl -s http://127.0.0.1:8080/v1/models | jq
```

#### 6. Optional: start the agent runtime

```bash
cd citrate-agent-runtime
cargo run --release -- --rpc-url http://127.0.0.1:8545
```

For a multi-node devnet, the network simulation harness, or a dockerized variant,
see [`docs/PRIVATE_NETWORK.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/PRIVATE_NETWORK.md).

> **License note.** A private devnet is **Permitted Community Use** under the
> [`LICENSE`](https://github.com/CitrateNetwork/citrate-labs/blob/main/LICENSE) as long as you stay within the bounds described in
> [`docs/LICENSE_POLICY.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/LICENSE_POLICY.md) (≤ 25 nodes, ≤ 250 accounts,
> non-commercial, non-public). Anything beyond that requires a commercial license.

### Connect to the public testnet

> **Status check first.** The public testnet release is gated on the Tier-1 audit
> of `citrate-chain`. Confirm the active sprint at
> [`citrate-federation/agentile/CURRENT.md`](https://github.com/CitrateNetwork/citrate-federation/blob/main/agentile/CURRENT.md)
> before assuming testnet endpoints are live. The endpoint list below is the planned
> shape; the canonical values land in [`docs/PUBLIC_TESTNET.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/PUBLIC_TESTNET.md)
> when the testnet opens.

#### Network parameters (planned)

| Field | Value |
|---|---|
| Network name | Citrate Testnet |
| Chain ID | (TBA — see `docs/PUBLIC_TESTNET.md`) |
| RPC URL | `https://rpc.testnet.citrate.network` |
| WebSocket | `wss://ws.testnet.citrate.network` |
| Block explorer | `https://explorer.testnet.citrate.network` |
| Faucet | `https://faucet.testnet.citrate.network` |
| Chain spec | `citrate-chain/specs/testnet.toml` |

#### Run a syncing node against the testnet

```bash
cd citrate-chain
cargo build --release --bin citrate-node
./target/release/citrate-node run \
    --network testnet \
    --datadir ~/.citrate/testnet
```

Bootnodes and chain spec ship inside the `citrate-chain` binary; no manual config
is required.

#### Connect a wallet to the testnet

For the desktop wallet, browser extension, or any wallet that speaks JSON-RPC:

```
Network name: Citrate Testnet
RPC URL:      https://rpc.testnet.citrate.network
Chain ID:     (see docs/PUBLIC_TESTNET.md)
Symbol:       tCTR
Explorer:     https://explorer.testnet.citrate.network
```

Request testnet funds at the faucet (one drip per address per day).

#### Deploy a contract

```bash
cd citrate-chain/contracts
forge build
forge create src/MyContract.sol:MyContract \
    --rpc-url https://rpc.testnet.citrate.network \
    --private-key $TESTNET_DEPLOYER_KEY
```

#### Hit the inference gateway

```bash
curl -s https://gateway.testnet.citrate.network/v1/chat/completions \
    -H "Authorization: Bearer $TESTNET_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"model":"citrate-mcp/llama-3.1-8b","messages":[{"role":"user","content":"hello"}]}'
```

See [`docs/PUBLIC_TESTNET.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/PUBLIC_TESTNET.md) for full endpoint inventory,
rate limits, and the path from testnet to mainnet.

### Using individual repositories

Each child repo is independently buildable and has its own README. The high-level
map:

| Repo | What it builds | Run |
|---|---|---|
| [`citrate-chain`](https://github.com/CitrateNetwork/citrate-chain) | `citrate-node`, `citrate-cli`, contracts | `cargo build --release && ./target/release/citrate-node run` |
| [`citrate-gui-native`](https://github.com/CitrateNetwork/citrate-gui-native) | Slint desktop wallet + DAG explorer | `cargo run --release` |
| [`citrate-learning-center`](https://github.com/CitrateNetwork/citrate-learning-center) | School-pilot desktop app | `cargo run --release` |
| [`citrate-wallet-extension`](https://github.com/CitrateNetwork/citrate-wallet-extension) | Browser extension (MV3) | `pnpm install && pnpm build` then load `dist/` |
| [`citrate-buyer-webapp`](https://github.com/CitrateNetwork/citrate-buyer-webapp) | Buyer marketplace web | `pnpm install && pnpm dev` |
| [`citrate-dashboard`](https://github.com/CitrateNetwork/citrate-dashboard) | Network monitoring | `pnpm install && pnpm dev` |
| [`citrate-inference-gateway`](https://github.com/CitrateNetwork/citrate-inference-gateway) | x402 inference gateway | `cargo run --release` |
| [`citrate-compute-pool`](https://github.com/CitrateNetwork/citrate-compute-pool) | Training pool coordinator | `cargo run --release` |
| [`citrate-agent-runtime`](https://github.com/CitrateNetwork/citrate-agent-runtime) | Agent runtime | `cargo run --release` |
| [`citrate-simulation`](https://github.com/CitrateNetwork/citrate-simulation) | Network simulator | `cargo run --release` |
| [`citrate-sdk-js`](https://github.com/CitrateNetwork/citrate-sdk-js) | `@citratenetwork/sdk` | `pnpm install && pnpm build` |
| [`citrate-sdk-python`](https://github.com/CitrateNetwork/citrate-sdk-python) | `citrate-sdk` (PyPI) | `pip install -e .` |
| [`citrate-sdk-marketplace`](https://github.com/CitrateNetwork/citrate-sdk-marketplace) | `@citratenetwork/marketplace-sdk` | `pnpm install && pnpm build` |
| [`citrate-docs`](https://github.com/CitrateNetwork/citrate-docs) | Docs site | `pnpm install && pnpm dev` |
| [`citrate-boeing-shell`](https://github.com/CitrateNetwork/citrate-boeing-shell) | Federated shell client | `cargo run --release` |

**SDK quick examples**

TypeScript:

```ts
import { CitrateClient } from "@citratenetwork/sdk";

const client = new CitrateClient({ rpcUrl: "https://rpc.testnet.citrate.network" });
const head = await client.chain.head();
console.log("latest DAG tip:", head);
```

Python:

```python
from citrate_sdk import CitrateClient

client = CitrateClient(rpc_url="https://rpc.testnet.citrate.network")
print("latest DAG tip:", client.chain.head())
```

### Working in the Agentile methodology

The federation uses a methodology called **Agentile** — a set of 13 federation-wide
rules plus a sprint-driven workflow that keeps planning, governance, and audit
posture consistent across every repo. Both human contributors and AI agents
participate the same way.

The quickest tour:

1. Read [`AGENTILE.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/AGENTILE.md) — a 10-minute overview of why the
   methodology exists and the benefits it delivers.
2. Read [`docs/AGENTILE_RULES.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/AGENTILE_RULES.md) — the 13 rules in full,
   each with its rationale and how-to-apply guidance.
3. Read [`docs/AGENTILE_WORKFLOW.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/AGENTILE_WORKFLOW.md) — how a sprint
   moves from kickoff to close across repos, with the file-locations and tooling.
4. Read [`citrate-federation/agentile/AGENT_ENTRY.md`](https://github.com/CitrateNetwork/citrate-federation/blob/main/agentile/AGENT_ENTRY.md) —
   the canonical entry point inside the control plane.

The **benefit** of working inside Agentile: every change — code, doc, audit, plan —
is traceable to a frontmatter-stamped sprint file, the federation manifest stays
the single source of truth for cross-repo state, and an external auditor can walk
in cold and find the evidence trail without spelunking.

### Federation sync

When you commit at the **parent** `citrate-labs` repo, a post-commit hook walks each child
directory and **reports** which of them have changes that need attention (uncommitted
working tree, unstaged files, or local commits ahead of `origin/main`). It does
**not** push automatically.

```bash
# install the hook in the parent repo (one-time)
./scripts/install-hooks.sh

# detect-only report — what would sync if we pushed today?
./scripts/federation-sync.sh

# explicit apply — push children that already have local commits ahead of origin
./scripts/federation-sync.sh --apply

# strict: also auto-commit dirty working trees with a federation-sync message
./scripts/federation-sync.sh --apply --commit-dirty
```

See [`docs/SYNC.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/SYNC.md) for the full design, the safety rails, and how
this complements [`citrate-federation/manifest.toml`](https://github.com/CitrateNetwork/citrate-federation/blob/main/manifest.toml).

### Licensing and IP

All code, documentation, designs, specifications, and other materials authored by
Mozi Cooperative and distributed through Citrate-Labs and its federated repositories
are licensed under the **[Business Source License 1.1](https://github.com/CitrateNetwork/citrate-labs/blob/main/LICENSE)** with the Citrate
Additional Use Grant.

- **All rights reserved.** Production, commercial, hosted, managed, or
  revenue-generating use requires a separate written license.
- **Patent claims** covering consensus, precompile, ZK, agent-harness, and
  embedded-node designs are filed, pending, or contemplated. See [`PATENTS.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/PATENTS.md).
- **Trademarks** (Citrate, Citrate OpenWallet, SALT, Mozi Cooperative) are reserved.
  See [`TRADEMARK.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/TRADEMARK.md).
- **Intellectual property is actively defended.** See [`NOTICE`](https://github.com/CitrateNetwork/citrate-labs/blob/main/NOTICE) and
  [`docs/IP_POLICY.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/IP_POLICY.md).

Commercial, production, institutional, and partnership use inquiries:
**Partnerships@Citrate.ai**

### Document index

#### Root meta (`citrate-labs`)

| Document | Purpose |
|---|---|
| [`README.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/README.md) | The walkthrough |
| [`LICENSE`](https://github.com/CitrateNetwork/citrate-labs/blob/main/LICENSE) | BUSL-1.1 + Citrate Additional Use Grant |
| [`NOTICE`](https://github.com/CitrateNetwork/citrate-labs/blob/main/NOTICE) | Copyright, contributor acknowledgement, IP-defense statement |
| [`PATENTS.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/PATENTS.md) | Patent rights reservation |
| [`TRADEMARK.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/TRADEMARK.md) | Trademark policy and permitted uses |
| [`SECURITY.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/SECURITY.md) | Vulnerability reporting (defers to org policy in this repo) |
| [`CONTRIBUTING.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/CONTRIBUTING.md) | Contribution + CLA flow |
| [`AGENTILE.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/AGENTILE.md) | Methodology overview and benefits |

#### `citrate-labs/docs/` — deeper guides

| Document | Purpose |
|---|---|
| [`ARCHITECTURE.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/ARCHITECTURE.md) | Federation topology and wire diagram |
| [`PRIVATE_NETWORK.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/PRIVATE_NETWORK.md) | Private devnet walkthrough (1-node, multi-node, dockerized) |
| [`PUBLIC_TESTNET.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/PUBLIC_TESTNET.md) | Public testnet endpoints and onboarding |
| [`IP_POLICY.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/IP_POLICY.md) | Full IP defense and enforcement posture |
| [`LICENSE_POLICY.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/LICENSE_POLICY.md) | How BUSL applies in practice |
| [`SYNC.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/SYNC.md) | Parent-driven federation sync mechanics |
| [`AGENTILE_WORKFLOW.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/AGENTILE_WORKFLOW.md) | Sprint lifecycle across repos |
| [`AGENTILE_RULES.md`](https://github.com/CitrateNetwork/citrate-labs/blob/main/docs/AGENTILE_RULES.md) | The 13 rules, each in full |

#### Inside the federation

| Path | Purpose |
|---|---|
| [`citrate-federation/manifest.toml`](https://github.com/CitrateNetwork/citrate-federation/blob/main/manifest.toml) | Canonical SHA pins per repo |
| [`citrate-federation/agentile/AGENT_ENTRY.md`](https://github.com/CitrateNetwork/citrate-federation/blob/main/agentile/AGENT_ENTRY.md) | Control-plane entry point |
| [`citrate-federation/agentile/CURRENT.md`](https://github.com/CitrateNetwork/citrate-federation/blob/main/agentile/CURRENT.md) | Active sprint |
| [`citrate-federation/agentile/rules/CORE_RULES.md`](https://github.com/CitrateNetwork/citrate-federation/blob/main/agentile/rules/CORE_RULES.md) | Canonical rules (active) |
| [`citrate-federation/routing/topology.md`](https://github.com/CitrateNetwork/citrate-federation/blob/main/routing/topology.md) | Runtime wire diagram |
| [`SECURITY.md`](SECURITY.md) (in this repo) | Org-level security policy |
| [`AUDIT_POSTURE.md`](AUDIT_POSTURE.md) (in this repo) | Audit tiers per repo |

---

## Org-level CI infrastructure

> This section is **only** in this repo (`CitrateNetwork/.github`) — it documents the
> reusable workflows consumed by every other org repo.

### Reusable workflows

| Workflow | Purpose | Notable inputs |
|---|---|---|
| `reusable-rust-ci.yml` | cargo fmt, clippy, test | `working-directory`, `apt-packages`, `test-args` |
| `reusable-solidity-ci.yml` | forge build + test, optional Slither | `working-directory`, `run-slither` |
| `reusable-js-ci.yml` | npm/pnpm/yarn install + lint + build + test | `working-directory`, `package-manager`, `node-version` |
| `reusable-python-ci.yml` | pip install + ruff + mypy + pytest | `working-directory`, `python-version`, `install-extra` |

### Calling from a repo

Each org repo's `.github/workflows/ci.yml` should be a thin shim:

```yaml
name: CI
on:
  push: { branches: [main] }
  pull_request:

jobs:
  rust:
    if: hashFiles('Cargo.toml') != ''
    uses: citratenetwork/.github/.github/workflows/reusable-rust-ci.yml@main

  js:
    if: hashFiles('package.json') != ''
    uses: citratenetwork/.github/.github/workflows/reusable-js-ci.yml@main
```

### Release notifications

No Discord webhook is wired in (per Saul, 2026-05-17 split decisions). To add one later, augment the reusable workflows with a `secrets:` block + `${{ secrets.DISCORD_WEBHOOK }}` step.

### Versioning

Reusable workflows pin to `@main` by default. For tagged stability, repos can pin to a SHA or a release tag:

```yaml
uses: citratenetwork/.github/.github/workflows/reusable-rust-ci.yml@v1
```

When breaking-change updates are made, cut a new tag here so consumer repos can pin against it.

---

© 2026 Mozi Cooperative. All rights reserved. Citrate, Citrate OpenWallet, SALT, and Mozi Cooperative are trademarks of Mozi Cooperative.
