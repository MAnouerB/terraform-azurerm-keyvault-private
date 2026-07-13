# Observability — Diagnostic settings streaming Key Vault logs and metrics to Log Analytics

data "azurerm_monitor_diagnostic_categories" "this" {
  count = var.diagnostic_settings_enabled ? 1 : 0

  resource_id = azurerm_key_vault.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings_enabled ? 1 : 0

  name                       = "${local.resource_name}-diag"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(
      coalesce(
        var.diagnostic_log_categories,
        data.azurerm_monitor_diagnostic_categories.this[0].log_category_types
      )
    )
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }

  lifecycle {
    precondition {
      condition     = !var.diagnostic_settings_enabled || var.log_analytics_workspace_id != null
      error_message = "log_analytics_workspace_id must be set when diagnostic_settings_enabled is true."
    }
  }
}
