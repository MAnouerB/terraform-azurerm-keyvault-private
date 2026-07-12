---
description: Create a new example under examples/
argument-hint: <example-name:basic|complete|with-cmk|with-ha|...>
---

Create a new example folder `examples/$1/` demonstrating a specific usage
pattern of this module.

## Steps

1. Read the existing `examples/basic/` and `examples/complete/` to understand
   the current scope
2. Create `examples/$1/` with:
   - `main.tf` — module call + minimal supporting resources
     (resource group, VNet, subnet if needed)
   - `variables.tf` — inputs required to run this example
     (region, name prefix)
   - `outputs.tf` — expose the module's outputs for inspection
   - `versions.tf` — Terraform + provider constraints matching the root
   - `providers.tf` — `provider "azurerm" { features {} }` block
     (examples DO configure providers, unlike the module)
   - `terraform.tfvars.example` — commented example values
   - `README.md` — what this example demonstrates, how to run it,
     estimated cost, cleanup instructions
3. The example MUST be runnable end-to-end with `terraform apply` after
   `terraform init` and `terraform.tfvars` is filled
4. Use SKUs and sizes optimized for cost — this is a demo, not production
5. Update the root `README.md` "Examples" section to list this new example
6. Add a `CHANGELOG.md` entry under `[Unreleased] / ### Added`
7. Show me the diff before writing

## Constraints

- Never hardcode a subscription ID
- Region default should be `francecentral` (aligned with module CONVENTIONS)
- Example must destroy cleanly (`terraform destroy` succeeds without manual cleanup)
- No secrets in `terraform.tfvars.example` — use placeholders
- SKUs and sizes should reflect realistic production usage. The `basic`
  example may use entry-level SKUs where they exist in real prod
  (e.g. single-zone deployments for dev/test workloads), but the `complete`
  example MUST demonstrate the module's production-grade capabilities
  (HA, zone-redundancy, private endpoints, diagnostic settings all wired)
- If the example provisions premium resources, mention it in the example's
  README under a "Cost order of magnitude" section (informational)
