#-------------------------------------------------------------------------------
# Resource Group 모듈 - 출력 (기존 호환: id, name, location)
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
