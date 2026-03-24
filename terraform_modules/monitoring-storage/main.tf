#--------------------------------------------------------------
# monitoring-storage — 분류: AVM + azurerm (공동 모듈 정책은 docs/AVM_COVERAGE.md 참고)
# - Storage / PE: 내부 모듈 storage-account·private-endpoint (Registry AVM 래퍼)
# - 예외: azurerm_role_assignment (역할 할당 전용 경량 AVM 미사용)
#--------------------------------------------------------------
# Random suffix for unique storage account / Key Vault names
#--------------------------------------------------------------
resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false

  keepers = {
    project = var.project_name
  }
}

#--------------------------------------------------------------
# Storage Accounts for Logging (Hub + Spoke resources) — AVM (storage-account 래퍼)
#--------------------------------------------------------------
module "logs_storage" {
  for_each = local.storage_accounts

  source = "../storage-account"

  project_name  = var.project_name
  environment   = var.environment
  location      = var.location
  resource_group_name = var.resource_group_name

  storage_account_name = "${each.value}${random_string.storage_suffix.result}"

  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = false

  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [var.monitoring_vm_subnet_id, var.pep_subnet_id]
  }

  tags = local.common_tags
}

#--------------------------------------------------------------
# Private Endpoints for Storage Accounts — AVM (private-endpoint 래퍼)
#--------------------------------------------------------------
module "storage_blob_pe" {
  for_each = local.storage_accounts

  source = "../private-endpoint"

  project_name  = var.project_name
  environment   = var.environment
  name          = "pe-${each.value}-blob"
  location      = var.location
  resource_group_name = var.resource_group_name
  subnet_id     = var.pep_subnet_id

  target_resource_id = module.logs_storage[each.key].storage_account_id
  subresource_names  = ["blob"]
  private_dns_zone_ids = [var.private_dns_zone_ids["blob"]]

  tags = local.common_tags
}

#--------------------------------------------------------------
# Role Assignments: VM Managed Identity → Storage Accounts
# 예외: Azure에서 단일 역할 할당 전용 경량 AVM이 없어 azurerm_role_assignment 유지
#--------------------------------------------------------------
resource "azurerm_role_assignment" "vm_storage_access" {
  for_each = var.enable_monitoring_vm && var.monitoring_vm_identity_principal_id != "" ? local.storage_accounts : {}

  scope                = module.logs_storage[each.key].storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.monitoring_vm_identity_principal_id
}
