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
