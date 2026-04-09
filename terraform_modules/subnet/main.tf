variable "name" {
  type = string
}

variable "virtual_network_id" {
  type        = string
  description = "부모 Virtual Network의 리소스 ID. 호출 측에서 vnet 스택 remote_state로 주입한다."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.virtual_network_id))
    error_message = "virtual_network_id must be a valid Virtual Network resource ID."
  }
}

variable "address_prefixes" {
  type = list(string)
}

variable "service_endpoints" {
  type    = list(string)
  default = []
}

variable "private_endpoint_network_policies" {
  type    = string
  default = "Disabled"
}

variable "private_link_service_network_policies_enabled" {
  type    = bool
  default = false
}

variable "network_security_group_id" {
  type    = string
  default = null
}

variable "delegation" {
  type = object({
    name         = string
    service_name = string
    actions      = list(string)
  })
  default = null
}

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-virtualnetwork-0.17.1/modules/subnet"

  name      = var.name
  parent_id = var.virtual_network_id

  address_prefixes                              = var.address_prefixes
  private_endpoint_network_policies             = var.private_endpoint_network_policies
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
  network_security_group = var.network_security_group_id == null ? null : {
    id = var.network_security_group_id
  }

  service_endpoints_with_location = [
    for service in var.service_endpoints : {
      service   = service
      locations = ["*"]
    }
  ]

  delegations = var.delegation == null ? null : [
    {
      name = var.delegation.name
      service_delegation = {
        name = var.delegation.service_name
      }
    }
  ]
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = module.avm.name
}

output "address_prefixes" {
  value = module.avm.address_prefixes
}
