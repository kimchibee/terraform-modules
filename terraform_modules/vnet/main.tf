#-------------------------------------------------------------------------------
# Virtual Network — Azure Verified Module (AVM) 래퍼
# 공식: Azure/avm-res-network-virtualnetwork/azurerm v0.17.1 (vendor 경로)
# 0.17.1은 AzAPI 기반으로 재작성되어 parent_id 패턴, delegations(복수형),
# service_endpoints_with_location 사용. wrapper의 외부 인터페이스는 단순 유지하고
# 내부에서 0.17.1 스키마로 변환한다.
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
        private_endpoint_network_policies             = v.private_endpoint_network_policies
        private_link_service_network_policies_enabled = v.private_link_service_network_policies == "Enabled"
        default_outbound_access_enabled               = true
      },
      length(coalesce(v.service_endpoints, [])) > 0 ? {
        service_endpoints_with_location = [
          for service in v.service_endpoints : {
            service   = service
            locations = ["*"]
          }
        ]
      } : {},
      try(v.delegation, null) != null ? {
        delegations = [{
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
  source = "../../vendor/terraform-azurerm-avm-res-network-virtualnetwork-0.17.1"

  name             = var.vnet_name
  parent_id        = var.resource_group_id
  location         = var.location
  address_space    = toset(var.vnet_address_space)
  subnets          = local.subnets_avm
  tags             = local.common_tags
  enable_telemetry = false
}
