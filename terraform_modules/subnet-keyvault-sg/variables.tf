# keyvault-sg 모듈 변수 (IaC hub-pep-subnet 과 동일 계약)

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "create_standalone_nsg" {
  type    = bool
  default = true
}

variable "standalone_nsg_name" {
  type = string
}

variable "subnet_ids_attach_keyvault_sg" {
  type    = list(string)
  default = []
}

variable "nsg_ids_add_keyvault_rule" {
  type    = list(string)
  default = []
}

variable "enable_pe_inbound_from_asg" {
  type    = bool
  default = false
}

variable "pe_nsg_id" {
  type    = string
  default = null
}

variable "keyvault_clients_asg_name" {
  type    = string
  default = "keyvault-clients-asg"
}

variable "existing_keyvault_clients_asg_id" {
  type    = string
  default = null
}

variable "existing_keyvault_standalone_nsg_id" {
  type    = string
  default = null
}
