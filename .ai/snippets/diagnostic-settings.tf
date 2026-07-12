###############################################################################
# Snippet: Diagnostic settings
#
# Purpose: wire all supported log categories + AllMetrics to a Log Analytics
# workspace, gated by a variable.
#
# Consumer inputs required:
#   - var.diagnostic_settings_enabled (bool, default true)
#   - var.log_analytics_workspace_id  (string, required when enabled)
#   - var.diagnostic_log_categories   (list(string), default = null → all)
#
# Adjust:
#   - <RESOURCE_NAME> : the local reference of the target resource
#   - <RESOURCE_ID>   : usually <RESOURCE_NAME>.id
###############################################################################

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings_enabled ? 1 : 0
  resource_id = <RESOURCE_ID>
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.diagnostic_settings_enabled ? 1 : 0
  name                       = "${local.resource_name}-diag"
  target_resource_id         = <RESOURCE_ID>
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

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
