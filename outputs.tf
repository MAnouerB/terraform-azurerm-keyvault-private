###############################################################################
# Outputs
#
# Expose only what a consumer of this module needs to reference downstream.
# Prefer resource IDs and names over full objects.
# Mark outputs sensitive = true when they carry secrets or connection strings.
#
# See .ai/examples-of-good/good-output.tf for the canonical format.
###############################################################################

output "id" {
  description = "Resource ID of the Key Vault. Use this to reference the vault from downstream resources (e.g. role assignments outside the module, diagnostic wiring, CMK)."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the Key Vault as provisioned in Azure."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "URI of the Key Vault's data plane. Used by SDKs and CLI to interact with the vault's secrets, keys, and certificates."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint."
  value       = azurerm_private_endpoint.this.id
}

output "private_endpoint_ip_address" {
  description = "The private IP the Key Vault is reachable on inside the linked VNet, useful for DNS troubleshooting or custom DNS scenarios."
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}
