output "key_vault_id" {
  description = "Resource ID of the Key Vault created by the module."
  value       = module.keyvault.id
}

output "key_vault_name" {
  description = "Name of the Key Vault as provisioned in Azure."
  value       = module.keyvault.name
}

output "key_vault_uri" {
  description = "Data plane URI of the Key Vault."
  value       = module.keyvault.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the Key Vault's private endpoint."
  value       = module.keyvault.private_endpoint_id
}

output "private_endpoint_ip_address" {
  description = "Private IP address of the Key Vault's private endpoint NIC."
  value       = module.keyvault.private_endpoint_ip_address
}
