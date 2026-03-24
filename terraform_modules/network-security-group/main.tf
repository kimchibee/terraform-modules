#-------------------------------------------------------------------------------
# Network Security Group
# 단일 책임: Network Security Group 1개와 그 NSG에 속한 규칙만 생성
#-------------------------------------------------------------------------------

resource "azurerm_network_security_group" "this" {
  count = var.enabled ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                                       = security_rule.value.name
      priority                                   = security_rule.value.priority
      direction                                  = security_rule.value.direction
      access                                     = security_rule.value.access
      protocol                                   = security_rule.value.protocol
      source_port_range                          = security_rule.value.source_port_range
      destination_port_range                     = security_rule.value.destination_port_range
      source_address_prefix                      = try(security_rule.value.source_address_prefix, null)
      destination_address_prefix                 = try(security_rule.value.destination_address_prefix, null)
      source_application_security_group_ids      = try(security_rule.value.source_application_security_group_ids, null)
      destination_application_security_group_ids = try(security_rule.value.destination_application_security_group_ids, null)
      description                                = try(security_rule.value.description, null)
    }
  }
}
