variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

data "azurerm_resource_group" "parent" {
  name = var.resource_group_name
}

module "avm" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"

  domain_name      = var.name
  parent_id        = data.azurerm_resource_group.parent.id
  tags             = var.tags
  enable_telemetry = false
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = try(module.avm.name, var.name)
}
