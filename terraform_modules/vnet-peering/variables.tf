#-------------------------------------------------------------------------------
# VNet Peering 모듈 - 입력 변수
# 한 방향 Peering만 생성 (양방향 시 반대 방향은 별도 모듈 호출)
#-------------------------------------------------------------------------------

variable "name" {
  description = "Peering 이름 (로컬 VNet 쪽에 붙는 이름)"
  type        = string
}

variable "resource_group_name" {
  description = "로컬 VNet이 속한 리소스 그룹 이름"
  type        = string
}

variable "virtual_network_name" {
  description = "로컬 VNet 이름 (Peering을 붙일 VNet)"
  type        = string
}

variable "remote_virtual_network_id" {
  description = "원격 VNet 리소스 ID (연결 대상)"
  type        = string
}

variable "allow_virtual_network_access" {
  description = "로컬 VNet에서 원격 VNet 주소 공간 접근 허용"
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "다른 VNet에서 전달된 트래픽 허용"
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "원격 VNet의 Gateway를 이 VNet에서 트랜짓으로 사용 허용"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "원격 VNet의 Gateway 사용 (로컬에 Gateway 없을 때)"
  type        = bool
  default     = false
}
