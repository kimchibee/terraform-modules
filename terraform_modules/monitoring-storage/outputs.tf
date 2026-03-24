#--------------------------------------------------------------
# monitoring-storage Module Outputs
#--------------------------------------------------------------
output "key_vault_id" {
  description = "Key Vault ID"
  value       = try(module.hub_key_vault[0].id, null)
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = try(module.hub_key_vault[0].vault_uri, null)
}

output "monitoring_storage_account_ids" {
  description = "Monitoring Storage Account IDs map"
  value       = { for k, m in module.logs_storage : k => m.storage_account_id }
}
