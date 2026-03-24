#-------------------------------------------------------------------------------
# Key Vault - 공식 AVM 모듈 래퍼
# 공식: Azure/avm-res-keyvault-vault/azurerm (Terraform Registry)
# 버전 변경 시 아래 version 만 수정 후 이 레포 태그 갱신
#-------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

module "avm" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.sku_name
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
  enable_telemetry              = false

  network_acls = var.network_acls != null ? {
    bypass                     = join(",", var.network_acls.bypass)
    default_action             = var.network_acls.default_action
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  } : null
}
