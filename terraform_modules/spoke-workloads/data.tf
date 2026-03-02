#--------------------------------------------------------------
# When subnets = {} the Spoke RG and VNet are created by network stack.
#--------------------------------------------------------------
data "azurerm_resource_group" "spoke" {
  count = length(var.subnets) == 0 ? 1 : 0

  name = var.resource_group_name
}

data "azurerm_virtual_network" "spoke" {
  count = length(var.subnets) == 0 ? 1 : 0

  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}
