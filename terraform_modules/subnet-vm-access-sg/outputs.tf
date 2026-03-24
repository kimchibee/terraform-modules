output "vm_allowed_clients_asg_id" {
  description = "VM 접속 허용 클라이언트 ASG ID"
  value       = var.enable_vm_access_sg ? local.vm_allowed_clients_asg_id : null
}
