variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "bgp_route_propagation_enabled" {
  type    = bool
  default = true
}

variable "routes_legacy_mode" {
  type        = bool
  default     = true
  description = "true: azurerm_route, false: AzAPI routes (AVM 기본 경로)"
}

variable "routes" {
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

variable "subnet_resource_ids" {
  type        = map(string)
  default     = {}
  description = "서브넷 ID 맵 — 키는 임의(association for_each 키)"
}

variable "enable_telemetry" {
  type    = bool
  default = false
}
