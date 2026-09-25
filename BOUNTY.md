# Citrate Bug Bounty (draft)

> **Status: DRAFT, not in force.** This document is not policy yet: the safe-harbor text needs counsel
> review, and reward amounts, the launch date and the PGP key are owner decisions, all marked
> `OWNER TO FILL` below. Until this banner is removed, report through the [security policy](SECURITY.md)
> as usual.

This program covers the public repositories of the [`CitrateNetwork`](https://github.com/CitrateNetwork)
organization and the public Citrate testnet (chain id 40204). It extends [`SECURITY.md`](SECURITY.md),
which sets the reporting channels, response times and the 90-day coordinated-disclosure window.

## How to report

1. Use **GitHub private vulnerability reporting** on the affected repository (Security tab, "Report a
   vulnerability"). This is the preferred channel.
2. Or email **security@citrate.ai**. A PGP key is not published yet (`OWNER TO FILL`); until it is, use
   private vulnerability reporting for anything sensitive.
3. Include the repository and commit SHA (or release tag), the affected host if any, a reproducible
   proof of concept, and your severity assessment.

One issue per report. If a report chains several issues, say which link is new.

## Ground rules

- **Testnet only.** Chain 40204 is a public testnet. SALT has no cash value until mainnet (targeted Q2
  2027). Nothing in this program pays out in SALT, and a finding does not "steal funds" in a
  cash sense on testnet; we grade it by what the same flaw would do on mainnet.
- **Your own accounts only.** Use accounts and keys you create. Get test SALT from the public faucet.
  Do not access, modify or move anything belonging to another account, member or tenant beyond the
  minimum needed to show the issue, and stop as soon as you have shown it.
- **No personal data.** If you reach another person's data (identity evidence, messages, memories,
  CRM records), stop, do not copy it, and report immediately.
- **Show, do not exploit.** Prove impact with the smallest possible demonstration: one transaction,
  one request, one block. Do not halt the network, fork it, or leave it in a degraded state on purpose.
  For consensus or liveness issues, a local multi-node reproduction is preferred to a live one.
- **Load limits on shared hosts.** `rpc.citrate.ai`, `bundler.citrate.ai`, `faucet.citrate.ai`,
  `coordinator.citrate.ai`, `explorer.citrate.ai`, `docs.citrate.ai`, `membership.citrate.ai` and
  `auth.citrate.ai` are shared by everyone. Stay under **5 requests per second** and **10,000
  requests per day** per host, never run volumetric or amplification tests against them, and
  demonstrate denial-of-service findings against a local build instead. `OWNER TO FILL`: confirm or
  change these limits.
- **No social engineering, phishing or physical attacks**, and no attacks on third-party services
  (GitHub, Vercel, npm, PyPI, DNS providers) or on other users.
- **Keep it private** until the issue is fixed and disclosed under the coordinated-disclosure window.

## Safe harbor

If you follow these rules in good faith, we will treat your research as authorized, we will not
pursue or support legal action against you for it, and we will not ask a third party to do so. If a
third party brings an action against you for research done under this program, we will make it known
that you acted with our authorization. If you are unsure whether something is allowed, ask at
security@citrate.ai before you do it. `OWNER TO FILL`: counsel to confirm this wording.

## In scope

| Asset | What we want |
|---|---|
| `citrate-chain`: node, consensus, sequencer and mempool, execution (EVM, LVM, precompiles), storage, P2P, JSON-RPC and MCP API | Consensus safety and liveness, remote node crash or halt, state or balance corruption, signature or replay bypass, RPC auth bypass |
| `citrate-chain/contracts`: contracts **with code** on chain 40204 (see the [address page](https://docs.citrate.ai/chain/addresses)) | Unauthorized transfer, mint or burn, governance or role bypass, stuck funds, broken accounting |
| Account abstraction (Keyring) stack and `citrate-bundler` | Unauthorized user operations, sponsorship abuse, signature bypass |
| `citrate-identity` (OIDC, VERI) | Authentication or authorization bypass, token forgery, access to another person's verification data |
| `citrate-sdk-js`, `citrate-sdk-python` | Key or secret disclosure, signing the wrong thing, chain-id or replay mistakes |
| `citrate-core` (desktop full node), `citrate-agent-runtime`, `nist-agent`, `citrate-quorum` | Key extraction, sandbox or capability escape, HIC approval bypass |
| `citrate-compute-pool` (coordinator and worker), `citrate-inference-gateway` free routes | Escrow or payout theft, job hijack, coordinator auth bypass |
| `citrate-comms`, `citrate-memories` | Cross-tenant or cross-member access, relay confidentiality or integrity breaks |
| `citrate-explorer` | RPC allow-list bypass, stored XSS, auth bypass |
| Public web hosts listed under "Load limits" | Auth bypass, XSS, CSRF with real impact, secret exposure |

Other public first-party repositories are in scope for code findings at the tier set in their
`AUDIT_TIER.md`. Forks of third-party code (for example the `chains` fork) are out of scope.

## Not deployed or not running (out of scope for live impact)

These exist in code or in the design but are not live. A report that they are missing is a duplicate.
A code-level flaw in them is accepted as a low-priority design finding, not a live exploit.

| Surface | Status |
|---|---|
| Checkpoint finality (committee of 100, quorum 67) | Specified, not running. Confirmation is probabilistic (see `verification/claims.json` in citrate-chain) |
| Stake-gated proposer eligibility and a multi-producer validator set | Staged: off by default, enabled when a validator registry is configured. The testnet runs a single block producer operated by Citrate |
| Inference gateway paid routes (x402 and API-key metering) | Not mounted by the gateway binary; not deployed |
| Membership x402 endpoint | Not configured; not deployed |
| SALT bridge | Specified, not deployed |
| The 19 governance and cooperative contracts with no code on 40204 (AnchorRegistry, MeetingRegistry, GovernanceTemplateRegistry, GovernanceProtocolFactory, PolicyBinding, CapabilityGrant, VoteAllowance, Sortition, PatronageLedger, ModelCooperative, FacilitySBTImpl, NetworkSBTImpl, FacilitySBT, NetworkSBT, CitrateCooperativeFactory, CoopDeployer, CoopMembershipSBT, ContributionRewardPool, CoopGovernor) | In the address book, not deployed |
| Zero-knowledge compute tier | Research preview; not a production guarantee |
| TEE compute tier | Inert on 40204: no TEE oracle is registered with `ComputeVerifier` (`teeOracleCount()` is 0) |
| Passkey-only accounts | Not yet available on 40204 |

## Out of scope

- Everything listed in `SECURITY.md` under "Out of scope".
- Findings that need a compromised operator key, a malicious block producer acting alone on testnet
  with no effect beyond what the single-producer topology already implies, or physical access.
- Missing security headers, banner or version disclosure, clickjacking on pages with no sensitive
  action, SPF/DMARC settings, and rate limits on non-sensitive endpoints, unless you show real impact.
- Issues in dependencies that are already public upstream (report them upstream).
- Anything already on the known-issues list below.
- Automated scanner output without a working proof of concept.

## Known issues

Published per finding once fixed. `OWNER TO FILL`.

## Rewards

`OWNER TO FILL`. Severity is graded under the CIT-SEV rubric used by our audits, by the impact the
same flaw would have on mainnet.

| Severity | Examples | Reward |
|---|---|---|
| Critical | Consensus safety break, unauthorized spend from any account, network-wide halt, key disclosure at scale | `OWNER TO FILL` |
| High | Theft or freeze of funds in a deployed contract, auth bypass on identity, cross-tenant data access | `OWNER TO FILL` |
| Medium | Single-node crash, limited griefing, privilege escalation with preconditions | `OWNER TO FILL` |
| Low | Hardening gaps with a concrete but limited impact | `OWNER TO FILL` |
| Documentation | A public claim that does not match the code or the live chain | `OWNER TO FILL` (recognition or swag) |

Payment method, currency, KYC requirements for payout, and the eligibility rules for employees and
contractors are also `OWNER TO FILL`.

## Contact

security@citrate.ai
