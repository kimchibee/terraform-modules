#-------------------------------------------------------------------------------
# Virtual Machine 모듈 - 출력 (IaC compute 스택 호환)
#-------------------------------------------------------------------------------

output "id" {
  description = "VM 리소스 ID"
  value       = module.avm.resource_id
}

output "vm_id" {
  description = "VM 리소스 ID (compute 스택 호환)"
  value       = module.avm.resource_id
}

output "vm_name" {
  description = "VM 이름"
  value       = var.name
}

output "identity_principal_id" {
  description = "시스템 할당 Managed Identity Principal ID (enable_identity=true 일 때)"
  value       = var.enable_identity ? try(module.avm.system_assigned_mi_principal_id, null) : null
}

output "identity_tenant_id" {
  description = "Managed Identity Tenant ID (enable_identity=true 일 때)"
  value       = var.enable_identity ? try(module.avm.virtual_machine_azurerm.identity.tenant_id, null) : null
}

output "vm_private_ip" {
  description = "NIC Private IP"
  value       = try(module.avm.virtual_machine_azurerm.private_ip_address, null)
}

output "network_interface_id" {
  description = "NIC ID"
  value       = try(values(module.avm.network_interfaces)[0].id, null)
}
