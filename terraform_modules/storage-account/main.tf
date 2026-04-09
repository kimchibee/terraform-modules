#-------------------------------------------------------------------------------
# Storage Account — Azure Verified Module (AVM) 래퍼
# 공식: Azure/avm-res-storage-storageaccount/azurerm
#-------------------------------------------------------------------------------
locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
  # 이름 미지정 시 prefix + 랜덤 4자 (Azure: 3~24자, 소문자+숫자만)
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
  source = "../../vendor/terraform-azurerm-avm-res-storage-storageaccount-0.4.0"

  name                          = local.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  min_tls_version               = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = local.common_tags
  enable_telemetry              = false
  shared_access_key_enabled     = true

  network_rules = var.network_rules != null ? {
    default_action             = var.network_rules.default_action
    bypass                     = toset(coalesce(var.network_rules.bypass, ["AzureServices"]))
    virtual_network_subnet_ids = toset(coalesce(var.network_rules.virtual_network_subnet_ids, []))
    ip_rules                   = toset(coalesce(var.network_rules.ip_rules, []))
  } : null
}
