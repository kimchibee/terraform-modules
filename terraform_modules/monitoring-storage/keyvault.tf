#--------------------------------------------------------------
# Key Vault — AVM (key-vault 래퍼)
#--------------------------------------------------------------
module "hub_key_vault" {
  count = var.enable_key_vault ? 1 : 0

  source = "../key-vault"

  project_name        = var.project_name
  environment         = var.environment
  name                = local.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = false

  network_acls = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [var.monitoring_vm_subnet_id, var.pep_subnet_id]
  }

  tags = local.common_tags
}

#--------------------------------------------------------------
# Private Endpoint for Key Vault — AVM (private-endpoint 래퍼)
#--------------------------------------------------------------
module "key_vault_pe" {
  count = var.enable_key_vault ? 1 : 0

  source = "../private-endpoint"

  project_name        = var.project_name
  environment         = var.environment
  name                = "pe-${var.key_vault_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pep_subnet_id

  target_resource_id   = module.hub_key_vault[0].id
  subresource_names    = ["vault"]
  private_dns_zone_ids = [var.private_dns_zone_ids["vault"]]

  tags = local.common_tags
}

#--------------------------------------------------------------
# Role Assignment: VM Managed Identity → Key Vault
# 예외: 단일 할당에 AVM 패턴이 과도하여 azurerm_role_assignment 유지
#--------------------------------------------------------------
resource "azurerm_role_assignment" "vm_key_vault_access" {
  count = var.enable_monitoring_vm && var.enable_key_vault && var.monitoring_vm_identity_principal_id != "" ? 1 : 0

  scope                = module.hub_key_vault[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.monitoring_vm_identity_principal_id
}

resource "azurerm_role_assignment" "vm_key_vault_reader" {
  count = var.enable_monitoring_vm && var.enable_key_vault && var.monitoring_vm_identity_principal_id != "" ? 1 : 0

  scope                = module.hub_key_vault[0].id
  role_definition_name = "Key Vault Reader"
  principal_id         = var.monitoring_vm_identity_principal_id
}
