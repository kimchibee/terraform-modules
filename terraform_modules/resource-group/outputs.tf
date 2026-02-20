#-------------------------------------------------------------------------------
# Resource Group 모듈 - 출력 (기존 호환: id, name, location)
# AVM 0.1.0 은 resource_id, name 만 출력. location 은 입력값 그대로 노출
#-------------------------------------------------------------------------------

output "id" {
  description = "Resource Group ID"
  value       = module.avm.resource_id
}

output "name" {
  description = "Resource Group 이름"
  value       = module.avm.name
}

output "location" {
  description = "Resource Group 위치"
  value       = var.location
}
