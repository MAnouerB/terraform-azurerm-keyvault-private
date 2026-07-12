###############################################################################
# Canonical output examples
#
# Reference file. Do not include in a module.
###############################################################################

# ✅ GOOD — expose id (always)
output "id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

# ✅ GOOD — expose name (always)
output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

# ✅ GOOD — expose derived useful attributes
output "vault_uri" {
  description = "URI of the Key Vault, used by SDKs and CLI to reach the data plane."
  value       = azurerm_key_vault.this.vault_uri
}

# ✅ GOOD — sensitive when carrying a secret
output "primary_connection_string" {
  description = "Primary connection string for the resource. Consumers should read this from Key Vault in production."
  value       = azurerm_example_resource.this.primary_connection_string
  sensitive   = true
}

# ✅ GOOD — expose PE private IP for downstream DNS config
output "private_endpoint_ip_address" {
  description = "Private IP address assigned to the private endpoint NIC."
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}

###############################################################################
# ❌ ANTI-PATTERNS
###############################################################################

# ❌ BAD — no description
# output "id" {
#   value = azurerm_key_vault.this.id
# }

# ❌ BAD — secret without sensitive flag
# output "primary_connection_string" {
#   value = azurerm_example_resource.this.primary_connection_string
# }

# ❌ BAD — exposing the entire object when only id is needed downstream
# output "key_vault" {
#   value = azurerm_key_vault.this
# }
