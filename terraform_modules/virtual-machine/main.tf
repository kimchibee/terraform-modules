#-------------------------------------------------------------------------------
# Virtual Machine — AVM 래퍼
# 공식: Azure/avm-res-compute-virtualmachine/azurerm
#-------------------------------------------------------------------------------

locals {
  os_type_normalized = lower(var.os_type) == "windows" ? "Windows" : "Linux"

  source_image_reference = local.os_type_normalized == "Windows" ? {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
    } : {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  network_interfaces = {
    primary = {
      name = "${var.name}-nic"
      ip_configurations = {
        primary = {
          name                          = "internal"
          private_ip_subnet_resource_id = var.subnet_id
          private_ip_address_allocation = "Dynamic"
        }
      }
      is_primary = true
      tags       = var.tags
    }
  }

  extensions = {
    for idx, ext in var.vm_extensions : tostring(idx) => {
      name                       = ext.name
      publisher                  = ext.publisher
      type                       = ext.type
      type_handler_version       = ext.type_handler_version
      auto_upgrade_minor_version = ext.auto_upgrade_minor_version
      settings                   = length(keys(ext.settings)) > 0 ? jsonencode(ext.settings) : null
      protected_settings         = length(keys(ext.protected_settings)) > 0 ? jsonencode(ext.protected_settings) : null
    }
  }

  admin_ssh_keys = local.os_type_normalized == "Linux" && trimspace(var.admin_ssh_public_key) != "" ? [
    {
      username   = var.admin_username
      public_key = var.admin_ssh_public_key
    }
  ] : []
}

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-compute-virtualmachine-0.20.0"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zone                = var.zone

  os_type                = local.os_type_normalized
  sku_size               = var.size
  source_image_reference = local.source_image_reference
  network_interfaces     = local.network_interfaces
  extensions             = local.extensions

  admin_username = var.admin_username
  admin_password = trimspace(var.admin_password) != "" ? var.admin_password : null
  admin_ssh_keys = local.admin_ssh_keys

  managed_identities = {
    system_assigned            = var.enable_identity
    user_assigned_resource_ids = []
  }

  tags             = var.tags
  enable_telemetry = false
}
