#-------------------------------------------------------------------------------
# Log Analytics Workspace 모듈 - 출력
#-------------------------------------------------------------------------------

output "id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "name" {
  description = "Log Analytics Workspace 이름"
  value       = azurerm_log_analytics_workspace.main.name
}

output "workspace_id" {
  description = "Workspace ID (Customer ID)"
  value       = azurerm_log_analytics_workspace.main.workspace_id
}
