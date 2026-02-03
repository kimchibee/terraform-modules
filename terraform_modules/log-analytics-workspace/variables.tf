#-------------------------------------------------------------------------------
# Log Analytics Workspace 모듈 - 입력 변수
#-------------------------------------------------------------------------------

variable "name" {
  description = "Log Analytics Workspace 이름 (4~63자, 영숫자·하이픈)"
  type        = string
}

variable "location" {
  description = "Azure 리전"
  type        = string
}

variable "resource_group_name" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "retention_in_days" {
  description = "데이터 보존 기간(일). 최소 30."
  type        = number
  default     = 30
}

variable "tags" {
  description = "태그"
  type        = map(string)
  default     = {}
}
