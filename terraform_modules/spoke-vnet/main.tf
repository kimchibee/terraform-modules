#--------------------------------------------------------------
# Spoke VNet — 분류: azurerm 중심 + 점진적 AVM (docs/AVM_COVERAGE.md)
# 단순 VNet·서브넷은 `vnet` 모듈(AVM)과 동일하게 옮길 수 있으나, NSG·피어링·DNS 링크 등
# 기존 출력 계약 유지를 위해 현재는 azurerm 리소스를 사용합니다(점진적 AVM화 대상).
#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------
resource "azurerm_resource_group" "spoke" {
  count = var.create_resource_group ? 1 : 0

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "spoke_existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  spoke_resource_group_name     = var.create_resource_group ? azurerm_resource_group.spoke[0].name : data.azurerm_resource_group.spoke_existing[0].name
  spoke_resource_group_location = var.create_resource_group ? azurerm_resource_group.spoke[0].location : data.azurerm_resource_group.spoke_existing[0].location
  spoke_resource_group_id       = var.create_resource_group ? azurerm_resource_group.spoke[0].id : data.azurerm_resource_group.spoke_existing[0].id
}

#--------------------------------------------------------------
# Virtual Network
#--------------------------------------------------------------
resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = local.spoke_resource_group_location
  resource_group_name = local.spoke_resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

#--------------------------------------------------------------
# Subnets
#--------------------------------------------------------------
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = local.spoke_resource_group_name
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
  location            = local.spoke_resource_group_location
  resource_group_name = local.spoke_resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
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
  resource_group_name          = local.spoke_resource_group_name
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
# Link Private DNS Zones (from Hub) to Spoke VNet (Optional)
# Zones live in Hub RG → link must be created with azurerm.hub
#--------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each = var.enable_private_dns_links ? { for k in var.private_dns_zone_keys : k => var.private_dns_zone_names[k] if try(var.private_dns_zone_names[k], "") != "" } : {}

  provider = azurerm.hub

  name                  = "${var.vnet_name}-link"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
}

#--------------------------------------------------------------
# Spoke-owned Private DNS Zones (Optional)
# Create zones in Spoke RG and link Spoke VNet (e.g. APIM, OpenAI, AI Foundry)
#--------------------------------------------------------------
resource "azurerm_private_dns_zone" "spoke" {
  for_each = var.spoke_private_dns_zones

  name                = each.value
  resource_group_name = local.spoke_resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_zones" {
  for_each = var.spoke_private_dns_zones

  name                  = "${var.vnet_name}-link"
  resource_group_name   = local.spoke_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.spoke[each.key].name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
}
