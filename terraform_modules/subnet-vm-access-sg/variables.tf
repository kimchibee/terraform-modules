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

variable "enable_vm_access_sg" {
  type    = bool
  default = false
}

variable "vm_allowed_clients_asg_name" {
  type    = string
  default = "vm-allowed-clients-asg"
}

variable "existing_vm_allowed_clients_asg_id" {
  type    = string
  default = null
}

variable "target_nsg_ids" {
  type    = list(string)
  default = []
}

variable "destination_ports" {
  type    = list(string)
  default = ["22", "3389"]
}
