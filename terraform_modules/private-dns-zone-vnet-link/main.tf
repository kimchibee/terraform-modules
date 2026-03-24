variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "private_dns_zone_name" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "registration_enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

data "azurerm_private_dns_zone" "zone" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

module "avm" {
  source = "git::https://github.com/Azure/terraform-azurerm-avm-res-network-privatednszone.git//modules/private_dns_virtual_network_link?ref=v0.5.0"

  parent_id            = data.azurerm_private_dns_zone.zone.id
  name                 = var.name
  virtual_network_id   = var.virtual_network_id
  registration_enabled = var.registration_enabled
  tags                 = var.tags
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = var.name
}
