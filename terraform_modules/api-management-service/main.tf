variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "publisher_name" {
  type    = string
  default = "platform-team"
}

variable "sku_name" {
  type    = string
  default = "Developer_1"
}

variable "tags" {
  type    = map(string)
  default = {}
}

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-apimanagement-service-0.0.7"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = var.sku_name
  tags                = var.tags
  enable_telemetry    = false
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = module.avm.name
}

output "gateway_url" {
  value = module.avm.apim_gateway_url
}

output "private_ip_addresses" {
  value = module.avm.private_ip_addresses
}
