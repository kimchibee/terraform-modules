#-------------------------------------------------------------------------------
# Virtual Machine 모듈 - 출력
#-------------------------------------------------------------------------------

output "id" {
  description = "VM 리소스 ID"
  value       = var.os_type == "linux" ? azurerm_linux_virtual_machine.main[0].id : azurerm_windows_virtual_machine.main[0].id
}

output "identity_principal_id" {
  description = "시스템 할당 Managed Identity Principal ID (enable_identity=true 일 때)"
  value       = var.enable_identity ? (var.os_type == "linux" ? azurerm_linux_virtual_machine.main[0].identity[0].principal_id : azurerm_windows_virtual_machine.main[0].identity[0].principal_id) : null
}

output "vm_private_ip" {
  description = "NIC Private IP"
  value       = azurerm_network_interface.main.private_ip_address
}

output "network_interface_id" {
  description = "NIC ID"
  value       = azurerm_network_interface.main.id
}
