#-------------------------------------------------------------------------------
# Log Analytics Workspace 모듈 - 출력 (기존 IaC 호환: id, name, workspace_id)
#-------------------------------------------------------------------------------

output "id" {
  description = "Log Analytics Workspace ID"
  value       = module.avm.resource_id
}

output "name" {
  description = "Log Analytics Workspace 이름"
  value       = module.avm.resource.name
}

output "workspace_id" {
  description = "Workspace ID (Customer ID)"
  value       = module.avm.resource.workspace_id
}
