#--------------------------------------------------------------
# Resource Group Outputs
#--------------------------------------------------------------
output "resource_group_name" {
  description = "Spoke resource group name"
  value       = local.spoke_resource_group_name
}

output "resource_group_id" {
  description = "Spoke resource group ID"
  value       = local.spoke_resource_group_id
}

#--------------------------------------------------------------
# Virtual Network Outputs
#--------------------------------------------------------------
output "vnet_id" {
  description = "Spoke VNet ID"
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "Spoke VNet name"
  value       = azurerm_virtual_network.spoke.name
}

output "vnet_address_space" {
  description = "Spoke VNet address space"
  value       = azurerm_virtual_network.spoke.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

#--------------------------------------------------------------
# Network Security Group Outputs
#--------------------------------------------------------------
output "nsg_pep_id" {
  description = "Private Endpoint NSG ID"
  value       = var.enable_pep_nsg ? azurerm_network_security_group.pep[0].id : null
}

#--------------------------------------------------------------
# VNet Peering Outputs
#--------------------------------------------------------------
output "vnet_peering_id" {
  description = "VNet Peering ID (Spoke to Hub)"
  value       = var.enable_hub_peering ? azurerm_virtual_network_peering.spoke_to_hub[0].id : null
}

#--------------------------------------------------------------
# Spoke-owned Private DNS Zone Outputs
#--------------------------------------------------------------
output "spoke_private_dns_zone_ids" {
  description = "Map of Spoke Private DNS Zone IDs (key = logical name)"
  value       = { for k, v in azurerm_private_dns_zone.spoke : k => v.id }
}

output "spoke_private_dns_zone_names" {
  description = "Map of Spoke Private DNS Zone names (key = logical name)"
  value       = { for k, v in azurerm_private_dns_zone.spoke : k => v.name }
}
