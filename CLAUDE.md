# Claude Code Guide — terraform-azurerm-keyvault-private

## What this repo is

Production-grade Terraform module that provisions an Azure Key Vault with
private endpoint, RBAC-only authorization, and diagnostic settings wired
to Log Analytics. Consumed by platform and application teams.

## Read before acting

Before proposing any change, read these files in order:

1. `.ai/CONTEXT.md` — module purpose, scope, non-goals
2. `.ai/ARCHITECTURE.md` — Architecture Decision Records (RBAC-only, PE-mandatory in complete example, purge protection irreversible, etc.)
3. `.ai/CONVENTIONS.md` — code style, naming, tags
4. `.ai/examples-of-good/` — canonical variable/resource/output style
5. `.ai/snippets/` — reusable patterns (tags, PE, diagnostics, validations)

Do not reinvent patterns that exist in `.ai/snippets/`. Copy and adapt them.

## Never

- Add `azurerm_key_vault_access_policy` — this module is RBAC-only (see ADR-001)
- Set `enable_rbac_authorization` as a variable — it is hardcoded to `true`
- Expose a variable to disable `purge_protection_enabled` — it is `true`, hardcoded (see ADR-003)
- Set `soft_delete_retention_days` below 7 or above 90
- Provision `azurerm_key_vault_secret`, `azurerm_key_vault_key`, or `azurerm_key_vault_certificate` — the module is the container, consumers manage contents (see ADR-005)
- Use `data.azurerm_client_config` to derive `tenant_id` — accept it as a variable for multi-tenant portability (see ADR-004)
- Configure providers inside the module (`provider "azurerm" {}` belongs to the consumer)
- Hardcode SKU, region, subscription ID, tenant ID, or tag values
- Use `count` when `for_each` fits
- Skip diagnostic settings when `diagnostic_settings_enabled = true`
- Introduce a breaking change without documenting it under `### Changed` or `### Removed` in CHANGELOG

## Always

- Default `public_network_access_enabled = false`
- Default `network_acls.default_action = "Deny"`, `bypass = "AzureServices"`
- Default `soft_delete_retention_days = 90` (maximum)
- Default `sku_name = "standard"` (Premium only when HSM-backed keys are required)
- Merge user-supplied `tags` with module-managed metadata via `.ai/snippets/tags-merge.tf`
- Add `for_each` on role assignments (see `.ai/examples-of-good/good-resource.tf`)
- Wire diagnostic settings via `.ai/snippets/diagnostic-settings.tf` when enabled
- Add a CHANGELOG entry under `[Unreleased]` for any user-facing change
- Regenerate the README section between `<!-- BEGIN_TF_DOCS -->` markers
- Add or update Terratest assertions when adding a new output or behavior
- Use azurerm v4 attribute names — the provider renamed several attributes from enable_X to X_enabled between v3 and v4. Check the provider docs when in doubt.
- When adding resources, prefer azurerm v4 attribute names. Known renames: enable_X → X_enabled (booleans), metric → enabled_metric (on diagnostic settings). Check terraform validate output for other deprecations.

## Common commands

```bash
terraform fmt -recursive
terraform-docs markdown table --output-file README.md --output-mode inject .
tflint --recursive
tfsec .
cd test && go test -v -timeout 60m
```

## Repo layout

- `main.tf` — the Key Vault resource itself
- `network.tf` — private endpoint + private DNS A record
- `security.tf` — RBAC role assignments (for_each on `var.role_assignments`)
- `observability.tf` — diagnostic settings
- `variables.tf`, `outputs.tf`, `versions.tf`, `locals.tf` — standard
- `examples/basic/` — dev/test usage, public network (with warning)
- `examples/complete/` — production-representative: private only, HA, diagnostics, RBAC
- `test/` — Terratest cases

## Task-specific workflows

- `/tf-add-variable` — add a new input variable
- `/tf-add-resource` — add a new Azure resource
- `/tf-write-example` — create a new example
- `/tf-write-terratest` — add a Terratest case
- `/tf-review-pr` — self-review before push
- `/tf-update-docs` — regenerate README + CHANGELOG
- `/tf-release` — cut a new SemVer release

## Version stance

SemVer. While at `0.x.y`, any release may include breaking changes.
Consumers should pin: `source = "github.com/MAnouerB/terraform-azurerm-keyvault-private?ref=v0.1.0"`.

CMK (Customer-Managed Keys) is out of scope for `v0.1.0` — planned for `v0.2.0`.