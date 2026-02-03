#-------------------------------------------------------------------------------
# VNet Peering 모듈 - 출력
#-------------------------------------------------------------------------------

output "id" {
  description = "Peering 리소스 ID"
  value       = azurerm_virtual_network_peering.main.id
}

output "name" {
  description = "Peering 이름"
  value       = azurerm_virtual_network_peering.main.name
}
