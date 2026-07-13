###############################################################################
# Main resource — Azure Key Vault
###############################################################################

resource "azurerm_key_vault" "this" {
  name                = local.resource_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id

  sku_name                      = var.sku_name
  rbac_authorization_enabled    = true
  public_network_access_enabled = var.public_network_access_enabled

  purge_protection_enabled   = true
  soft_delete_retention_days = var.soft_delete_retention_days

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  tags = local.tags

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
