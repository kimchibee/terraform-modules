variable "name" {
  type = string
}

variable "private_dns_zone_id" {
  type        = string
  description = "부모 Private DNS Zone의 리소스 ID. 호출 측에서 private-dns-zone 스택 remote_state로 주입한다."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/privateDnsZones/[^/]+$", var.private_dns_zone_id))
    error_message = "private_dns_zone_id must be a valid Private DNS Zone resource ID."
  }
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

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-privatednszone-0.5.0/modules/private_dns_virtual_network_link"

  parent_id            = var.private_dns_zone_id
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
