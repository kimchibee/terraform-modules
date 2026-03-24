#-------------------------------------------------------------------------------
# Application Security Group
# 단일 책임: Application Security Group 1개 생성
#-------------------------------------------------------------------------------

resource "azurerm_application_security_group" "this" {
  count = var.enabled ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
