#--------------------------------------------------------------
# Hub VNet (복합 스택) — 분류: azurerm 중심 + 점진적 AVM (docs/AVM_COVERAGE.md)
# 리소스 생성은 가능한 한 Azure Verified Module(AVM) 래퍼 모듈로 옮기는 중입니다.
# 아래 azurerm_* 리소스는 AVM이 없거나(예: VPN Gateway, Local Network Gateway 연결),
# 기존 state·출력 계약 유지가 필요한 경우 예외로 둡니다.
#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

#--------------------------------------------------------------
# Resource Group (optional — securitygroup/hub 등에서 먼저 만들 수 있음)
#--------------------------------------------------------------
resource "azurerm_resource_group" "hub" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "hub_existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  hub_resource_group_name     = var.create_resource_group ? azurerm_resource_group.hub[0].name : data.azurerm_resource_group.hub_existing[0].name
  hub_resource_group_location = var.create_resource_group ? azurerm_resource_group.hub[0].location : data.azurerm_resource_group.hub_existing[0].location
  hub_resource_group_id       = var.create_resource_group ? azurerm_resource_group.hub[0].id : data.azurerm_resource_group.hub_existing[0].id
}

#--------------------------------------------------------------
# Virtual Network
#--------------------------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = var.vnet_name
  location            = local.hub_resource_group_location
  resource_group_name = local.hub_resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

#--------------------------------------------------------------
# Subnets
#--------------------------------------------------------------
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = local.hub_resource_group_name
  virtual_network_name                          = azurerm_virtual_network.hub.name
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

  timeouts {
    create = "50m"
    update = "30m"
    delete = "30m"
  }
}

#--------------------------------------------------------------
# Network Security Groups
#--------------------------------------------------------------
resource "azurerm_network_security_group" "monitoring_vm" {
  name                = "${var.project_name}-monitoring-vm-nsg"
  location            = local.hub_resource_group_location
  resource_group_name = local.hub_resource_group_name
  tags                = var.tags

  # Inbound Rules
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Outbound Rules - Allow access to Private Endpoints in pep-snet
  security_rule {
    name                       = "AllowOutboundToPrivateEndpoints"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    description                = "Allow VM to access Private Endpoints in pep-snet subnet"
  }

  security_rule {
    name                       = "AllowOutboundHTTPS"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS outbound for Azure services"
  }

  security_rule {
    name                       = "AllowOutboundHTTP"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTP outbound for Azure services"
  }
}

resource "azurerm_subnet_network_security_group_association" "monitoring_vm" {
  subnet_id                 = azurerm_subnet.subnets["Monitoring-VM-Subnet"].id
  network_security_group_id = azurerm_network_security_group.monitoring_vm.id
}

resource "azurerm_network_security_group" "pep" {
  name                = "${var.project_name}-pep-nsg"
  location            = local.hub_resource_group_location
  resource_group_name = local.hub_resource_group_name
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
  subnet_id                 = azurerm_subnet.subnets["pep-snet"].id
  network_security_group_id = azurerm_network_security_group.pep.id
}

