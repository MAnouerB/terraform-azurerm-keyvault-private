###############################################################################
# Snippet: Tags merge pattern
#
# Purpose: standardize how modules combine user-supplied tags with
# module-managed metadata.
#
# Usage: place the local block in locals.tf, then reference local.tags on
# every taggable resource.
###############################################################################

locals {
  # Module identity — hardcode module_source, keep module_version aligned
  # with the current release (bumped by the /tf-release workflow).
  module_managed_tags = {
    managed_by     = "terraform"
    module_source  = "github.com/MAnouerB/terraform-azurerm-<name>"
    module_version = "0.1.0"
  }

  # User tags win over module tags for module_source / module_version
  # only (useful when testing a local checkout). All other module-managed
  # tags are protected.
  tags = merge(
    local.module_managed_tags,
    var.tags,
    {
      managed_by = "terraform" # non-overridable
    }
  )
}
