#--------------------------------------------------------------
# General Variables
#--------------------------------------------------------------
variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------
variable "resource_group_name" {
  description = "Spoke resource group name"
  type        = string
}

variable "create_resource_group" {
  description = "true면 Spoke RG를 이 모듈에서 생성, false면 기존 RG를 data source로 조회"
  type        = bool
  default     = true
}

#--------------------------------------------------------------
# Virtual Network
#--------------------------------------------------------------
variable "vnet_name" {
  description = "Spoke VNet name"
  type        = string
}

variable "vnet_address_space" {
  description = "Spoke VNet address space"
  type        = list(string)
}

variable "subnets" {
  description = "Subnet configurations"
  type = map(object({
    address_prefixes                      = list(string)
    service_endpoints                     = optional(list(string), [])
    private_endpoint_network_policies     = optional(string, "Disabled")
    private_link_service_network_policies = optional(string, "Disabled")
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
  }))
}

#--------------------------------------------------------------
# Hub VNet (for peering) - Optional
#--------------------------------------------------------------
variable "enable_hub_peering" {
  description = "Enable VNet peering to Hub"
  type        = bool
  default     = false
}

variable "hub_vnet_id" {
  description = "Hub VNet ID for peering"
  type        = string
  default     = ""
}

variable "hub_resource_group_name" {
  description = "Hub resource group name (for Private DNS Zone links)"
  type        = string
  default     = ""
}

#--------------------------------------------------------------
# Private DNS Zones (from Hub) - Optional
#--------------------------------------------------------------
variable "enable_private_dns_links" {
  description = "Enable Private DNS Zone links to Spoke VNet"
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "Map of Private DNS Zone IDs from Hub"
  type        = map(string)
  default     = {}
}

variable "private_dns_zone_keys" {
  description = "Set of zone keys (logical names) for Hub DNS zone links. Use a static set so for_each keys are known at plan time (avoids 'known only after apply' errors)."
  type        = set(string)
  default     = []
}

variable "private_dns_zone_names" {
  description = "Static map key => zone FQDN (e.g. agentsvc => privatelink.agentsvc.azure-automation.net). Used for Hub→Spoke links so for_each is known at plan time."
  type        = map(string)
  default     = {}
}

#--------------------------------------------------------------
# Spoke-owned Private DNS Zones (Optional)
# Create zones in Spoke RG and link Spoke VNet (e.g. APIM, OpenAI, AI Foundry)
#--------------------------------------------------------------
variable "spoke_private_dns_zones" {
  description = "Private DNS Zones to create in Spoke (key = logical name, value = zone FQDN). E.g. azure-api, openai, cognitiveservices, ml, notebooks."
  type        = map(string)
  default     = {}
}

#--------------------------------------------------------------
# Network Security Groups - Optional
#--------------------------------------------------------------
variable "enable_pep_nsg" {
  description = "Enable NSG for Private Endpoint subnet"
  type        = bool
  default     = false
}

variable "pep_subnet_name" {
  description = "Private Endpoint subnet name (for NSG association)"
  type        = string
  default     = "pep-snet"
}
