# Conventions

Applies to all Terraform modules derived from this template.

## File organization

Split resources by concern. Each file has a single-line comment header
describing its purpose.

| File               | Contents                                                                   |
|--------------------|----------------------------------------------------------------------------|
| `versions.tf`      | Terraform + provider version constraints. No provider blocks.              |
| `variables.tf`     | All input variables, grouped by section (see below).                       |
| `locals.tf`        | Computed names, merged tags, derived flags.                                |
| `main.tf`          | Primary resource(s) that give the module its name.                         |
| `network.tf`       | VNet, subnet, private endpoint, private DNS records, NSG.                  |
| `security.tf`      | RBAC role assignments (module-managed only), identities, encryption keys.  |
| `observability.tf` | Diagnostic settings, metric alerts, action groups.                         |
| `outputs.tf`       | Exposed values.                                                            |

Do not create additional `.tf` files without adding them to `.ai/CONVENTIONS.md`.

## Variable sections

Order in `variables.tf`:

1. **General** — `name`, `location`, `resource_group_name`, `tags`
2. **Configuration** — module-specific behavior toggles (e.g. `sku_name`, `enable_ha`)
3. **Network** — VNet/subnet IDs, private endpoint config, private DNS zone IDs
4. **Security** — RBAC assignments, identities, encryption keys, network ACLs
5. **Observability** — Log Analytics workspace ID, retention days, categories

Separate sections with a comment header:

```hcl
###############################################################################
# Network
###############################################################################
```

## Variable format

Every variable MUST have:

- `description` — imperative sentence, ends with a period, mentions default
  behavior when non-obvious
- explicit `type` — no `any` unless justified in a comment
- `default` — only when a sensible-and-secure value exists
- `validation` block — for string enums, integer ranges, CIDR blocks,
  or any constrained input
- `sensitive = true` — for secrets, connection strings, encryption keys
- `nullable = false` — when `null` is not a meaningful value

Description style:

- ✅ `"Name of the Key Vault. Must be globally unique and 3-24 characters."`
- ❌ `"key vault name"`
- ❌ `"The name of the Key Vault"`  (missing period, not imperative-friendly)

## Naming convention

Terraform resource labels (the string after the resource type in HCL):

- Use lowercase and underscores
- Use `this` when there is exactly one instance of the resource in the module
  (idiomatic in HashiCorp modules)
- Use a descriptive suffix when multiple instances of the same resource type
  exist (e.g. `azurerm_role_assignment.reader`, `azurerm_role_assignment.admin`)

Azure resource names (the actual name provisioned in Azure) are computed in
`locals.tf` following this pattern:
    <prefix>-<workload>-<env>-<region_short>-<resource_type_short>-<instance>
Where:

- `prefix` — organizational prefix passed via variable (e.g. `sky`, `sol`)
- `workload` — application or platform name (e.g. `payments`, `platform`)
- `env` — `dev`, `tst`, `stg`, `prd`
- `region_short` — 3-letter Azure region code (`frc` for francecentral,
  `weu` for westeurope, `nue` for northeurope)
- `resource_type_short` — CAF abbreviation (`kv` for Key Vault, `psql` for
  PostgreSQL Flexible, `aks` for AKS cluster, `ca` for Container App,
  `pe` for Private Endpoint)
- `instance` — 2-digit instance number (`01`, `02`) when multiple instances
  are expected

Follow [Microsoft CAF abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
for resource type shorts. When CAF has no abbreviation, document the choice
in this file.

Exceptions to the pattern (documented in the module's ADR):

- Storage accounts: no hyphens allowed → `<prefix><workload><env><region_short>st<instance>`
- Key Vault: dot notation not allowed, 3-24 chars → shorten aggressively if needed

## Tagging convention

Every taggable resource MUST use the `merge()` pattern from
`.ai/snippets/tags-merge.tf`.

Module-managed tags (always applied):

- `managed_by = "terraform"` — signals ownership
- `module_source = "<repo URL>"` — traceability to source
- `module_version = "<version>"` — traceability to version (populated from
  a `module_version` local set to the current release)

User-supplied tags (from the `tags` variable) are merged on top and can
override module-managed tags only for `module_source` and `module_version`
in exceptional cases (e.g. testing a local checkout).

Never hardcode business tags (`cost_center`, `owner`, `environment`) in
the module — those belong to the consumer.

## Provider configuration

Modules NEVER contain `provider "azurerm" {}` blocks. This is a hard rule.

Examples DO configure providers in `examples/*/providers.tf`:

```hcl
provider "azurerm" {
  features {}
}
```

## Outputs

- Expose resource `id` and `name` at minimum for every top-level resource
- Expose full resource objects only when the consumer clearly needs multiple
  attributes (e.g. `key_vault` output containing id, name, vault_uri)
- Mark `sensitive = true` for any output carrying a secret or connection string
- Prefer stable identifiers (resource IDs) over computed values

## Data sources

- Prefer accepting an ID via a variable over using a `data` source to look
  up a resource by name — this avoids ambient authority and makes the module
  more portable across subscriptions
- `data "azurerm_client_config" "current"` is acceptable when the module
  needs to reference the current tenant ID for a resource that requires it
  (e.g. Key Vault `tenant_id`)

## Loops

- Prefer `for_each` (map or set) over `count` — predictable addressing,
  additions and removals don't cascade-recreate
- Use `count` only for feature flags: `count = var.enable_foo ? 1 : 0`

## Timeouts

Add explicit `timeouts` blocks for resources known to be slow:

- Key Vault: 30 min create/update, 30 min delete (soft delete)
- PostgreSQL Flexible: 60 min create/update
- AKS: 90 min create, 60 min update, 60 min delete
- Private endpoint: 20 min

## Diagnostic settings

Every resource that supports diagnostic settings MUST have them wired,
gated by a variable `diagnostic_settings_enabled` (default `true`).

Use the pattern from `.ai/snippets/diagnostic-settings.tf`.

Default categories: all supported log categories + `AllMetrics`.
Categories can be overridden via a variable.

## Documentation markers

Every module's `README.md` contains:

```markdown
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

`terraform-docs` regenerates the content between markers. Never edit
the generated content manually.

## Changelog entries

Entries under `[Unreleased]` are user-facing sentences, not commit messages.

- ✅ `Added: New input variable subnet_id to attach the private endpoint to a specific subnet.`
- ❌ `feat(pe): add subnet_id var`
- ❌ `Refactor.`

Six categories, in this order: Added, Changed, Deprecated, Removed, Fixed, Security.
