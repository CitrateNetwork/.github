# citratenetwork/.github

Org-level GitHub configuration for the Citrate Network. Contains:

- **`profile/README.md`** — landing page rendered on https://github.com/citratenetwork
- **`.github/workflows/reusable-*.yml`** — reusable CI workflows consumed by every repo in the org

## Reusable workflows

| Workflow | Purpose | Notable inputs |
|---|---|---|
| `reusable-rust-ci.yml` | cargo fmt, clippy, test | `working-directory`, `apt-packages`, `test-args` |
| `reusable-solidity-ci.yml` | forge build + test, optional Slither | `working-directory`, `run-slither` |
| `reusable-js-ci.yml` | npm/pnpm/yarn install + lint + build + test | `working-directory`, `package-manager`, `node-version` |
| `reusable-python-ci.yml` | pip install + ruff + mypy + pytest | `working-directory`, `python-version`, `install-extra` |

## Calling from a repo

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

## Release notifications

No Discord webhook is wired in (per Saul, 2026-05-17 split decisions). To add one later, augment the reusable workflows with a `secrets:` block + `${{ secrets.DISCORD_WEBHOOK }}` step.

## Versioning

Reusable workflows pin to `@main` by default. For tagged stability, repos can pin to a SHA or a release tag:

```yaml
uses: citratenetwork/.github/.github/workflows/reusable-rust-ci.yml@v1
```

When breaking-change updates are made, cut a new tag here so consumer repos can pin against it.
