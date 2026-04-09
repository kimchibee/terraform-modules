#-------------------------------------------------------------------------------
# VNet Peering — AVM 서브모듈 래퍼
# 공식: Azure/avm-res-network-virtualnetwork/azurerm//modules/peering
#-------------------------------------------------------------------------------

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-virtualnetwork-0.17.1/modules/peering"

  name                      = var.name
  parent_id                 = var.local_virtual_network_id
  remote_virtual_network_id = var.remote_virtual_network_id

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways
}
