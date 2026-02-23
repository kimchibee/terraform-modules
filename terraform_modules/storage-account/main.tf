#-------------------------------------------------------------------------------
# Storage Account - 공식 AVM 모듈 래퍼
# 공식: Azure/avm-res-storage-storageaccount/azurerm (Terraform Registry)
# 버전 변경 시 아래 version 만 수정 후 이 레포 태그 갱신
#-------------------------------------------------------------------------------

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
  name_prefix_used = substr(lower(replace(coalesce(var.name_prefix, "${var.project_name}${var.environment}"), "-", "")), 0, 20)
}

resource "random_string" "suffix" {
  count = var.storage_account_name == null ? 1 : 0

  length  = 4
  special = false
  upper   = false
  keepers = {
    project = var.project_name
    env     = var.environment
  }
}

locals {
  storage_account_name = var.storage_account_name != null ? var.storage_account_name : "${local.name_prefix_used}${random_string.suffix[0].result}"
}

module "avm" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.1.1"

  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  min_tls_version          = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  tags                     = local.common_tags
  enable_telemetry         = false

  network_rules = var.network_rules != null ? {
    default_action             = var.network_rules.default_action
    bypass                     = toset(var.network_rules.bypass)
    virtual_network_subnet_ids = toset(var.network_rules.virtual_network_subnet_ids)
    ip_rules                   = toset(var.network_rules.ip_rules)
  } : null
}
