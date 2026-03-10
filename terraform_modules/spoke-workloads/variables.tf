#--------------------------------------------------------------
# spoke-workloads Module Variables
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
}

variable "resource_group_name" {
  description = "Spoke resource group name"
  type        = string
}

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
# Optional: network/connectivity 스택에서 이미 생성 시 false
#--------------------------------------------------------------
variable "enable_spoke_to_hub_peering" {
  description = "Spoke→Hub VNet Peering 생성 여부 (connectivity 스택에서 관리 시 false)"
  type        = bool
  default     = true
}

variable "enable_private_dns_zone_links" {
  description = "Private DNS Zone VNet Link 생성 여부 (network 스택에서 관리 시 false)"
  type        = bool
  default     = true
}

variable "enable_pep_nsg" {
  description = "Spoke PEP용 NSG 생성 여부 (network 스택에서 관리 시 false)"
  type        = bool
  default     = true
}

variable "hub_vnet_id" {
  description = "Hub VNet ID for peering"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub VNet name"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Hub resource group name"
  type        = string
}

variable "hub_monitoring_vm_subnet_id" {
  description = "Hub Monitoring VM Subnet ID"
  type        = string
}

variable "hub_key_vault_id" {
  description = "Hub Key Vault ID"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Map of Private DNS Zone IDs from Hub"
  type        = map(string)
}

variable "apim_name" {
  description = "API Management name"
  type        = string
}

variable "apim_sku_name" {
  description = "API Management SKU"
  type        = string
}

variable "apim_publisher_name" {
  description = "API Management publisher name"
  type        = string
}

variable "apim_publisher_email" {
  description = "API Management publisher email"
  type        = string
}

variable "openai_name" {
  description = "Azure OpenAI name"
  type        = string
}

variable "openai_sku" {
  description = "Azure OpenAI SKU"
  type        = string
}

variable "openai_deployments" {
  description = "Azure OpenAI model deployments"
  type = list(object({
    name       = string
    model_name = string
    version    = string
    capacity   = number
  }))
}

variable "ai_foundry_name" {
  description = "Azure AI Foundry name"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = ""
}

variable "hub_monitoring_storage_ids" {
  description = "Map of Hub monitoring storage account IDs for Spoke resources"
  type = object({
    openai    = string
    apim      = string
    aifoundry = string
    acr       = string
    spoke_kv  = string
  })
}

# When subnets = {} (Spoke created by network stack), pass subnet IDs from remote_state.
variable "subnet_id_apim" {
  description = "Spoke subnet ID for APIM (required when subnets = {})"
  type        = string
  default     = null
}

variable "subnet_id_pep" {
  description = "Spoke subnet ID for Private Endpoints (required when subnets = {})"
  type        = string
  default     = null
}
