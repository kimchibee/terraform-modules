variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "type" {
  type    = string
  default = "Vpn"
}

variable "vpn_type" {
  type    = string
  default = "RouteBased"
}

variable "sku" {
  type = string
}

variable "generation" {
  type    = string
  default = "Generation1"
}

variable "active_active" {
  type    = bool
  default = false
}

variable "enable_bgp" {
  type    = bool
  default = false
}

variable "ip_configuration_name" {
  type    = string
  default = "default"
}

variable "subnet_id" {
  type = string
}

variable "public_ip_address_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

data "azurerm_resource_group" "parent" {
  name = var.resource_group_name
}

locals {
  # /.../virtualNetworks/<name>/subnets/<subnet-name> -> /.../virtualNetworks/<name>
  virtual_network_id = regexreplace(var.subnet_id, "(?i)(.*/virtualNetworks/[^/]+)/subnets/[^/]+", "$1")
}

module "avm" {
  source  = "Azure/avm-ptn-vnetgateway/azurerm"
  version = "0.10.3"

  parent_id = data.azurerm_resource_group.parent.id
  name      = var.name
  location  = var.location
  tags      = var.tags

  virtual_network_id                = local.virtual_network_id
  virtual_network_gateway_subnet_id = var.subnet_id

  vpn_type                  = var.vpn_type
  vpn_generation            = var.generation
  vpn_active_active_enabled = var.active_active
  vpn_bgp_enabled           = var.enable_bgp

  enable_telemetry = false
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = try(module.avm.virtual_network_gateway.name, var.name)
}
