#--------------------------------------------------------------
# spoke-workloads Module Outputs
#--------------------------------------------------------------
output "resource_group_name" {
  description = "Spoke resource group name"
  value       = local.rg_name
}

output "resource_group_id" {
  description = "Spoke resource group ID"
  value       = local.rg_id
}

output "vnet_id" {
  description = "Spoke VNet ID"
  value       = local.vnet_id
}

output "vnet_name" {
  description = "Spoke VNet name"
  value       = local.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs (empty when subnets created by network stack)"
  value       = length(var.subnets) > 0 ? { for k, v in azurerm_subnet.subnets : k => v.id } : {}
}

output "apim_id" {
  description = "API Management ID"
  value       = try(azurerm_api_management.main[0].id, null)
}

output "apim_gateway_url" {
  description = "API Management gateway URL"
  value       = try(azurerm_api_management.main[0].gateway_url, null)
}

output "apim_private_ip_addresses" {
  description = "API Management private IP addresses"
  value       = try(azurerm_api_management.main[0].private_ip_addresses, null)
}

output "openai_id" {
  description = "Azure OpenAI ID"
  value       = try(azurerm_cognitive_account.openai[0].id, null)
}

output "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  value       = try(azurerm_cognitive_account.openai[0].endpoint, null)
}

output "openai_primary_access_key" {
  description = "Azure OpenAI primary access key"
  value       = try(azurerm_cognitive_account.openai[0].primary_access_key, null)
  sensitive   = true
}

output "ai_foundry_id" {
  description = "AI Foundry workspace ID"
  value       = try(azurerm_machine_learning_workspace.ai_foundry[0].id, null)
}

output "ai_foundry_discovery_url" {
  description = "AI Foundry discovery URL"
  value       = try(azurerm_machine_learning_workspace.ai_foundry[0].discovery_url, null)
}

output "key_vault_id" {
  description = "Hub Key Vault ID"
  value       = var.hub_key_vault_id
}

output "storage_account_id" {
  description = "AI Foundry Storage Account ID"
  value       = try(azurerm_storage_account.ai_foundry[0].id, null)
}
