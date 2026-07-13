# Security — RBAC role assignments on the Key Vault

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = azurerm_key_vault.this.id
  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name

  condition         = each.value.condition
  condition_version = each.value.condition != null ? "2.0" : null
}
