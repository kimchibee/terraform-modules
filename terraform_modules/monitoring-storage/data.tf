#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "existing" {
  count               = var.existing_storage_account_name != null && var.existing_storage_account_name != "" ? 1 : 0
  name                = var.existing_storage_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "existing" {
  count               = var.existing_key_vault_name != null && var.existing_key_vault_name != "" ? 1 : 0
  name                = var.existing_key_vault_name
  resource_group_name = var.resource_group_name
}
