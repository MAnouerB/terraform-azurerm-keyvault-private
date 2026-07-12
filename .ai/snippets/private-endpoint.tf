
###############################################################################
# Snippet: Private endpoint + Private DNS zone A record
#
# Purpose: standardize the private endpoint pattern across modules.
#
# Consumer inputs required:
#   - var.private_endpoint_subnet_id      : subnet where the PE lives
#   - var.private_dns_zone_id             : privatelink zone (managed elsewhere)
#   - var.private_endpoint_name (optional): override for the PE resource name
#
# Adjust:
#   - <RESOURCE_NAME>       : the local reference of the target resource
#     (e.g. azurerm_key_vault.this, azurerm_postgresql_flexible_server.this)
#   - <SUBRESOURCE>          : the target subresource name from the Azure
#     PE reference table (e.g. "vault", "postgresqlServer", "sqlServer")
#   - <PE_NAME_SHORT>        : CAF short for the resource in the PE name
###############################################################################

resource "azurerm_private_endpoint" "this" {
  name = coalesce(
    var.private_endpoint_name,
    "${local.resource_name}-pe"
  )
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags

  private_service_connection {
    name                           = "${local.resource_name}-psc"
    private_connection_resource_id = <RESOURCE_NAME>.id
    subresource_names              = ["<SUBRESOURCE>"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}