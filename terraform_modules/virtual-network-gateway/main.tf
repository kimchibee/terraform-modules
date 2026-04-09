variable "name" {
  type = string
}

variable "resource_group_id" {
  type        = string
  description = "VPN Gateway가 속할 Resource Group의 리소스 ID. 호출 측에서 rg 스택 remote_state로 주입."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "resource_group_id must be a valid Resource Group ID."
  }
}

variable "virtual_network_id" {
  type        = string
  description = "VPN Gateway가 속한 Virtual Network의 리소스 ID. 호출 측에서 vnet 스택 remote_state로 주입."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.virtual_network_id))
    error_message = "virtual_network_id must be a valid Virtual Network resource ID."
  }
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

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-ptn-vnetgateway-0.10.3"

  parent_id = var.resource_group_id
  name      = var.name
  location  = var.location
  tags      = var.tags

  virtual_network_id                = var.virtual_network_id
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
