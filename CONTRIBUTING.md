# Contributing

Thanks for your interest in improving this module. This document explains
how to propose changes and what quality bar to meet.

## Before you start

- **Small changes** (typos, docs, obvious bug fixes) — open a PR directly.
- **New features or breaking changes** — open an issue first to discuss
  scope. This avoids wasted effort if the change falls outside the module's
  purpose (see `.ai/CONTEXT.md` for scope and non-goals).

## Development setup

You need:

- Terraform `>= 1.6.0`
- Go `>= 1.23` (for Terratest)
- [`tflint`](https://github.com/terraform-linters/tflint) with the azurerm ruleset
- [`tfsec`](https://github.com/aquasecurity/tfsec)
- [`checkov`](https://github.com/bridgecrewio/checkov)
- [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) `>= 0.19`
- An Azure subscription (required only for Terratest)

Clone and prepare:

```bash
git clone https://github.com/MAnouerB/terraform-azurerm-module-template.git
cd terraform-azurerm-module-template
terraform init -backend=false
```

## Making a change

1. Create a branch from `main` — name it `feat/<short-name>`,
   `fix/<short-name>`, or `docs/<short-name>`.
2. Make the change. Keep the PR focused: one concern per PR.
3. Run the local checks (see below) before pushing.
4. Update `CHANGELOG.md` under `[Unreleased]` with a user-facing entry
   in the correct category (Added, Changed, Deprecated, Removed, Fixed,
   Security).
5. If you touched variables, outputs, or resources, regenerate the
   README section:
```bash
   terraform-docs markdown table --output-file README.md --output-mode inject .
```
6. Open a PR against `main`. Fill in the PR template.

## Local checks

Run these before pushing. CI runs the same checks.

```bash
# Format
terraform fmt -recursive -diff

# Validate module and examples
terraform init -backend=false && terraform validate
for e in examples/*/; do (cd "$e" && terraform init -backend=false && terraform validate); done

# Lint
tflint --init
tflint --recursive

# Security
tfsec .
checkov -d . --framework terraform

# Docs drift
terraform-docs markdown table --output-check --output-file README.md --output-mode inject .
```

## Running Terratest

Terratest deploys real Azure resources. See `docs/OIDC-SETUP.md` for the
one-time Azure setup. Once done:

```bash
cd test
go mod download
export ARM_USE_OIDC=true          # or use ARM_CLIENT_SECRET locally (discouraged)
export ARM_SUBSCRIPTION_ID=<...>
export ARM_TENANT_ID=<...>
export ARM_CLIENT_ID=<...>
go test -v -timeout 90m ./...
```

Terratest destroys the resources it created. If a test is interrupted,
check the Azure portal for orphaned resource groups tagged
`managed_by = terraform` and `terratest = true`, and delete them.

## SemVer discipline

While the module is at `0.x.y`, any release may include breaking changes,
but we still classify them properly in the CHANGELOG so downstream
consumers can decide when to upgrade.

- **patch** — bug fix, doc fix, internal refactor without behavior change
- **minor** — new input, new output, new resource; existing users unaffected
- **major** — removed or renamed input/output, changed default with security
  or cost impact, changed variable type

If your change is a breaking change, say so explicitly in the PR
description and in the CHANGELOG entry.

## Working with the AI-assisted layer

This repository is designed to be productive with AI coding assistants
(Claude Code specifically). If you use one:

- Read `CLAUDE.md` and the files in `.ai/` before prompting
- Prefer the slash commands in `.claude/commands/` over freestyle prompts
- The conventions in `.ai/CONVENTIONS.md` are enforced in CI — the
  assistant should not propose changes that violate them

Contributions to `.ai/` (new snippets, better examples, refined
conventions) are welcome — they help every future contributor, human
or AI.

## Code review

Reviewers look for:

- Fit with the module's scope (`.ai/CONTEXT.md`)
- Consistency with existing patterns (`.ai/CONVENTIONS.md` and `.ai/snippets/`)
- Test coverage proportional to the change
- No degraded security defaults
- Clear CHANGELOG entry in the right category

Expect direct feedback. Reviewers are peers, not gatekeepers — pushback
is a normal part of the process and always about the change, not the person.

## Code of conduct

Participation in this project is governed by the
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under
the [Apache License 2.0](LICENSE).