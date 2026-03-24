#-------------------------------------------------------------------------------
# Azure Firewall Policy — 분류: AVM-only (docs/AVM_COVERAGE.md)
# 공식: Azure/avm-res-network-firewallpolicy/azurerm (Terraform Registry)
#-------------------------------------------------------------------------------
module "avm" {
  source  = "Azure/avm-res-network-firewallpolicy/azurerm"
  version = "0.3.4"

  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  firewall_policy_sku                      = var.firewall_policy_sku
  firewall_policy_threat_intelligence_mode = var.firewall_policy_threat_intelligence_mode

  enable_telemetry = var.enable_telemetry
}
