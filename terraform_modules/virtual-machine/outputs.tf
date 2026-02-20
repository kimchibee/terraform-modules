#-------------------------------------------------------------------------------
# Virtual Machine 모듈 - 출력 (IaC compute 스택 호환)
#-------------------------------------------------------------------------------

output "id" {
  description = "VM 리소스 ID"
  value       = var.os_type == "linux" ? azurerm_linux_virtual_machine.main[0].id : azurerm_windows_virtual_machine.main[0].id
}

output "vm_id" {
  description = "VM 리소스 ID (compute 스택 호환)"
  value       = var.os_type == "linux" ? azurerm_linux_virtual_machine.main[0].id : azurerm_windows_virtual_machine.main[0].id
}

output "vm_name" {
  description = "VM 이름"
  value       = var.name
}

output "identity_principal_id" {
  description = "시스템 할당 Managed Identity Principal ID (enable_identity=true 일 때)"
  value       = var.enable_identity ? (var.os_type == "linux" ? azurerm_linux_virtual_machine.main[0].identity[0].principal_id : azurerm_windows_virtual_machine.main[0].identity[0].principal_id) : null
}

output "identity_tenant_id" {
  description = "Managed Identity Tenant ID (enable_identity=true 일 때)"
  value       = var.enable_identity ? (var.os_type == "linux" ? azurerm_linux_virtual_machine.main[0].identity[0].tenant_id : azurerm_windows_virtual_machine.main[0].identity[0].tenant_id) : null
}

output "vm_private_ip" {
  description = "NIC Private IP"
  value       = azurerm_network_interface.main.private_ip_address
}

output "network_interface_id" {
  description = "NIC ID"
  value       = azurerm_network_interface.main.id
}
