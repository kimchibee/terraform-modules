#-------------------------------------------------------------------------------
# VNet 모듈 - 출력
# 다른 모듈 또는 루트에서 참조할 값만 노출
#-------------------------------------------------------------------------------

output "vnet_id" {
  description = "생성된 Virtual Network ID"
  value       = module.avm.resource_id
}

output "vnet_name" {
  description = "Virtual Network 이름"
  value       = module.avm.name
}

output "vnet_address_space" {
  description = "VNet 주소 공간"
  value = try(
    module.avm.resource.output.properties.addressSpace.addressPrefixes,
    module.avm.resource.body.properties.addressSpace.addressPrefixes
  )
}

output "subnet_ids" {
  description = "서브넷 ID 맵 (서브넷 이름 → ID). 예: subnet_ids[\"GatewaySubnet\"]"
  value       = { for k, s in module.avm.subnets : k => s.resource_id }
}
