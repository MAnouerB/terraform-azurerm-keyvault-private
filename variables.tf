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
# Observability
###############################################################################

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
