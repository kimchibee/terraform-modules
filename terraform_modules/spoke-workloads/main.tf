#--------------------------------------------------------------
# Spoke Workloads — 분류: azurerm 중심 (docs/AVM_COVERAGE.md)
# 서비스별 AVM이 분산되어 있어 기존 azurerm 구성 유지. 필요 시 서비스 단위로 AVM으로 분해 가능.
#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

#--------------------------------------------------------------
# Resource Group (only when this module creates subnets)
#--------------------------------------------------------------
resource "azurerm_resource_group" "spoke" {
  count = length(var.subnets) > 0 ? 1 : 0

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

#--------------------------------------------------------------
# Virtual Network (only when this module creates subnets)
#--------------------------------------------------------------
resource "azurerm_virtual_network" "spoke" {
  count = length(var.subnets) > 0 ? 1 : 0

  name                = var.vnet_name
  location            = azurerm_resource_group.spoke[0].location
  resource_group_name = azurerm_resource_group.spoke[0].name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

#--------------------------------------------------------------
# Subnets
#--------------------------------------------------------------
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = local.rg_name
  virtual_network_name                          = azurerm_virtual_network.spoke[0].name
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
# Network Security Groups
# APIM NSG는 apim_name이 설정된 스택(APIM 스택)에서만 생성
# ai-services 스택(apim_name = "")에서는 생성하지 않음
#--------------------------------------------------------------
resource "azurerm_network_security_group" "apim" {
  count = length(var.apim_name) > 0 ? 1 : 0

  name                = "${var.project_name}-apim-nsg"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags

  security_rule {
    name                       = "AllowAPIMManagement"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "apim" {
  count = length(var.apim_name) > 0 ? 1 : 0

  subnet_id                 = local.subnet_id_apim
  network_security_group_id = azurerm_network_security_group.apim[0].id
}

resource "azurerm_network_security_group" "pep" {
  count = var.enable_pep_nsg ? 1 : 0

  name                = "${var.project_name}-spoke-pep-nsg"
  location            = local.rg_location
  resource_group_name = local.rg_name
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
  count = var.enable_pep_nsg ? 1 : 0

  subnet_id                 = local.subnet_id_pep
  network_security_group_id = azurerm_network_security_group.pep[0].id
}
