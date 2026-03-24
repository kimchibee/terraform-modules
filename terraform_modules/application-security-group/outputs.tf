output "id" {
  value = try(azurerm_application_security_group.this[0].id, null)
}

output "name" {
  value = try(azurerm_application_security_group.this[0].name, null)
}
