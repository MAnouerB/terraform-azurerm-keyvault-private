###############################################################################
# Input variables
#
# Organization:
#   1. General         : name, location, resource_group_name, tags
#   2. Configuration   : module-specific behavior toggles
#   3. Network         : VNet, subnet, private endpoint, DNS
#   4. Security        : RBAC, identities, access
#   5. Observability   : diagnostic settings, log analytics
#
# Every variable MUST have:
#   - a description (imperative, ends with a period)
#   - an explicit type
#   - a default when a safe one exists
#   - a validation block for string enums or constrained values
#   - sensitive = true when applicable
#
# See .ai/examples-of-good/good-variable.tf for the canonical format.
###############################################################################

###############################################################################
# General
###############################################################################

variable "name" {
  description = "Base name of the Key Vault. Must be 1-20 characters, must start with a letter, alphanumeric and hyphens only. Combined with prefix, environment, and region suffixes in locals to compute the final Azure resource name, which Key Vault caps at 24 characters."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,19}$", var.name))
    error_message = "name must be 1-20 characters, start with a letter, and contain only alphanumeric characters and hyphens."
  }
}

variable "location" {
  description = "Set the Azure region where the Key Vault is created, as a canonical lowercase region name with no spaces or special characters (e.g. francecentral, westeurope, northeurope). No default — the consumer must specify the region explicitly."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.location))
    error_message = "location must be a non-empty canonical Azure region name in lowercase with letters and digits only, no spaces or special characters (e.g. francecentral, westeurope, northeurope)."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group in which the Key Vault is created. No default — the consumer must provide an existing resource group. Must be 1-90 characters and may not end with a period."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{0,89}[a-zA-Z0-9_()-]$", var.resource_group_name))
    error_message = "resource_group_name must be 1-90 characters, contain only alphanumerics, underscores, parentheses, hyphens, and periods, and may not end with a period."
  }
}

variable "tags" {
  description = "Map of tags to assign to all taggable resources created by the module. Merged on top of module-managed metadata tags (managed_by, module_source, module_version). Defaults to an empty map."
  type        = map(string)
  default     = {}
  nullable    = false
}

###############################################################################
# Configuration
###############################################################################

variable "sku_name" {
  description = "SKU of the Key Vault. Must be one of: standard, premium. Defaults to standard; use premium only when HSM-backed keys are required."
  type        = string
  default     = "standard"
  nullable    = false

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be one of: standard, premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days a deleted Key Vault and its contents remain recoverable before permanent purge becomes possible. Must be between 7 and 90. Defaults to 90 (the maximum) for the strongest recovery window. Note that purge protection is hardcoded to true (see ADR-003), so contents cannot be permanently purged before this window expires."
  type        = number
  default     = 90
  nullable    = false

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "public_network_access_enabled" {
  description = "Whether the Key Vault is reachable from the public internet. Defaults to false for production use — the vault is private-only, reached via its mandatory private endpoint (see ADR-002). Set to true only for break-glass scenarios or the examples/basic dev/test pattern; this exposes the vault's data plane to public network access subject to the network ACLs."
  type        = bool
  default     = false
  nullable    = false
}

###############################################################################
# Network
###############################################################################

variable "subnet_id_private_endpoint" {
  description = "Resource ID of the subnet the Key Vault private endpoint is attached to. Required — the module does not create the subnet (see .ai/CONTEXT.md non-goals); the consumer provides an existing subnet whose VNet is reachable from the workloads and whose private_endpoint_network_policies is set appropriately (Disabled or NetworkSecurityGroupEnabled)."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet_id_private_endpoint))
    error_message = "subnet_id_private_endpoint must be a valid subnet resource ID (/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/.../subnets/...)."
  }
}

