variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
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

variable "delegation" {
  type = object({
    name         = string
    service_name = string
    actions      = list(string)
  })
  default = null
}

data "azurerm_virtual_network" "parent" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

module "avm" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.17.1"

  name      = var.name
  parent_id = data.azurerm_virtual_network.parent.id

  address_prefixes                              = var.address_prefixes
  private_endpoint_network_policies             = var.private_endpoint_network_policies
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled

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
