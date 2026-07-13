# Networking — Private Endpoint and Private DNS zone group for the Key Vault

resource "azurerm_private_endpoint" "this" {
  name                = "${local.resource_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint
  tags                = local.tags

  private_service_connection {
    name                           = "${local.resource_name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
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
