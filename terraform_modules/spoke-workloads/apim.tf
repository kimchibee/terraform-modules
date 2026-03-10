#--------------------------------------------------------------
# Random suffix for unique APIM name
#--------------------------------------------------------------
resource "random_string" "apim_suffix" {
  count = length(var.apim_name) > 0 ? 1 : 0

  length  = 4
  special = false
  upper   = false

  keepers = {
    apim_name = var.apim_name
  }
}

#--------------------------------------------------------------
# API Management (only when apim_name is set)
#--------------------------------------------------------------
resource "azurerm_api_management" "main" {
  count = length(var.apim_name) > 0 ? 1 : 0

  name                 = "${var.apim_name}-${random_string.apim_suffix[0].result}"
  location              = local.rg_location
  resource_group_name   = local.rg_name
  publisher_name       = var.apim_publisher_name
  publisher_email      = var.apim_publisher_email
  sku_name             = var.apim_sku_name
  virtual_network_type = "Internal"
  tags                 = var.tags

  virtual_network_configuration {
    subnet_id = local.subnet_id_apim
  }

  identity {
    type = "SystemAssigned"
  }

  # APIM은 서브넷에 NSG가 연결된 뒤에만 배포 가능 (Azure 요구사항)
  depends_on = [azurerm_subnet_network_security_group_association.apim]
}

#--------------------------------------------------------------
# API Management Diagnostic Settings
#--------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "apim" {
  count = length(var.apim_name) > 0 ? 1 : 0

  name                        = "${var.apim_name}-diag"
  target_resource_id          = azurerm_api_management.main[0].id
  log_analytics_workspace_id  = var.log_analytics_workspace_id

  enabled_log {
    category = "GatewayLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
