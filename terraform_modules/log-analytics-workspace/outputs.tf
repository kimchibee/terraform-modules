#-------------------------------------------------------------------------------
# Log Analytics Workspace 모듈 - 출력 (기존 IaC 호환: id, name, workspace_id)
# AVM 0.4.1: name, workspace_id는 최상위 출력이 없고 resource 객체 내부에 있음.
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
