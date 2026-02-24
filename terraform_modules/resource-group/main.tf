#-------------------------------------------------------------------------------
# Resource Group - 공식 AVM 모듈 래퍼
# 공식: Azure/avm-res-resources-resourcegroup/azurerm (Terraform Registry)
# 버전 변경 시 아래 version 만 수정 후 이 레포 태그 갱신
#-------------------------------------------------------------------------------
module "avm" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = var.name
  location = var.location
  tags     = var.tags
}
