#--------------------------------------------------------------
# Use created RG/VNet when subnets provided, else use data (existing from network stack).
#--------------------------------------------------------------
locals {
  rg_name     = length(var.subnets) > 0 ? azurerm_resource_group.spoke[0].name : data.azurerm_resource_group.spoke[0].name
  rg_id       = length(var.subnets) > 0 ? azurerm_resource_group.spoke[0].id : data.azurerm_resource_group.spoke[0].id
  rg_location = length(var.subnets) > 0 ? azurerm_resource_group.spoke[0].location : data.azurerm_resource_group.spoke[0].location
  vnet_id     = length(var.subnets) > 0 ? azurerm_virtual_network.spoke[0].id : data.azurerm_virtual_network.spoke[0].id
  vnet_name   = length(var.subnets) > 0 ? azurerm_virtual_network.spoke[0].name : data.azurerm_virtual_network.spoke[0].name
  subnet_id_apim = length(var.subnets) > 0 ? azurerm_subnet.subnets["apim-snet"].id : var.subnet_id_apim
  subnet_id_pep  = length(var.subnets) > 0 ? azurerm_subnet.subnets["pep-snet"].id : var.subnet_id_pep
}