variable "private_dns_zone_id" {
  description = "Resource ID of the pre-existing private DNS zone (must be privatelink.vaultcore.azure.net) used to resolve the Key Vault's private endpoint. Required — the module does not create the zone (see .ai/CONTEXT.md non-goals and ADR-002); the consumer provides an existing zone linked to a VNet reachable by their workloads. The module only registers the A record inside the zone via the private endpoint's private_dns_zone_group."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/privateDnsZones/[^/]+$", var.private_dns_zone_id))
    error_message = "private_dns_zone_id must be a valid private DNS zone resource ID (/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/privateDnsZones/...)."
  }
}

###############################################################################
# Security
###############################################################################

variable "network_acls" {
  description = "Network ACL configuration applied to the Key Vault, complementing the private endpoint. Defaults to the most restrictive posture — default_action = Deny and bypass = AzureServices with no IP or subnet allowances, so consumers explicitly whitelist. ip_rules (public IPs or CIDR ranges) and virtual_network_subnet_ids (subnet IDs with service endpoint access) only take effect when public_network_access_enabled = true or traffic is admitted via bypass. See examples/complete for a realistic configuration."
  type = object({
    default_action             = string
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default  = { default_action = "Deny" }
  nullable = false

  validation {
    condition     = contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be one of: Allow, Deny."
  }

  validation {
    condition     = contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be one of: AzureServices, None."
  }
}

variable "tenant_id" {
  description = "Entra ID (Azure AD) tenant GUID that owns the Key Vault. Required — the consumer must pass this explicitly; the module never derives it from data.azurerm_client_config (see ADR-004) to avoid ambient authority and stay multi-tenant portable. Example: 00000000-0000-0000-0000-000000000000."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "tenant_id must be a valid GUID (e.g. 00000000-0000-0000-0000-000000000000)."
  }
}

variable "role_assignments" {
  description = "Map of Entra ID RBAC role assignments granted on the Key Vault, each binding a principal to a role at the vault scope. Keyed by a stable, consumer-chosen identifier (e.g. \"platform-admin\", \"app-team-secrets-reader\") used as the for_each key so additions and removals stay predictable. role_definition_name accepts built-in or custom roles such as \"Key Vault Administrator\", \"Key Vault Secrets User\", or \"Key Vault Reader\". Defaults to an empty map; consumers may omit it and manage RBAC outside the module via their own azurerm_role_assignment resources."
  type = map(object({
    principal_id         = string
    role_definition_name = string
    condition            = optional(string)
    condition_version    = optional(string)
  }))
  default  = {}
  nullable = false
}

###############################################################################
# Observability
###############################################################################

variable "diagnostic_settings_enabled" {
  description = "Whether to wire diagnostic settings streaming the Key Vault's logs and metrics to Log Analytics. Defaults to true for observability-by-default. When true, log_analytics_workspace_id must be provided. When false, no azurerm_monitor_diagnostic_setting resource is created — useful for early bootstrap or sandbox scenarios where a Log Analytics workspace does not exist yet."
  type        = bool
  default     = true
  nullable    = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace to stream diagnostic logs and metrics to. Defaults to null; set this when diagnostic_settings_enabled is true so the module can wire diagnostic settings."
  type        = string
  default     = null

  validation {
    condition = var.log_analytics_workspace_id == null || can(regex(
      "^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$",
      var.log_analytics_workspace_id
    ))
    error_message = "log_analytics_workspace_id must be null or a valid Log Analytics workspace resource ID (/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/...)."
  }
}

variable "diagnostic_log_categories" {
  description = "Explicit list of Key Vault diagnostic log categories to stream to Log Analytics. Defaults to null, which auto-discovers and enables all supported categories at plan time (via data.azurerm_monitor_diagnostic_categories). Provide a list to restrict to specific categories (e.g. [\"AuditEvent\", \"AzurePolicyEvaluationDetails\"]). AllMetrics is always enabled separately regardless of this value. Only takes effect when diagnostic_settings_enabled is true."
  type        = list(string)
  default     = null
}
