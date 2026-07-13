###############################################################################
# Local values
#
# Use locals for:
#   - computed names following the naming convention (see .ai/CONVENTIONS.md)
#   - merged tags (user-supplied + module-managed metadata)
#   - flags derived from input variables
#
# Do not use locals to hide magic values — prefer explicit variables.
###############################################################################

locals {
  # ---- Computed Key Vault name ----
  # Simple CAF prefix: prepend "kv-" to the consumer's base name. We do NOT
  # compose from prefix/workload/env/region components. var.name is validated
  # (variables.tf) to 1-20 chars starting with a letter, so "kv-" + var.name
  # is 4-23 chars starting with a letter — within Key Vault's 3-24 char,
  # alphanumeric-and-hyphen, must-start-with-a-letter constraints. No hashing,
  # truncation, or uniqueness suffix — consumers compose global uniqueness
  # outside the module if they need it.
  resource_name = "kv-${var.name}"

  # ---- Module-managed tags ----
  # Module identity — hardcode module_source, keep module_version aligned
  # with the current release (bumped by the /tf-release workflow).
  module_managed_tags = {
    managed_by     = "terraform"
    module_source  = "github.com/MAnouerB/terraform-azurerm-keyvault-private"
    module_version = "0.1.0"
  }

  # User tags win over module tags for module_source / module_version only
  # (useful when testing a local checkout). managed_by is re-applied last so
  # it can never be overridden by user-supplied tags.
  tags = merge(
    local.module_managed_tags,
    var.tags,
    {
      managed_by = "terraform" # non-overridable
    }
  )
}
