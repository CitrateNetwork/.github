# Citrate Network — `.github`

> Org-defaults repo for the [Citrate Network](https://github.com/CitrateNetwork) federation.
> It carries the org-level defaults every repo inherits, the reusable CI workflows, and a
> walkthrough for standing up a Citrate network from the **public** repositories.
>
> **Public developers start here:**
>
> ```bash
> gh repo clone CitrateNetwork/.github && bash .github/setup.sh
> ```
>
> `setup.sh` clones every public CitrateNetwork repo into one `citrate-labs/` workspace on
> disk (it only ever touches public repos). See [§ Clone the public repos](#clone-the-public-repos).
>
> What's *only* in this repo:
> - `profile/README.md` — the landing page rendered on https://github.com/citratenetwork
> - `.github/workflows/reusable-*.yml` — reusable CI workflows available for every org repo to call
> - `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `AUDIT_POSTURE.md`, `AGENTS.md`, `dependabot.yml` — org defaults
>
> See [§ Org-level CI infrastructure](#org-level-ci-infrastructure) at the bottom for the CI details.

---

## Federation walkthrough

The Citrate Network is an AI-native Layer-1 BlockDAG using **GhostDAG consensus**, with
an EVM-compatible execution environment (LVM) and a standardized Model Context Protocol
(MCP) layer. It runs on **chain 40204** (hex `0x9d0c`); mainnet target is **Q2 2027**.

This walkthrough covers:

1. [How the federation fits together](#how-the-federation-fits-together)
2. [Public repository set](#public-repository-set)
3. [Prerequisites](#prerequisites)
4. [Clone the public repos](#clone-the-public-repos)
5. [Run a private network for testing](#run-a-private-network-for-testing)
6. [Connect to the public network](#connect-to-the-public-network)
7. [Using individual repositories](#using-individual-repositories)
8. [Working in the Agentile methodology](#working-in-the-agentile-methodology)
9. [Federation sync](#federation-sync)
10. [Licensing and IP](#licensing-and-ip)
11. [Document index](#document-index)

---

### How the federation fits together

The Citrate codebase is a **federation** of independent git repositories under the
[`CitrateNetwork`](https://github.com/CitrateNetwork) GitHub organization, each with its
own release cadence and audit tier. There is no single monorepo; the code you build and
audit lives in the individual public repos listed below.

Two coordinating pieces are **private (maintainers only)** and are not browsable or
required to build from the public set:

- `citrate-labs` — the maintainer meta-repo that brackets every repo into one tree on
  disk and holds the umbrella IP/license documents *(private; maintainers only)*.
- `citrate-federation` — the control plane that pins per-repo SHAs and hosts the
  Agentile control files *(private; maintainers only)*.

Public developers never need either: `setup.sh` reproduces the same on-disk layout using
only the public repos.

### Public repository set

The public launch set is **23 repos** plus the methodology tooling (`agentile`,
`agentile-skills`) and this `.github` repo. The authoritative, always-current index —
grouped by license tier — is [`profile/README.md`](profile/README.md) (rendered at
https://github.com/citratenetwork). Summary:

**Infrastructure — Apache-2.0 (open source)**
`citrate-chain`, `citrate-fed-types`, `citrate-node-agent`, `citrate-bundler`, `nat`,
`citrate-coop`, `citrate-agent-runtime`, `citrate-sdk-js`, `citrate-sdk-python`,
`citrate-sdk-marketplace`, `citrate-docs`, `citrate-explorer`.

**Application layer / commercial core — BUSL-1.1 (source-available, converts to Apache-2.0)**
`citrate-inference-gateway`, `citrate-compute-pool`, `citrate-cluster`, `citrate-core`,
`citrate-comms`, `citrate-quorum`, `citrate-identity`, `citrate-memories`,
`citrate-native`, `nist-agent`, `citrate-studio`.

**Methodology + org tooling**
`agentile`, `agentile-skills`, `.github`.

> A small set of **client, enterprise (Homestead), security, and internal** repositories
> stays private and is intentionally not listed here.

### Prerequisites

A working setup needs:

| Tool | Version | Used by |
|---|---|---|
| **Git** | ≥ 2.40 | everything |
| **GitHub CLI (`gh`)** | latest, authenticated | `setup.sh` bootstrap |
| **Rust toolchain** | stable (`rustup default stable`) | `citrate-chain`, native apps, gateway, compute-pool, runtime |
| **Foundry** | latest | Solidity contracts in `citrate-chain`, `citrate-coop` |
| **Node.js** | ≥ 20 LTS | `citrate-sdk-js`, web apps |
| **pnpm** | ≥ 8 | web apps (the SDKs use npm) |
| **Python** | ≥ 3.11 | `citrate-sdk-python` |
| **Slint deps** | `libfontconfig1-dev libxkbcommon-dev libwayland-dev` (Linux) | `citrate-native` |
| **clang / cmake / pkg-config / libssl-dev** | distro defaults | Rust C-binding deps |

Quick install (Debian/Ubuntu):

```bash
sudo apt-get install -y build-essential pkg-config libssl-dev libclang-dev cmake \
                        libfontconfig1-dev libxkbcommon-dev libwayland-dev git
# GH-B-010: these are the upstream projects' own documented installers, which
# the org does not verify. At minimum force HTTPS + TLS 1.2 (as rustup does) so a
# protocol-downgrade or plaintext-redirect cannot feed a substituted script into
# your shell. For a hardened setup, download to a file, verify the published
# checksum/signature, then run — foundryup and fnm both publish release checksums.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl --proto '=https' --tlsv1.2 -L https://foundry.paradigm.xyz | bash && foundryup
curl --proto '=https' --tlsv1.2 -fsSL https://fnm.vercel.app/install | bash && fnm install --lts && fnm use lts
corepack enable pnpm
```

### Clone the public repos

One command clones every public repo into a `citrate-labs/` workspace directory (a local
folder name — not the private meta-repo), matching the maintainer layout so each repo is
its own git root your IDE picks up when you open the folder:

```bash
gh repo clone CitrateNetwork/.github        # get this repo (for setup.sh)
bash .github/setup.sh                        # clone every PUBLIC repo as a sibling
```

Variants:

```bash
bash .github/setup.sh fork      # fork each repo to your account, clone your fork, set `upstream`
NO_STAR=1 bash .github/setup.sh # don't star the repos (starring is on by default)
SHALLOW=1  bash .github/setup.sh # shallow clones (faster; no full history)
```

`setup.sh` enumerates the org's public, non-archived repos live (so new public repos are
picked up automatically) and **never touches private repos**. Requires `gh` authenticated
via `gh auth login`.

> Maintainers use the private `citrate-labs` meta-repo overlay and the
> `citrate-federation` control-plane bootstrap instead *(both private; maintainers only)*.

### Run a private network for testing

The fastest path to a working, fully-private Citrate network is the one-machine
devnet. It runs a single node plus a wallet plus the agent runtime, all bound to
localhost.

#### 1. Build the chain

```bash
cd citrate-chain
cargo build --release --bin citrate-node --bin citrate-cli
```

#### 2. Initialize a fresh chain state

```bash
./target/release/citrate-cli devnet init \
    --chain-id 40204 \
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

- **Desktop wallet** — `cd citrate-native && cargo run --release` and add the
  RPC URL `http://127.0.0.1:8545` under Network → Custom RPC.
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

> **License note.** A private devnet is **Permitted Community Use** under each BUSL
> component's `LICENSE` as long as you stay within its Additional Use Grant
> (non-commercial, non-public). Anything beyond that requires a commercial license from
> Citrate Inc.

### Connect to the public network

#### Network parameters

| Field | Value |
|---|---|
| Network name | Citrate |
| Chain ID | `40204` (hex `0x9d0c`) |
| RPC URL | `https://rpc.citrate.ai` |
| WebSocket | `wss://ws.citrate.ai` |
| Block explorer | `https://explorer.citrate.ai` |
| Faucet | `https://faucet.citrate.ai` |
| Chain spec | `citrate-chain/specs/testnet.toml` |

> Mainnet target is Q2 2027; the current network is chain 40204. Confirm live endpoint
> status in the [docs](https://docs.citrate.ai) before assuming availability.

#### Run a syncing node against the network

```bash
cd citrate-chain
cargo build --release --bin citrate-node
./target/release/citrate-node run \
    --network testnet \
    --datadir ~/.citrate/testnet
```

Bootnodes and chain spec ship inside the `citrate-chain` binary; no manual config
is required.

#### Connect a wallet

For the desktop wallet or any wallet that speaks JSON-RPC:

```
Network name: Citrate
RPC URL:      https://rpc.citrate.ai
Chain ID:     40204
Symbol:       tCTR
Explorer:     https://explorer.citrate.ai
```

Request funds at the faucet (one drip per address per day).

#### Deploy a contract

```bash
cd citrate-chain/contracts
forge build
forge create src/MyContract.sol:MyContract \
    --rpc-url https://rpc.citrate.ai \
    --private-key $CITRATE_DEPLOYER_KEY
```

#### Hit the inference gateway

```bash
curl -s https://infer.citrate.ai/v1/chat/completions \
    -H "Authorization: Bearer $CITRATE_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"model":"citrate-mcp/llama-3.1-8b","messages":[{"role":"user","content":"hello"}]}'
```

See the [docs](https://docs.citrate.ai) for the full endpoint inventory, rate limits, and
the path from the current network to mainnet.

### Using individual repositories

Each public repo is independently buildable and has its own README. Descriptions track
[`profile/README.md`](profile/README.md); run commands below are the common entry point —
see each repo's README for specifics.

**Infrastructure — Apache-2.0**

| Repo | What it builds | Run |
|---|---|---|
| [`citrate-chain`](https://github.com/CitrateNetwork/citrate-chain) | `citrate-node`, `citrate-cli`, contracts | `cargo build --release && ./target/release/citrate-node run` |
| [`citrate-fed-types`](https://github.com/CitrateNetwork/citrate-fed-types) | Shared cross-repo type definitions | used as a library dependency |
| [`citrate-node-agent`](https://github.com/CitrateNetwork/citrate-node-agent) | Node supervision, cost-plus bidding, health | `cargo run --release` |
| [`citrate-bundler`](https://github.com/CitrateNetwork/citrate-bundler) | ERC-4337 bundler for embedded wallets | `cargo run --release` |
| [`nat`](https://github.com/CitrateNetwork/nat) | NAT, the federated neuroarchitectural transformer | `cargo build --release` |
| [`citrate-coop`](https://github.com/CitrateNetwork/citrate-coop) | On-chain cooperative governance contracts | `forge build` |
| [`citrate-agent-runtime`](https://github.com/CitrateNetwork/citrate-agent-runtime) | Capability-scoped agent runtime + capsules | `cargo run --release` |
| [`citrate-sdk-js`](https://github.com/CitrateNetwork/citrate-sdk-js) | `@citratelabs/sdk` | `pnpm install && pnpm build` |
| [`citrate-sdk-python`](https://github.com/CitrateNetwork/citrate-sdk-python) | `citrate-labs-sdk` (PyPI) | `pip install -e .` |
| [`citrate-sdk-marketplace`](https://github.com/CitrateNetwork/citrate-sdk-marketplace) | `@citratelabs/marketplace-sdk` | `pnpm install && pnpm build` |
| [`citrate-docs`](https://github.com/CitrateNetwork/citrate-docs) | The Almanac: docs.citrate.ai | `pnpm install && pnpm dev` |
| [`citrate-explorer`](https://github.com/CitrateNetwork/citrate-explorer) | CitrateScan, the BlockDAG explorer | `pnpm install && pnpm dev` |

**Application layer / commercial core — BUSL-1.1**

| Repo | What it builds | Run |
|---|---|---|
| [`citrate-inference-gateway`](https://github.com/CitrateNetwork/citrate-inference-gateway) | x402-metered inference gateway | `cargo run --release` |
| [`citrate-compute-pool`](https://github.com/CitrateNetwork/citrate-compute-pool) | Coordinator + workers for pooled training | `cargo run --release` |
| [`citrate-cluster`](https://github.com/CitrateNetwork/citrate-cluster) | GPU-fleet and compute-cluster tooling | `cargo run --release` |
| [`citrate-core`](https://github.com/CitrateNetwork/citrate-core) | Desktop app that runs a full node | `cargo run --release` |
| [`citrate-comms`](https://github.com/CitrateNetwork/citrate-comms) | E2E-encrypted, server-blind team workspace | `pnpm install && pnpm dev` |
| [`citrate-quorum`](https://github.com/CitrateNetwork/citrate-quorum) | Human-in-the-loop governance surface for AI | `cargo run --release` |
| [`citrate-identity`](https://github.com/CitrateNetwork/citrate-identity) | OIDC/OAuth2 authority (SIWE, passkeys) | `pnpm install && pnpm dev` |
| [`citrate-memories`](https://github.com/CitrateNetwork/citrate-memories) | Content-addressed knowledge graph for agents | `cargo run --release` |
| [`citrate-native`](https://github.com/CitrateNetwork/citrate-native) | Slint desktop wallet + agent client | `cargo run --release` |
| [`nist-agent`](https://github.com/CitrateNetwork/nist-agent) | NIST-compliant agent harness (sidecar) | `cargo run --release` |
| [`citrate-studio`](https://github.com/CitrateNetwork/citrate-studio) | Native operator control surface | `cargo run --release` |

**SDK quick examples**

TypeScript:

```ts
import { CitrateClient } from "@citratelabs/sdk";

const client = new CitrateClient({ rpcUrl: "https://rpc.citrate.ai" });
const head = await client.chain.head();
console.log("latest DAG tip:", head);
```

Python:

```python
from citrate_sdk import CitrateClient

client = CitrateClient(rpc_url="https://rpc.citrate.ai")
print("latest DAG tip:", client.chain.head())
```

### Working in the Agentile methodology

The federation uses a methodology called **Agentile** — a set of federation-wide rules
plus a sprint-driven workflow that keeps planning, governance, and audit posture
consistent across every repo. Both human contributors and AI agents participate the same
way.

The methodology and its tooling are public:

1. [`agentile`](https://github.com/CitrateNetwork/agentile) — the institutional
   methodology for human-agent software: the rules and the sprint workflow in full.
2. [`agentile-skills`](https://github.com/CitrateNetwork/agentile-skills) — the same
   methodology packaged as an installable Claude Code skills marketplace.
3. [`AGENTS.md`](AGENTS.md) (in this repo) — the org-level agent entry point.

The **benefit** of working inside Agentile: every change — code, doc, audit, plan — is
traceable to a frontmatter-stamped sprint file, and an external auditor can walk in cold
and find the evidence trail without spelunking.

### Federation sync

Cross-repo state is coordinated by maintainers through the private `citrate-federation`
control plane, which pins a canonical SHA per repo and reports drift *(private;
maintainers only)*. Public contributors work per-repo: open a PR against the individual
repo you're changing; there is no public multi-repo push step.

### Licensing and IP

Citrate is **open-core**, and every repository's own `LICENSE` file is authoritative:

- **Apache-2.0 (open source)** — the infrastructure tier: `citrate-chain`, `citrate-fed-types`,
  `citrate-node-agent`, `citrate-bundler`, `nat`, `citrate-coop`, `citrate-agent-runtime`, the SDKs
  (`citrate-sdk-js`, `citrate-sdk-python`, `citrate-sdk-marketplace`), `citrate-docs`, and `citrate-explorer`.
- **BUSL-1.1 (source-available)** — the application-layer / commercial-core tier:
  `citrate-inference-gateway`, `citrate-compute-pool`, `citrate-cluster`, `citrate-core`, `citrate-comms`,
  `citrate-quorum`, `citrate-identity`, `citrate-memories`, `citrate-native`, `nist-agent`, and
  `citrate-studio`. Each converts to **Apache-2.0** on the Change Date stated in its `LICENSE`.
  Production, commercial, hosted, or managed use of a BUSL component before its Change Date requires a
  separate written license from Citrate Inc.

- **Patent claims** covering consensus, precompile, ZK, agent-harness, and
  embedded-node designs are filed, pending, or contemplated.
- **Trademarks** (Citrate, Citrate OpenWallet, SALT) are reserved.
- **Intellectual property is actively defended.**

Licensor and IP holder: **Citrate Inc.** Commercial, production, institutional, and partnership use
inquiries: **Partnerships@Citrate.ai**

### Document index

#### Org defaults (this repo)

| Document | Purpose |
|---|---|
| [`profile/README.md`](profile/README.md) | Org landing page + canonical public repo index |
| [`SECURITY.md`](SECURITY.md) | Org-level security policy + vulnerability reporting |
| [`AUDIT_POSTURE.md`](AUDIT_POSTURE.md) | Audit tiers per repo |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Contribution + CLA flow |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | Community expectations |
| [`AGENTS.md`](AGENTS.md) | Org-level agent entry point |

#### Public docs + methodology

| Resource | Purpose |
|---|---|
| [docs.citrate.ai](https://docs.citrate.ai) | The Almanac — architecture, endpoints, guides |
| [docs.citrate.ai/start/open-source](https://docs.citrate.ai/start/open-source) | Full open-core / licensing policy |
| [`agentile`](https://github.com/CitrateNetwork/agentile) | Methodology: rules + sprint workflow |
| [`agentile-skills`](https://github.com/CitrateNetwork/agentile-skills) | Methodology as installable Claude Code skills |

> The `citrate-labs` meta-repo and `citrate-federation` control plane hold the umbrella IP
> documents and cross-repo SHA pins, but both are **private (maintainers only)** and are
> not linked here.

---

## Org-level CI infrastructure

> This section is **only** in this repo (`CitrateNetwork/.github`) — it documents the
> reusable workflows that every other org repo can call (adoption is opt-in per repo,
> not automatic). The repo also self-checks via `ci.yml` (workflow-guardrails +
> canon-guardrail regression) and `canon-guardrail.yml`.

### Reusable workflows

| Workflow | Purpose | Notable inputs |
|---|---|---|
| `reusable-rust-ci.yml` | cargo fmt, clippy, test, **cargo-audit** | `working-directory`, `apt-packages`, `test-args`, `dep-audit` |
| `reusable-solidity-ci.yml` | forge build + test + **Slither (default on)** | `working-directory`, `run-slither` (default `true`) |
| `reusable-js-ci.yml` | npm/pnpm/yarn install + lint + build + test, **audit** | `working-directory`, `package-manager`, `node-version`, `dep-audit` |
| `reusable-python-ci.yml` | pip install + ruff + mypy + pytest, **pip-audit** | `working-directory`, `python-version`, `install-extra`, `dep-audit` |
| `reusable-canon-guardrail.yml` | retired-claim canon gate (CC-1) | *(none)* |
| `reusable-secret-scan.yml` | blocking gitleaks secret scan | `gitleaks-version`, `gitleaks-sha256` |

The dependency-CVE gate (`dep-audit`, on by every language pipeline) and the
secret scan (`reusable-secret-scan.yml`) were formerly two standalone files under
a repo-root `workflows/` directory that GitHub never dispatched; they are now
inherited by every caller. Lint / build / test steps are **blocking** — to skip
one, pass an empty script input deliberately, never a hidden `continue-on-error`.

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
    uses: citratenetwork/.github/.github/workflows/reusable-rust-ci.yml@v1   # pin a tag or SHA, not @main

  js:
    if: hashFiles('package.json') != ''
    uses: citratenetwork/.github/.github/workflows/reusable-js-ci.yml@v1   # pin a tag or SHA, not @main
```

### Release notifications

No Discord webhook is wired in (per Saul, 2026-05-17 split decisions). To add one later, augment the reusable workflows with a `secrets:` block + `${{ secrets.DISCORD_WEBHOOK }}` step.

### Versioning

**Pin callers to a release tag or a full commit SHA — never `@main`** (GH-B-003).
`@main` is a mutable branch: a single push to this repo (whose `main` has no
required review) instantly changes what runs in every consuming repo's CI, with
no diff for a caller's reviewer to see. Pin to a tag or SHA so an upgrade is a
reviewable change in the caller:

```yaml
uses: citratenetwork/.github/.github/workflows/reusable-rust-ci.yml@v1   # or @<40-hex-sha>
```

When breaking-change updates are made, cut a new tag here so consumer repos can pin against it.

---

© 2026 Citrate Inc. All rights reserved. Citrate, Citrate OpenWallet, and SALT are trademarks of Citrate Inc.
