#--------------------------------------------------------------
# VNet Peering: Spoke to Hub (enable_spoke_to_hub_peering = true 시에만)
#--------------------------------------------------------------
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count = var.enable_spoke_to_hub_peering ? 1 : 0

  name                         = "${local.vnet_name}-to-hub"
  resource_group_name          = local.rg_name
  virtual_network_name         = local.vnet_name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}

#--------------------------------------------------------------
# Link Private DNS Zones to Spoke VNet (enable_private_dns_zone_links = true 시에만)
#--------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each = var.enable_private_dns_zone_links ? var.private_dns_zone_ids : {}

  name                  = "${local.vnet_name}-link"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = split("/", each.value)[8]
  virtual_network_id    = local.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
