variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

module "avm" {
  source  = "Azure/avm-res-network-dnsresolver/azurerm"
  version = "0.8.0"

  name                        = var.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  virtual_network_resource_id = var.virtual_network_id
  tags                        = var.tags
  enable_telemetry            = false
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = module.avm.name
}
