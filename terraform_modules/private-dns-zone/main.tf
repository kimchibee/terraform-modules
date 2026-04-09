variable "name" {
  type = string
}

variable "resource_group_id" {
  type        = string
  description = "Private DNS Zone이 속할 Resource Group의 리소스 ID. 호출 측에서 rg 스택 remote_state로 주입."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "resource_group_id must be a valid Resource Group ID."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-privatednszone-0.5.0"

  domain_name      = var.name
  parent_id        = var.resource_group_id
  tags             = var.tags
  enable_telemetry = false
}

output "id" {
  value = module.avm.resource_id
}

output "name" {
  value = try(module.avm.name, var.name)
}
