#-------------------------------------------------------------------------------
# Log Analytics Workspace 모듈 - 메인 리소스
# 역할: Log Analytics Workspace 1개 생성
#-------------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  retention_in_days   = var.retention_in_days
  sku                 = "PerGB2018"
  tags                = var.tags
}
