#--------------------------------------------------------------
# subnet-keyvault-sg — 분류: azurerm-only 예외 (docs/AVM_COVERAGE.md)
# keyvault-sg (시나리오 3): Key Vault 접근 허용 NSG 규칙
# NSG·ASG 전용 AVM이 호출 계약에 맞을 때까지 azurerm 유지 (terraform-iac _modules 에서 이전)
#--------------------------------------------------------------

resource "azurerm_network_security_group" "keyvault_sg" {
  count               = var.create_standalone_nsg && var.existing_keyvault_standalone_nsg_id == null ? 1 : 0
  name                = var.standalone_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "keyvault_outbound_standalone" {
  count                       = var.create_standalone_nsg && var.existing_keyvault_standalone_nsg_id == null ? 1 : 0
  name                        = "AllowKeyVaultOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureKeyVault"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.keyvault_sg[0].name
}

resource "azurerm_subnet_network_security_group_association" "keyvault_sg" {
  for_each                  = var.create_standalone_nsg ? toset(var.subnet_ids_attach_keyvault_sg) : toset([])
  subnet_id                 = each.value
  network_security_group_id = local.keyvault_standalone_nsg_id
}

resource "azurerm_network_security_rule" "keyvault_outbound_existing" {
  for_each                    = toset(var.nsg_ids_add_keyvault_rule)
  name                        = "AllowKeyVaultOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureKeyVault"
  resource_group_name         = split("/", each.value)[4]
  network_security_group_name = split("/", each.value)[8]
}

resource "azurerm_application_security_group" "keyvault_clients" {
  count               = var.enable_pe_inbound_from_asg && var.existing_keyvault_clients_asg_id == null ? 1 : 0
  name                = var.keyvault_clients_asg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  keyvault_standalone_nsg_id = var.create_standalone_nsg ? (
    var.existing_keyvault_standalone_nsg_id != null ? var.existing_keyvault_standalone_nsg_id : try(azurerm_network_security_group.keyvault_sg[0].id, null)
  ) : null
  keyvault_clients_asg_id = var.enable_pe_inbound_from_asg ? (
    var.existing_keyvault_clients_asg_id != null ? var.existing_keyvault_clients_asg_id : try(azurerm_application_security_group.keyvault_clients[0].id, null)
  ) : null
}

resource "azurerm_network_security_rule" "pe_inbound_from_keyvault_clients" {
  count                                 = var.enable_pe_inbound_from_asg && var.pe_nsg_id != null && local.keyvault_clients_asg_id != null ? 1 : 0
  name                                  = "AllowKeyVaultClientsInbound443"
  priority                              = 4095
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_range                = "443"
  source_application_security_group_ids = [local.keyvault_clients_asg_id]
  destination_address_prefix            = "*"
  resource_group_name                   = split("/", var.pe_nsg_id)[4]
  network_security_group_name           = split("/", var.pe_nsg_id)[8]
}
