#--------------------------------------------------------------
# Terraform Settings
#--------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------
resource "azurerm_resource_group" "spoke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

#--------------------------------------------------------------
# Virtual Network
#--------------------------------------------------------------
resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

#--------------------------------------------------------------
# Subnets
#--------------------------------------------------------------
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = azurerm_resource_group.spoke.name
  virtual_network_name                          = azurerm_virtual_network.spoke.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies == "Enabled" ? true : false
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies == "Enabled" ? true : false

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

#--------------------------------------------------------------
# Network Security Groups (Optional)
#--------------------------------------------------------------
resource "azurerm_network_security_group" "pep" {
  count = var.enable_pep_nsg ? 1 : 0

  name                = "${var.project_name}-spoke-pep-nsg"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range      = "*"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "pep" {
  count = var.enable_pep_nsg && contains(keys(var.subnets), var.pep_subnet_name) ? 1 : 0

  subnet_id                 = azurerm_subnet.subnets[var.pep_subnet_name].id
  network_security_group_id = azurerm_network_security_group.pep[0].id
}

#--------------------------------------------------------------
# VNet Peering: Spoke to Hub (Optional)
#--------------------------------------------------------------
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count = var.enable_hub_peering ? 1 : 0

  name                         = "${var.vnet_name}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.spoke
  ]
}

#--------------------------------------------------------------
# Link Private DNS Zones to Spoke VNet (Optional)
#--------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each = var.enable_private_dns_links ? var.private_dns_zone_ids : {}

  name                  = "${var.vnet_name}-link"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = split("/", each.value)[8]
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
}
