output "resource_id" {
  description = "Firewall Policy resource ID (AVM resource_id)."
  value       = module.avm.resource_id
}

output "resource" {
  description = "Full azurerm_firewall_policy object (AVM resource output)."
  value       = module.avm.resource
}
