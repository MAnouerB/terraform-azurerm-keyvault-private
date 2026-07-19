# ---- Data sources ----

# Auto-resolve the current tenant (for the vault's tenant_id, ADR-004) and the
# current principal (for the automatic admin role assignment).
data "azurerm_client_config" "current" {}

# ---- Locals: region-short mapping and computed names ----

locals {
  # Region short mapping — extend as needed
  region_short_map = {
    francecentral = "frc"
    westeurope    = "weu"
    northeurope   = "nue"
    eastus        = "eus"
    eastus2       = "eus2"
  }
  region_short = lookup(local.region_short_map, var.location, "unk")

  # Computed names — pattern: <type>-<prefix>-<region_short>-<instance>
  rg_name       = "rg-${var.name_prefix}-${local.region_short}-001"
  vnet_name     = "vnet-${var.name_prefix}-${local.region_short}-001"
  subnet_name   = "snet-${var.name_prefix}-pe-${local.region_short}-001"
  vnetlink_name = "vnetlink-${var.name_prefix}-${local.region_short}-001"
  law_name      = "log-${var.name_prefix}-${local.region_short}-001"
  kv_name       = "${var.name_prefix}-${local.region_short}-001" # passed to module; module prepends "kv-"
}

# ---- Resource group ----

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = var.location
}

# ---- Networking: VNet + subnet + Private DNS Zone + VNet link ----

resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "pe" {
  name                              = local.subnet_name
  resource_group_name               = azurerm_resource_group.this.name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = ["10.0.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# The zone name is FIXED (Azure requirement for Key Vault private endpoints).
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name                  = local.vnetlink_name
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# ---- Observability: Log Analytics workspace ----

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.law_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---- Key Vault module invocation ----

module "keyvault" {
  source = "../.."

  name                = local.kv_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Production posture — private-only access
  public_network_access_enabled = false

  subnet_id_private_endpoint = azurerm_subnet.pe.id
  private_dns_zone_id        = azurerm_private_dns_zone.kv.id

  # Network ACLs — Deny by default, allowlist optional IPs for manual testing
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.additional_ip_allowlist
  }

  # Observability enabled with the Log Analytics workspace provisioned above
  diagnostic_settings_enabled = true
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.this.id

  # RBAC — current user gets admin automatically, optional reader role for a second principal
  role_assignments = merge(
    {
      current-user-admin = {
        principal_id         = data.azurerm_client_config.current.object_id
        role_definition_name = "Key Vault Administrator"
      }
    },
    var.additional_reader_object_id == null ? {} : {
      additional-reader = {
        principal_id         = var.additional_reader_object_id
        role_definition_name = "Key Vault Secrets User"
      }
    }
  )

  tags = {
    environment = "example"
    example     = "complete"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.kv
  ]
}
