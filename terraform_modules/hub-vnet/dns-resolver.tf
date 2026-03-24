#--------------------------------------------------------------
# DNS Private Resolver
#--------------------------------------------------------------
resource "azurerm_private_dns_resolver" "hub" {
  name                = var.dns_resolver_name
  resource_group_name = local.hub_resource_group_name
  location            = local.hub_resource_group_location
  virtual_network_id  = azurerm_virtual_network.hub.id
  tags                = var.tags
}

#--------------------------------------------------------------
# DNS Resolver Inbound Endpoint
#--------------------------------------------------------------
resource "azurerm_private_dns_resolver_inbound_endpoint" "hub" {
  name                    = "${var.dns_resolver_name}-inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub.id
  location                = local.hub_resource_group_location
  tags                    = var.tags

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.subnets["DNSResolver-Inbound"].id
  }
}

# Outbound endpoint 및 Forwarding Ruleset 제거 (내부 주소 관리 전용이므로 외부 포워딩 불필요)
