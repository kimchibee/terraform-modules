#--------------------------------------------------------------
# AI Foundry resources (only when ai_foundry_name is set)
#--------------------------------------------------------------
resource "random_string" "ai_foundry_suffix" {
  count = length(var.ai_foundry_name) > 0 ? 1 : 0

  length  = 4
  special = false
  upper   = false

  keepers = {
    project = var.project_name
    name    = var.ai_foundry_name
  }
}

resource "azurerm_storage_account" "ai_foundry" {
  count = length(var.ai_foundry_name) > 0 ? 1 : 0

  name                          = "${replace(var.ai_foundry_name, "-", "")}st${random_string.ai_foundry_suffix[0].result}"
  location                      = local.rg_location
  resource_group_name           = local.rg_name
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false
  tags                          = var.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_application_insights" "ai_foundry" {
  count = length(var.ai_foundry_name) > 0 ? 1 : 0

  name                = "${var.ai_foundry_name}-ai"
  location            = local.rg_location
  resource_group_name = local.rg_name
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id != "" ? var.log_analytics_workspace_id : null
  tags                = var.tags
}

resource "azurerm_container_registry" "ai_foundry" {
  count = length(var.ai_foundry_name) > 0 ? 1 : 0

  name                          = "${replace(var.ai_foundry_name, "-", "")}acr${random_string.ai_foundry_suffix[0].result}"
  resource_group_name           = local.rg_name
  location                      = local.rg_location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  tags                          = var.tags

  network_rule_set {
    default_action = "Deny"
  }
}

resource "azurerm_machine_learning_workspace" "ai_foundry" {
  count = length(var.ai_foundry_name) > 0 ? 1 : 0

  name                          = var.ai_foundry_name
  location                      = local.rg_location
  resource_group_name           = local.rg_name
  application_insights_id       = azurerm_application_insights.ai_foundry[0].id
  key_vault_id                  = var.hub_key_vault_id
  storage_account_id            = azurerm_storage_account.ai_foundry[0].id
  container_registry_id         = azurerm_container_registry.ai_foundry[0].id
  public_network_access_enabled = false
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "ai_foundry" {
  count = length(var.ai_foundry_name) > 0 ? 1 : 0

  name                = "pe-${var.ai_foundry_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  subnet_id           = local.subnet_id_pep
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.ai_foundry_name}"
    private_connection_resource_id = azurerm_machine_learning_workspace.ai_foundry[0].id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      var.private_dns_zone_ids["ml"],
      var.private_dns_zone_ids["notebooks"]
    ]
  }
}

resource "azurerm_private_endpoint" "ai_foundry_storage" {
  count = length(var.ai_foundry_name) > 0 ? 1 : 0

  name                = "pe-${var.ai_foundry_name}-storage"
  location            = local.rg_location
  resource_group_name = local.rg_name
  subnet_id           = local.subnet_id_pep
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.ai_foundry_name}-storage"
    private_connection_resource_id = azurerm_storage_account.ai_foundry[0].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["blob"]]
  }
}
