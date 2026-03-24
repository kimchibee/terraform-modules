#--------------------------------------------------------------
# subnet-vm-access-sg — 분류: azurerm-only 예외 (docs/AVM_COVERAGE.md)
# vm-access-sg: ASG + 타겟 NSG 인바운드
#--------------------------------------------------------------

resource "azurerm_application_security_group" "vm_allowed_clients" {
  count               = var.enable_vm_access_sg && var.existing_vm_allowed_clients_asg_id == null ? 1 : 0
  name                = var.vm_allowed_clients_asg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  vm_allowed_clients_asg_id = var.enable_vm_access_sg ? (
    var.existing_vm_allowed_clients_asg_id != null ? var.existing_vm_allowed_clients_asg_id : try(azurerm_application_security_group.vm_allowed_clients[0].id, null)
  ) : null
  vm_access_rules = var.enable_vm_access_sg && local.vm_allowed_clients_asg_id != null ? [
    for pair in setproduct(var.target_nsg_ids, var.destination_ports) : {
      key    = "${pair[0]}_${pair[1]}"
      nsg_id = pair[0]
      port   = pair[1]
    }
  ] : []
}

resource "azurerm_network_security_rule" "vm_inbound_from_clients" {
  for_each                              = { for r in local.vm_access_rules : r.key => r }
  name                                  = "AllowVMClients-${each.value.port}"
  priority                              = 4090 + index(var.destination_ports, each.value.port)
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_range                = each.value.port
  source_application_security_group_ids = [local.vm_allowed_clients_asg_id]
  destination_address_prefix            = "*"
  resource_group_name                   = split("/", each.value.nsg_id)[4]
  network_security_group_name           = split("/", each.value.nsg_id)[8]
}
