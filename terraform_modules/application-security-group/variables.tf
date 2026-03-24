#-------------------------------------------------------------------------------
# Application Security Group - 입력 변수
#-------------------------------------------------------------------------------

variable "enabled" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
