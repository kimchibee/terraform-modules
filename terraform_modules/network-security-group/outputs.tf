output "id" {
  value = try(module.avm[0].resource_id, null)
}

output "name" {
  value = try(module.avm[0].name, null)
}

output "security_rules" {
  value = try(module.avm[0].security_rules, null)
}
