#-------------------------------------------------------------------------------
# Private Endpoint - 공식 AVM 모듈 래퍼
# 공식: Azure/avm-res-network-privateendpoint/azurerm (Terraform Registry)
#-------------------------------------------------------------------------------
locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-privateendpoint-0.2.0"

  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  subnet_resource_id              = var.subnet_id
  network_interface_name          = "nic-${var.name}"
  private_connection_resource_id  = var.target_resource_id
  subresource_names               = var.subresource_names
  tags                            = local.common_tags
  enable_telemetry                = false
  private_service_connection_name = coalesce(var.private_connection_name, "psc-${var.name}")
  private_dns_zone_resource_ids   = var.private_dns_zone_ids
  private_dns_zone_group_name     = "default"
}
