###############################################################################
# Canonical variable examples
#
# These are annotated references. Do not copy this file into a module —
# use it as a style reference when writing variables.tf.
###############################################################################

# ✅ GOOD — required, no default, non-empty validation
variable "name" {
  description = "Base name of the resource. Combined with prefix and suffix in locals to compute the actual Azure resource name."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

# ✅ GOOD — secure default, description mentions the default behavior
variable "public_network_access_enabled" {
  description = "Whether the resource is reachable from the public internet. Defaults to false — enable only for break-glass scenarios and prefer private endpoint access."
  type        = bool
  default     = false
}

# ✅ GOOD — string enum with validation and clear error
variable "sku_name" {
  description = "SKU of the resource. Must be one of: standard, premium. Premium is required for HSM-backed keys."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be one of: standard, premium."
  }
}

# ✅ GOOD — sensitive secret, no default
variable "administrator_password" {
  description = "Password for the administrator account. Rotate via Key Vault reference in production."
  type        = string
  sensitive   = true
  nullable    = false
}

# ✅ GOOD — object with optional attributes and typed defaults
variable "backup" {
  description = "Backup configuration. Set retention and geo-redundancy per environment requirements."
  type = object({
    retention_days   = optional(number, 30)
    geo_redundant    = optional(bool, true)
  })
  default = {}

  validation {
    condition     = var.backup.retention_days >= 7 && var.backup.retention_days <= 35
    error_message = "backup.retention_days must be between 7 and 35."
  }
}

###############################################################################
# ❌ ANTI-PATTERNS — do not do this
###############################################################################

# ❌ BAD — no description
# variable "name" {
#   type = string
# }

# ❌ BAD — insecure default
# variable "public_network_access_enabled" {
#   type    = bool
#   default = true
# }

# ❌ BAD — enum without validation
# variable "sku_name" {
#   type    = string
#   default = "standard"
# }

# ❌ BAD — untyped
# variable "config" {
#   type = any
# }

# ❌ BAD — secret without sensitive flag
# variable "administrator_password" {
#   type = string
# }
