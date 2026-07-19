variable "name_prefix" {
  description = "Set the short prefix used to compose every resource name in this example, following the pattern <type>-<prefix>-<region_short>-<instance> (e.g. rg-<prefix>-frc-001). Must be non-empty."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.name_prefix) > 0
    error_message = "name_prefix must be a non-empty string."
  }
}

variable "location" {
  description = "Set the Azure region where all example resources are created, as a canonical lowercase region name (e.g. francecentral, westeurope, northeurope). Defaults to francecentral; consumers can override."
  type        = string
  default     = "francecentral"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.location))
    error_message = "location must be a non-empty canonical Azure region name in lowercase with letters and digits only, no spaces or special characters (e.g. francecentral, westeurope, northeurope)."
  }
}

variable "additional_reader_object_id" {
  description = "Set the Entra ID (Azure AD) object ID of an additional principal (user, group, or service principal) to grant the \"Key Vault Secrets User\" role on the vault. Defaults to null, in which case no reader role assignment is created. When set, must be a valid GUID."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.additional_reader_object_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.additional_reader_object_id))
    error_message = "additional_reader_object_id must be null or a valid GUID (e.g. 00000000-0000-0000-0000-000000000000)."
  }
}

variable "additional_ip_allowlist" {
  description = "Set an optional list of public IP addresses or CIDR ranges added to the Key Vault network ACLs so the vault can be reached from outside the VNet for manual testing. Defaults to an empty list, in which case the vault is reachable only through its private endpoint. Add your client IP (e.g. from `curl ifconfig.me`) in terraform.tfvars (git-ignored) for local testing; leave empty for production."
  type        = list(string)
  default     = []
  nullable    = false
}
