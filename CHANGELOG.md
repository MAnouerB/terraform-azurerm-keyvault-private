# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

While this module is at `0.x.y`, any release may include breaking changes.
Once `1.0.0` is released, breaking changes will only occur on major version bumps.

## [Unreleased]

### Added

- New input variable `location` to set the Azure region the Key Vault is deployed into.
- New input variable `name` to set the base name used to compute the Key Vault's Azure resource name.
- New input variable `log_analytics_workspace_id` to specify the Log Analytics workspace that receives diagnostic logs and metrics.
- New input variable `resource_group_name` to specify the resource group in which the Key Vault is created.
- New input variable `tags` to assign user-defined tags, merged with module-managed metadata.
- New input variable `tenant_id` to set the Entra ID tenant GUID for the Key Vault (passed explicitly per ADR-004).
- New input variable `sku_name` to select the Key Vault SKU (standard or premium; defaults to standard).
- New input variable `soft_delete_retention_days` to set the Key Vault soft-delete retention window (7–90 days; defaults to 90).
- New input variable `public_network_access_enabled` to control public network access to the Key Vault (defaults to false — private-only).
- New input variable `subnet_id_private_endpoint` to specify the subnet the Key Vault private endpoint attaches to.
- New input variable `private_dns_zone_id` to specify the private DNS zone for the Key Vault private endpoint's A record.
- New input variable `network_acls` to configure Key Vault data-plane network rules (defaults to default_action = Deny, bypass = AzureServices).
- New input variable `role_assignments` to grant RBAC roles on the Key Vault (map keyed by stable identifiers; defaults to empty).
- New input variable `diagnostic_settings_enabled` to toggle Key Vault diagnostic settings (defaults to true).
- New input variable `diagnostic_log_categories` to restrict which Key Vault diagnostic log categories are sent to Log Analytics (defaults to null — all supported categories).
- `locals`: computed Key Vault name (`kv-<name>`) and module-managed tags merged with user-supplied tags per the tags-merge convention.
- Azure Key Vault resource with RBAC authorization, purge protection, configurable soft-delete retention, dynamic network ACLs block, and 30-minute create/update/delete timeouts.
- Azure Private Endpoint on the Key Vault with a private DNS zone group registration for `privatelink.vaultcore.azure.net` name resolution.
- RBAC role assignments on the Key Vault via `for_each` on the `role_assignments` input, with ABAC condition support.
- Diagnostic settings streaming Key Vault logs (auto-discovered categories or explicit list) and AllMetrics to a Log Analytics workspace, gated by `diagnostic_settings_enabled` with a plan-time precondition ensuring the workspace ID is set when enabled.
- Five outputs exposing the Key Vault (`id`, `name`, `vault_uri`) and the private endpoint (`id`, private IP).

### Changed

### Deprecated

### Removed

### Fixed

- Use `rbac_authorization_enabled` instead of the deprecated `enable_rbac_authorization` on `azurerm_key_vault` (azurerm v4 rename).
- Use `enabled_metric` instead of the deprecated `metric` block on `azurerm_monitor_diagnostic_setting` (azurerm v4 rename).

### Security
