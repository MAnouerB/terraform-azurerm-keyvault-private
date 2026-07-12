# Claude Code Guide

> This file is auto-loaded by Claude Code at session start.
> Read it fully before acting on any request in this repository.

## What this repo is

This is a **template** for production-grade Terraform modules targeting Azure.
Modules derived from this template follow HashiCorp module structure, InnerSource
practices, and are designed to be consumed by multiple teams.

When this template is cloned to create a specific module (e.g. `terraform-azurerm-keyvault-private`),
this file MUST be updated with module-specific `Never` / `Always` rules and
architecture references.

## Read before acting

Before proposing any change, read these files in order:

1. `.ai/CONTEXT.md` — module purpose, scope, non-goals, consumers
2. `.ai/ARCHITECTURE.md` — Architecture Decision Records (ADRs)
3. `.ai/CONVENTIONS.md` — code style, naming, tagging, file layout
4. `.ai/examples-of-good/` — canonical examples of good variables, resources, outputs
5. `.ai/snippets/` — reusable patterns (private endpoint, diagnostic settings, tags merge)

Do not reinvent patterns that exist in `.ai/snippets/`. Copy and adapt them.

## Never

- Configure providers inside the module (`provider "azurerm" {}` belongs to the consumer)
- Hardcode SKU, region, subscription ID, tenant ID, or tag values
- Use `count` when `for_each` fits (predictable addressing)
- Expose secrets or connection strings in outputs without `sensitive = true`
- Skip diagnostic settings on a resource that supports them
- Add a variable without a `description` and, for string enums, a `validation` block
- Commit without running `terraform fmt -recursive` and refreshing terraform-docs
- Set defaults that reduce security (`public_network_access_enabled = true`,
  `local_authentication_enabled = true`, `enable_rbac_authorization = false`, etc.)
- Introduce a breaking change without bumping the appropriate SemVer component
  and documenting it under `### Changed` or `### Removed` in CHANGELOG

## Always

- Match the variable format shown in `.ai/examples-of-good/good-variable.tf`
- Merge user-supplied `tags` with module-managed metadata via the pattern in
  `.ai/snippets/tags-merge.tf`
- Follow the naming convention in `.ai/CONVENTIONS.md`
- Add a CHANGELOG entry under `[Unreleased]` for any user-facing change
- Regenerate the README section between `<!-- BEGIN_TF_DOCS -->` and
  `<!-- END_TF_DOCS -->` markers using `terraform-docs`
- Add or update a Terratest assertion when adding a new output or a
  behavior-changing variable
- Prefer sensible, secure, and production-representative defaults.
  This module is intended for production use — do not weaken defaults
  for cost or convenience reasons. Consumers who need lighter configs
  can override explicitly.
- Ask before running `terraform apply` or any command that provisions
  cloud resources. `terraform destroy` at the end of a test cycle is
  expected and does not require confirmation when it targets a
  test-scoped resource group.

## Common commands

```bash
# Format all .tf files recursively
terraform fmt -recursive

# Validate the module and each example
terraform init -backend=false && terraform validate
(cd examples/basic && terraform init -backend=false && terraform validate)
(cd examples/complete && terraform init -backend=false && terraform validate)

# Refresh terraform-docs section in README.md
terraform-docs markdown table --output-file README.md --output-mode inject .

# Lint
tflint --recursive

# Security scan
tfsec .

# Run Terratest (requires Azure credentials via OIDC or env vars)
cd test && go test -v -timeout 45m
```

## Repo layout
