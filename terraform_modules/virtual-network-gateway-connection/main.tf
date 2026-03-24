variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "type" {
  type    = string
  default = "IPsec"
}

variable "virtual_network_gateway_id" {
  type = string
}

variable "local_network_gateway_id" {
  type = string
}

variable "shared_key" {
  type      = string
  sensitive = true
}

variable "enable_bgp" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

module "avm" {
  source  = "Azure/avm-res-network-connection/azurerm"
  version = "0.2.0"

  name                                = var.name
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  type                                = var.type
  virtual_network_gateway_resource_id = var.virtual_network_gateway_id
  local_network_gateway_resource_id   = var.local_network_gateway_id
  shared_key                          = var.shared_key
  enable_bgp                          = var.enable_bgp
  tags                                = var.tags
  enable_telemetry                    = false
}

output "id" {
  value = module.avm.resource_id
}
