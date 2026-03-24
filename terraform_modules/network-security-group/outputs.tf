output "id" {
  value = try(azurerm_network_security_group.this[0].id, null)
}

output "name" {
  value = try(azurerm_network_security_group.this[0].name, null)
}
