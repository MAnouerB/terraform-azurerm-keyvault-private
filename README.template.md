<!--
This file is the starting point for a module's README. When you create
a new module from this template:

1. Copy this file to README.md (overwriting the current one)
2. Replace every <PLACEHOLDER> with real content
3. Delete this HTML comment block
4. Run `terraform-docs markdown table --output-file README.md --output-mode inject .`
   to populate the sections between the BEGIN_TF_DOCS / END_TF_DOCS markers
5. Delete the "Removing this comment block" reminder above
-->

# <module-name>

> <One-sentence description. What resource this module provisions and its main security stance.>
>
> Example: "Provisions an Azure Key Vault with private endpoint, RBAC-only authorization, and diagnostic settings wired to Log Analytics."

[![CI](https://github.com/MAnouerB/<repo-name>/actions/workflows/ci.yml/badge.svg)](https://github.com/MAnouerB/<repo-name>/actions/workflows/ci.yml)
[![Terratest](https://github.com/MAnouerB/<repo-name>/actions/workflows/terratest.yml/badge.svg)](https://github.com/MAnouerB/<repo-name>/actions/workflows/terratest.yml)
[![Release](https://img.shields.io/github/v/release/MAnouerB/<repo-name>?sort=semver)](https://github.com/MAnouerB/<repo-name>/releases)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

## Features

- <Feature 1 — e.g. Private endpoint with Private DNS zone A record>
- <Feature 2 — e.g. RBAC-only authorization; access policies not supported>
- <Feature 3 — e.g. Diagnostic settings wired to a Log Analytics workspace>
- <Feature 4 — e.g. Purge protection and soft delete enabled by default>
- <Feature 5 — e.g. Configurable network ACLs and IP rules for break-glass>

## Usage

Minimal example (see [`examples/basic`](examples/basic) for the runnable version):

```hcl
module "<module-short-name>" {
  source  = "github.com/MAnouerB/<repo-name>?ref=v0.1.0"

  name                = "<name>"
  location            = "francecentral"
  resource_group_name = azurerm_resource_group.example.name

  # <One or two required inputs specific to the module>
  # <e.g. private_endpoint_subnet_id, log_analytics_workspace_id, etc.>

  tags = {
    workload    = "<workload>"
    environment = "dev"
    owner       = "<owner>"
  }
}
```

For a full-featured configuration with all options wired, see
[`examples/complete`](examples/complete).

## Examples

| Example | What it demonstrates |
|---|---|
| [`basic`](examples/basic) | Minimal viable configuration — recommended for first-time users |
| [`complete`](examples/complete) | Production-representative usage with HA, private endpoint, diagnostic settings, and RBAC assignments |
<!-- Add rows as new examples are added. -->

## Design decisions

Key design decisions are recorded as ADRs in
[`.ai/ARCHITECTURE.md`](.ai/ARCHITECTURE.md). Highlights:

- <Reference to ADR-001 — e.g. "RBAC-only authorization (no Access Policies)">
- <Reference to ADR-002 — e.g. "Private endpoint mandatory; public network disabled by default">
- <Reference to ADR-00X — e.g. "Consumer owns the surrounding infrastructure (RG, VNet, DNS zone)">

See [`.ai/CONTEXT.md`](.ai/CONTEXT.md) for the module's scope, non-goals,
and intended consumers.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Testing

Continuous integration runs on every pull request:

- `terraform fmt -check -recursive`
- `terraform validate` on the module and every example
- `tflint --recursive` with the azurerm ruleset
- `tfsec` and `checkov` security scans
- `terraform-docs` drift check
- Infracost cost diff commented on the PR

Terratest deploys real Azure resources against production-representative
configurations. It runs automatically on push to `main` and on PRs
labelled `run-tests`. See [`test/`](test) and
[`docs/OIDC-SETUP.md`](docs/OIDC-SETUP.md) for setup.

## Versioning

This module follows [Semantic Versioning](https://semver.org/). While at
`0.x.y`, any release may include breaking changes — pin to a minor
version:

```hcl
source = "github.com/MAnouerB/<repo-name>?ref=v0.2.0"
```

Once `1.0.0` is released, breaking changes will only occur on major
version bumps. See [`CHANGELOG.md`](CHANGELOG.md) for release history.

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md)
for the development setup, quality bar, and PR process, and
[`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

For security issues, please follow [`SECURITY.md`](SECURITY.md) — do not
open public issues for vulnerabilities.

## AI-assisted maintenance

This repository is designed to work well with AI coding assistants
(Claude Code specifically). The `CLAUDE.md` file at the root and the
`.ai/` folder encode the module's conventions, decisions, and reusable
patterns so that AI contributions respect the module's design without
supervision.

Slash commands in `.claude/commands/` cover common maintenance tasks:
adding a variable, adding a resource, writing an example or a Terratest
case, reviewing a PR, refreshing docs, and cutting a release.

## License

Apache License 2.0 — see [LICENSE](LICENSE).

## Maintainer

Mohamed Anouer Bahloul — [@MAnouerB](https://github.com/MAnouerB)