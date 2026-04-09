variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "allocation_method" {
  type    = string
  default = "Static"
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "zones" {
  type    = list(string)
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-publicipaddress-0.2.1"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.allocation_method
  sku                 = var.sku
  zones               = var.zones == null ? null : toset([for z in var.zones : tonumber(z)])
  tags                = var.tags
  enable_telemetry    = false
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = module.avm.name
}

output "ip_address" {
  value = module.avm.public_ip_address
}
