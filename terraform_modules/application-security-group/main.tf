#-------------------------------------------------------------------------------
# Application Security Group
# 단일 책임: Application Security Group 1개 생성
# 공식 AVM: Azure/avm-res-network-applicationsecuritygroup/azurerm
#-------------------------------------------------------------------------------

module "avm" {
  count  = var.enabled ? 1 : 0
  source = "Azure/avm-res-network-applicationsecuritygroup/azurerm"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  enable_telemetry    = false
}
