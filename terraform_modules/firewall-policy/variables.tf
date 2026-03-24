variable "location" {
  type        = string
  description = "Azure region for the Firewall Policy."
}

variable "name" {
  type        = string
  description = "Name of the Firewall Policy."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags for the policy."
}

variable "firewall_policy_sku" {
  type        = string
  description = "SKU tier: Standard, Premium, or Basic."
}

variable "firewall_policy_threat_intelligence_mode" {
  type        = string
  default     = "Alert"
  description = "Threat intelligence mode (e.g. Alert, Deny, Off)."
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "AVM telemetry (Microsoft)."
}
