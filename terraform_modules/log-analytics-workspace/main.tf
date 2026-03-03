#-------------------------------------------------------------------------------
# Log Analytics Workspace - 공식 AVM 모듈 래퍼
# 공식: Azure/avm-res-operationalinsights-workspace/azurerm (Terraform Registry)
# 버전 변경 시 아래 version 만 수정 후 이 레포 태그 갱신
#-------------------------------------------------------------------------------
module "avm" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.1"

  name                                  = var.name
  location                              = var.location
  resource_group_name                   = var.resource_group_name
  log_analytics_workspace_retention_in_days = var.retention_in_days
  tags                                  = var.tags
}
