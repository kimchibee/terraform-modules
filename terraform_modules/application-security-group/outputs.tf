output "id" {
  value = try(module.avm[0].resource_id, null)
}

output "name" {
  value = try(module.avm[0].application_security_group.name, null)
}
