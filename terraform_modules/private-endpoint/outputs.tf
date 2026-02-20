#-------------------------------------------------------------------------------
# Private Endpoint 모듈 - 출력 (AVM 래퍼)
#-------------------------------------------------------------------------------

output "id" {
  description = "Private Endpoint 리소스 ID"
  value       = module.avm.resource_id
}

output "name" {
  description = "Private Endpoint 이름"
  value       = module.avm.name
}

output "private_ip_address" {
  description = "Private Endpoint에 할당된 프라이빗 IP"
  value       = module.avm.resource.private_service_connection[0].private_ip_address
}
