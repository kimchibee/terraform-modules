#-------------------------------------------------------------------------------
# VNet Peering — AVM 서브모듈 래퍼
# 공식: Azure/avm-res-network-virtualnetwork/azurerm//modules/peering
#-------------------------------------------------------------------------------

data "azurerm_virtual_network" "local" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

module "avm" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version = "0.17.1"

  name                      = var.name
  parent_id                 = data.azurerm_virtual_network.local.id
  remote_virtual_network_id = var.remote_virtual_network_id

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways
}
