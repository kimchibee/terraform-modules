#-------------------------------------------------------------------------------
# Virtual Network — Azure Verified Module (AVM) 래퍼
# 공식: Azure/avm-res-network-virtualnetwork/azurerm (VNet·서브넷은 AzAPI 기반)
#-------------------------------------------------------------------------------

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  subnets_avm = {
    for k, v in var.subnets : k => merge(
      {
        name                                          = k
        address_prefixes                              = v.address_prefixes
        service_endpoints                             = toset(coalesce(v.service_endpoints, []))
        private_endpoint_network_policies             = v.private_endpoint_network_policies
        private_link_service_network_policies_enabled = v.private_link_service_network_policies == "Enabled"
        default_outbound_access_enabled               = true
      },
      try(v.delegation, null) != null ? {
        delegation = [{
          name = v.delegation.name
          service_delegation = {
            name = v.delegation.service_name
          }
        }]
      } : {}
    )
  }
}

module "avm" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.7.1"

  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = toset(var.vnet_address_space)
  subnets             = local.subnets_avm
  tags                = local.common_tags
  enable_telemetry    = false
}
