###############################################################################
# Canonical resource examples
#
# Reference file. Do not include in a module.
###############################################################################

# ✅ GOOD — main resource pattern
resource "azurerm_key_vault" "this" {
  name                = local.resource_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                      = var.sku_name
  enable_rbac_authorization     = true
  public_network_access_enabled = var.public_network_access_enabled

  purge_protection_enabled   = true
  soft_delete_retention_days = var.soft_delete_retention_days

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.subnet_ids
    }
  }

  tags = local.tags

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# ✅ GOOD — for_each over count for multiple instances
resource "azurerm_role_assignment" "data_plane" {
  for_each = var.role_assignments

  scope                = azurerm_key_vault.this.id
  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  condition            = try(each.value.condition, null)
  condition_version    = each.value.condition != null ? "2.0" : null
}

###############################################################################
# ❌ ANTI-PATTERNS
###############################################################################

# ❌ BAD — hardcoded values
# resource "azurerm_key_vault" "this" {
#   name                = "my-kv-prd-001"
#   location            = "francecentral"
#   sku_name            = "standard"
# }

# ❌ BAD — count instead of for_each
# resource "azurerm_role_assignment" "data_plane" {
#   count = length(var.principal_ids)
#   scope        = azurerm_key_vault.this.id
#   principal_id = var.principal_ids[count.index]
# }

# ❌ BAD — no timeouts on slow resource
# ❌ BAD — provider block inside module
# provider "azurerm" { features {} }
