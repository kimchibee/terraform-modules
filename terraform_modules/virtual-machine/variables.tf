#-------------------------------------------------------------------------------
# Virtual Machine 모듈 - 입력 변수
#-------------------------------------------------------------------------------

variable "name" {
  description = "VM 이름"
  type        = string
}

variable "os_type" {
  description = "OS 타입: linux 또는 windows"
  type        = string
  default     = "linux"
}

variable "size" {
  description = "VM SKU (예: Standard_B2s)"
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

variable "subnet_id" {
  description = "NIC에 연결할 서브넷 ID"
  type        = string
}

variable "admin_username" {
  description = "관리자 사용자명"
  type        = string
}

variable "admin_password" {
  description = "관리자 비밀번호 (windows 시 필수, linux 시 비밀번호 인증용)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_ssh_public_key" {
  description = "Linux SSH 공개키 (비어 있으면 비밀번호 인증만 사용 시 placeholder 사용)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "태그"
  type        = map(string)
  default     = {}
}

variable "enable_identity" {
  description = "시스템 할당 Managed Identity 사용 여부"
  type        = bool
  default     = false
}

variable "vm_extensions" {
  description = "VM 확장 목록. 각 항목: name, publisher, type, type_handler_version, auto_upgrade_minor_version, settings, protected_settings"
  type = list(object({
    name                     = string
    publisher                = string
    type                     = string
    type_handler_version     = string
    auto_upgrade_minor_version = bool
    settings                 = optional(map(any), {})
    protected_settings       = optional(map(any), {})
  }))
  default = []
}
