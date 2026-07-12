###############################################################################
# Snippet: Variable validation patterns
#
# Purpose: canonical validation blocks for common input types.
# Copy-adapt to variables.tf; do not import as a file.
###############################################################################

# String enum
variable "sku_name" {
  description = "SKU of the resource. Must be one of: standard, premium."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be one of: standard, premium."
  }
}

# Integer range
variable "retention_days" {
  description = "Retention in days for diagnostic logs. Range: 7-730."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_days >= 7 && var.retention_days <= 730
    error_message = "retention_days must be between 7 and 730."
  }
}

# CIDR block
variable "allowed_cidr" {
  description = "CIDR block allowed to access the resource. IPv4 only."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_cidr, 0))
    error_message = "allowed_cidr must be a valid IPv4 CIDR notation."
  }
}

# Non-empty string
variable "resource_group_name" {
  description = "Name of the resource group where resources will be created."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

# Map with typed values (map(string) with structured content)
variable "tags" {
  description = "Tags applied to all resources managed by this module. Merged with module-managed tags."
  type        = map(string)
  default     = {}
}

# Object with required + optional attributes
variable "network_acls" {
  description = "Network ACLs configuration. Set to null to disable network restrictions."
  type = object({
    default_action = string
    bypass         = optional(string, "AzureServices")
    ip_rules       = optional(list(string), [])
    subnet_ids     = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.network_acls == null || contains(
      ["Allow", "Deny"],
      try(var.network_acls.default_action, "")
    )
    error_message = "network_acls.default_action must be Allow or Deny."
  }
}

# List of objects with for_each pattern
variable "role_assignments" {
  description = "RBAC role assignments granted on the resource. Keyed by a stable identifier."
  type = map(object({
    principal_id         = string
    role_definition_name = string
    condition            = optional(string)
  }))
  default  = {}
  nullable = false
}
