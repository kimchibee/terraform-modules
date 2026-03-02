#--------------------------------------------------------------
# Azure OpenAI Cognitive Service (only when openai_name is set)
#--------------------------------------------------------------
resource "random_string" "openai_suffix" {
  count = length(var.openai_name) > 0 ? 1 : 0

  length  = 4
  special = false
  upper   = false

  keepers = {
    project = var.project_name
    name    = var.openai_name
  }
}

resource "azurerm_cognitive_account" "openai" {
  count = length(var.openai_name) > 0 ? 1 : 0

  name                          = "${var.openai_name}${random_string.openai_suffix[0].result}"
  location                      = local.rg_location
  resource_group_name           = local.rg_name
  kind                          = "OpenAI"
  sku_name                      = var.openai_sku
  custom_subdomain_name         = "${var.openai_name}${random_string.openai_suffix[0].result}"
  public_network_access_enabled = false
  tags                          = var.tags

  network_acls {
    default_action = "Deny"
    ip_rules       = []
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_deployment" "models" {
  for_each = length(var.openai_name) > 0 ? { for d in var.openai_deployments : d.name => d } : {}

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.openai[0].id

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.version
  }

  scale {
    type     = "GlobalStandard"
    capacity = each.value.capacity
  }
}

resource "azurerm_private_endpoint" "openai" {
  count = length(var.openai_name) > 0 ? 1 : 0

  name                = "pe-${var.openai_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  subnet_id           = local.subnet_id_pep
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.openai_name}"
    private_connection_resource_id = azurerm_cognitive_account.openai[0].id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["openai"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "openai" {
  count = length(var.openai_name) > 0 ? 1 : 0

  name                        = "${var.openai_name}-diag"
  target_resource_id          = azurerm_cognitive_account.openai[0].id
  log_analytics_workspace_id  = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  enabled_log {
    category = "RequestResponse"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
