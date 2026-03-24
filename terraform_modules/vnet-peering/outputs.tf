#-------------------------------------------------------------------------------
# VNet Peering 모듈 - 출력
#-------------------------------------------------------------------------------

output "id" {
  description = "Peering 리소스 ID"
  value       = module.avm.resource_id
}

output "name" {
  description = "Peering 이름"
  value       = module.avm.name
}
