# Module Context — terraform-azurerm-keyvault-private

## Purpose

Provisions an Azure Key Vault with private endpoint, RBAC-only authorization,
network ACLs, and diagnostic settings. Designed as a drop-in secrets store
for platform and application teams that need Entra ID-based access and no
public network exposure by default.

## Scope

This module manages:

- The Key Vault (`azurerm_key_vault`)
- The Private Endpoint targeting the Key Vault (`azurerm_private_endpoint`)
- The A record in the caller-provided Private DNS Zone
- Diagnostic Settings streaming to a caller-provided Log Analytics Workspace
- RBAC role assignments on the Key Vault, driven by the `role_assignments`
  input variable

## Non-goals

This module does NOT manage:

- The resource group (passed in via `resource_group_name`)
- The VNet or subnet used for the private endpoint (passed in via
  `subnet_id_private_endpoint`)
- The Private DNS Zone itself (passed in via `private_dns_zone_id`) —
  only the A record inside it
- The Log Analytics workspace (passed in via `log_analytics_workspace_id`)
- Secrets, keys, or certificates stored inside the Key Vault — the module
  is the container, not the content. Consumers manage
  `azurerm_key_vault_secret`, `azurerm_key_vault_key`, and
  `azurerm_key_vault_certificate` in their own root modules
- Customer-Managed Key encryption of the Key Vault itself — planned for
  `v0.2.0`
- Purge / recovery of soft-deleted vaults from previous incarnations

Rationale: this module composes with existing platform resources.
Consumers own the surrounding infrastructure and the vault contents.

## Consumers

Intended consumers:

- Platform teams provisioning secrets stores for multiple application teams
- Application teams via a self-service pattern (module called from their
  own root modules or via a higher-level composition)

Consumers are expected to:

- Provide a pre-existing resource group, VNet, subnet, Private DNS Zone
  (`privatelink.vaultcore.azure.net`), and Log Analytics workspace
- Pass their tenant ID explicitly via the `tenant_id` variable
- Manage role assignments via the `role_assignments` map (or supplement
  with their own `azurerm_role_assignment` resources outside the module)
- Manage the vault contents (secrets, keys, certificates) in their own code
- Pin to a minor version (`~> 0.1`) while the module is at `0.x.y`

## Dependencies

Required before calling this module:

- A resource group in the target subscription
- A VNet with a subnet accessible from the caller (private endpoints are
  supported on subnets without `PrivateEndpointNetworkPolicies` if the
  module is called with the `complete` pattern)
- A Private DNS Zone `privatelink.vaultcore.azure.net` linked to the VNet
- A Log Analytics workspace for diagnostic settings (required when
  `diagnostic_settings_enabled = true`, which is the default)
- The caller's Entra ID tenant ID

## Security posture

- Public network access: **disabled by default** (`public_network_access_enabled = false`)
- Authorization: **RBAC only**. Access Policies are not supported by this
  module. Consumers grant `Key Vault Administrator`, `Key Vault Secrets User`,
  etc. via `azurerm_role_assignment` — either through the `role_assignments`
  input or outside the module
- Network ACLs: `default_action = "Deny"` by default, bypass
  `AzureServices` allowed for platform integrations
- Soft delete: **always on** (Azure enforces this since Feb 2025 anyway),
  retention 90 days by default (configurable 7-90)
- Purge protection: **always on**, hardcoded, irreversible once the vault
  exists. This is intentional — see ADR-003
- Diagnostic settings: enabled by default; all supported log categories
  plus `AllMetrics` are streamed to the caller-provided workspace

## Versioning policy

Semantic Versioning. While at `0.x.y`, any release may include breaking
changes. Consumers should pin to a minor version:

```hcl
source = "github.com/MAnouerB/terraform-azurerm-keyvault-private?ref=v0.1.0"
```

Once `1.0.0` is released, breaking changes will only occur on major
version bumps.

Planned for `v0.2.0`:

- Customer-Managed Key encryption of the vault
- Optional module-managed Private DNS Zone (opt-in for consumers without
  a pre-existing hub DNS)

## Glossary

- **PE**: Private Endpoint — Azure resource that provides a private IP
  for a PaaS service (here, the Key Vault) inside a VNet
- **Private DNS Zone**: Azure DNS zone linked to a VNet, resolving PaaS
  service FQDNs to their private IPs. For Key Vault:
  `privatelink.vaultcore.azure.net`
- **RBAC**: Role-Based Access Control via Entra ID role assignments
- **Diagnostic Settings**: Azure feature that streams platform logs and
  metrics to a destination (Log Analytics, Storage, Event Hub)
- **Purge protection**: Key Vault feature preventing permanent deletion
  before the soft-delete retention window expires
- **CMK**: Customer-Managed Key — encryption of the vault itself with a
  key controlled by the customer (as opposed to Microsoft-managed keys)