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

variable "inbound_endpoints" {
  type = map(object({
    name                         = optional(string)
    subnet_name                  = string
    private_ip_allocation_method = optional(string, "Dynamic")
    private_ip_address           = optional(string)
    tags                         = optional(map(string))
  }))
  default = {}
}

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-dnsresolver-0.8.0"

  name                        = var.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  virtual_network_resource_id = var.virtual_network_id
  inbound_endpoints           = var.inbound_endpoints
  tags                        = var.tags
  enable_telemetry            = false
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = module.avm.name
}

output "inbound_endpoint_ids" {
  value = {
    for k, v in module.avm.inbound_endpoints : k => v.id
  }
}

output "inbound_endpoint_ip_addresses" {
  value = module.avm.inbound_endpoint_ips
}
