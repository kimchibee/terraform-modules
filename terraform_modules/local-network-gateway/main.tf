variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "gateway_address" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "bgp_settings" {
  type = object({
    asn                 = number
    bgp_peering_address = string
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

module "avm" {
  source  = "Azure/avm-res-network-localnetworkgateway/azurerm"
  version = "0.2.0"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.gateway_address
  address_space       = var.address_space
  bgp_settings        = var.bgp_settings
  tags                = var.tags
  enable_telemetry    = false
}

output "id" {
  value = module.avm.resource_id
}
