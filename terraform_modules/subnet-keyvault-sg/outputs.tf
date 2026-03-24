output "keyvault_sg_nsg_id" {
  description = "Standalone keyvault-sg NSG ID (null if create_standalone_nsg is false)"
  value       = var.create_standalone_nsg ? local.keyvault_standalone_nsg_id : null
}

output "keyvault_sg_nsg_name" {
  description = "Standalone keyvault-sg NSG name"
  value       = try(azurerm_network_security_group.keyvault_sg[0].name, null)
}

output "keyvault_clients_asg_id" {
  description = "Key Vault 접근 허용 대상 ASG ID"
  value       = var.enable_pe_inbound_from_asg ? local.keyvault_clients_asg_id : null
}
