#-------------------------------------------------------------------------------
# Key Vault 모듈 - 출력 (기존 IaC 호환: id, name, vault_uri)
#-------------------------------------------------------------------------------

output "id" {
  description = "Key Vault 리소스 ID"
  value       = module.avm.resource_id
}

output "name" {
  description = "Key Vault 이름"
  value       = module.avm.name
}

output "vault_uri" {
  description = "Key Vault URI (시크릿/키 API용)"
  value       = module.avm.uri
}
