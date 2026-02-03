#-------------------------------------------------------------------------------
# Virtual Machine 모듈 - NIC, OS Disk, VM
# 역할: Linux/Windows VM 1대 + NIC + (선택) 확장
#-------------------------------------------------------------------------------

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Linux VM (admin_password 사용 시 비밀번호 인증)
resource "azurerm_linux_virtual_machine" "main" {
  count = var.os_type == "linux" ? 1 : 0

  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password != "" ? var.admin_password : null
  disable_password_authentication = var.admin_password != "" ? false : true
  network_interface_ids           = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = var.admin_username
    # 비밀번호 인증만 쓸 때도 azurerm은 admin_ssh_key 1개 필요. 호출 측에서 admin_ssh_public_key 넘기거나, 임시 공개키 사용 권장
    public_key = var.admin_ssh_public_key != "" ? var.admin_ssh_public_key : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDummyPlaceholderForPasswordOnlyLogin"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  dynamic "identity" {
    for_each = var.enable_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
}

# Windows VM
resource "azurerm_windows_virtual_machine" "main" {
  count = var.os_type == "windows" ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  dynamic "identity" {
    for_each = var.enable_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
}

# VM 확장 (Linux)
resource "azurerm_virtual_machine_extension" "linux" {
  for_each = var.os_type == "linux" ? { for i, e in var.vm_extensions : i => e } : {}

  name                 = each.value.name
  virtual_machine_id   = azurerm_linux_virtual_machine.main[0].id
  publisher            = each.value.publisher
  type                 = each.value.type
  type_handler_version = each.value.type_handler_version
  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
  settings             = jsonencode(each.value.settings)
  protected_settings   = jsonencode(each.value.protected_settings)
}

# VM 확장 (Windows)
resource "azurerm_virtual_machine_extension" "windows" {
  for_each = var.os_type == "windows" ? { for i, e in var.vm_extensions : i => e } : {}

  name                 = each.value.name
  virtual_machine_id   = azurerm_windows_virtual_machine.main[0].id
  publisher            = each.value.publisher
  type                 = each.value.type
  type_handler_version = each.value.type_handler_version
  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
  settings             = jsonencode(each.value.settings)
  protected_settings   = jsonencode(each.value.protected_settings)
}
