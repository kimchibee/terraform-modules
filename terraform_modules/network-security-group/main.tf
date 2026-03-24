#-------------------------------------------------------------------------------
# Network Security Group
# 단일 책임: Network Security Group 1개와 그 NSG에 속한 규칙만 생성
# 공식 AVM: Azure/avm-res-network-networksecuritygroup/azurerm
#-------------------------------------------------------------------------------

locals {
  security_rules = {
    for rule in var.security_rules : rule.name => {
      name                                       = rule.name
      priority                                   = rule.priority
      direction                                  = rule.direction
      access                                     = rule.access
      protocol                                   = rule.protocol
      source_port_range                          = try(rule.source_port_range, null)
      source_port_ranges                         = try(rule.source_port_ranges, null)
      destination_port_range                     = try(rule.destination_port_range, null)
      destination_port_ranges                    = try(rule.destination_port_ranges, null)
      source_address_prefix                      = try(rule.source_address_prefix, null)
      source_address_prefixes                    = try(rule.source_address_prefixes, null)
      destination_address_prefix                 = try(rule.destination_address_prefix, null)
      destination_address_prefixes               = try(rule.destination_address_prefixes, null)
      source_application_security_group_ids      = try(toset(rule.source_application_security_group_ids), null)
      destination_application_security_group_ids = try(toset(rule.destination_application_security_group_ids), null)
      description                                = try(rule.description, null)
    }
  }
}

module "avm" {
  count  = var.enabled ? 1 : 0
  source = "Azure/avm-res-network-networksecuritygroup/azurerm"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = local.security_rules
  tags                = var.tags
  enable_telemetry    = false
}
